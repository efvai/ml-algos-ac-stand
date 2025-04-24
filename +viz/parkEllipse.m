function [hFig, result] = parkEllipse(sigTableRow)
% Analyze Park Vector and Clarke Ellipse from a row of sigTable
% Returns:
%   hFig   : Figure handle (with 4 subplots)
%   result : Struct with ellipse parameters, eccentricity, etc.

    % === Extract data ===
    currents = sigTableRow.currents{1};  % Nx2 double
    Fs       = sigTableRow.meta.Fs;      % scalar

    % Phase currents
    ia = currents(:,1);
    ib = currents(:,2);
    ic = -ia - ib;  % Reconstruct third phase (balanced)

    % Clarke transform
    alpha = ia;
    beta = (1/sqrt(3)) * (ia + 2*ib);

    % Park vector modulus
    modulus = sqrt(alpha.^2 + beta.^2);

    % Time vector
    N = length(ia);
    t = (0:N-1) / Fs;

    % === Fit Ellipse ===
    [ellipse_params, ellipse_xy] = utils.fitEllipse(alpha, beta);
    a = ellipse_params.a;
    b = ellipse_params.b;
    ecc = sqrt(1 - (min(a, b)^2 / max(a, b)^2));

    % === Frequency Domain (FFT) of modulus ===
    Y = fft(modulus);
    P2 = abs(Y / N);              % Normalize
    P1 = P2(1:floor(N/2)+1);      % One-sided spectrum
    P1(2:end-1) = 2 * P1(2:end-1);  % Double non-DC/Nyquist

    f = Fs * (0:(N/2)) / N;       % Frequency vector (one-sided)

    % === Output struct ===
    result = struct();
    result.ellipse_params = ellipse_params;
    result.eccentricity   = ecc;
    result.modulus        = modulus;
    result.time           = t;
    result.freq           = f;
    result.modulus_fft    = P1;

    % === Create Figure (4 subplots) ===
    hFig = figure('Visible','off'); % Set to 'on' to show by default

    % Subplot 1: Phase currents
    subplot(4,1,1);
    plot(t, ia, t, ib, t, ic, 'LineWidth', 1.2);
    title('Phase Currents');
    xlabel('Time (s)');
    ylabel('Current (A)');
    legend('i_a','i_b','i_c');
    grid on;

    % Subplot 2: Clarke ellipse
    subplot(4,1,2);
    plot(alpha, beta, 'b.'); hold on;
    plot(ellipse_xy(1,:), ellipse_xy(2,:), 'r-', 'LineWidth', 2);
    title('Clarke Vector Trajectory (\alpha-\beta)');
    xlabel('\alpha');
    ylabel('\beta');
    axis equal;
    grid on;

    % Subplot 3: Modulus (Time Domain)
    subplot(4,1,3);
    plot(t, modulus, 'k', 'LineWidth', 1.2);
    title('Park Vector Modulus (Time Domain)');
    xlabel('Time (s)');
    ylabel('|Vector|');
    grid on;

    % Subplot 4: Modulus (Frequency Domain)
    subplot(4,1,4);
    semilogy(f, P1 + eps, 'k', 'LineWidth', 1.2);  % Add eps to avoid log(0)
    title('Park Vector Modulus Spectrum');
    xlabel('Frequency (Hz)');
    ylabel('|FFT|');
    xlim([0 Fs/2]);
    grid on;

    % Show figure
    set(hFig, 'Visible', 'on');  % Set to 'off' for batch processing
end