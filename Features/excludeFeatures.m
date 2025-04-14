function [XFiltered, retainedFeatureNames] = excludeFeatures(X, featureTables, featuresToRemove)
    debugCols = ["TimeInterval", "FileIndex", "FaultLabel"];
    allNames = string(featureTables.Properties.VariableNames);
    featureNames = allNames(~ismember(allNames, debugCols));
    retainedNames = featureNames(~ismember(featureNames, featuresToRemove));

    % Find indices of retained features
    keptIdx = ismember(featureNames, retainedNames);
    XFiltered = X(:, keptIdx);
    retainedFeatureNames = retainedNames;
end
