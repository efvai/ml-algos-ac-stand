function featuresVec = extractVibration(data, Fs)
%FEATURES.EXTRACTVIBRATION Extract features from 4-channel vibration signal.
%
%   FEATURES = extractVibration(DATA, FS) returns a 1xN vector of features 
%   extracted from a 4-channel vibration signal.
%
%   Input:
%       data - Nx4 matrix (4 channels of vibration)
%       Fs   - Sampling frequency in Hz
%
%   Output:
%       featuresVec - 1xN row vector of features (N = 44 if 11 per channel)

    if isempty(data) || size(data, 2) ~= 4
        warning("extractVibration: Input must be Nx4 matrix (4-channel vibration signal).");
        featuresVec = nan(1, 44);  % 11 features × 4 channels
        return;
    end

    % --- Extract features for each channel ---
    f1 = features.extractBasic(data(:,1), Fs);
    f2 = features.extractBasic(data(:,2), Fs);
    f3 = features.extractBasic(data(:,3), Fs);
    f4 = features.extractBasic(data(:,4), Fs);

    % --- Reorder and combine features ---
    featuresVec = [
        f1(1), f2(1), f3(1), f4(1), ...   % Mean
        f1(2), f2(2), f3(2), f4(2), ...   % Std
        f1(3), f2(3), f3(3), f4(3), ...   % RMS
        f1(4), f2(4), f3(4), f4(4), ...   % Skew
        f1(5), f2(5), f3(5), f4(5), ...   % Kurt
        f1(6), f2(6), f3(6), f4(6), ...   % PTP
        f1(7), f2(7), f3(7), f4(7), ...   % Crest
        f1(8), f2(8), f3(8), f4(8), ...   % DominantFreq
        f1(9), f2(9), f3(9), f4(9), ...   % Spectral Energy
        f1(10), f2(10), f3(10), f4(10),...% Centroid
        f1(11), f2(11), f3(11), f4(11)    % Entropy
    ];

    % Optional: Feature names for reference
    featureNames = {};
    labels = {'Ch1', 'Ch2', 'Ch3', 'Ch4'};
    baseNames = {'Mean','Std','RMS','Skew','Kurt','PTP','Crest', ...
                 'DominantFreq','SpecEnergy','Centroid','Entropy'};

    for i = 1:numel(baseNames)
        for ch = 1:4
            featureNames{end+1} = [baseNames{i}, '_', labels{ch}]; %#ok<AGROW>
        end
    end
end