function fig = featureScatter(featureTbl, Y, featureName)
    if ~ismember(featureName, featureTbl.Properties.VariableNames)
        error('Feature "%s" not found in the table.', featureName);
    end

    % Extract feature data
    data = featureTbl.(featureName);
    
    % Ensure Y is categorical for consistent grouping
    if ~iscategorical(Y)
        Y = categorical(Y);
    end

    % Sort data by label for grouped plotting
    [Y_sorted, sortIdx] = sort(Y);
    data_sorted = data(sortIdx);

    % Create figure
    fig = figure('Visible', 'off');
    hold on;

    % Plot points with different colors per label
    uniqueLabels = categories(Y_sorted);
    colors = lines(numel(uniqueLabels));

    startIdx = 1;
    for i = 1:numel(uniqueLabels)
        label = uniqueLabels{i};
        labelIdx = Y_sorted == label;
        numPoints = sum(labelIdx);
        x = startIdx:(startIdx + numPoints - 1);
        y = data_sorted(labelIdx);

        scatter(x, y, 20, ...
            'MarkerEdgeColor', colors(i,:), ...
            'MarkerFaceColor', colors(i,:), ...
            'DisplayName', label, ...
            'MarkerFaceAlpha', 0.6, ...
            'MarkerEdgeAlpha', 0.8);
        
        startIdx = startIdx + numPoints;
    end

    hold off;
    xlabel('Sample Index (Grouped by Label)');
    ylabel(['Value of ', strrep(featureName, '_', '\_')]);
    title(['Feature: ', strrep(featureName, '_', '\_')]);
    legend('show');
    grid on;
end