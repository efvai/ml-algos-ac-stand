function fig = windowTimeDomain(row)
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

    % Time vector
    t = (0:N-1) / Fs;

    % Create figure
    fig = figure('Visible', 'off');
    for ch = 1:C
        subplot(C, 1, ch);
        plot(t, sig(:, ch));
        title(['Time Domain - Channel ', num2str(ch)]);
        xlabel('Time (s)');
        ylabel('Amplitude');
        grid on;
    end

    sgtitle('Time Domain Signal');
end