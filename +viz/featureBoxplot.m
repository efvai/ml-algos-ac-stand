function fig = featureBoxplot(featureTbl, Y, featureName)
    % Check if feature exists
    if ~ismember(featureName, featureTbl.Properties.VariableNames)
        error('Feature "%s" not found in the table.', featureName);
    end

    % Extract data
    data = featureTbl.(featureName);

    % Create figure
    fig = figure('Visible', 'off');
    boxplot(data, Y);
    title(['Boxplot of ', featureName]);
    xlabel('Label');
    ylabel('Feature Value');
    grid on;
end