function matchedRows = findRowsByFilePath(sigTable, mydatapath)
% findRowsByFilePath - Find all rows in sigTable where meta.FilePath matches a given path.
%
% Usage:
%   matchedRows = findRowsByFilePath(sigTable, mydatapath)
%
% Inputs:
%   sigTable   - The table containing metaCurrent or metaVibro fields with a FilePath column
%   mydatapath - The file path to match (char or string)
%
% Output:
%   matchedRows - Subtable of sigTable with matching FilePath value

    % Normalize mydatapath to string for comparison consistency
    mydatapath = string(mydatapath);

    % --- Try finding FilePath from metaCurrent or metaVibro ---
    if ismember('metaCurrent', sigTable.Properties.VariableNames) ...
            && ismember('FilePath', sigTable.metaCurrent.Properties.VariableNames)
        filePaths = sigTable.metaCurrent.FilePath;

    elseif ismember('metaVibro', sigTable.Properties.VariableNames) ...
            && ismember('FilePath', sigTable.metaVibro.Properties.VariableNames)
        filePaths = sigTable.metaVibro.FilePath;

    else
        error('Neither metaCurrent nor metaVibro contains a "FilePath" column.');
    end

    % Convert paths to strings for unified comparison
    filePaths = string(filePaths);

    % Logical index of matching rows
    idx = filePaths == mydatapath;

    % Return the filtered table
    matchedRows = sigTable(idx, :);
end