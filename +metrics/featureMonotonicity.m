function score = featureMonotonicity(featureTbl, featureName, labelOrder)
% featureMonotonicity - Computes signed monotonicity score for a feature
% with respect to an ordinal label.
%
% Inputs:
%   featureTbl  - Table containing features and label
%   featureName - String or char name of the feature column
%   labelOrder  - Cell array or string array specifying label order
%
% Output:
%   score       - Monotonicity score in [-1, 1]

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

    % Compute signed monotonicity (assuming metrics.monotonicity exists)
    score = metrics.monotonicity(sortedFeature);
end