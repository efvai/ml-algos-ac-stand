function groupCV = makeGroupedCV(featureTbl, K)
% makeGroupedCV - Create K-fold cross-validation by file
%
% Inputs:
%   featureTbl - table containing features and meta info
%   K          - number of folds
%
% Output:
%   groupCV    - structure containing:
%                  .folds (Kx1 cell) - each cell has train/test logical indices

    if nargin < 2
        K = 5;  % default value
    end

    % Extract string file paths from meta
    filePaths = cellfun(@(x) string(x), featureTbl.meta.FilePath);

    % Get unique file identifiers and group indices
    [uniqueFiles, ~, fileGroupIndices] = unique(filePaths);
    numFiles = numel(uniqueFiles);

    % Create cvpartition on files
    fileCV = cvpartition(numFiles, 'KFold', K);

    % Build logical train/test indices per window
    groupCV.folds = cell(K, 1);
    for k = 1:K
        trainFileIdx = training(fileCV, k);
        trainFiles = uniqueFiles(trainFileIdx);
        isTrain = ismember(filePaths, trainFiles);
        isTest = ~isTrain;

        groupCV.folds{k}.trainIdx = isTrain;
        groupCV.folds{k}.testIdx = isTest;
    end

    groupCV.K = K;
    groupCV.fileCV = fileCV;
    groupCV.uniqueFiles = uniqueFiles;
end