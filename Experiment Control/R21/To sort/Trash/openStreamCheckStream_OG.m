%% openStreamCheckStream
% Designed as an extra precaution to check various features of the
% streaming and acquisition of real-time data.
%
% this code checks:
%   1) That streaming is open
%   2) That CSC data streaming is function
%   3) That CSC data streaming is occuring at the exact same time
%   4) That the sampling rate is identical between CSCs
%
% Note: Sampling rate was considered by taking the mode, therefore if
% fluctuations occur (which they shouldn't), it would not be accounted for.
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
[succeeded1, dataArray1, timeStampArray1, channelNumberArray1, samplingFreqArray1, ...
    numValidSamplesArray1, numRecordsReturned1, numRecordsDropped1 ] = NlxGetNewCSCData(LFP1name);  
[succeeded2, dataArray2, timeStampArray2, channelNumberArray2, samplingFreqArray2, ...
    numValidSamplesArray2, numRecordsReturned2, numRecordsDropped2 ] = NlxGetNewCSCData(LFP2name);  

% check 2 - check that data is being opened
if succeeded1 == 1 && succeeded2 == 1
    disp('CSC real-time acquisition up and running!');
end
    
% check 3 - check that the timestamps and sizes are identical
sizeCheck = length(dataArray1) == length(dataArray2);   % the lengths of these vectors should be identical
timeCheck = isempty(find((timeStampArray1-timeStampArray2)~=0)); % the difference between timestamps should all be zero (ie identical timestamps)
if sizeCheck == 0 && timeCheck == 0
    disp('Error in the sampling of data - data not being sampled simultaneously')
    return
end

% get sampling rate
srate = double(mode(samplingFreqArray1));

% check 4
srateCheck = double(mode(samplingFreqArray1)) == double(mode(samplingFreqArray2));
if srateCheck == 0
    disp('Defined CSCs are not sampled at the same rate')
    return
end

end
