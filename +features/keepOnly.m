function [XKept, featureNamesKept] = keepOnly(X, featureNames, featuresToKeep)
%FEATURES.KEEPONLY Keeps only the specified features in the matrix
%
%   [XKept, featureNamesKept] = features.keepOnly(X, featureNames, featuresToKeep)
%
%   INPUTS:
%       X               - Feature matrix [nSamples x nFeatures]
%       featureNames    - Cell array of feature names (1 x nFeatures)
%       featuresToKeep  - Cell array of feature names to keep
%
%   OUTPUTS:
%       XKept           - Reduced feature matrix
%       featureNamesKept- Corresponding feature names
%
%   See also: features.exclude, features.registry

    % Validate inputs
    if isempty(X)
        error('Input feature matrix X is empty.');
    end
    if isempty(featureNames)
        error('Input featureNames is empty.');
    end
    if isempty(featuresToKeep)
        % Nothing to keep!
        XKept = [];
        featureNamesKept = {};
        return;
    end

    % Ensure cellstr types
    if isstring(featureNames)
        featureNames = cellstr(featureNames);
    end
    if isstring(featuresToKeep)
        featuresToKeep = cellstr(featuresToKeep);
    end

    % Logical mask for features to keep
    keepMask = ismember(featureNames, featuresToKeep);

    % Apply mask
    XKept = X(:, keepMask);
    featureNamesKept = featureNames(keepMask);
end