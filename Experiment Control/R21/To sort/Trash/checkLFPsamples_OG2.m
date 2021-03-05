%% testing if lfp is sampled at the same time
% using NlxGetNewCSCData back to back could sample things at the same time,
% or it could have a small offset. This code was designed to answer that
% question.
%
% In order to replicate, please play the test_theta .WAV file through the
% signal mouse and acquire the data with cheetah.
%
% JS - 8/4/20

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

% check various features of streaming - this includes srate checks.
% Sometimes, when this is initially run, you'll get errors
openStreamCheckStream(LFP1name,LFP2name);

%{
% extract lfp data - note that this has to be sampled regularly to prevent
% a streaming disconnect
[succeeded1, dataArray1, timeStampArray1, channelNumberArray1, samplingFreqArray1, ...
    numValidSamplesArray1, numRecordsReturned1, numRecordsDropped1 ] = NlxGetNewCSCData(LFP1name);  
[succeeded2, dataArray2, timeStampArray2, channelNumberArray2, samplingFreqArray2, ...
    numValidSamplesArray2, numRecordsReturned2, numRecordsDropped2 ] = NlxGetNewCSCData(LFP2name);  
%}

% extract lfp data - this is condensed to save time processing. FUture code
% may have to have a function that effectively clears the signal before it.
% Or maybe the for loop will work fine.
clearStream(LFP1name,LFP2name);
pause(1); % this pause function makes it so NlxGetNewCSCData function only extracts the amount of time you pause for. BUT this only works if you recently called the data in to work with
[succeeded, dataArray, timeStampArray, channelNumberArray, samplingFreqArray, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% get sampling rate - note that 'openStreamCheckStream' checks for
% inconsistencies in sampling rate between your two signals
srate = double(mode(samplingFreqArray(1,:)));

% get timing
timing(1,:) = length(dataArray(1,:))/srate;
timing(2,:) = length(dataArray(2,:))/srate;

% because this data is being fed via signal mouse, the lfp should be
% identical
figure(); 
subplot 311; plot(dataArray(1,:),'k'); title([LFP1name]); axis tight;
subplot 312; plot(dataArray(2,:),'r'); title([LFP2name]); axis tight; ylabel('Voltage')
subplot 313; plot(dataArray(1,:),'k','LineWidth',3); hold on; plot(dataArray(2,:),'r','LineWidth',1); title([LFP2name,' overlayed on thickened ', LFP1name]); axis tight;
xlabel('Samples')

% orignially, I assumed that all values should be zero becuase they're
% being sampled at the same time. However, even microsecond fluctuations in
% sampling would cause microscale changes in the voltage. Therefore, while
% its not 100% perfect, the overlap in signals is incredibly close. Due to
% this, I modified the NlxGetNewCSCData function to pull two signals in
% closer proximity in time.
lfpDifference   = dataArray(2,:)-dataArray(1,:);

% To further prove this point, the two arrays are perfectly correlated in
% time.
[r,p]=corrcoef(dataArray(1,:),dataArray(2,:));
figure()
scatter(dataArray(1,:),dataArray(2,:),'m')
l1 = lsline;
l1.Color = 'k';
l1.LineWidth = 2;
xlabel(['Voltage from ',LFP1name])
ylabel(['Voltage from ',LFP2name])
xlimits = xlim;
ylimits = ylim;
text(xlimits(2)/6,ylimits(1)/2,['Pearsons R = ', num2str(r(2)), '; p = ',num2str(p(2))])

% try filtering

% remove path of github download directory
rmpath(github_download_directory);
