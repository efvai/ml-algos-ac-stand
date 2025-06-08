function fig = windowFreqDomain(row, opts)
% windowFreqDomain - Plot frequency domain of a signal with custom options.
%
% Inputs:
%   row  - Table row(s) with signal fields and meta info
%   opts - Struct with fields:
%       .signalType  - 'currents' [default] or 'vibro'
%       .logScale    - Apply log scale (true [default] or false)
%       .xlim        - frequency axis limits (e.g., [0 500])
%       .visible     - Show figure (true or false [default])
%       .titleStr    - Custom plot title
%       .xlabelStr   - Label for X axis
%       .ylabelStr   - Label for Y axis
%
% Output:
%   fig - Handle to the created figure

% ===== Set Default Options =====
if nargin < 2
    opts = struct();
end

opts = setDefault(opts, 'signalType', 'currents');
opts = setDefault(opts, 'logScale', true);
opts = setDefault(opts, 'visible', false);
opts = setDefault(opts, 'titleStr', ['Frequency Domain - ', opts.signalType]);

% Determine dynamic labels
opts = setDefault(opts, 'xlabelStr', 'Частота, Гц');
defaultYLabel = ternary(opts.logScale, ...
                        ternary(strcmp(opts.signalType, 'vibro'), 'Уровень вибро, дБ', 'Уровень тока, дБ'), ...
                        'Magnitude');
opts = setDefault(opts, 'ylabelStr', defaultYLabel);

% ===== Validate Signal Type =====
validTypes = {'currents', 'vibro'};
if ~ismember(opts.signalType, validTypes)
    error("Invalid signal type. Must be 'currents' or 'vibro'.");
end

if ~ismember(opts.signalType, row.Properties.VariableNames)
    error("Signal '%s' not found in the table.", opts.signalType);
end

metaField = ternary(strcmp(opts.signalType, 'vibro'), 'metaVibro', 'metaCurrent');

% ===== Handle Multiple Rows =====
numRows = height(row);
sigCells = cell(numRows,1);
FsVec = zeros(numRows,1);

for i = 1:numRows
    sigCells{i} = row.(opts.signalType){i};
    FsVec(i) = row.(metaField).Fs(i);
end

if any(diff(FsVec) ~= 0)
    error('Sampling frequencies differ between rows. Cannot continue.');
end

Fs = FsVec(1);
sig = cat(1, sigCells{:});
[N, C] = size(sig);
f = Fs * (0:(N/2)) / N;

% Default freq axis limit if not set
opts = setDefault(opts, 'xlim', [0 Fs/2]);

% ===== Create Figure =====
if isfield(opts, 'parent') && ~isempty(opts.parent)
    t = tiledlayout(opts.parent, C,1, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');
    fig = ancestor(t, 'figure'); % Just for compatibility
else
    fig = figure('Visible', ternary(opts.visible, 'on', 'off'));
    t = tiledlayout(C, 1, 'Padding', 'compact', 'TileSpacing', 'compact');
end
title(t, opts.titleStr, 'FontWeight', 'bold', 'FontSize', 14, 'Interpreter', 'none');

% ===== Plot Each Channel =====
for ch = 1:C
    Y = fft(sig(:, ch));
    P2 = abs(Y / N);                     % Two-sided spectrum
    P1 = P2(1:N/2+1);
    P1(2:end-1) = 2 * P1(2:end-1);

    if opts.logScale
        P1 = 20 * log10(P1 + eps);       % Avoid log(0)
    end

    ax = nexttile(t);
    plot(ax, f, P1, 'LineWidth', 1.2);
    xlabel(ax, opts.xlabelStr, 'FontWeight', 'bold');
    ylabel(ax, opts.ylabelStr, 'FontWeight', 'bold');
    title(ax, ['Канал ', num2str(ch)], 'FontWeight', 'bold');
    xlim(ax, opts.xlim);
    grid(ax, 'on');
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