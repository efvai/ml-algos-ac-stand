function subTbl = select(featureTbl, varargin)
% selectByMeta - Filter rows of featureTbl according to filters on meta fields
%
% Usage:
%   subTbl = select(featureTbl, 'Fault', ["frequency converter №2", "misalignment"])
%
% This will return rows of featureTbl where featureTbl.meta.Fault matches either value.

    meta = featureTbl.metaCurrent;  % Extract meta table

    if mod(length(varargin),2) ~= 0
        error('Filters must be specified as name-value pairs.');
    end

    mask = true(height(featureTbl), 1);

    for i = 1:2:length(varargin)
        colName = varargin{i};
        value   = varargin{i+1};

        if iscell(meta.(colName)) || isstring(meta.(colName))
            mask = mask & ismember(meta.(colName), value);
        else
            mask = mask & meta.(colName) == value;
        end
    end

    subTbl = featureTbl(mask, :);
end