function featuresVec = extractPark(data, Fs)

    if isempty(data) || size(data, 2) ~= 2
        warning("extractCurrent: Input must be Nx2 matrix (2-phase signal).");
        featuresVec = nan(1, 24);  % Expected feature count
        return;
    end
       
    ia = data(:,1);
    ib = data(:,2);

    % Clarke Transform
    alpha = ia;
    beta = (1/sqrt(3))*(ia + 2*ib);
    modulus = sqrt(alpha.^2 + beta.^2);

    % Basic modulus statistics
    fM = features.extractBasic(modulus, Fs);
    % Ellipse features
    try
        [ellipse, ~] = utils.fitEllipse(alpha, beta);
        ellipse_a = ellipse.a;
        ellipse_b = ellipse.b;
        ellipse_ratio = ellipse.b / ellipse.a;
        ellipse_eccentricity = sqrt(1 - (min(ellipse.a, ellipse.b)^2 / max(ellipse.a, ellipse.b)^2));
        ellipse_phi_deg = rad2deg(ellipse.phi);
        ellipse_offset = norm([ellipse.X0_in, ellipse.Y0_in]);
    catch
        % In case of fitting failure, fill NaNs
        ellipse_a = NaN;
        ellipse_b = NaN;
        ellipse_ratio = NaN;
        ellipse_eccentricity = NaN;
        ellipse_phi_deg = NaN;
        ellipse_offset = NaN;
    end

    featuresVec = [fM, ellipse_a, ellipse_b, ellipse_ratio, ellipse_eccentricity, ellipse_phi_deg, ellipse_offset];
end