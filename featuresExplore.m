clear;

% Load dataset
datasetName = "dataset5";
files = getDataset(collectMetadata('DataSet/Faulty bearing'), datasetName);

% Get Phase Current Features
[X, Y, featureTables] = getCachedFeatures(files, datasetName, 1, 50);
clear datasetName

% Features Correlation Check
featureCorrMatrix = corr(X);
% Get Features Names
[~, ~, ~, featureNames] = generateCurrentFeaturesFromFiles(files, 1, 50, true);
figure;
heatmap(featureNames, ...
    featureNames, featureCorrMatrix);
title('Feature Correlation Matrix');