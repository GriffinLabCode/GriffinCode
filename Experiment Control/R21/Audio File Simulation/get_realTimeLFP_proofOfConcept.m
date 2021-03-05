%% get_realTimeCoherence

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
LFP2name = 'CSC9';

% sometimes you'll get an error here, still trying to figure out why. It
% has something to due with the duration of sampling.

% check various features of streaming - this includes srate checks.
% Sometimes, when this is initially run, you'll get errors. THis is
% probably related to the amount of data being streamed.
try
    openStreamCheckStream(LFP1name,LFP2name);
catch
    pause(2) % adding this pause helps get data. Sometimes you'll get an error bc youre streaming too quickly without enough data
    openStreamCheckStream(LFP1name,LFP2name);
end

% clear the working stream via netcom - funDur is a variable to track time
funDur.clearStream = clearStream(LFP1name,LFP2name);

% get data - note that in the theta range of 4-12hz, .25 seconds gets you
% 1-3cycles. Thats not a whole lot of theta cycles to detect coherence and
% may induce high coherence due to low number of cycles. Therefore,
% consider using .5-1 per event, then using a threshold of 1 event being
% high coherence. We need to test the distribution of coherence events.
% Therefore, acquire data and calculate coherence using this script, then
% open SCRIPT_determining_threshold to plot the results. Note that if the
% sampling event exceeds .5, doubling to 1 or adding a multiple of 4 to
% .75seconds, its okay because coherence has been high for a while. Its
% just a confound. Sometimes, this jump in sampling occurs.
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
params.tapers = [3 5];
params.Fs     = srate;
params.fpass  = [4 12];

% define a looping time
loop_time = .5; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

% define amount of data to collect
amountOfData = .25; % seconds

% define number of samples that correspond to the amount of data in time
numSamples2use = amountOfData*srate;

% define for loop
looper = (loop_time*60)/amountOfData; % N minutes * 60sec/1min * (1 loop is about .250 ms of data)

%% initial
% start with this variable set to zero, it tells the code whether to clear
% the stream
clearIt = 0;

%% now add/remove time and calculate coherence
    
% for loop start

for i = 1:looper
    
    if i == 1
        % clear the stream
        clearStream(LFP1name,LFP2name);

        % get data
        pause(2); % grab one sec of data if this is the first loop
        try
            [succeeded, dataArray, timeStampArray, channelNumberArray, samplingFreqArray, ...
            numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  
        catch
        end  
        figure(); subplot 211; plot(dataArray(1,:),'b');
    else
        figure(); subplot 211; plot(dataArray(1,:),'b');
    end

    % now collect .25sec, remove the initial .25sec
    %clearStream(LFP1name,LFP2name);  % we may not need to do this
    pause(0.25)
    [~, dataArray_new, timeStampArray, ~, ~, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

    % define number of samples for continuous updating
    numSamples2use = [];
    numSamples2use = size(dataArray_new,2);
    
    % remove number of samples
    dataArray(:,1:numSamples2use)=[];
    
    % add data to end of dataArray
    dataArray = horzcat(dataArray,dataArray_new);
    
    subplot 212; plot(dataArray(1,:),'b');

    pause()
end

