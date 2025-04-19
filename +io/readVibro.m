function data = readCurrent(filePath)
%READCURRENTSIGNAL Read binary ADC current signal.
%
%   data = readCurrentSignal(filePath, numChannels)
%
%   Inputs:
%       - filePath: path to binary file
%
%   Outputs:
%       - data: [samples x channels] 

    % Read raw data using your base function
    data = io.readRaw(filePath, 4);
end
