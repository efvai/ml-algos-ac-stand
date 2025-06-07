function groupCV = makeGroupedCV(featureTbl, K)
% makeGroupedCV - Create K-fold grouped by Experiment + Fault + Config
%
% Inputs:
%   featureTbl - table with features and metaCurrent/metaVibro
%   K          - number of folds
%
% Output:
%   groupCV    - struct with .folds{k}.trainIdx and .testIdx

    if nargin < 2
        K = 5;
    end

    n = height(featureTbl);
    groupKeys = strings(n, 1);

    for i = 1:n
        meta = [];

        % Check if metaCurrent exists and is not empty
        if ismember('metaCurrent', featureTbl.Properties.VariableNames) && ...
           ~isempty(featureTbl.metaCurrent{1,1}) && ...
           ~isempty(featureTbl.metaCurrent(i, :).FilePath)  % using dot + (i)
            meta = featureTbl.metaCurrent(i, :);
        elseif ismember('metaVibro', featureTbl.Properties.VariableNames) && ...
               ~isempty(featureTbl.metaVibro{1,1}) && ...
               ~isempty(featureTbl.metaVibro(i, :).FilePath)
            meta = featureTbl.metaVibro(i, :);
        end

        % Fallback for missing metadata
        if isempty(meta) || ~ismember('Experiment', meta.Properties.VariableNames) ...
                || ~ismember('Fault', meta.Properties.VariableNames) ...
                || ~ismember('Config', meta.Properties.VariableNames)
            warning("Row %d has incomplete meta info. Using fallback key.", i);
            groupKeys(i) = "Unknown_" + i;
        else
            groupKeys(i) = string(meta.Experiment) + "_" + string(meta.Fault) + "_" + string(meta.Config);
        end
    end

    % Unique group identifiers
    [uniqueGroups, ~, groupIndices] = unique(groupKeys);
    numGroups = numel(uniqueGroups);

    % Create K-fold partition on unique group IDs
    groupCVPartition = cvpartition(numGroups, 'KFold', K);

    % Build train/test indices
    groupCV.folds = cell(K, 1);
    for k = 1:K
        trainGroupIdx = training(groupCVPartition, k);
        trainGroups = uniqueGroups(trainGroupIdx);

        isTrain = ismember(groupKeys, trainGroups);
        isTest = ~isTrain;

        groupCV.folds{k}.trainIdx = isTrain;
        groupCV.folds{k}.testIdx = isTest;
    end

    % Output metadata
    groupCV.K = K;
    groupCV.groupCVPartition = groupCVPartition;
    groupCV.uniqueGroups = uniqueGroups;
    groupCV.groupKeys = groupKeys;
end