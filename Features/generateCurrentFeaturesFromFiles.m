function [X, Y, featureTables, featureNames] = generateCurrentFeaturesFromFiles(files, windowDuration, overlapPercent, emptyFlag)
%GENERATECURRENTFEATURESFROMFILES Extracts Phase Current features from signals in files
%
% Inputs:
%   files           - Files Metadata Table
%   windowDuration  - Duration of window in seconds (e.g., 1)
%   overlapPercent  - Overlap between windows in percent (e.g., 50, 75)
%
% Outputs:
%   X - Matrix of feature vectors (each row = 1 window)
%   Y - Cell array of class labels (fault labels)
%   featureTables - Table with feature metadata (if includeDebug is true)

X = [];
featureTables = table();  % For debug info
Y = {};

if nargin == 4
    if emptyFlag == true
        [~, featureTables] = extractCurrentFeaturesTable([0 0], 1);
        featureTables.NA4_A = 0;
        featureTables.NA4_B = 0;
        featureTables.NA4star_A = 0;
        featureTables.NA4star_B = 0;
        featureTables.DeltaRMS_A = 0;
        featureTables.DeltaRMS_B = 0;
        featureNames = featureTables.Properties.VariableNames;
        return
    end
end

% Compute variance of healthy residuals (for NA4*)
[M2_A, M2_B] = computeHealthyResidualVariance(files, windowDuration, overlapPercent);

% NA4, NA4* Storage
na4_A_all = [];
na4_B_all = [];
na4star_A_all = [];
na4star_B_all = [];

% DeltaRMS Storage


for i = 1:height(files)
    filePath = files.FilePath{i};
    faultLabel = files.Fault{i};
    Fs = files.Fs(i);

    % Ensemble residuals for the current file
    residualsA = [];
    residualsB = [];

    % Compute window and step sizes
    windowSize = Fs * windowDuration;
    overlapFraction = overlapPercent / 100;
    stepSize = round(windowSize * (1 - overlapFraction));

    [data, ~] = readCurrentSignal(filePath, 2, Fs);
    N = size(data, 1);

    windowsNum = floor((N - windowSize) / stepSize) + 1;
    for startIdx = 1:stepSize:(N - windowSize + 1)
        stopIdx = startIdx + windowSize - 1;
        window = data(startIdx:stopIdx, :);

        % Remove outliers
        window = filloutliers(window, "linear", "movmedian", 400);

        residualsA = [residualsA, detrend(window(:,1))];
        residualsB = [residualsB, detrend(window(:,2))];

        % Extract features
        [fArray, fTable] = extractCurrentFeaturesTable(window, Fs);

        % Add time and file metadata
        tStart = (startIdx - 1) / Fs;
        tEnd = (stopIdx - 1) / Fs;
        fTable.TimeInterval = string(sprintf('%.2f - %.2f s', tStart, tEnd));
        fTable.FileIndex = i;
        fTable.FaultLabel = string(faultLabel);

        % Reorder columns to place debug info first
        debugCols = ["TimeInterval", "FileIndex", "FaultLabel"];
        allCols = fTable.Properties.VariableNames;
        newColOrder = [debugCols, allCols(~ismember(allCols, debugCols))];
        fTable = fTable(:, newColOrder);

        % Store debug info
        featureTables = [featureTables; fTable];

        % Store features and label
        X = [X; fArray];
        Y{end+1,1} = faultLabel;
    end

    % Compute NA4 and NA4*
    na4_A = computeNA4(residualsA);
    na4_B = computeNA4(residualsB);
    na4star_A = computeNA4Star(residualsA, M2_A);
    na4star_B = computeNA4Star(residualsB, M2_B);

    % Store values for later appending
    na4_A_all = [na4_A_all; repmat(na4_A, windowsNum, 1)];
    na4_B_all = [na4_B_all; repmat(na4_B, windowsNum, 1)];
    na4star_A_all = [na4star_A_all; repmat(na4star_A, windowsNum, 1)];
    na4star_B_all = [na4star_B_all; repmat(na4star_B, windowsNum, 1)];

end
% Add NA4 and NA4* features
% Append NA4 and NA4* features to feature matrix
X = [X, na4_A_all, na4_B_all, na4star_A_all, na4star_B_all];

% Add to feature table
featureTables.NA4_A = na4_A_all;
featureTables.NA4_B = na4_B_all;
featureTables.NA4star_A = na4star_A_all;
featureTables.NA4star_B = na4star_B_all;

% Add DeltaRMS_A and DeltaRMS_B features
deltaRMS_A = zeros(height(featureTables), 1);
deltaRMS_B = zeros(height(featureTables), 1);

for fileIdx = unique(featureTables.FileIndex)'  % Loop over each file
    idx = featureTables.FileIndex == fileIdx;
    rmsA = featureTables.RMS_A(idx);
    rmsB = featureTables.RMS_B(idx);

    % Compute delta within the file
    deltaA = [0; diff(rmsA)];
    deltaB = [0; diff(rmsB)];

    % Assign back
    deltaRMS_A(idx) = deltaA;
    deltaRMS_B(idx) = deltaB;
end
X = [X, deltaRMS_A, deltaRMS_B];
featureTables.DeltaRMS_A = deltaRMS_A;
featureTables.DeltaRMS_B = deltaRMS_B;

% Pass Feature Names into return variable
featureNames = featureTables.Properties.VariableNames;
% Exclude Debug Variables
featureNames(1:3) = [];
end

function [M2_A, M2_B] = computeHealthyResidualVariance(files, windowDuration, overlapPercent)
% Computes variance of residual signals for healthy motor data
% Used for NA4* normalization
%
% Inputs:
%   files           - Table with file info and FaultLabel
%   windowDuration  - Duration of each analysis window (in seconds)
%   overlapPercent  - Overlap between windows (percent)
%
% Outputs:
%   M2_A, M2_B      - Variance of residuals (phases A and B)

healthyRS_A = [];
healthyRS_B = [];

for i = 1:height(files)
    % Only process healthy signals
    if strcmp(files.Fault{i}, 'frequency converter №2')
        Fs = files.Fs(i);
        filePath = files.FilePath{i};

        % Read and clean the signal
        [data, ~] = readCurrentSignal(filePath, 2, Fs);
        data = filloutliers(data, "linear", "movmedian", 400);

        % Compute window and step size
        windowSize = Fs * windowDuration;
        stepSize = round(windowSize * (1 - overlapPercent / 100));

        N = size(data,1);
        for startIdx = 1:stepSize:(N - windowSize + 1)
            stopIdx = startIdx + windowSize - 1;
            window = data(startIdx:stopIdx, :);

            % Compute residuals (detrend or bandstop)
            rsA = detrend(window(:,1));
            rsB = detrend(window(:,2));

            healthyRS_A = [healthyRS_A, rsA];
            healthyRS_B = [healthyRS_B, rsB];
        end
    end
end

% Compute variance across all residuals (flattened)
M2_A = var(healthyRS_A(:));
M2_B = var(healthyRS_B(:));
end

%   $$NA4 = \frac{N \sum_{i=1}^{N} (r_i - R)^4}
%   {\left\{ \frac{1}{M} \sum_{j=1}^{M} \left[ \sum_{i=1}^{N} (r_{ij} - R)^2 \right] \right\}^2}$$
%   $$NA4^* = \frac{N \sum_{i=1}^{N} (r_i - R)^4}
%   {\left\{ M_2 \right\}^2}
%   $$

function na4 = computeNA4(RS)
[N, M] = size(RS);
R = mean(RS(:));
numerator = N * sum((RS(:) - R).^4);

denSum = 0;
for j = 1:M
    rj = RS(:, j);
    denSum = denSum + sum((rj - R).^2);
end
denominator = (denSum / M)^2;
na4 = numerator / denominator;
end

function na4star = computeNA4Star(RS, M2)
% Compute NA4* from residual signal matrix RS (N x M), and healthy variance M2
N = size(RS, 1);
R = mean(RS(:));
numerator = N * sum((RS(:) - R).^4);
na4star = numerator / (M2^2);
end
