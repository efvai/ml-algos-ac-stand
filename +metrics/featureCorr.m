function score = featureCorr(featureTbl, featureName, labelOrder)
% featureCorr - Computes correlation between a feature and its ordinal progression.
%
% Inputs:
%   featureTbl  - Table containing features and label
%   featureName - String or char name of the feature column
%   labelOrder  - Cell array or string array specifying label order
%
% Output:
%   score       - Correlation coefficient (Pearson, in [-1, 1])

    % Validate inputs
    if ~istable(featureTbl)
        error('Input must be a table.');
    end

    % Extract feature and label
    featureVec = featureTbl.(featureName);
    labelVec = featureTbl.label;

    % Convert labelOrder and labelVec to string for consistency
    labelOrder = string(labelOrder);
    labelVec = string(labelVec);

    % Find rows where label is in labelOrder
    isValid = ismember(labelVec, labelOrder);

    % Keep only valid rows
    featureVec = featureVec(isValid);
    labelVec = labelVec(isValid);

    % Convert class labels to numeric based on given order
    labelNumeric = zeros(length(labelVec), 1);
    for i = 1:length(labelOrder)
        labelNumeric(labelVec == labelOrder(i)) = i;
    end

    % Sort feature based on label ordering
    [~, idx] = sort(labelNumeric);
    sortedFeature = featureVec(idx);

    % Create time vector (1, 2, 3, ..., N)
    timeVec = (1:length(sortedFeature))';

    % Compute Pearson correlation
    score = corr(sortedFeature, timeVec);
end