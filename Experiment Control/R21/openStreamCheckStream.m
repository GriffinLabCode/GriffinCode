%% openStreamCheckStream
% Designed as an extra precaution to check various features of the
% streaming and acquisition of real-time data.
%
% this code checks:
%   1) That streaming is open
%   2) That CSC data streaming is function
%   3) That CSC data streaming is occuring at an almost identical time
%   4) That the sampling rate is identical between CSCs
%
% Note: Sampling rate was considered by taking the mode, therefore if
% fluctuations occur (which they shouldn't), it would not be accounted for.
%
% In 3) note that I mentioned its almost identical in time. The two signals
% are almost perfectly identical, with about perfect correlations (see
% checkLFPsamples.m). The reason it is 'almost identical' is because the
% voltage can fluctuate at a microscopic scale. This is not something that
% we can get around as of yet, and as you will see by running
% checkLFPsamples.m, it's not something worth worrying over.
%
% INPUTS: 
% LFP1name and LFP2name: The names (as a string variable) of the CSC
%                         channels that you want to open. Note that these
%                         have to be similarly found in the cheetahObjects
%                         variable.
%
% written by John Stout - 7/31/2020

function [] = openStreamCheckStream(LFP1name,LFP2name)

% -- to save time, this first chunk will be a 'check' on various features -- %

% open a stream to extract LFP data
succeeded_LFP1 = NlxOpenStream(LFP1name);
succeeded_LFP2 = NlxOpenStream(LFP2name);
if succeeded_LFP1 == 1 && succeeded_LFP2 == 1 % this is a check point
    disp(['Successfully opened a stream with ', LFP1name, ' and ', LFP2name])
else
    disp(['Failed to opened a stream with ', LFP1name, ' and ', LFP2name])    
end

% extract lfp data - note that this has to be sampled regularly to prevent
% a streaming disconnect
[succeeded, dataArray, timeStampArray, channelNumberArray, samplingFreqArray, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% check 2 - check that data is being opened
if succeeded(1) == 1 && succeeded(2) == 1
    disp('CSC real-time acquisition up and running!');
end
    
% check 3 - check that the timestamps and sizes are identical
sizeCheck = length(dataArray(1,:)) == length(dataArray(2,:));   % the lengths of these vectors should be identical
timeCheck = isempty(find((timeStampArray(1,:)-timeStampArray(2,:))~=0)); % the difference between timestamps should all be zero (ie identical timestamps)
if sizeCheck == 0 && timeCheck == 0
    disp('Error in the sampling of data - data not being sampled simultaneously')
    return
else
end

% get sampling rate - this should only require one signal because the data
% should all be sampled at the same rate
srate = double(mode(samplingFreqArray(1,:)));

% check 4 - in the case where your lfp is not sampled at the same rate
srateCheck = double(mode(samplingFreqArray(1,:))) == double(mode(samplingFreqArray(2,:)));
if srateCheck == 0
    disp('Defined CSCs are not sampled at the same rate')
    return
end

end
