function [windows, timeIntervals] = windows(data, fs, duration, overlap)
%WINDOWS Splits signal into overlapping time windows.
%
%   [windows, timeIntervals] = windows(data, fs, duration, overlap)
%
%   Inputs:
%       data        - NxM matrix of signal data (N samples, M channels)
%       fs          - Sampling frequency in Hz
%       duration    - Duration of each window in seconds
%       overlap     - Overlap between windows in percent (0–100)
%
%   Outputs:
%       windows         - Cell array of windows, each of size (windowSize x M)
%       timeIntervals   - Nx2 matrix of time intervals [startTime, endTime] (in seconds)
%
%   Example:
%       [w, t] = windows(signal, 1000, 0.5, 50);
%       % Returns 0.5s windows with 50% overlap at 1kHz sampling rate

    % Compute sizes
    windowSize = round(fs * duration);
    overlapFraction = overlap / 100;
    stepSize = round(windowSize * (1 - overlapFraction));

    N = size(data, 1); % Total samples
    numWindows = floor((N - windowSize) / stepSize) + 1;

    % Preallocate
    windows = cell(numWindows, 1);
    timeIntervals = zeros(numWindows, 2);

    for i = 1:numWindows
        startIdx = (i - 1) * stepSize + 1;
        stopIdx = startIdx + windowSize - 1;

        windows{i} = data(startIdx:stopIdx, :);
        timeIntervals(i, :) = [(startIdx - 1) / fs, (stopIdx - 1) / fs]; % in seconds
    end
end