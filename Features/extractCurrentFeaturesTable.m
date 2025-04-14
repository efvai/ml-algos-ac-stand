function [featureArray, featureTable] = extractCurrentFeaturesTable(data, Fs)
% Extracts features and returns both array and table

    % Get vector of features
    f = extractCurrentFeatures(data, Fs);

    % Extract individual feature vectors
    fA = f(1:11);
    fB = f(12:22);
    corrAB = f(23);
    rmsVec = f(24);

    % Reorder features by type
    reorderedFeatures = [
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
    
    % Flatten into row vector and append cross features
    featureArray = [reorderedFeatures, corrAB, rmsVec];

    % Reordered feature names
    featureNames = {
        'Mean_A', 'Mean_B', ...
        'Std_A', 'Std_B', ...
        'RMS_A', 'RMS_B', ...
        'Skew_A', 'Skew_B', ...
        'Kurt_A', 'Kurt_B', ...
        'PTP_A', 'PTP_B', ...
        'Crest_A', 'Crest_B', ...
        'DominantFreq_A', 'DominantFreq_B', ...
        'SpecEnergy_A', 'SpecEnergy_B', ...
        'Centroid_A', 'Centroid_B', ...
        'Entropy_A', 'Entropy_B', ...
        'Corr_AB', 'RMS_VectorMag'
    };

    % Create table
    featureTable = array2table(featureArray, 'VariableNames', featureNames);
end