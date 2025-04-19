function signalTable = buildSignalTable(metadataTable, windowDuration, overlapPercent, readFnCurrents, readFnVibro)
%BUILDSIGNALTABLE Creates a table of windowed signal data from metadata table.
%
%   signalTable = buildSignalTable(metadataTable, windowDuration, overlapPercent, readFnCurrents, readFnVibro)
%
%   INPUTS:
%       metadataTable   - Table with at least the following columns:
%                         .FilePath (string or char), .Fault (label), .Fs (sampling rate)
%       windowDuration  - Duration of each window in seconds
%       overlapPercent  - Overlap between windows (0–100)
%       readFnCurrents  - Function handle to read current from file path (e.g., @io.readCurrent)
%       readFnVibro     - Function handle to read vibration signal
%
%   OUTPUT:
%       signalTable     - Table with columns:
%                         .currents (Nx2), .vibro (Nx1, optional),
%                         .label (same as Fault), .meta, .timeInterval

    allEntries = [];

    for i = 1:height(metadataTable)
        rowMeta = metadataTable(i, :);

        % Load data using provided functions
        dataPath = rowMeta.FilePath{1};  % Assuming FilePath is a cellstr or string

        signalType = string(rowMeta.SignalType);
        switch signalType
            case "Current"
                signalData = readFnCurrents(dataPath);  % Nx2
                isCurrent = true;

            case "Vibration"
                signalData = readFnVibro(dataPath);     % Nx4
                isCurrent = false;

            otherwise
                error("Unknown SignalType: %s", signalType);
        end

        % Sampling frequency from table
        Fs = rowMeta.Fs;

        % Windowing
        [signalWindows, timeIntervals] = preprocess.windows(signalData, Fs, windowDuration, overlapPercent);

        % Label from table
        label = rowMeta.Fault;

        % Create one row per window
        for w = 1:numel(signalWindows)
            entry = struct();
            % Remove outliers (TEMP LOCATED HERE)
            %currentWindows(w) = filloutliers(currentWindows(w), "linear", "movmedian", 400);
            if isCurrent
                entry.currents = signalWindows(w);
            else
                entry.vibro = signalWindows(w);
            end
            entry.label = string(label);
            entry.timeInterval = timeIntervals(w, :);
            entry.meta = rowMeta;
            allEntries = [allEntries; entry]; %#ok<AGROW>
        end
    end

    % Convert to final table
    signalTable = struct2table(allEntries);
end