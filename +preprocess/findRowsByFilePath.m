function matchedRows = findRowsByFilePath(sigTable, mydatapath)
% Find all rows in sigTable where meta.FilePath matches mydatapath.
%
% Usage:
%   matchedRows = findRowsByFilePath(sigTable, mydatapath)
%
% Inputs:
%   sigTable   - The main table, containing a sub-table or struct column 'meta'
%   mydatapath - The file path to match (char or string)
%
% Output:
%   matchedRows - Subtable of sigTable with matching FilePath

    % Extract FilePath from meta
    filePaths = sigTable.meta.FilePath;
    
    % Check data type and compare
    if iscell(filePaths)
        idx = strcmp(mydatapath, filePaths);
    elseif isstring(filePaths)
        idx = filePaths == mydatapath;
    else
        error('Unsupported FilePath data type');
    end

    matchedRows = sigTable(idx, :);
end