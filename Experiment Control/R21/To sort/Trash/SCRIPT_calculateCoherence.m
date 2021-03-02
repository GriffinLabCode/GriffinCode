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

% check various features of streaming - this includes srate checks
openStreamCheckStream(LFP1name,LFP2name);


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

% calculate coherence
[wcoh,wcs,f] = wcoherence(dataArray1,dataArray2,srate,'FrequencyLimits',[4 12]);
toc;

% remove path of github download directory
rmpath(github_download_directory);
