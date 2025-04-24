function [score, rs, trend] = featureRobustness(featureTbl, featureName, labelOrder)
% featureRobustness - Computes exponential robustness score and returns residual and trend signals.
%
% Output:
%   score       - Robustness score (scalar, with exponent)
%   rs          - Residual Signal (detrended)
%   trend       - Trend Signal

    % Validate inputs
    if ~istable(featureTbl)
        error('Input must be a table.');
    end

    % Extract feature and label
    featureVec = featureTbl.(featureName);
    labelVec = featureTbl.label;

    % Convert to string for consistency
    labelOrder = string(labelOrder);
    labelVec = string(labelVec);

    % Filter for valid labels
    isValid = ismember(labelVec, labelOrder);
    featureVec = featureVec(isValid);
    labelVec = labelVec(isValid);

    % Convert class labels to numeric based on given order
    labelNumeric = zeros(length(labelVec), 1);
    for i = 1:length(labelOrder)
        labelNumeric(labelVec == labelOrder(i)) = i;
    end

    % Sort featureVec by label order
    [~, idx] = sort(labelNumeric);
    sortedFeature = featureVec(idx);

    % Calculate trend and residual
    rs = detrend(sortedFeature, 0); 
    trend = sortedFeature - rs;

    % Exponential robustness score: avoid division by zero
    normed = rs ./ (abs(sortedFeature) + eps); % add eps to denom to avoid zero div
    score = sum(exp(-abs(normed))) / length(normed);
end