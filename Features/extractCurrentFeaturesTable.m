function [featureArray, featureTable] = extractCurrentFeaturesTable(data, Fs)
% Extracts features and returns both array and table

    % Get vector of features
    f = extractCurrentFeatures(data, Fs);

    % Define names (match extractCurrentFeatures)
    featureNames = {
        'Mean_A', 'Std_A', 'RMS_A', 'Skew_A', 'Kurt_A', 'PTP_A', 'Crest_A', ...
        'DominantFreq_A', 'SpecEnergy_A', 'Centroid_A', 'Entropy_A', ...
        'Mean_B', 'Std_B', 'RMS_B', 'Skew_B', 'Kurt_B', 'PTP_B', 'Crest_B', ...
        'DominantFreq_B', 'SpecEnergy_B', 'Centroid_B', 'Entropy_B', ...
        'Corr_AB', 'RMS_VectorMag'
    };

    % Return array (for ML) and table (for inspection)
    featureArray = f;
    featureTable = array2table(f, 'VariableNames', featureNames);
end