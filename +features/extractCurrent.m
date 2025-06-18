function featuresVec = extractCurrent(data, Fs)
% Extract features from a 2-channel current signal.
%
%   Includes: statistical, spectral, harmonic, and envelope features.
%   Automatically determines main_freq and computes BPFO-based features.

    if isempty(data) || size(data, 2) ~= 2
        warning("extractCurrent: Input must be Nx2 matrix (2-phase signal).");
        featuresVec = nan(1, 36);
        return;
    end

    % Bearing parameters (Elprom Troyan 6204 bearing)
    N_balls = 8;
    d_b = 7.94;      % mm
    D_p = 33.5;      % mm
    alpha = 0;       % deg; contact angle

    % --- Split Phases ---
    phaseA = data(:, 1);
    phaseB = data(:, 2);

    % Get basic features and FFT data
    [fA, freqVecA, FFTVecA] = features.extractBasic(phaseA, Fs);
    [fB, freqVecB, FFTVecB] = features.extractBasic(phaseB, Fs);

    % --- Dominant Frequency (main_freq) ---
    main_freqA = fA(8);  % Dominant freq from feature vector
    main_freqB = fB(8);

    % --- Compute BPFO per phase ---
    bpfo_factor = (N_balls / 2) * (1 - (d_b / D_p) * cosd(alpha)); % dimensionless
    BPFO_A = main_freqA * bpfo_factor;
    BPFO_B = main_freqB * bpfo_factor;

    % --- Reorder Basic Time+Spectral Features ---
    reorderedfAfB = [
        fA(1), fB(1),    ... % Mean
        fA(2), fB(2),    ... % Std
        fA(3), fB(3),    ... % RMS
        fA(4), fB(4),    ... % Skew
        fA(5), fB(5),    ... % Kurt
        fA(6), fB(6),    ... % PTP
        fA(7), fB(7),    ... % Crest Factor
        fA(8), fB(8),    ... % Dominant Freq
        fA(9), fB(9),    ... % Spectral Energy
        fA(10), fB(10),  ... % Spectral Centroid
        fA(11), fB(11)   ... % Spectral Entropy
    ];

    % --- Cross-phase features ---
    corrAB = corr(phaseA, phaseB);  % Pearson correlation
    vectorRMS = sqrt(phaseA.^2 + phaseB.^2);
    avgVectorRMS = mean(vectorRMS);

    % --- Spectral Features for Each Phase ---
    max_harm = 5;
    N = length(phaseA);

    % High-Frequency Energy (2–5 kHz)
    hfA = sum(FFTVecA(freqVecA >= 2000 & freqVecA <= 5000).^2);
    hfB = sum(FFTVecB(freqVecB >= 2000 & freqVecB <= 5000).^2);

    % Harmonic Analysis
    thdA = computeTHD(FFTVecA, main_freqA, Fs, N, max_harm);
    thdB = computeTHD(FFTVecB, main_freqB, Fs, N, max_harm);

    % Sidebands around ±BPFO
    sbA = extractSidebands(FFTVecA, freqVecA, main_freqA, BPFO_A, Fs, N);
    sbB = extractSidebands(FFTVecB, freqVecB, main_freqB, BPFO_B, Fs, N);

    % Signal Envelope (Hilbert-based)
    envA = abs(hilbert(phaseA));
    envB = abs(hilbert(phaseB));
    envFeatures = [mean(envA), std(envA), mean(envB), std(envB)];

    % --- Assemble Final Feature Vector ---
    featuresVec = [
        reorderedfAfB,       ... % 22
        corrAB,              ... % 1
        avgVectorRMS,        ... % 1
        hfA, hfB,            ... % 2
        thdA, thdB,          ... % 2
        sbA, sbB,            ... % 4 (2 amps * 2 ch)
        envFeatures          ... % 4 (mean/std * 2 ch)
    ];
end

function thdVal = computeTHD(FFT, mainFreq, Fs, N, maxHarm)
    freqBin = round(mainFreq * N / Fs) + 1;
    P2 = abs(FFT);
    
    harmonics = zeros(1, maxHarm);
    for k = 1:maxHarm
        idx = k * freqBin;
        if idx <= length(P2)
            harmonics(k) = P2(idx);
        end
    end

    fundamental = harmonics(1);
    if fundamental == 0
        thdVal = NaN;
    else
        thdVal = norm(harmonics(2:end)) / fundamental * 100;
    end
end

function sidebandVals = extractSidebands(P2, freqVec, mainFreq, BPFO, Fs, N)
    sidebandFreqs = [mainFreq - BPFO, mainFreq + BPFO];
    sidebandVals = zeros(1, 2);
    
    for i = 1:2
        f_target = sidebandFreqs(i);
        idx = round(f_target * N / Fs) + 1;
        if idx > 0 && idx <= length(P2)
            sidebandVals(i) = abs(P2(idx));
        end
    end
end