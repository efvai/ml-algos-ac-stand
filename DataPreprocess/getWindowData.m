function [segment, tSegment] = getWindowData(files, windowRef, Fs)
%GETWINDOWDATA Extract a data segment from signal given time interval and file index
%
%   [segment, tSegment] = getWindowData(files, {"16.50 - 17.50 s", 1}, Fs)
%
%   Inputs:
%       files      - table with FilePath
%       windowRef  - cell array: {timeIntervalStr, fileIndex}
%       Fs         - sampling rate (Hz)
%
%   Outputs:
%       segment    - [samples x channels] signal in the time window
%       tSegment   - corresponding time vector in seconds

    if nargin < 3
        Fs = 10000;  % Default sampling rate
    end

    % === Extract components from windowRef cell array ===
    timeIntervalStr = windowRef{1};
    fileIndex = windowRef{2};

    % === Parse time interval string ===
    tokens = regexp(timeIntervalStr, '([\d.]+)\s*-\s*([\d.]+)', 'tokens');
    if isempty(tokens)
        error('Invalid time interval format: %s', timeIntervalStr);
    end
    tStart = str2double(tokens{1}{1});
    tEnd   = str2double(tokens{1}{2});

    % === Convert to sample indices ===
    startSample = floor(tStart * Fs) + 1;
    endSample   = floor(tEnd * Fs);

    % === Load signal ===
    filePath = files.FilePath{fileIndex};
    [data, ~] = readCurrentSignal(filePath, 2, Fs);

    % === Handle edge case: window longer than signal ===
    if endSample > size(data,1)
        warning('Requested time window exceeds file length. Truncating.');
        endSample = size(data,1);
    end

    % === Extract segment ===
    segment = data(startSample:endSample, :);

    % === Remove outliers === 
    segment = filloutliers(segment,"linear","movmedian",400);

    tSegment = (startSample:endSample)' / Fs;
end