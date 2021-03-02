%% get_realTimeCoherence
clear; clc

%% initialize

% define LFPs to use
LFP1name = 'CSC1';
LFP2name = 'CSC9';

% setup
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,0.25);

%% coherence detection

% for multitapers
params.tapers = [3 5];
params.Fs     = srate;
params.fpass  = [4 12];

% define a looping time
loop_time = 60*4; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

% define amount of data to collect
amountOfData = .25; % seconds

% define number of samples that correspond to the amount of data in time
numSamples2use = amountOfData*srate;

% define for loop
looper = (loop_time*60)/amountOfData; % N minutes * 60sec/1min * (1 loop is about .250 ms of data)

%% now add/remove time and calculate coherence
    
% get the data change as an output (ie sampling issue) can account for this
% later or in the online detet

% for loop start
coh_temp = [];
coh = [];
for i = 1:looper
    
    tic;
    % first get a chunk of data the run a moving window on
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
        
        % calculate og coherence
        coh_temp = [];
        coh_temp = coherencyc(dataArray(1,:),dataArray(2,:),params);
        coh(i)   = nanmean(coh_temp);
        
    else
        
    end

    % sometimes when collecting data, it will fail. But eventually, it will
    % collect the data successfully. It's not clear if the instance of
    % failing to collect the data results in lost data, or if its collected
    % later
    %{
    pause(0.25);
    next = 0;
    while next == 0
        try
            [~, dataArray_new, timeStampArray, ~, ~, ...
            numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  
            next = 1;
        catch
            [~, dataArray_new, timeStampArray, ~, ~, ...
            numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  
            next = 1;
        end  
    end
    %}
    
    % running this a ton of times until we get failures          
    pause(.25);
    [~, dataArray_new, timeStampArray, ~, ~, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

    % define number of samples for continuous updating
    numSamples2use = [];
    numSamples2use = size(dataArray_new,2);
    
    % remove number of samples from the start of signal
    dataArray(:,1:numSamples2use)=[];
    
    % add data to end of dataArray creating a moving window on real-time
    % data
    dataArray = horzcat(dataArray,dataArray_new);

    % calculate coherence - chronux toolbox is way faster. Like sub 0.01
    % seconds sometimes, while wcoherence is around 0.05 sec.
    %[coh(i+1),phase,~,~,~,freq] = coherencyc(dataArray(1,:),dataArray(2,:),params);
    coh_temp = [];
    coh_temp = coherencyc(dataArray(1,:),dataArray(2,:),params);
    coh(i+1) = nanmean(coh_temp);
    
    % amount of data in consideration
    timings(i) = length(dataArray)/srate;
    
    % take averages
    outtoc(i) = toc;
    
    disp(['loop # ',num2str(i),'/',num2str(looper)])

    % store timestamp array to check later
    timeStamps{i} = timeStampArray;
end

% check timestamps
for i = 1:length(timeStamps)
    
    if size(timeStamps{i},2) == 1
        disp(['0.25 sec ',num2str(i)])
        check = timeStamps{i}(1) ==  timeStamps{i}(2);
        if check == 0
            disp(['Error on event ',num2str(i)])
        end
    elseif size(timeStamps{i},2) == 2
        disp('Double time! = .5 sec')
        check1 = timeStamps{i}(1,1) == timeStamps{i}(2,1);
        check2 = timeStamps{i}(1,2) == timeStamps{i}(2,2);
        if check1 == 0 | check2 == 0
            error(['Error on event ',num2str(i)])
        end
    else
        disp('> double time (> .5 sec)?')
    end
    
end
figure('color','w');
stem(coh)
axis tight;
xlim([100 200])

% load in data_20min to keep working

% plot the histogram of coherence magnitudes
figure('color','w')
h_og = histogram(coh,'FaceColor',[.6 .6 .6]); hold on;
h_og.FaceColor = [.6 .6 .6];
% zscore coherence
zscoredCoh = zscore(coh);
% get 1 std
cohHighStd = coh(zscoredCoh > 1);
cohHighVal = coh(dsearchn(zscoredCoh',1));
% plot
h_highS = histogram(cohHighStd,'FaceColor',[0 .6 0]);
% get -1std
cohLowStd = coh(zscoredCoh < -1);
cohLowVal = coh(dsearchn(zscoredCoh',-1));
% plot
h_lowS = histogram(cohLowStd,'FaceColor','r');
box off;
legend(['All data'],['High Thresh. (1std = ',num2str(cohHighVal),')'],['Low Thresh. (-1std = ',num2str(cohLowVal),')'])
ylabel('Iteration')
xlabel('Coherence magnitude')

% histogram of coherence durations


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

figure('color','w')


% remove path of github download directory
rmpath(github_download_directory);

