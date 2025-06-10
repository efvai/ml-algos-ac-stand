function [XRetained, rowMask, featureNamesRetained] = removeOutOfScopeRows(X, featureNames, featureScopeNames, featureTbl)
%FEATURES.REMOVEOUTOFSCOPEROWS Remove rows where specified features are outliers based on within-class z-scores
%
%   [XRetained, rowMask, featureNamesRetained] = features.removeOutOfScopeRows(X, featureNames, featureScopeNames, featureTbl)
%
%   INPUTS:
%       X                 - Numeric feature matrix [nSamples × nFeatures]
%       featureNames      - Cell array of strings (1 × nFeatures), names of features
%       featureScopeNames - Cell array of strings, names of features to check for outliers
%       featureTbl        - Table with at least a `labels` property, mapping rows to class labels
%
%   OUTPUTS:
%       XRetained            - Subset of X with out-of-scope (outlier) rows removed
%       rowMask              - Logical mask [nSamples × 1] indicating retained rows
%       featureNamesRetained - Unchanged list of input featureNames

    % Validate inputs
    if isempty(X)
        error('Input X is empty.');
    end
    if isempty(featureNames)
        error('Input featureNames is empty.');
    end
    if isempty(featureScopeNames)
        % Nothing to check; retain all rows
        rowMask = true(size(X, 1), 1);
        XRetained = X;
        featureNamesRetained = featureNames;
        return;
    end

    % Ensure inputs are cellstring
    if isstring(featureNames), featureNames = cellstr(featureNames); end
    if isstring(featureScopeNames), featureScopeNames = cellstr(featureScopeNames); end

    % Get feature index mapping
    [found, featureIdx] = ismember(featureScopeNames, featureNames);
    if any(~found)
        missing = featureScopeNames(~found);
        error('Missing features in featureNames: %s', strjoin(missing, ', '));
    end

    % Get class labels
    labels = featureTbl.label;
    if height(featureTbl) ~= size(X, 1)
        error('featureTbl and X must have the same number of rows.');
    end

    uniqueLabels = unique(labels);
    nSamples = size(X, 1);
    isOutlier = false(nSamples, 1);  % initialize outlier mask

    outlierThreshold = 5;

    % Check each class separately
    for i = 1:numel(uniqueLabels)
        label = uniqueLabels(i);
        classMask = labels == label;
        classData = X(classMask, featureIdx);

        % Compute z-scores within class (omit NaNs)
        mu = mean(classData, 1, 'omitnan');
        sigma = std(classData, 0, 1, 'omitnan');    
        classZ = abs((classData - mu) ./ sigma);  % [nClassSamples x nScopeFeatures]

        % Any feature z-score > threshold is considered an outlier
        outlierInClass = any(classZ > outlierThreshold, 2);

        % Update the global outlier mask
        isOutlier(find(classMask)) = outlierInClass;
    end

    % Create mask for retained rows
    rowMask = ~isOutlier;

    % Apply mask
    XRetained = X(rowMask, :);
    featureNamesRetained = featureNames;
end