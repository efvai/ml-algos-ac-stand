function rfMetrics = rfMetrics(X, Y, featureNames, cv)
    rng(1);
    rfMetrics = struct();

    TreesNum = 100;
    numFeatures = size(X, 2);

    % Cross-Validated Feature Importance (overall)
    impMatrix = zeros(cv.K, numFeatures);
    for loopFold = 1:cv.K
        loopTrainIdx = cv.folds{loopFold}.trainIdx;
        loopXTrain = X(loopTrainIdx, :);
        loopYTrain = Y(loopTrainIdx);

        loopModel = TreeBagger(TreesNum, loopXTrain, loopYTrain, ...
            'OOBPrediction', 'on', ...
            'OOBPredictorImportance', 'on');

        impMatrix(loopFold, :) = loopModel.OOBPermutedPredictorDeltaError;
    end

    % Average importance across folds
    avgImportance = mean(impMatrix, 1);
    [rfMetrics.featureImp, sortIdx] = sort(avgImportance, 'descend');
    rfMetrics.featureNames = featureNames(sortIdx);

    % ======= Per-Class Feature Importance (one-vs-rest, cross-validated) ======
    uniqueClasses = unique(Y);
    numClasses = numel(uniqueClasses);
    perClassImpMatrix = zeros(numFeatures, numClasses, cv.K); % [features x classes x folds]

    for loopFold = 1:cv.K
        loopTrainIdx = cv.folds{loopFold}.trainIdx;
        loopXTrain = X(loopTrainIdx, :);
        loopYTrain = Y(loopTrainIdx);

        for c = 1:numClasses
            % One-vs-rest: make binary label for this class
            Y_bin = categorical(loopYTrain == uniqueClasses(c));
            model = TreeBagger(TreesNum, loopXTrain, Y_bin, ...
                'OOBPrediction', 'on', ...
                'OOBPredictorImportance', 'on');
            perClassImpMatrix(:, c, loopFold) = model.OOBPermutedPredictorDeltaError(:);
        end
    end
    % Average over folds
    avgPerClassImportance = mean(perClassImpMatrix, 3); % [features x classes]

    % Save (sorted per class)
    rfMetrics.perClassFeatureImp = avgPerClassImportance;
    rfMetrics.perClassFeatureNames = featureNames;
    rfMetrics.perClassLabels = uniqueClasses;


    % Cross-Validated Metrics vs. Number of Features
    metrics = zeros(numFeatures, 4);  % [accuracy, precision, recall, f1]
    for loopN = 1:numFeatures % For all features
        loopIdx = sortIdx(1:loopN);  % Top-N features

        loopAllYPred = [];
        loopAllYTrue = [];

        for loopFold = 1:cv.K
            loopTrainIdx = cv.folds{loopFold}.trainIdx;
            loopTestIdx  = cv.folds{loopFold}.testIdx;

            loopXTrainSub = X(loopTrainIdx, loopIdx);
            loopYTrainSub = Y(loopTrainIdx);
            loopXTestSub  = X(loopTestIdx, loopIdx);
            loopYTestSub  = Y(loopTestIdx);

            loopModel = TreeBagger(TreesNum, loopXTrainSub, loopYTrainSub);
            loopYPred = categorical(predict(loopModel, loopXTestSub));

            loopAllYPred = [loopAllYPred; loopYPred];
            loopAllYTrue = [loopAllYTrue; loopYTestSub];
        end

        % === Metrics ===
        loopConf = confusionmat(loopAllYTrue, loopAllYPred);
        loopTP = diag(loopConf);
        loopFP = sum(loopConf, 1)' - loopTP;
        loopFN = sum(loopConf, 2) - loopTP;

        loopPrecision = loopTP ./ (loopTP + loopFP + eps);
        loopRecall    = loopTP ./ (loopTP + loopFN + eps);
        loopF1        = 2 * (loopPrecision .* loopRecall) ./ (loopPrecision + loopRecall + eps);

        metrics(loopN, :) = [mean(loopAllYPred == loopAllYTrue), mean(loopPrecision), mean(loopRecall), mean(loopF1)];
    end

    rfMetrics.metrics = metrics;

end

