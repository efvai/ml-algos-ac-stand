function [X, Y, featureTbl, featureNames] = fromSignalTable(signalTable)
%FEATURES.FROMSIGNALTABLE Extracts features from a table of signals
%   [X, Y, featureTbl, featureNames] = features.fromSignalTable(signalTable)
%
%   INPUTS:
%       signalTable - table with columns:
%           .currents - Nx2 matrix (optional)
%           .vibro    - Nx1 vector (optional)
%           .label    - scalar/class label
%
%   OUTPUTS:
%       X           - Feature matrix [nSamples x nFeatures]
%       Y           - Labels
%       featureTbl  - Table with named features (for inspection)
%       featureNames- Cell array of feature names

    nSamples = height(signalTable);
    allFeatures = {};
    labels = cell(nSamples, 1);

    for i = 1:nSamples
        row = signalTable(i,:);
        Fs = row.meta.Fs;
        feats = [];

        % Extract current features
        if isfield(row, 'currents') || ismember('currents', signalTable.Properties.VariableNames)
            fCurrent = features.extractCurrent(row.currents{1}, Fs);  % assuming cell array in table
            fPark = features.extractPark(row.currents{1}, Fs);
            feats = [feats, fCurrent, fPark];
        end

        % Extract vibration features
        if isfield(row, 'vibro') || ismember('vibro', signalTable.Properties.VariableNames)
            fVibro = features.extractVibration(row.vibro{1}, Fs);
            feats = [feats, fVibro];
        end

        allFeatures{i,1} = feats;
        labels{i,1} = row.label;
    end

    % Convert cell array to matrix
    X = cell2mat(allFeatures);

    % Determine which feature names to use based on input table
    useVibro = ismember('vibro', signalTable.Properties.VariableNames);
    if useVibro
        featureNames = features.registry('vibro');
    else
        featureNames = features.registry('currents');
    end

    % Feature table
    featureTbl = array2table(X, 'VariableNames', featureNames);
    featureTbl.label = signalTable.label;
    featureTbl.meta = signalTable.meta;
    featureTbl.timeInterval = signalTable.timeInterval;

    % Output labels
    Y = categorical(string(labels));
end