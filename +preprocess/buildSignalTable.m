function signalTable = buildSignalTable(metadataTable, windowDuration, overlapPercent, readFnCurrents, readFnVibro)
%BUILDSIGNALTABLE Creates a table of windowed signal data from metadata table.
%
%   OUTPUT:
%       signalTable - Table with columns:
%           .currents, .vibro, .label, .metaCurrent, .metaVibro, .timeInterval
%
%   INPUT:
%       addSynthData - if true, generate synthetic 'WindingsShort' from 'healthy' current

allEntries = [];

% Ensure string type for grouping fields
metadataTable.Experiment = string(metadataTable.Experiment);
metadataTable.Fault = string(metadataTable.Fault);
metadataTable.Config = string(metadataTable.Config);

% Create composite group key: Experiment + Fault + Config
groupKeys = metadataTable.Experiment + "_" + metadataTable.Fault + "_" + metadataTable.Config;
uniqueGroups = unique(groupKeys);

for g = 1:numel(uniqueGroups)
    groupName = uniqueGroups(g);
    groupRows = metadataTable(groupKeys == groupName, :);

    % Initialize
    currentData = [];
    vibroData = [];
    metaCurrent = [];
    metaVibro = [];

    % Load signals by type
    for i = 1:height(groupRows)
        row = groupRows(i, :);
        dataPath = row.FilePath;
        signalType = string(row.SignalType);

        switch signalType
            case "Current"
                currentData = readFnCurrents(dataPath);
                metaCurrent = row;

            case "Vibration"
                vibroData = readFnVibro(dataPath);
                metaVibro = row;

            otherwise
                warning("Unknown SignalType: %s", signalType);
        end
    end

    % Use sampling rate and label from available metadata
    if ~isempty(metaCurrent)
        Fs = metaCurrent.Fs;
        label = metaCurrent.Fault;
    elseif ~isempty(metaVibro)
        Fs = metaVibro.Fs;
        label = metaVibro.Fault;
    else
        continue;
    end

    % Window signals
    currentWindows = {};
    vibroWindows = {};
    timeIntervals = [];

    if ~isempty(currentData)
        [currentWindows, timeIntervals] = preprocess.windows(currentData, Fs, windowDuration, overlapPercent);
    end

    if ~isempty(vibroData)
        [vibroWindows, timeIntervalsVibro] = preprocess.windows(vibroData, Fs, windowDuration, overlapPercent);
        if isempty(timeIntervals)
            timeIntervals = timeIntervalsVibro;
        end
    end

    % Create entries for each window
    numWindows = size(timeIntervals, 1);
    for w = 1:numWindows
        entry = struct();

        if ~isempty(currentWindows)
            entry.currents = currentWindows(w);
        end

        if ~isempty(vibroWindows)
            entry.vibro = vibroWindows(w);
        end

        entry.label = string(label);
        entry.timeInterval = timeIntervals(w, :);

        entry.metaCurrent = [];
        if ~isempty(metaCurrent)
            entry.metaCurrent = metaCurrent;
        end

        entry.metaVibro = [];
        if ~isempty(metaVibro)
            entry.metaVibro = metaVibro;
        end

        allEntries = [allEntries; entry]; %#ok<AGROW>
    end
end

% Convert to table
signalTable = struct2table(allEntries);
end
