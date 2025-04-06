function [data, timeVector] = readCurrentSignal(filePath, numChannels, samplingRate)
%READCURRENTSIGNAL Read binary ADC current signal and remove fixed offset.
%
%   [data, timeVector] = readCurrentSignal(filePath, numChannels, samplingRate)
%
%   Inputs:
%       - filePath: path to binary file
%       - numChannels: number of ADC channels in the file
%       - samplingRate: sampling frequency in Hz
%
%   Outputs:
%       - data: [samples x channels] with fixed ADC offset removed
%       - timeVector: time vector in seconds

    % === Constant ADC offset (e.g., 2.5V for 0–5V unipolar ADC) ===
    ADC_OFFSET = 2.5;

    % Read raw data using your base function
    [rawData, timeVector] = readBinarySignal(filePath, numChannels, samplingRate);

    % Subtract fixed offset from all channels
    data = rawData - ADC_OFFSET;
end
