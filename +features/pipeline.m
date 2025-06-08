function [X, Y, featureTbl, featureNames] = pipeline(files, options)
%FEATURES.PIPELINE Full feature extraction pipeline from files
%
%   [X, Y, featureTbl, featureNames] = features.pipeline(files, options)
%
%   INPUTS:
%       files   - Cell array of file paths or metadata table
%       options - Struct with fields:
%                   .windowDuration   - (default: 1.0 [s])
%                   .windowOverlap    - (default: 50 [%])
%                   .readCurrentFn    - (default: @io.readCurrent)
%                   .exclude          - (default: {} — no features excluded)
%
%   OUTPUTS:
%       X            - Feature matrix
%       Y            - Labels
%       featureTbl   - Table with metadata + features
%       featureNames - Cell array of feature names

    % === Set defaults ===
    if nargin < 2
        options = struct();
    end

    if ~isfield(options, 'windowDuration')
        options.windowDuration = 1.0;  % seconds
    end

    if ~isfield(options, 'windowOverlap')
        options.windowOverlap = 50;  % percent
    end

    if ~isfield(options, 'readCurrentFn')
        options.readCurrentFn = @io.readCurrent;
    end

    if ~isfield(options, 'readVibroFn')
        options.readVibroFn = @io.readVibro;
    end

    if ~isfield(options, 'exclude')
        options.exclude = {};  % no excluded features
    end

    if ~isfield(options, 'include')
        options.include = {};  % allow full set by default
    end

    % === Build signal table ===
    sigTable = preprocess.buildSignalTable( ...
        files, ...
        options.windowDuration, ...
        options.windowOverlap, ...
        options.readCurrentFn, ...
        options.readVibroFn...
    );

    % === Extract features ===
    [X, Y, featureTbl, featureNames] = features.fromSignalTable(sigTable);

    % === Filter features ===
    if ~isempty(options.include)
        % Filter to ONLY included features
        [X, featureNames] = features.keepOnly(X, featureNames, options.include);
    end
    % Remove excluded features
    [X, featureNames] = features.exclude(X, featureNames, options.exclude);
    [X, rowMask, featureNames] = features.removeOutOfScopeRows(X, featureNames, featureNames);
    featureTbl = featureTbl(rowMask, :);
    
end