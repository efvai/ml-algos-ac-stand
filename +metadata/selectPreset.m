function metadataSubset = selectPreset(dataTable, datasetName)
    % Helper function to get datasets metadata by name
    % datasetName: 'dataset1' through 'dataset10'
    
    switch lower(datasetName)
        case 'dataset1'
            d1 = metadata.filter(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH", "10hz", "Current");
            d1 = [d1; metadata.filter(dataTable, "misalignment", "HH", "10hz", "Current")];
            metadataSubset = d1;

        case 'dataset2'
            d2 = metadata.filter(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH", "20hz", "Current");
            d2 = [d2; metadata.filter(dataTable, "misalignment", "HH", "20hz", "Current")];
            metadataSubset = d2;

        case 'dataset3'
            d3 = metadata.filter(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH", "30hz", "Current");
            d3 = [d3; metadata.filter(dataTable, "misalignment", "HH", "30hz", "Current")];
            metadataSubset = d3;

        case 'dataset4'
            d4 = metadata.filter(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH", "40hz", "Current");
            d4 = [d4; metadata.filter(dataTable, "misalignment", "HH", "40hz", "Current")];
            metadataSubset = d4;

        case 'dataset5'
            % Combined 10Hz–40Hz (sistem HH)
            d1 = metadata.selectPreset(dataTable, 'dataset1');
            d2 = metadata.selectPreset(dataTable, 'dataset2');
            d3 = metadata.selectPreset(dataTable, 'dataset3');
            d4 = metadata.selectPreset(dataTable, 'dataset4');
            metadataSubset = [d1; d2; d3; d4];

        case 'dataset6'
            d6 = metadata.filter(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH + brake", "20hz", "Current");
            d6 = [d6; metadata.filter(dataTable, "misalignment", "under load", "20hz", "Current")];
            metadataSubset = d6;

        case 'dataset7'
            d7 = metadata.filter(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH + brake", "30hz", "Current");
            d7 = [d7; metadata.filter(dataTable, "misalignment", "under load", "30hz", "Current")];
            metadataSubset = d7;

        case 'dataset8'
            d8 = metadata.filter(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH + brake", "40hz", "Current");
            d8 = [d8; metadata.filter(dataTable, "misalignment", "under load", "40hz", "Current")];
            metadataSubset = d8;

        case 'dataset9'
            % Combined 20Hz–40Hz (sistem HH + brake)
            d6 = metadata.selectPreset(dataTable, 'dataset6');
            d7 = metadata.selectPreset(dataTable, 'dataset7');
            d8 = metadata.selectPreset(dataTable, 'dataset8');
            metadataSubset = [d6; d7; d8];

        case 'dataset10'
            % Combined dataset5 + dataset9
            d5 = metadata.selectPreset(dataTable, 'dataset5');
            d9 = metadata.selectPreset(dataTable, 'dataset9');
            metadataSubset = [d5; d9];

        case 'dataset11'
            d11 = metadata.filter(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH", "10hz", "Vibration");
            d11 = [d11; metadata.filter(dataTable, "misalignment", "HH", "10hz", "Vibration")];
            metadataSubset = d11;
        case 'dataset12'
            d12 = metadata.filter(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH", "20hz", "Vibration");
            d12 = [d12; metadata.filter(dataTable, "misalignment", "HH", "20hz", "Vibration")];
            metadataSubset = d12;

        case 'dataset13'
            d13 = metadata.filter(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH", "30hz", "Vibration");
            d13 = [d13; metadata.filter(dataTable, "misalignment", "HH", "30hz", "Vibration")];
            metadataSubset = d13;

        case 'dataset14'
            d14 = metadata.filter(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH", "40hz", "Vibration");
            d14 = [d14; metadata.filter(dataTable, "misalignment", "HH", "40hz", "Vibration")];
            metadataSubset = d14;

        case 'dataset15'
            % Combined 10Hz–40Hz (sistem HH, Vibration)
            d11 = metadata.selectPreset(dataTable, 'dataset11');
            d12 = metadata.selectPreset(dataTable, 'dataset12');
            d13 = metadata.selectPreset(dataTable, 'dataset13');
            d14 = metadata.selectPreset(dataTable, 'dataset14');
            metadataSubset = [d11; d12; d13; d14];


        otherwise
            error("Unknown dataset name: '%s'", datasetName);
    end
end