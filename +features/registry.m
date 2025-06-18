function names = registry(signalType)
%FEATURES.REGISTRY Returns list of feature names by signal type or options
%
%   names = features.registry(signalType)
%   names = features.registry(regOptionsStruct)
%
%   INPUT:
%       signalType - string (legacy) OR struct with flags
%
%   OUTPUT:
%       names - Cell array of feature names

    if nargin < 1
        signalType = struct();  % Default to empty struct → all false
    end

    %% === Define Feature Name Templates ===
    timeFeatures = {'Mean','Std','RMS','Skew','Kurt','PTP','Crest'};
    freqFeatures = {'DominantFreq','SpecEnergy','Centroid','Entropy'};

    % New group: Advanced spectral + envelope features
    advancedSpectralFeatures = {
        'HF_Energy', ...
        'THD', ...
        'Sideband_1_Amp', ...
        'Sideband_2_Amp', ...
        'Envelope_Mean', ...
        'Envelope_Std'
    };

    %% === Handle struct input (preferred new style) ===
    if isstruct(signalType)
        opt = signalType;

        % === All options default to false ===
        defaultFlags = struct( ...
            'phaseA', false, ...
            'phaseB', false, ...
            'timeDomain', false, ...
            'freqDomain', false, ...
            'crossPhase', false, ...
            'park', false, ...
            'advancedSpectral', false, ...
            'vibroChannels', [] ...
        );

        % Merge user options (opt) with defaults
        flags = defaultFlags;
        userFields = fieldnames(opt);
        for i = 1:numel(userFields)
            if isfield(flags, userFields{i})
                flags.(userFields{i}) = opt.(userFields{i});
            end
        end

        names = {};

        %% === Currents: Time-Domain & Frequency-Domain ===
        if flags.timeDomain
            for i = 1:numel(timeFeatures)
                if flags.phaseA
                    names{end+1} = [timeFeatures{i}, '_A'];
                end
                if flags.phaseB
                    names{end+1} = [timeFeatures{i}, '_B'];
                end
            end
        end

        if flags.freqDomain
            for i = 1:numel(freqFeatures)
                if flags.phaseA
                    names{end+1} = [freqFeatures{i}, '_A'];
                end
                if flags.phaseB
                    names{end+1} = [freqFeatures{i}, '_B'];
                end
            end
        end

        %% === Advanced Spectral Features (new section) ===
        if flags.advancedSpectral
            for i = 1:numel(advancedSpectralFeatures)
                feat = advancedSpectralFeatures{i};
                if flags.phaseA
                    names{end+1} = [feat, '_A'];
                end
                if flags.phaseB
                    names{end+1} = [feat, '_B'];
                end
            end
        end

        %% === Cross-phase features ===
        if flags.crossPhase
            names{end+1} = 'Corr_AB';
            names{end+1} = 'RMS_VectorMag';
        end

        %% === Park Features ===
        if flags.park
            parkFields = {
                'Mean_P','Std_P','RMS_P','Skew_P','Kurt_P','PTP_P','Crest_P', ...
                'DominantFreq_P','SpecEnergy_P','Centroid_P','Entropy_P', ...
                'Ellipse_A', 'Ellipse_B', 'Ellipse_Ratio', 'Ellipse_Ecc', ...
                'Ellipse_PhiDeg', 'Ellipse_Offset'
            };
            names = [names, parkFields];
        end

        %% === Vibro Features ===
        vibroBase = [timeFeatures, freqFeatures];
        for i = 1:numel(vibroBase)
            for ch = flags.vibroChannels
                names{end+1} = sprintf('%s_Ch%d', vibroBase{i}, ch);
            end
        end

        return;  % Done with struct input
    end

    %% === Legacy string-based behavior ===
    switch lower(signalType)
        case 'currents'
            names = features.registry(struct( ...
                'phaseA', true, ...
                'phaseB', true, ...
                'timeDomain', true, ...
                'freqDomain', true, ...
                'advancedSpectral', true, ...
                'crossPhase', true, ...
                'park', true ...
            ));
        case 'vibro'
            names = features.registry(struct('vibroChannels', 1:4));
        case 'all'
            names = features.registry(struct( ...
                'phaseA', true, ...
                'phaseB', true, ...
                'timeDomain', true, ...
                'freqDomain', true, ...
                'advancedSpectral', true, ...
                'crossPhase', true, ...
                'park', true, ...
                'vibroChannels', 1:4 ...
            ));
        otherwise
            error('Unknown signal type: %s', signalType);
    end
end