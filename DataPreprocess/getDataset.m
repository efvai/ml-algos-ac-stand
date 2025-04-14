function dataset = getDataset(dataTable, datasetName)
    % Helper function to get datasets by name
    % datasetName: 'dataset1' through 'dataset10'
    
    switch lower(datasetName)
        case 'dataset1'
            d1 = selectFiles(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH", "10hz", "Current");
            d1 = [d1; selectFiles(dataTable, "misalignment", "HH", "10hz", "Current")];
            dataset = d1;

        case 'dataset2'
            d2 = selectFiles(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH", "20hz", "Current");
            d2 = [d2; selectFiles(dataTable, "misalignment", "HH", "20hz", "Current")];
            dataset = d2;

        case 'dataset3'
            d3 = selectFiles(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH", "30hz", "Current");
            d3 = [d3; selectFiles(dataTable, "misalignment", "HH", "30hz", "Current")];
            dataset = d3;

        case 'dataset4'
            d4 = selectFiles(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH", "40hz", "Current");
            d4 = [d4; selectFiles(dataTable, "misalignment", "HH", "40hz", "Current")];
            dataset = d4;

        case 'dataset5'
            % Combined 10Hz–40Hz (sistem HH)
            d1 = getDataset(dataTable, 'dataset1');
            d2 = getDataset(dataTable, 'dataset2');
            d3 = getDataset(dataTable, 'dataset3');
            d4 = getDataset(dataTable, 'dataset4');
            dataset = [d1; d2; d3; d4];

        case 'dataset6'
            d6 = selectFiles(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH + brake", "20hz", "Current");
            d6 = [d6; selectFiles(dataTable, "misalignment", "under load", "20hz", "Current")];
            dataset = d6;

        case 'dataset7'
            d7 = selectFiles(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH + brake", "30hz", "Current");
            d7 = [d7; selectFiles(dataTable, "misalignment", "under load", "30hz", "Current")];
            dataset = d7;

        case 'dataset8'
            d8 = selectFiles(dataTable, {"frequency converter №2", "serviceable bearing"}, ...
                "sistem HH + brake", "40hz", "Current");
            d8 = [d8; selectFiles(dataTable, "misalignment", "under load", "40hz", "Current")];
            dataset = d8;

        case 'dataset9'
            % Combined 20Hz–40Hz (sistem HH + brake)
            d6 = getDataset(dataTable, 'dataset6');
            d7 = getDataset(dataTable, 'dataset7');
            d8 = getDataset(dataTable, 'dataset8');
            dataset = [d6; d7; d8];

        case 'dataset10'
            % Combined dataset5 + dataset9
            d5 = getDataset(dataTable, 'dataset5');
            d9 = getDataset(dataTable, 'dataset9');
            dataset = [d5; d9];

        otherwise
            error("Unknown dataset name: '%s'", datasetName);
    end
end