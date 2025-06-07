function fig = windowTimeDomain(row, opts)
    % windowTimeDomain - Plot time-domain signal of 'currents' or 'vibro'
    % If multiple rows are passed, concatenate signals and plot the entire file.
    % Inputs:
    %   row  - A table row with signal data and meta
    %   opts - Struct with optional fields:
    %       .signalType - 'currents' [default] or 'vibro'
    %       .visible    - true to show figure, false to hide [default: false]
    %       .xlim       - time axis limits (e.g., [0 0.1])
    %       .ylim       - amplitude axis limits (e.g., [-1 1])
    %       .titleStr   - custom title string
    %
    % Output:
    %   fig - Handle to created figure

    % Set defaults
    if nargin < 2
        opts = struct();
    end
    if ~isfield(opts, 'signalType') || isempty(opts.signalType)
        opts.signalType = 'currents';
        disp("No signal type provided. Using 'currents' by default.");
    end
    if ~isfield(opts, 'visible')
        opts.visible = false;
    end
    if ~isfield(opts, 'titleStr') || isempty(opts.titleStr)
        opts.titleStr = ['Time Domain - ', opts.signalType];
    end

    % Validate signal type
    validSignals = {'currents', 'vibro'};
    if ~ismember(opts.signalType, validSignals)
        error("Invalid signalType. Must be 'currents' or 'vibro'.");
    end

    % Check if signal exists
    if ~ismember(opts.signalType, row.Properties.VariableNames)
        error("Signal type '%s' not found in the row.", opts.signalType);
    end

    % === Handle multiple rows ===
    if height(row) > 1  % <<< multiple rows
        % Preallocate cell arrays to collect signals and Fs
        sigCells = cell(height(row),1);
        FsVec = zeros(height(row),1);
        for i = 1:height(row)
            sigCells{i} = row.(opts.signalType){i};
            FsVec(i) = row.metaVibro(i, :).Fs;
        end
        if any(FsVec ~= FsVec(1))
            error('Sampling rates differ between rows!');
        end
        Fs = FsVec(1);
        % Check channel consistency
        nChans = cellfun(@(s) size(s,2), sigCells);
        if any(nChans ~= nChans(1))
            error('Number of channels differ between rows!');
        end
        C = nChans(1);
        % Concatenate signals along time (assume all [N x C])
        sig = cat(1, sigCells{:});
        N = size(sig,1);
        % Create time vector for entire file
        t = (0:N-1) / Fs;
        if ~isfield(opts, 'titleStr') || isempty(opts.titleStr)
            opts.titleStr = sprintf('Time Domain - %s (all rows, N=%d)', opts.signalType, height(row));
        end
    else
        % Extract signal and sampling rate, single row
        sig = row.(opts.signalType){1};  % [N x C]
        Fs = row.metaCurrent.Fs;
        [N, C] = size(sig);
        t = (0:N-1) / Fs;
    end


    % Create figure
    fig = figure('Visible', ternary(opts.visible, 'on', 'off'));
    tLayout = tiledlayout(C, 1, 'Padding', 'compact', 'TileSpacing', 'compact');
    title(tLayout, opts.titleStr, 'FontWeight', 'bold', 'FontSize', 14);

    % Plot each channel
    for ch = 1:C
        nexttile;
        plot(t, sig(:, ch), 'LineWidth', 1.2);
        xlabel('Время, с', 'FontWeight', 'bold');
        ylabel('Виброускорение, мм/c^2', 'FontWeight', 'bold');
        title(['Канал ', num2str(ch)], 'FontWeight', 'bold');
        grid on;

        % Apply axis limits if provided
        if isfield(opts, 'xlim') && ~isempty(opts.xlim)
            xlim(opts.xlim);
        end
        if isfield(opts, 'ylim') && ~isempty(opts.ylim)
            ylim(opts.ylim);
        end
    end
end

% === Helper ternary function ===
function out = ternary(cond, valTrue, valFalse)
    if cond
        out = valTrue;
    else
        out = valFalse;
    end
end