function fig = windowFreqDomain(row)
    % Extract signal and sampling rate
    % Extract current features
    if ismember('currents', row.Properties.VariableNames)
        sig = row.currents{1};   % [N x C]
    end

    % Extract vibration features
    if ismember('vibro', row.Properties.VariableNames)
        sig = row.vibro{1};   % [N x C]
    end
    Fs = row.meta.Fs;        % Scalar
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

    sgtitle('Frequency Domain Signal');
end