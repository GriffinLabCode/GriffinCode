%%
clear; clc

% downloaded location of github code
github_download_directory = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21';
addpath(github_download_directory);

% connect to netcom - pathName will be unique to your download location
pathName   = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21\NetComDevelopmentPackage_v3.1.0\MATLAB_M-files';
serverName = '192.168.3.100'; % server name can be found: cmd > ipconfig > IPv4
connect2netcom(pathName,serverName)

% open a stream to interface with Nlx objects - this is required
[succeeded, cheetahObjects, cheetahTypes] = NlxGetDASObjectsAndTypes; % gets cheetah objects and types

% define LFPs to use
LFP1name = 'CSC1';
LFP2name = 'CSC2';

% check various features of streaming - this includes srate checks
openStreamCheckStream(LFP1name,LFP2name);

for i = 1:50
tic;
% extract lfp data - note that this has to be sampled regularly to prevent
% a streaming disconnect
[succeeded1, dataArray1, timeStampArray1, channelNumberArray1, samplingFreqArray1, ...
    numValidSamplesArray1, numRecordsReturned1, numRecordsDropped1 ] = NlxGetNewCSCData(LFP1name);  
[succeeded2, dataArray2, timeStampArray2, channelNumberArray2, samplingFreqArray2, ...
    numValidSamplesArray2, numRecordsReturned2, numRecordsDropped2 ] = NlxGetNewCSCData(LFP2name);  

% get sampling rate
srate = double(mode(samplingFreqArray1));

% convert data to a double
dataArray1 = double(dataArray1);
dataArray2 = double(dataArray2);

% get timing
timing(i) = length(dataArray1)/srate;

% calculate coherence if the arrays are sampled at the same time
if timeStampArray1 == timeStampArray2
    [wcoh,wcs,f] = wcoherence(dataArray1,dataArray2,srate,'FrequencyLimits',[4 12]);
    success(i) = 1;
else
    success(i) = 0;
end
output(i) = toc;
pause(0.2)
end

% I've had success with this so long that pause(0.5), srate is 2000.
% Success with pause(0.25) srate = 2000; success with pause(0.2) srate =
% 2000; Ratio of 41:9 success to failure at pause(0.15) srate = 2000; Ratio
% of 46:4 success to failures at pause(0.175) srate = 2000; Ratio of 28:22
% success to failure at pause(0.1) srate = 2000; Interestingly, with a
% pause(0.1) and srate of 2000, my length of data in consideration is about
% 0.2560 sec. THerefore, I should loop this based on duration of timing.
% Once timing reaches above 0.256, then move on to the next loop. In this
% way, I will successfully take samples of 0.256 of data and be able to
% calculate coherence with low time lags. With a pause of 0.1, my time lags
% range from 0.006 to 0.02. So, by making the loop dependent on the length
% of the samples, i will better estimate time.
idx_success = find(success == 1);
idx_failure = find(success == 0);

% length of data in consideration
timing(idx_success)
timing(idx_failure)

% time it takes to run
output(idx_success)
output(idx_failure)

% remove path of github download directory
rmpath(github_download_directory);
