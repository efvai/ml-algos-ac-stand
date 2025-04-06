function [data, timeVector] = readBinarySignal(filePath, numChannels, samplingRate)
% readBinarySignal Reads interleaved multi-channel ADC data from binary file
%   [data, timeVector] = readBinarySignal(filePath, numChannels, samplingRate)
%
%   Inputs:
%       - filePath: path to the binary file
%       - numChannels: number of channels in the file (e.g. 2 or 4)
%       - samplingRate: sampling rate in Hz (e.g. 10000 or 26041)
%
%   Outputs:
%       - data: [channels x samples] matrix of raw data
%       - timeVector: corresponding time vector in seconds

    % === Open and Read File ===
    fileId = fopen(filePath, 'rb');
    if fileId == -1
        error('Could not open file: %s', filePath);
    end

    rawData = fread(fileId, 'double');  % Read as 64-bit floats
    fclose(fileId);

    % === Data Reshaping ===
    totalSamples = floor(length(rawData) / numChannels);
    rawData = rawData(1:totalSamples * numChannels);  % Trim excess if needed
    % Reshape to [samples x channels]
    data = reshape(rawData, [numChannels, totalSamples])';
    %                                                   ^ transpose to [samples x channels]

    % === Time Vector ===
    timeVector = linspace(0, totalSamples / samplingRate, totalSamples);
end
