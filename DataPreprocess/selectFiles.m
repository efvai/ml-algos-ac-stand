function selectedFiles = selectFiles(metadataTable, faultValues, configValues, frequencyValues, signalTypeValues)
%SELECTFILES Flexible filtering of metadata table by multiple optional fields.
%
%   selectedFiles = selectFiles(metadataTable, faultValues, configValues, frequencyValues, signalTypeValues)
%
%   All filter values can be:
%     - a string (e.g., 'HH')
%     - a cell array of strings (e.g., {'HH', 'sistem HH'})
%     - empty [] or '' to skip that filter (include all values)
%
%   Inputs:
%       metadataTable      - Table with metadata
%       faultValues        - Desired Fault(s) (e.g., 'frequency converter №2' or {'№1','№2'})
%       configValues       - Desired Config(s) (e.g., 'HH' or {'HH','sistem HH'})
%       frequencyValues    - Desired Frequency(s) (e.g., '10hz' or {'10hz','20hz'})
%       signalTypeValues   - Desired SignalType(s) (e.g., 'Current' or {'Current','Vibration'})
%
%   Output:
%       selectedFiles      - Filtered table of matching rows

    % Start with all rows included
    matchedRows = true(height(metadataTable), 1);

    % Helper to build logical index for each filter
    function idx = matchField(fieldData, values)
        if isempty(values)
            idx = true(size(fieldData));  % Include all
        elseif ischar(values) || isstring(values)
            idx = strcmp(fieldData, values);
        elseif iscell(values)
            idx = false(size(fieldData));
            for v = 1:length(values)
                idx = idx | strcmp(fieldData, values{v});
            end
        else
            error('Unsupported filter type');
        end
    end

    % Combine filters if provided
    if nargin >= 2 && ~isempty(faultValues)
        matchedRows = matchedRows & matchField(metadataTable.Fault, faultValues);
    end
    if nargin >= 3 && ~isempty(configValues)
        matchedRows = matchedRows & matchField(metadataTable.Config, configValues);
    end
    if nargin >= 4 && ~isempty(frequencyValues)
        matchedRows = matchedRows & matchField(metadataTable.Frequency, frequencyValues);
    end
    if nargin >= 5 && ~isempty(signalTypeValues)
        matchedRows = matchedRows & matchField(metadataTable.SignalType, signalTypeValues);
    end

    % Return filtered table
    selectedFiles = metadataTable(matchedRows, :);
end

