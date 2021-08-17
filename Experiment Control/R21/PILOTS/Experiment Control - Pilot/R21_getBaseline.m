%% get_baseline
% this code is designed to assign threshold variable
%
% -- INPUTS -- %
% LFP1name:
% LFP2name:
% amountOfData: specified in seconds. Use 0.25 for .25 sec
% amountOfTime: how much time do you want this code to be run on? Try 10 for
%               10 minutes
%
% -- OUTPUTS -- %
% threshold: coherence thresholds
%
% written by John Stout 
% last edit 1/19/21

function [threshold] = R21_getBaseline(LFP1name,LFP2name,amountOfData,amountOfTime)

% setup
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,0.25);

%% coherence detection

% for multitapers
params.tapers = [3 5]; 
params.Fs     = srate;
params.fpass  = [4 12];

% define a looping time
%loop_time = 60*amountOfTime; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

% define amount of data to collect
%amountOfData = .25; % seconds

% define number of samples that correspond to the amount of data in time
numSamples2use = amountOfData*srate;

% define for loop
looper = ceil((amountOfTime*60)/amountOfData); % N minutes * 60sec/1min * (1 loop is about .250 ms of data)

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
    
    % running this a ton of times until we get failures          
    pause(amountOfData);
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
    coh(i) = nanmean(coh_temp);
    
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

%% coherence magnitudes 
coh(1) = [];

% plot the histogram of coherence magnitudes
figure('color','w')
h_og = histogram(coh,'FaceColor',[.6 .6 .6]); hold on;
h_og.FaceColor = [.6 .6 .6];
% zscore coherence
zscoredCoh = zscore(coh);
% remove first calculation
% get 1 std
cohHighStd = coh(zscoredCoh > 1);
cohHighVal = coh(dsearchn(zscoredCoh',1));
% plot
h_highS = histogram(cohHighStd,'FaceColor','b');
h_highS.BinWidth = h_og.BinWidth;
% get -1std
cohLowStd = coh(zscoredCoh < -1);
cohLowVal = coh(dsearchn(zscoredCoh',-1));
% plot
h_lowS = histogram(cohLowStd,'FaceColor','r');
h_lowS.BinWidth = h_og.BinWidth;
box off;
legend(['All data'],['High Thresh. (1std = ',num2str(cohHighVal),')'],['Low Thresh. (-1std = ',num2str(cohLowVal),')'])
ylabel('Iteration')
xlabel('Coherence magnitude')

% chance of observing high/low coh
figure('color','w'); hold on;
prob_high = numel(cohHighStd)/numel(coh);
prob_low  = numel(cohLowStd)/numel(coh);
bar(1,prob_high,'FaceColor','b');
bar(2,prob_low,'FaceColor','r');
ylabel('p(coherence)')
axes = gca;
axes.XTick = [ 1 2 ];
axes.XTickLabel = [{'High Coherence'} {'Low Coherence'}];
axes.XTickLabelRotation = 45;

%% coherence durations

% each sample is sampled at .25 seconds, therefore, if the size is 1, it
% was sampled at .25, if size is 2, then 0.5, etc..

% get sizes of timeStamps - to use cellfun2, run Startup in pipeline
timeSizes = cell2mat(cellfun2(timeStamps,'size',{'2'}));

% max of 
[maxTime, maxLoc] = max(timeSizes);

% convert to seconds
timeConv = zeros(size(timeSizes));
prob_observe = [];
for i = 1:maxTime
    timeConv(timeSizes == i) = i*amountOfData;
    
    % get p(i)
    prob_observe(i) = numel(find(timeSizes == i))/numel(timeConv);
end

% histogram of sampled times
figure('color','w')
plot(prob_observe,'k','LineWidth',2)
box off
ylabel('Coherence Magnitude')
xlabel('Duration Possibilities (ms)')
axes = gca;
axes.XTick = [1:maxTime];
for i = 1:maxTime
    axes.XTickLabel{i} = i*amountOfData;
end
axes.XTickLabelRotation = 45;

    
%% script function

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

%% Within the high and low coherence distributions, what durations are we working with?

% -- high coherence -- %

% get above threshold
idxAbove = [];
idxAbove = find(coh > cohHighVal);

% in other words, how long was coherence >1std or <1std?
% define std_above_mean start time
idxDiff = []; idxChangeDiff = []; idxStart = [];
idxDiff       = diff(idxAbove);
idxChangeDiff = [1 find(idxDiff ~= 1)+1];
idxStart      = idxAbove(idxChangeDiff);

% get end of ripple event (dips below 1)
idxEnd = []; idxRem = [];
for i = 1:length(idxStart)
    restOfData  = []; idxBelowAll = []; idxBelow = [];
    restOfData  = coh(idxStart(i):length(coh));
    idxBelowAll = find(restOfData < cohHighVal);
    % sometimes a ripple continues outside of your window. remove that
    % event
    if isempty(idxBelowAll)
        idxRem(i) = 1;
        idxStart(i) = [];
        continue
    end
    idxBelow    = idxBelowAll(1);
    idxEnd(i)   = idxStart(i)+(idxBelow-2);
end

% find numerical duration (is not actual duration)
cohNumIdx = []; cohNumDur = [];
cohNumIdx(1,:) = idxStart;
cohNumIdx(2,:) = idxEnd;
for i = 1:length(cohNumIdx)
    % get numerical duration
    cohNumDur{i} = cohNumIdx(1,i):cohNumIdx(2,i);
end

% find actual times
for i = 1:length(cohNumDur)
    cohDur(i) = sum(timeConv(cohNumDur{i})); % in sec
end
    
figure('color','w'); hold on;
histogram(cohDur,40,'FaceColor',[0 .6 0])
box off
ylabel('Number of high coherence epochs')
xlabel('Duration of sustained high coherence')

% find the 1st std
highCohDurZ   = zscore(cohDur);
cohHighDurStd = cohDur(highCohDurZ > 1);
cohHighDurVal = cohDur(dsearchn(highCohDurZ',1));

% plt line
ylimits = ylim;
line([cohHighDurVal cohHighDurVal], [ylimits(1) ylimits(2)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2);
text(2,600,['Duration 1std = ',num2str(cohHighDurVal), ' sec'])

% -- LOW COHERENCE -- %

% get above threshold
idxAbove = [];
idxAbove = find(coh < cohLowVal);

% in other words, how long was coherence >1std or <1std?
% define std_above_mean start time
idxDiff = []; idxChangeDiff = []; idxStart = [];
idxDiff       = diff(idxAbove);
idxChangeDiff = [1 find(idxDiff ~= 1)+1];
idxStart      = [];
idxStart      = idxAbove(idxChangeDiff);

% get end of ripple event (dips below 1)
idxEnd = []; idxRem = [];
for i = 1:length(idxStart)
    restOfData  = []; idxBelowAll = []; idxBelow = [];
    restOfData  = coh(idxStart(i):length(coh));
    idxBelowAll = find(restOfData > cohLowVal);
    % sometimes a ripple continues outside of your window. remove that
    % event
    if isempty(idxBelowAll)
        idxRem(i) = 1;
        idxStart(i) = [];        
        continue
    end
    idxBelow    = idxBelowAll(1);
    idxEnd(i)   = idxStart(i)+(idxBelow-2);
end

% find numerical duration (is not actual duration)
cohNumIdx = []; cohNumDur = [];
cohNumIdx(1,:) = idxStart;
cohNumIdx(2,:) = idxEnd;
for i = 1:length(cohNumIdx)
    % get numerical duration
    cohNumDur{i} = cohNumIdx(1,i):cohNumIdx(2,i);
end

% find actual times
cohDur = [];
for i = 1:length(cohNumDur)
    cohDur(i) = sum(timeConv(cohNumDur{i})); % in sec
end
    
figure('color','w'); hold on;
histogram(cohDur,40,'FaceColor','r')
box off
ylabel('Number of low coherence epochs')
xlabel('Duration of sustained low coherence')

% find the 1st std
lowCohDurZ   = zscore(cohDur);
cohLowDurStd = cohDur(lowCohDurZ > 1);
cohLowDurVal = cohDur(dsearchn(lowCohDurZ',1));

% plt line
ylimits = ylim;
line([cohLowDurVal cohLowDurVal], [ylimits(1) ylimits(2)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2);
text(2,600,['Duration 1std = ',num2str(cohLowDurVal), ' sec'])

%% define outs - make this an output of this function
threshold.high_coherence_magnitude = cohHighVal;
threshold.low_coherence_magnitude  = cohLowVal;

threshold.high_coherence_longDuration = cohHighDurVal;
threshold.low_coherence_longDuration  = cohLowDurVal;

% defined as the smallest sampling range
threshold.short_duration = amountOfData;

