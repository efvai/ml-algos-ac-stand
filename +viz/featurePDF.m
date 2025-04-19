function fig = featurePDF(featureTbl, Y, featureName)
    % Check if feature exists
    if ~ismember(featureName, featureTbl.Properties.VariableNames)
        error('Feature "%s" not found in the table.', featureName);
    end

    % Extract feature data
    data = featureTbl.(featureName);

    % Get unique labels
    uniqueLabels = unique(Y);

    % Create figure
    fig = figure('Visible', 'off');
    hold on;

    colors = lines(numel(uniqueLabels));
    for i = 1:numel(uniqueLabels)
        label = uniqueLabels(i);
        idx = Y == label;
        labelData = data(idx);

        % Estimate PDF with kernel density
        [f, xi] = ksdensity(labelData);

        % Plot
        plot(xi, f, 'DisplayName', char(label), 'LineWidth', 2, 'Color', colors(i,:));
    end

    hold off;
    legend show;
    title(['PDF of ', featureName]);
    xlabel('Feature Value');
    ylabel('Density');
    grid on;
end