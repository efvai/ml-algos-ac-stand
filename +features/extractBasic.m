function features = extractBasic(signal, Fs)
%FEATURES.EXTRACTBASIC Extracts time and frequency domain features from a 1D signal.
%
%   FEATURES = extractBasic(SIGNAL, FS) returns a 1xN vector of features 
%   extracted from the input SIGNAL using sampling frequency FS.
%
%   Input:
%       signal - 1D array (vector), e.g., a single current or vibration channel
%       Fs     - Sampling frequency in Hz
%
%   Output:
%       features - 1xN feature vector
%
%   Extracted Features:
%     1) mean
%     2) std (standard deviation)
%     3) RMS (root mean square)
%     4) skewness
%     5) kurtosis
%     6) peak-to-peak
%     7) crest factor
%     8) dominant frequency
%     9) spectral energy
%    10) spectral centroid
%    11) spectral entropy

    if isempty(signal)
        warning("extractBasic: Empty signal provided.");
        features = nan(1, 11);  % Return NaNs if input is empty
        return;
    end

    % --- Time-Domain Features ---
    meanVal    = mean(signal);
    stdVal     = std(signal);
    rmsVal     = rms(signal);
    skewVal    = skewness(signal);
    kurtVal    = kurtosis(signal);
    ptpVal     = peak2peak(signal);
    
    % Avoid division by zero in crest factor
    crestFactor = max(abs(signal)) / max(rmsVal, eps);

    % --- Frequency-Domain Features ---
    Y = fft(signal);
    N = length(signal);
    P2 = abs(Y/N);
    P1 = P2(1:N/2+1);
    P1(2:end-1) = 2*P1(2:end-1); 
    fVec = Fs * (0:(N/2)) / N;

    % Dominant frequency
    [~, idx] = max(P1);
    dominantFreq = fVec(idx);

    % Spectral energy
    spectralEnergy = sum(P1 .^ 2);

    % Spectral centroid
    spectralCentroid = sum(fVec .* P1') / (sum(P1) + eps);

    % Spectral entropy
    Pnorm = P1 / (sum(P1) + eps);
    spectralEntropy = -sum(Pnorm .* log2(Pnorm + eps));

    % --- Combine into feature vector ---
    features = [
        meanVal, stdVal, rmsVal, skewVal, kurtVal, ptpVal, ...
        crestFactor, dominantFreq, spectralEnergy, spectralCentroid, spectralEntropy
    ];
end