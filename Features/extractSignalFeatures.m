function f = extractSignalFeatures(signal, Fs)
% Extracts features from a single signal (1D array)

    % Time-domain
    meanVal = mean(signal);
    stdVal = std(signal);
    rmsVal = rms(signal);
    skewVal = skewness(signal);
    kurtVal = kurtosis(signal);
    ptpVal = peak2peak(signal);
    crestFactor = max(abs(signal)) / rmsVal;

    % Frequency-domain
    N = length(signal);
    Y = fft(signal);
    P2 = abs(Y/N);
    P1 = P2(1:floor(N/2)+1);
    fVec = Fs*(0:(N/2))/N;

    % Dominant frequency
    [~, idx] = max(P1);
    dominantFreq = fVec(idx);

    % Fix
    if (mod(dominantFreq, 2) == 1)
        dominantFreq = dominantFreq - 1;
    end

    % Spectral energy
    spectralEnergy = sum(P1.^2);

    % Spectral centroid
    spectralCentroid = sum(fVec .* P1') / sum(P1 + eps);

    % Spectral entropy
    Pnorm = P1 / sum(P1 + eps);
    spectralEntropy = -sum(Pnorm .* log2(Pnorm + eps));

    % Combine
    f = [meanVal, stdVal, rmsVal, skewVal, kurtVal, ptpVal, ...
         crestFactor, dominantFreq, spectralEnergy, spectralCentroid, spectralEntropy];
end