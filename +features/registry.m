function names = registry(signalType)
%FEATURES.REGISTRY Returns list of feature names by signal type
%
%   names = features.registry(signalType)
%
%   INPUT:
%       signalType - 'currents', 'vibro', or 'all' (optional)
%
%   OUTPUT:
%       names - Cell array of feature names

    if nargin < 1
        signalType = 'all';
    end

    % Define current features
    currentNames = {
        'Mean_A', 'Mean_B', ...
        'Std_A', 'Std_B', ...
        'RMS_A', 'RMS_B', ...
        'Skew_A', 'Skew_B', ...
        'Kurt_A', 'Kurt_B', ...
        'PTP_A', 'PTP_B', ...
        'Crest_A', 'Crest_B', ...
        'DominantFreq_A', 'DominantFreq_B', ...
        'SpecEnergy_A', 'SpecEnergy_B', ...
        'Centroid_A', 'Centroid_B', ...
        'Entropy_A', 'Entropy_B', ...
        'Corr_AB', 'RMS_VectorMag'
    };

    % Define vibration features (4 channels × 11 features)
    labels = {'Ch1', 'Ch2', 'Ch3', 'Ch4'};
    baseNames = {'Mean','Std','RMS','Skew','Kurt','PTP','Crest', ...
                 'DominantFreq','SpecEnergy','Centroid','Entropy'};

    vibroNames = {};
    for i = 1:numel(baseNames)
        for ch = 1:4
            vibroNames{end+1} = [baseNames{i}, '_', labels{ch}]; %#ok<AGROW>
        end
    end

    switch lower(signalType)
        case 'currents'
            names = currentNames;
        case 'vibro'
            names = vibroNames;
        case 'all'
            names = [currentNames, vibroNames];
        otherwise
            error('Unknown signal type: %s', signalType);
    end
end