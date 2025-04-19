function [XRetained, FeatureNamesRetained] = exclude(X, featureNames, featuresToRemove)
%FEATURES.EXCLUDE Removes specified features from feature matrix and names
%
%   [XRetained, FeatureNamesRetained] = features.exclude(X, featureNames, featuresToRemove)
%
%   INPUTS:
%       X                - Feature matrix [nSamples x nFeatures]
%       featureNames     - Cell array of strings or chars, names of features (1 x nFeatures)
%       featuresToRemove - Cell array of strings or chars with names to remove
%
%   OUTPUTS:
%       XRetained           - Feature matrix with specified features removed
%       FeatureNamesRetained- Corresponding feature names
%
%   EXAMPLE:
%       X = rand(5, 4);
%       names = {'Mean', 'Std', 'RMS', 'Kurt'};
%       remove = {'Std', 'Kurt'};
%       [XNew, namesNew] = features.exclude(X, names, remove);
%
%   See also: array2table, features.registry

    % Validate inputs
    if isempty(X)
        error('Input feature matrix X is empty.');
    end
    if isempty(featureNames)
        error('Input featureNames is empty.');
    end
    if isempty(featuresToRemove)
        % Nothing to remove
        XRetained = X;
        FeatureNamesRetained = featureNames;
        return;
    end

    % Ensure featureNames is a cellstr
    if isstring(featureNames)
        featureNames = cellstr(featureNames);
    end
    if isstring(featuresToRemove)
        featuresToRemove = cellstr(featuresToRemove);
    end

    % Logical mask for features to keep
    keepMask = ~ismember(featureNames, featuresToRemove);

    % Apply mask
    XRetained = X(:, keepMask);
    FeatureNamesRetained = featureNames(keepMask);

end
