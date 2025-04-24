function fig = windowFreqDomain(row, opts)
    % windowFreqDomain - Plot frequency domain of a signal with custom options
    %
    % Inputs:
    %   row     - Table row with signal data and meta
    %   options - Struct with fields:
    %       .signalType ('currents' [default] or 'vibro')
    %       .logScale   (true [default] or false)
    %       .xlim       ([min max], default = [0 Fs/2])
    %       .visible    (false [default] or true)
    %
    % Output:
    %   fig - Handle to the created figure

    % ====== Set default options ======
    if nargin < 2
        opts = struct();
    end

    if ~isfield(opts, 'signalType')
        opts.signalType = 'currents';
        disp("No signal type provided. Using 'currents' by default.");
    end

    if ~isfield(opts, 'logScale')
        opts.logScale = true;
    end

    if ~isfield(opts, 'visible')
        opts.visible = false;
    end

    % ====== Extract signal ======
    signalType = opts.signalType;

    % Validate signalType
    validTypes = {'currents', 'vibro'};
    if ~ismember(signalType, validTypes)
        error("Invalid signal type. Must be 'currents' or 'vibro'.");
    end

    % Check availability in table
    if ~ismember(signalType, row.Properties.VariableNames)
        error('Signal type "%s" not found in the table.', signalType);
    end

    % === Handle multiple rows ===
    if height(row) > 1  % <<< multiple rows
        % Preallocate cell arrays to collect signals and Fs
        sigCells = cell(height(row),1);
        FsVec = zeros(height(row),1);
        for i = 1:height(row)
            sigCells{i} = row.(opts.signalType){i};
            FsVec(i) = row.meta(i, :).Fs;
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
        if ~isfield(opts, 'titleStr') || isempty(opts.titleStr)
            opts.titleStr = sprintf('Time Domain - %s (all rows, N=%d)', opts.signalType, height(row));
        end
    else
        % Extract signal and sampling rate, single row
        sig = row.(opts.signalType){1};  % [N x C]
        Fs = row.meta.Fs;
        [N, C] = size(sig);
    end

    % Default xlim if not provided
    if ~isfield(opts, 'xlim') || isempty(opts.xlim)
        opts.xlim = [0, Fs/2];
    end

    % ====== Create Figure ======
    fig = figure('Visible', ternary(opts.visible, 'on', 'off'));

    t = tiledlayout(C, 1, 'Padding', 'compact', 'TileSpacing', 'compact');
    title(t, ['Frequency Domain - ', signalType], 'FontSize', 14, 'FontWeight', 'bold');

    N = size(sig, 1);         % Number of samples
    f = Fs * (0:(N/2)) / N;   % Frequency vector (one-sided)

    % ====== Plot Each Channel ======
    for ch = 1:C
        Y = fft(sig(:, ch));
        P2 = abs(Y / N);               % Two-sided spectrum
        P1 = P2(1:N/2+1);              % One-sided spectrum
        P1(2:end-1) = 2 * P1(2:end-1); % Double energy (except DC/nyquist)

        if opts.logScale
            P1 = 20 * log10(P1 + eps); % Avoid log(0)
        end

        nexttile;
        plot(f, P1, 'LineWidth', 1.2);
        grid on;

        xlabel('Frequency (Hz)', 'FontWeight', 'bold');
        if opts.logScale
            ylabel("Magnitude (dB)", 'FontWeight', 'bold');
        else
            ylabel("Magnitude", 'FontWeight', 'bold');
        end
        
        title(['Channel ', num2str(ch)], 'FontWeight', 'bold');
        xlim(opts.xlim);
    end
end

% Helper ternary function (MATLAB doesn't have ? operator)
function out = ternary(cond, valTrue, valFalse)
    if cond
        out = valTrue;
    else
        out = valFalse;
    end
end