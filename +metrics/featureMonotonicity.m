function score = featureMonotonicity(featureTbl, featureName, labelOrder)
% featureMonotonicity - Computes monotonicity score or mean difference for a feature
% with respect to an ordinal label.
%
% Inputs:
%   featureTbl  - Table containing features and label
%   featureName - String or char name of the feature column
%   labelOrder  - Cell array or string array specifying label order
%
% Output:
%   score       - Monotonicity score in [-1, 1] (for >2 classes)
%                 or mean difference (for 2 classes)

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

    % If only two classes, return mean difference
    if numel(labelOrder) == 2
        class1 = featureVec(labelVec == labelOrder(1));
        class2 = featureVec(labelVec == labelOrder(2));
        mu1 = mean(class1);
        mu2 = mean(class2);
        s1 = std(class1);
        s2 = std(class2);
        n1 = numel(class1);
        n2 = numel(class2);
        pooledStd = sqrt(((n1-1)*s1^2 + (n2-1)*s2^2) / (n1 + n2 - 2));
        if pooledStd == 0
            score = NaN;
        else
            score = abs(mu1 - mu2) / pooledStd;
        end
        return;
    end

    % For 3+ classes, compute monotonicity
    % Convert class labels to numeric based on given order
    labelNumeric = zeros(length(labelVec), 1);
    for i = 1:length(labelOrder)
        labelNumeric(labelVec == labelOrder(i)) = i;
    end

    % Sort feature based on label ordering
    [~, idx] = sort(labelNumeric);
    sortedFeature = featureVec(idx);

    % Compute signed monotonicity: Spearman correlation with class order
    n = numel(sortedFeature);
    if n < 2
        score = NaN;
        return;
    end
    classOrder = (1:n)';
    score = corr(classOrder, sortedFeature, 'Type', 'Spearman');
end