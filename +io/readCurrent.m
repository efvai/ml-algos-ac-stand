function data = readCurrent(filePath)
%READCURRENTSIGNAL Read binary ADC current signal and remove fixed offset.
%
%   data = readCurrentSignal(filePath, numChannels)
%
%   Inputs:
%       - filePath: path to binary file
%
%   Outputs:
%       - data: [samples x channels] with fixed ADC offset removed

    % === Constant ADC offset (e.g., 2.5V for 0–5V unipolar ADC) ===
    ADC_OFFSET = 2.5;

    % Read raw data using your base function
    rawData = io.readRaw(filePath, 2);

    % Subtract fixed offset from all channels
    data = rawData - ADC_OFFSET;

    %data = filloutliers(data,"linear","percentiles",[10 90]);
end
