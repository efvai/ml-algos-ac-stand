function score = monotonicity(data)

    % Ensure input is a column vector
    data = data(:);

    n = length(data);

    if n < 2
        warning('Not a vector. Returning NaN')
        score = NaN;
        return;
    end

    diffs = diff(data);
    signs = sign(diffs);
    net_direction = sum(signs);

    % Normalized in [-1; 1]
    score = net_direction / (n - 1);
end

