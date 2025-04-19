function fig = windowFreqDomain(row, signalType)
    % windowFreqDomain Visualize the frequency domain of a signal
    %   fig = windowFreqDomain(row, signalType)
    %   - row: table row containing 'currents' or 'vibro' as cell array fields
    %   - signalType: 'currents' or 'vibro' (optional, defaults to 'currents')

    % Set default signal type if not provided
    if nargin < 2 || isempty(signalType)
        signalType = 'currents';
        disp('No signal type provided. Defaulting to ''currents''.');
    end

    % Validate signalType input
    if ~ismember(signalType, {'currents', 'vibro'})
        error('Invalid signal type. Choose either ''currents'' or ''vibro''.');
    end

    % Check if the selected signal exists in the table
    if ismember(signalType, row.Properties.VariableNames)
        sig = row.(signalType){1};  % [N x C]
    else
        error('The selected signal type "%s" is not present in the input row.', signalType);
    end

    % Extract sampling rate from meta
    Fs = row.meta.Fs;  % Scalar
    [N, C] = size(sig);

    % Frequency vector (one-sided)
    f = (0:floor(N/2)) * Fs / N;

    % Create figure
    fig = figure('Visible', 'off');
    for ch = 1:C
        Y = fft(sig(:, ch));
        Y = abs(Y(1:floor(N/2)+1));  % One-sided magnitude

        subplot(C, 1, ch);
        plot(f, Y);
        title(['Frequency Domain - Channel ', num2str(ch)]);
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        grid on;
    end

    sgtitle(['Frequency Domain - ', signalType]);
end