function dataTable = collect(rootDir)
    dataTable = [];

    faultTypes = dir(rootDir);

    for i = 1:length(faultTypes)
        if ~faultTypes(i).isdir || startsWith(faultTypes(i).name, '.')
            continue;
        end

        faultLabel = faultTypes(i).name;
        faultPath = fullfile(rootDir, faultLabel);
        configs = dir(faultPath);

        for j = 1:length(configs)
            if ~configs(j).isdir || startsWith(configs(j).name, '.')
                continue;
            end

            configLabel = configs(j).name;
            configPath = fullfile(faultPath, configLabel);
            experiments = dir(configPath);

            for k = 1:length(experiments)
                if ~experiments(k).isdir || startsWith(experiments(k).name, '.')
                    continue;
                end

                expLabel = experiments(k).name;
                expPath = fullfile(configPath, expLabel);
                datFiles = dir(fullfile(expPath, '*.dat'));

                for f = 1:length(datFiles)
                    fileName = datFiles(f).name;
                    filePath = fullfile(expPath, fileName);

                    if ~(contains(fileName, 'LTR11') || contains(fileName, 'LTR22'))
                        continue;
                    end

                    freqMatch = regexp(expLabel, '\d+hz', 'match');
                    frequency = 'Unknown';
                    if ~isempty(freqMatch)
                        frequency = freqMatch{1};
                    end

                    if contains(fileName, 'LTR11')
                        signalType = 'Current';
                        Fs = 10000;
                    elseif contains(fileName, 'LTR22')
                        signalType = 'Vibration';
                        Fs = 26041;
                    else
                        signalType = 'Unknown';
                        Fs = NaN;
                    end

                    newRow = table(string(filePath), string(fileName), string(faultLabel), ...
                        string(configLabel), string(frequency), string(expLabel), string(signalType), Fs, ...
                        'VariableNames', {'FilePath', 'FileName', 'Fault', ...
                        'Config', 'Frequency', 'Experiment', 'SignalType', 'Fs'});

                    dataTable = [dataTable; newRow];
                end
            end
        end
    end
end
