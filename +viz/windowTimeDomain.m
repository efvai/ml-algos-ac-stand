function fig = windowTimeDomain(row, opts)
% windowTimeDomain - Plot time-domain signal of 'currents' or 'vibro'
%
% Inputs:
%   row  - A table row with columns for signal and meta info
%   opts - Struct with fields:
%       .signalType - 'currents' [default] or 'vibro'
%       .visible    - true to show figure [default: false]
%       .xlim       - x-axis limits
%       .ylim       - y-axis limits
%       .titleStr   - Title for the full plot
%       .xlabelStr  - Label for X axis
%       .ylabelStr  - Label for Y axis
%
% Output:
%   fig - Handle to created figure

% === Default Options ===
if nargin < 2
    opts = struct();
end
opts = setDefault(opts, 'signalType', 'currents');
opts = setDefault(opts, 'visible', false);
opts = setDefault(opts, 'titleStr', ['Time Domain - ', opts.signalType]);
opts = setDefault(opts, 'xlabelStr', 'Time, s');
opts = setDefault(opts, 'ylabelStr', ternary(strcmp(opts.signalType, 'vibro'), 'Виброускорение, мм/c^2', 'Ток, A')); 

validSignals = {'currents', 'vibro'};
if ~ismember(opts.signalType, validSignals)
    error("Invalid signalType. Must be 'currents' or 'vibro'.");
end

if ~ismember(opts.signalType, row.Properties.VariableNames)
    error("Signal '%s' not found in the table.", opts.signalType);
end

% Determine correct meta field name
metaField = ternary(strcmp(opts.signalType, 'vibro'), 'metaVibro', 'metaCurrent');

% === Handle single or multiple rows ===
numRows = height(row);
sigCells = cell(numRows, 1);
FsVec = zeros(numRows, 1);

for i = 1:numRows
    sigCells{i} = row.(opts.signalType){i};
    FsVec(i) = row.(metaField).Fs(i);
end

if any(diff(FsVec) ~= 0)
    error('Sampling frequencies (Fs) differ between rows. Cannot continue.');
end

Fs = FsVec(1);
sig = cat(1, sigCells{:});
[N, C] = size(sig);
t = (0:N-1) / Fs;

% === Create figure ===
if isfield(opts, 'parent') && ~isempty(opts.parent)
    tLayout = tiledlayout(opts.parent, C,1, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');
    fig = ancestor(tLayout, 'figure'); % Just for compatibility
else
    fig = figure('Visible', ternary(opts.visible, 'on', 'off'));
    tLayout = tiledlayout(C, 1, 'Padding', 'compact', 'TileSpacing', 'compact');
end
title(tLayout, opts.titleStr, 'FontWeight', 'bold', 'FontSize', 14, 'Interpreter', 'none');

for ch = 1:C
    ax = nexttile(tLayout);
    plot(ax, t, sig(:, ch), 'LineWidth', 1.2);
    xlabel(ax, opts.xlabelStr, 'FontWeight', 'bold');
    ylabel(ax, opts.ylabelStr, 'FontWeight', 'bold');
    title(ax, ['Канал ', num2str(ch)], 'FontWeight', 'bold');
    grid(ax, 'on');

    if isfield(opts, 'xlim') && ~isempty(opts.xlim)
        xlim(ax, opts.xlim);
    end
    if isfield(opts, 'ylim') && ~isempty(opts.ylim)
        ylim(ax, opts.ylim);
    end
end
end

% === Helper Functions ===
function out = ternary(cond, valTrue, valFalse)
    if cond
        out = valTrue;
    else
        out = valFalse;
    end
end

function opts = setDefault(opts, fieldName, defaultValue)
    if ~isfield(opts, fieldName) || isempty(opts.(fieldName))
        opts.(fieldName) = defaultValue;
    end
end