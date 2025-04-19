function [trainIdx, testIdx, trainFiles, testFiles] = equalFileSplit(fileIndex, labels, testRatio)
%STRATIFIEDFILESPLIT Performs stratified split by file with class balance.
%
%   [trainIdx, testIdx, trainFiles, testFiles] = stratifiedFileSplit(fileIndex, labels, testRatio)
%   splits the data such that all entries from the same file (grouped by
%   fileIndex) go to either train or test, and the test set has approximately
%   equal class distribution.
%
%   Inputs:
%       fileIndex - Vector of file identifiers (e.g., numeric, string, or cellstr)
%       labels    - Categorical vector of class labels (same length as fileIndex)
%       testRatio - Fraction of files to assign to the test set (e.g., 0.2)
%
%   Outputs:
%       trainIdx   - Logical index vector for training samples
%       testIdx    - Logical index vector for test samples
%       trainFiles - List of files used for training
%       testFiles  - List of files used for testing

    arguments
        fileIndex
        labels (1,:) categorical
        testRatio (1,1) double {mustBeGreaterThanOrEqual(testRatio,0), mustBeLessThanOrEqual(testRatio,1)}
    end

    % Step 1: Get unique files and their corresponding label
    [uniqueFiles, ia] = unique(fileIndex, 'stable');
    fileLabels = labels(ia);  % One label per file

    % Step 2: Stratified split by file labels
    testFiles = [];
    trainFiles = [];
    classNames = categories(labels);

    rng(1); % For reproducibility

    for i = 1:numel(classNames)
        thisClass = classNames{i};
        idx = fileLabels == thisClass;
        filesInClass = uniqueFiles(idx);

        % Shuffle files
        filesInClass = filesInClass(randperm(numel(filesInClass)));

        % Compute number of test files for this class
        nTest = round(testRatio * numel(filesInClass));

        % Assign to test and train
        testFiles = [testFiles; filesInClass(1:nTest)];
        trainFiles = [trainFiles; filesInClass(nTest+1:end)];
    end

    % Step 3: Create logical indices for the full dataset
    trainIdx = ismember(fileIndex, trainFiles);
    testIdx  = ismember(fileIndex, testFiles);
end
