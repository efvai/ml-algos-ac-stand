function featuresVec = extractCurrent(data, Fs)
%FEATURES.EXTRACTCURRENT Extracts features from 2-phase current signal.
%
%   FEATURES = extractCurrent(DATA, FS) returns a 1xN vector of features 
%   extracted from a 2-phase current signal.
%
%   Input:
%       data - Nx2 matrix (column 1 = Phase A, column 2 = Phase B)
%       Fs   - Sampling frequency in Hz
%
%   Output:
%       featuresVec - 1xN row vector of features
%
%   Features include:
%       - Time & freq features from Phase A (11)
%       - Time & freq features from Phase B (11)
%       - Cross-correlation (1)
%       - RMS of vector magnitude (1)

    if isempty(data) || size(data, 2) ~= 2
        warning("extractCurrent: Input must be Nx2 matrix (2-phase signal).");
        featuresVec = nan(1, 24);  % Expected feature count
        return;
    end

    % --- Split Phases ---
    phaseA = data(:, 1);
    phaseB = data(:, 2);

    % --- Individual Phase Features ---
    fA = features.extractBasic(phaseA, Fs);
    fB = features.extractBasic(phaseB, Fs);

    % Reorder features by type
    reorderedfAfB = [
        fA(1), fB(1), ...   % Mean
        fA(2), fB(2), ...   % Std
        fA(3), fB(3), ...   % RMS
        fA(4), fB(4), ...   % Skew
        fA(5), fB(5), ...   % Kurt
        fA(6), fB(6), ...   % PTP
        fA(7), fB(7), ...   % Crest
        fA(8), fB(8), ...   % DominantFreq
        fA(9), fB(9), ...   % Spectral Energy
        fA(10), fB(10), ... % Centroid
        fA(11), fB(11) ...  % Entropy
    ];

    % --- Cross-Phase Features ---
    corrAB = corr(phaseA, phaseB);  % Pearson correlation
    vectorRMS = sqrt(phaseA.^2 + phaseB.^2);
    avgVectorRMS = mean(vectorRMS);

    % --- Combine All ---
    featuresVec = [reorderedfAfB, corrAB, avgVectorRMS];
end