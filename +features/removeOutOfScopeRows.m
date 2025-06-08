function [XRetained, rowMask, featureNamesRetained] = removeOutOfScopeRows(X, featureNames, featureScopeNames)
%FEATURES.REMOVEOUTOFSCOPEROWS Removes rows where specified features are out of scope
%
%   [XRetained, rowMask, featureNamesRetained] = features.removeOutOfScopeRows(X, featureNames, featureScopeNames)
%
%   INPUTS:
%       X                 - Numeric feature matrix [nSamples × nFeatures]
%       featureNames      - Cell array of strings, all feature names (1 × nFeatures)
%       featureScopeNames - Cell array of feature names to check for anomalies
%
%   OUTPUTS:
%       XRetained            - Matrix with out-of-scope rows removed
%       rowMask              - Logical [nSamples × 1] mask for kept rows
%       featureNamesRetained - Names of features (same as input list, not changed here)
%
%   NOTE:
%       Out-of-scope rows are those for which any selected feature has a z-score > 3
%
%   See also: features.exclude

    % Validate inputs
    if isempty(X)
        error('Input X is empty.');
    end
    if isempty(featureNames)
        error('Input featureNames is empty.');
    end
    if isempty(featureScopeNames)
        % Nothing to check; keep all rows
        rowMask = true(size(X, 1), 1);
        XRetained = X;
        featureNamesRetained = featureNames;
        return;
    end

    % Ensure inputs are cellstrings
    if isstring(featureNames), featureNames = cellstr(featureNames); end
    if isstring(featureScopeNames), featureScopeNames = cellstr(featureScopeNames); end

    % Map featureScopeNames ⟶ column indices
    [found, featureIdx] = ismember(featureScopeNames, featureNames);
    if any(~found)
        missingFeatures = featureScopeNames(~found);
        error('The following features are not found in featureNames: %s', strjoin(missingFeatures, ', '));
    end

    % Extract data for selected features
    selectedData = X(:, featureIdx);

    % Compute z-scores
    mu = mean(selectedData, 1, 'omitnan');
    sigma = std(selectedData, 0, 1, 'omitnan');
    zScores = abs((selectedData - mu) ./ sigma);

    % Identify out-of-scope rows
    outlierThreshold = 3;
    isOutlier = any(zScores > outlierThreshold, 2);

    % Rows to retain
    rowMask = ~isOutlier;

    % Apply mask
    XRetained = X(rowMask, :);
    featureNamesRetained = featureNames;  % No change to feature set
end