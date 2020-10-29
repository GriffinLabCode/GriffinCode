%% getLFPsrate
% this function provides an alternative method to calculate lfp srate if
% you don't have the SampleFrequencies variable
%
% -- INPUTS -- %
% Timestamps: raw format, NOT converted vector!
% Samples: raw format, MUST be a matrix
%
% -- OUTPUTS -- %
% srate: lfp sampling rate (samples/sec)
%
% written by John Stout

function [srate] = getLFPsrate(Timestamps,Samples)

% check size to make sure you input things correctly
checkSize = size(Samples);
if checkSize(1) == 1 | checkSize(2) == 1 % check to make sure you didn't input a vector
    error(['ERROR: Please input RAW Samples and Timestamps variables. Do NOT convert to vectors. '...
        newline 'Also make sure your Timestamps variable is the FIRST input to getLFPsrate'])
end

% calculate and define the sampling rate
totalTime  = (Timestamps(2)-Timestamps(1))/1e6; % this is the time between valid samples
numValSam  = size(Samples,1);     % this is the number of valid samples (512)
srate      = round(numValSam/totalTime); % this is the sampling rate

