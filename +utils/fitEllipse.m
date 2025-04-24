function [ellipse_t, ellipse_xy] = fitEllipse(x, y)
    % Fit an ellipse to (x, y) points using least-squares method

    % Normalize data
    x = x(:);
    y = y(:);

    D = [x.^2, x.*y, y.^2, x, y, ones(size(x))];
    S = D' * D;
    C = zeros(6);
    C(1,3) = -2;
    C(2,2) = 1;
    C(3,1) = -2;

    [evec, eval] = eig(S, C);
    [~, idx] = find(real(diag(eval)) > 0 & isfinite(diag(eval)));
    a = real(evec(:, idx));

    % Extract ellipse parameters
    [X0, Y0, a_len, b_len, phi] = ellipse_params(a);
    theta = linspace(0, 2*pi, 500);
    ellipse_x = X0 + a_len * cos(theta) * cos(phi) - b_len * sin(theta) * sin(phi);
    ellipse_y = Y0 + a_len * cos(theta) * sin(phi) + b_len * sin(theta) * cos(phi);

    ellipse_t.X0_in = X0;
    ellipse_t.Y0_in = Y0;
    ellipse_t.a = a_len;
    ellipse_t.b = b_len;
    ellipse_t.phi = phi;

    ellipse_xy = [ellipse_x; ellipse_y];
end

function [X0, Y0, a, b, phi] = ellipse_params(coeff)
    % Convert conic coefficients to ellipse parameters

    A = coeff(1);
    B = coeff(2);
    C = coeff(3);
    D = coeff(4);
    E = coeff(5);
    F = coeff(6);

    delta = B^2 - 4*A*C;
    if delta >= 0
        error('Not an ellipse');
    end

    X0 = (2*C*D - B*E) / delta;
    Y0 = (2*A*E - B*D) / delta;

    numerator = 2*(A*E^2 + C*D^2 + F*B^2 - 2*B*D*E - A*C*F);
    denominator1 = (B^2 - A*C) * ((C - A)*sqrt(1 + 4*B^2 / (A - C)^2) - (C + A));
    denominator2 = (B^2 - A*C) * ((A - C)*sqrt(1 + 4*B^2 / (A - C)^2) - (C + A));

    a = sqrt(numerator / denominator1);
    b = sqrt(numerator / denominator2);

    phi = 0.5 * atan2(B, A - C);
end