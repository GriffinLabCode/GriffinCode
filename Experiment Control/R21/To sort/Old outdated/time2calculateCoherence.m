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
amountOfData = .5; % seconds
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
params.fpass  = [5 12];

% define a looping time
loop_time = 10; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

% define for loop
looper = (loop_time*60)/amountOfData; % N minutes * 60sec/1min * (1 loop is about .250 ms of data)

% start with this variable set to zero, it tells the code whether to clear
% the stream
clearIt = 0;
for i = 1:looper
    
    tic;
    if i == 1
        
        % clear the stream
        clearStream(LFP1name,LFP2name);
        
    elseif clearIt == 1
        
        % clear the stream
        clearStream(LFP1name,LFP2name);
        
        % define it to zero
        clearIt = 0;
        
    end
    
    % get data
    pause(amountOfData); % pause for the amount of time you want to get data from
    try
        [succeeded, dataArray, timeStampArray, channelNumberArray, samplingFreqArray, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  
    catch
        clearIt = 1; % this is so the code knows to re-clear the stream so that we can control the sampling rate
        continue
    end
    
    % calculate coherence - chronux toolbox is way faster. Like sub 0.01
    % seconds sometimes, while wcoherence is around 0.05 sec.
    [coh,phase,~,~,~,freq] = coherencyc(dataArray(1,:),dataArray(2,:),params);
    
    % amount of data in consideration
    timings(i) = length(dataArray)/srate;
    
    % take averages
    coh_theta(i) = mean(coh);
    coh_phase(i) = mean(phase);
    outtoc(i) = toc;
    
    disp(['loop # ',num2str(i),'/',num2str(looper)])
    
end 

figure('color','w')
stem(coh_theta)
ylabel('Coherency')
xlabel('250ms increment')
title(['Theta (',num2str(params.fpass),'Hz)', ' with tapers ',num2str(params.tapers)])

figure('color','w')
plot((coh_theta),'k')
ylabel('Coherency')
xlabel('250ms increment')
title(['Theta (',num2str(params.fpass),'Hz)', ' with tapers ',num2str(params.tapers)])

figure('color','w')
stem(coh_theta(1:100))
ylabel('Coherency')
xlabel('250ms increment')
title(['Theta (',num2str(params.fpass),'Hz)', ' with tapers ',num2str(params.tapers)])

% remove the very first 2 events, they will be excluded anyway. They take
% too long bc of initializing stuff
outtoc(1:2)=[];
outtoc_ms = outtoc*1000; % to ms
figure('color','w');
histogram(outtoc_ms);
ylabel('Number of streaming events')
xlabel('Time (ms) to stream and calculate coherence')
box off
title(['Events streamed at a rate of ', num2str(amountOfData),' seconds'])

% remove path of github download directory
rmpath(github_download_directory);
