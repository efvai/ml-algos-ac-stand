function rfMetrics = rfMetrics(X, Y, featureNames)
    rng(1);
    rfMetrics = struct();

    TreesNum = 100;
    K = 5; % Folds Num
    cv = cvpartition(Y, 'KFold', K);
    numFeatures = size(X, 2);

    % Cross-Validated Feature Importance
    impMatrix = zeros(K, numFeatures);
    for loopFold = 1:K
        loopTrainIdx = training(cv, loopFold);
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

    % Cross-Validated Metrics vs. Number of Features
    metrics = zeros(numFeatures, 4);  % [accuracy, precision, recall, f1]
    for loopN = 1:numFeatures % For all features
        loopIdx = sortIdx(1:loopN);  % Top-N features

        loopAllYPred = [];
        loopAllYTrue = [];

        for loopFold = 1:K
            loopTrainIdx = training(cv, loopFold);
            loopTestIdx  = test(cv, loopFold);

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

