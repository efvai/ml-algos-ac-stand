function data = readCurrent(filePath)
%READCURRENTSIGNAL Read binary ADC current signal
%
%   data = readCurrentSignal(filePath, numChannels)
%
%   Inputs:
%       - filePath: path to binary file
%
%   Outputs:
%       - data: [samples x channels] with fixed ADC offset removed

    ADC_OFFSET = 2.5;

    % Read raw data using base function
    rawData = io.readRaw(filePath, 2);
    
    % Removing offset
    %data = rawData - ADC_OFFSET;
    data = rawData - mean(rawData);

    % 2. Подавление выбросов
    signal_medfilt = medfilt1(data, 21);
    residual = data - signal_medfilt;
    mad_val = median(abs(residual - median(residual)));
    threshold = 5 * mad_val;
    is_outlier = abs(residual) > threshold;
    
    % Интерполяция выбросов
    outlier_pos = find(is_outlier);
    valid_pos = find(~is_outlier);
    signal_clean = data;
    if ~isempty(outlier_pos)
        signal_clean(outlier_pos) = interp1(valid_pos, data(valid_pos), outlier_pos, 'pchip');
    end

    data = signal_clean;
end
