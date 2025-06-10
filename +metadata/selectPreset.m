function metadataSubset = selectPreset(dataTable, datasetName)
    % Helper function to get datasets metadata by name
    % datasetName: 'dataset1' through 'dataset20'
    classLabels = {"healthy", "system misalignment", "misalignment", "faulty bearing"};

    switch lower(datasetName)
        case 'dataset1'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "no load", "10hz", "Current");

        case 'dataset2'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "no load", "20hz", "Current");

        case 'dataset3'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "no load", "30hz", "Current");

        case 'dataset4'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "no load", "40hz", "Current");

        case 'dataset5'
            % Combined 10Hz–40Hz (no load)
            d1 = metadata.selectPreset(dataTable, 'dataset1');
            d2 = metadata.selectPreset(dataTable, 'dataset2');
            d3 = metadata.selectPreset(dataTable, 'dataset3');
            d4 = metadata.selectPreset(dataTable, 'dataset4');
            metadataSubset = [d1; d2; d3; d4];

        case 'dataset6'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "under load", "20hz", "Current");

        case 'dataset7'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "under load", "30hz", "Current");

        case 'dataset8'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "under load", "40hz", "Current");

        case 'dataset9'
            % Combined 20Hz–30Hz (under load)
            % Also mixed with healthy 10 Hz and 40 Hz
            h10 = metadata.filter(dataTable, classLabels, ...
                "under load", "10hz", "Current");
            d6 = metadata.selectPreset(dataTable, 'dataset6');
            d7 = metadata.selectPreset(dataTable, 'dataset7');
            d8 = metadata.selectPreset(dataTable, 'dataset8');
            metadataSubset = [h10; d6; d7; d8];

        case 'dataset10'
            % Combined dataset5 + dataset9
            d5 = metadata.selectPreset(dataTable, 'dataset5');
            d9 = metadata.selectPreset(dataTable, 'dataset9');
            metadataSubset = [d5; d9];

        case 'dataset11'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "no load", "10hz", "Vibration");

        case 'dataset12'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "no load", "20hz", "Vibration");

        case 'dataset13'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "no load", "30hz", "Vibration");

        case 'dataset14'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "no load", "40hz", "Vibration");

        case 'dataset15'
            % Combined 10Hz–40Hz (no load, Vibration)
            d11 = metadata.selectPreset(dataTable, 'dataset11');
            d12 = metadata.selectPreset(dataTable, 'dataset12');
            d13 = metadata.selectPreset(dataTable, 'dataset13');
            d14 = metadata.selectPreset(dataTable, 'dataset14');
            metadataSubset = [d11; d12; d13; d14];

        case 'dataset16'
            d1 = metadata.selectPreset(dataTable, 'dataset1');
            d11 = metadata.selectPreset(dataTable, 'dataset11');
            metadataSubset = [d1; d11];

        case 'dataset17'
            d2 = metadata.selectPreset(dataTable, 'dataset2');
            d12 = metadata.selectPreset(dataTable, 'dataset12');
            metadataSubset = [d2; d12];

        case 'dataset18'
            d3 = metadata.selectPreset(dataTable, 'dataset3');
            d13 = metadata.selectPreset(dataTable, 'dataset13');
            metadataSubset = [d3; d13];

        case 'dataset19'
            d4 = metadata.selectPreset(dataTable, 'dataset4');
            d14 = metadata.selectPreset(dataTable, 'dataset14');
            metadataSubset = [d4; d14];

        case 'dataset20'
            d5 = metadata.selectPreset(dataTable, 'dataset5');
            d15 = metadata.selectPreset(dataTable, 'dataset15');
            metadataSubset = [d5; d15];

        case 'dataset21'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "under load", "20hz", "Vibration");

        case 'dataset22'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "under load", "30hz", "Vibration");

        case 'dataset23'
            metadataSubset = metadata.filter(dataTable, classLabels, ...
                "under load", "40hz", "Vibration");

        case 'dataset24'
            % Combined 20Hz–30Hz (under load, Vibration)
            h10 = metadata.filter(dataTable, classLabels, ...
                "under load", "10hz", "Vibration");
            d21 = metadata.selectPreset(dataTable, 'dataset21');
            d22 = metadata.selectPreset(dataTable, 'dataset22');
            d23 = metadata.selectPreset(dataTable, 'dataset23');
            
            metadataSubset = [h10; d21; d22; d23]; %d23];% d14];
        case 'dataset25'
            d15 = metadata.selectPreset(dataTable, 'dataset15');
            d24 = metadata.selectPreset(dataTable, 'dataset24');
            metadataSubset = [d15; d24];
        otherwise
            error("Unknown dataset name: '%s'", datasetName);
    end
end