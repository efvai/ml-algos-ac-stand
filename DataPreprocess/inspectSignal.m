function inspectSignal(signal, Fs, titleStr)
%INSPECTSIGNAL Plot time-domain and frequency-domain (FFT) of a signal.
%
%   signal   - N x 1 or N x 2 matrix (1 or 2 channels)
%   Fs       - Sampling frequency (Hz)
%   titleStr - Optional title for the plot window

    if nargin < 3
        titleStr = 'Signal Inspection';
    end

    t = (0:length(signal)-1) / Fs;

    % Plot Time-Domain
    figure('Name', titleStr, 'NumberTitle', 'off');
    subplot(2, 1, 1);
    if size(signal, 2) == 1
        plot(t, signal);
        legend('Signal');
    else
        plot(t, signal(:,1), 'b', t, signal(:,2), 'r');
        legend('Phase A', 'Phase B');
    end
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Time-Domain Signal');
    grid on;

    % Plot Frequency-Domain (FFT)
    subplot(2, 1, 2);
    N = length(signal);
    if size(signal, 2) == 1
        Y = fft(signal);
    else
        Y = fft(signal(:,1));  % Just first channel for quick inspection
    end
    P2 = abs(Y / N);
    P1 = P2(1:floor(N/2)+1);
    P1(2:end-1) = 2 * P1(2:end-1);  % Single-sided spectrum

    f = Fs * (0:(length(P1)-1)) / N;

    plot(f, P1);
    xlabel('Frequency (Hz)');
    ylabel('|Amplitude|');
    title('Frequency-Domain (FFT)');
    grid on;
    xlim([0 Fs/2]);  % Up to Nyquist
end
