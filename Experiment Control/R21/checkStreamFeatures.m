%%
clear; clc

% downloaded location of github code
github_download_directory = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21';
addpath(github_download_directory);

% connect to netcom
pathName   = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21\NetComDevelopmentPackage_v3.1.0\MATLAB_M-files';
serverName = '192.168.3.100';
connect2netcom(pathName,serverName)

% open a stream to interface with Nlx objects - this is required
[succeeded, cheetahObjects, cheetahTypes] = NlxGetDASObjectsAndTypes; % gets cheetah objects and types

% define LFPs to use
LFP1name = 'CSC1';
LFP2name = 'CSC2';

% -- to save time, this first chunk will be a 'check' on various features -- %

% open a stream to extract LFP data
succeeded_LFP1 = NlxOpenStream(LFP1name);
succeeded_LFP2 = NlxOpenStream(LFP2name);
if succeeded_LFP1 == 1 && succeeded_LFP2 == 1 % this is a check point
    disp(['Successfully opened a stream with ', LFP1name, ' and ', LFP2name])
end

% extract lfp data - note that this has to be sampled regularly to prevent
% a streaming disconnect
[succeeded1, dataArray1, timeStampArray1, channelNumberArray1, samplingFreqArray1, ...
    numValidSamplesArray1, numRecordsReturned1, numRecordsDropped1 ] = NlxGetNewCSCData(LFP1name);  
[succeeded2, dataArray2, timeStampArray2, channelNumberArray2, samplingFreqArray2, ...
    numValidSamplesArray2, numRecordsReturned2, numRecordsDropped2 ] = NlxGetNewCSCData(LFP2name);  

% check 2 - check that the timestamps and sizes are identical
sizeCheck = length(dataArray1) == length(dataArray2);   % the lengths of these vectors should be identical
timeCheck = find((timeStampArray1-timeStampArray2)~=0); % the difference between timestamps should all be zero (ie identical timestamps)
if sizeCheck == 1 && timeCheck == 0
    disp('Data sampled at the same time')
else
    disp('Error in the sampling of data - data not being sampled simultaneously')
    return
end

% get sampling rate
srate = double(mode(samplingFreqArray1));

% check 3
srateCheck = double(mode(samplingFreqArray1)) == double(mode(samplingFreqArray2));
if srateCheck == 0
    disp('Defined CSCs are not sampled at the same rate')
    return
end
    
[wcoh,wcs,f] = wcoherence(x,y,fs)

% remove path of github download directory
rmpath(github_download_directory);
