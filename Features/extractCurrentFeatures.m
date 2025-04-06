function features = extractCurrentFeatures(data, Fs)
%EXTRACTCURRENTFEATURES Extracts features from 2-phase current data
%   data: N x 2 matrix (columns = phase A, phase B)
%   Fs: sampling frequency (e.g., 51200)
%   Returns row vector of features [f1, f2, ..., fn]

    % Split the data
    phaseA = data(:,1);
    phaseB = data(:,2);

    % Time-domain features
    fA = extractSignalFeatures(phaseA, Fs);
    fB = extractSignalFeatures(phaseB, Fs);

    % Cross-phase features
    corrAB = corr(phaseA, phaseB);  % correlation coefficient
    rmsVector = sqrt(phaseA.^2 + phaseB.^2);
    avgRMSVec = mean(rmsVector);

    % Combine all features
    features = [fA, fB, corrAB, avgRMSVec];
end