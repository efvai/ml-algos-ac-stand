function [X, Y, featureTbl, featureNames] = fromSignalTable(signalTable)
%FEATURES.FROMSIGNALTABLE Extracts features from a table of signals
%   [X, Y, featureTbl, featureNames] = features.fromSignalTable(signalTable)
%
%   INPUTS:
%       signalTable - table with columns:
%           .currents - Nx2 matrix (optional)
%           .vibro    - Nx1 vector (optional)
%           .label    - scalar/class label
%           .metaCurrent / .metaVibro
%
%   OUTPUTS:
%       X           - Feature matrix [nSamples x nFeatures]
%       Y           - Labels
%       featureTbl  - Table with named features (for inspection)
%       featureNames- Cell array of feature names

    nSamples = height(signalTable);
    allFeatures = cell(nSamples, 1);
    labels = strings(nSamples, 1);  % use strings for categorical conversion later

    useCurrent = ismember('currents', signalTable.Properties.VariableNames);
    useVibro = ismember('vibro', signalTable.Properties.VariableNames);

    for i = 1:nSamples
        row = signalTable(i,:);
        feats = [];

        % Extract current features
        if useCurrent && ~isempty(row.currents{1})
            FsCurr = row.metaCurrent.Fs;
            fCurrent = features.extractCurrent(row.currents{1}, FsCurr);  % assuming cell
            fPark = features.extractPark(row.currents{1}, FsCurr);
            feats = [feats, fCurrent, fPark];
        end

        % Extract vibration features
        if useVibro && ~isempty(row.vibro{1})
            FsVibro = row.metaVibro.Fs;
            fVibro = features.extractVibration(row.vibro{1}, FsVibro);
            feats = [feats, fVibro];
        end

        allFeatures{i,1} = feats;
        labels(i) = string(row.label);
    end

    % Convert to matrix
    X = cell2mat(allFeatures);

    % Determine combined feature names
    featureNames = {};
    if useCurrent
        featureNames = [featureNames, features.registry('currents')];
    end
    if useVibro
        featureNames = [featureNames, features.registry('vibro')];
    end

    % Feature table
    featureTbl = array2table(X, 'VariableNames', featureNames);
    featureTbl.label = categorical(labels);

    if ismember('metaCurrent', signalTable.Properties.VariableNames)
        featureTbl.metaCurrent = signalTable.metaCurrent;
    end
    if ismember('metaVibro', signalTable.Properties.VariableNames)
        featureTbl.metaVibro = signalTable.metaVibro;
    end
    featureTbl.timeInterval = signalTable.timeInterval;

    % Output labels
    Y = categorical(labels);
end