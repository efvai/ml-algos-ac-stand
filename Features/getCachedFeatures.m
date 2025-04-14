function [X, Y, featureTables] = getCachedFeatures(files, datasetName, windowDuration, overlapPercent, force)
    if nargin < 5
        force = false;
    end

    % === Ensure ModelsData directory exists ===
    cacheDir = 'ModelsData/Cache';
    if ~exist(cacheDir, 'dir')
        mkdir(cacheDir);
    end

    % === Full path for cache file ===
    cacheFile = fullfile(cacheDir, sprintf('features_%s_win%d_ovlp%d.mat', ...
        datasetName, windowDuration, overlapPercent));

    % === Check for cache ===
    if exist(cacheFile, 'file') && ~force
        fprintf('[INFO] Checking cached features: %s\n', cacheFile);
        data = load(cacheFile);

        % Recompute feature hash from current feature extraction logic
        [~, ~, ~, currentFeatureNames] = generateCurrentFeaturesFromFiles(files, windowDuration, overlapPercent, true);
        currentHash = DataHash(currentFeatureNames);

        if isfield(data, 'featureHash') && strcmp(data.featureHash, currentHash)
            fprintf('[INFO] Cache is valid. Loading features from cache.\n');
            X = data.X;
            Y = data.Y;
            featureTables = data.featureTables;
            return;
        else
            fprintf('[WARN] Feature hash mismatch — cache is outdated. Re-extracting...\n');
        end
    else
        if force
            fprintf('[INFO] Forced re-extraction of features.\n');
        else
            fprintf('[INFO] No cache found. Extracting features...\n');
        end
    end

    % === Extract and Save ===
    [X, Y, featureTables, featureNames] = generateCurrentFeaturesFromFiles(files, windowDuration, overlapPercent);
    featureHash = DataHash(featureNames);

    fprintf('[INFO] Saving features to cache: %s\n', cacheFile);
    save(cacheFile, 'X', 'Y', 'featureTables', 'featureHash', '-v7.3');
end