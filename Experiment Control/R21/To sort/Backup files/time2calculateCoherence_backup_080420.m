%% testing times to calculate coherence
% What is the time that it takes matlab to read in, then calculate
% coherence?
%
% In order to replicate, please play the test_theta .WAV file through the
% signal mouse and acquire the data with cheetah.
%
% If you see a drastic drop in the first few samples of the graph, it's
% because the connect2netcom function starts and stops the acquisition
%
% JS - 8/4/20

%% initialize
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

% clear the working stream via netcom - funDur is a variable to track time
funDur.clearStream = clearStream(LFP1name,LFP2name);

% get data
amountOfData = .25; % seconds
pause(amountOfData); % pause for the amount of time you want to get data from
[succeeded, dataArray, timeStampArray, channelNumberArray, samplingFreqArray, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% get sampling rate - note that 'openStreamCheckStream' checks for
% inconsistencies in sampling rate between your two signals
srate = double(mode(samplingFreqArray(1,:)));

% get timing
timing(1,:) = length(dataArray(1,:))/srate;
timing(2,:) = length(dataArray(2,:))/srate;

%% coherence detection

% for multitapers
params.tapers = [2 3];
params.Fs     = srate;
params.fpass  = [4 12];

for i = 1:1000
    tic;
    if i == 1
    % clear the stream
    clearStream(LFP1name,LFP2name);
    else
    end
    
    % get data
    dataArray = [];
    pause(amountOfData); % pause for the amount of time you want to get data from
    [~,dataArray] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

    % calculate coherence - chronux toolbox is way faster. Like sub 0.01
    % seconds sometimes, while wcoherence is around 0.05 sec.
    tic
    [coh,phase,~,~,~,freq] = coherencyc(dataArray(1,:),dataArray(2,:),params);
    toc
    
    % time of data in consideration
    timings(i) = length(coh)/srate;
    
    % take averages
    coh_theta = mean(coh);
    coh_phase = mean(phase);
    outtoc(i) = toc;
end 

% remove the very first 2 events, they will be excluded anyway. They take
% too long bc of initializing stuff
outtoc(1:2)=[];
    
figure('color','w');
histogram(outtoc);
ylabel('Number of streaming events')
xlabel('Time (sec) to stream and calculate coherence')
box off

outtoc_ms = outtoc*1000; % to ms
figure('color','w');
histogram(outtoc_ms);
ylabel('Number of streaming events')
xlabel('Time (ms) to stream and calculate coherence')
box off

    
    



% remove path of github download directory
rmpath(github_download_directory);
