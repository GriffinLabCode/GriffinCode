% only include if data is > 50 spikes surrounding a ripple
clear; clc; %close all 
    
%% Load and isolate desired session data 
datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Usher\Muscimol\Baseline';
lfpName    = 'CSC7'; % CSC7 for usher
int_name   = 'Int_VTE_JS';

%% load i
cd(datafolder);
load(lfpName);
load(int_name);

% sometimes data can be named differently
if exist("CSC_Timestamp")
    Times_unf = CSC_Timestamp;
else
    Times_unf = Timestamps;
    clear Timestamps
end
    
if exist("CSC_Samples")
    Samples_unf = CSC_Samples;
else
    Samples_unf = Samples;
    clear Samples
end

% convert lfp data
[Timestamps, lfp] = interp_TS_to_CSC_length_non_linspaced(Times_unf, Samples_unf);     

%% extract swrs
% calculate and define the sampling rate
totalTime  = (Times_unf(2)-Times_unf(1))/1e6; % this is the time between valid samples
numValSam  = size(Samples_unf,1);     % this is the number of valid samples (512)
srate      = round(numValSam/totalTime); % this is the sampling rate

% phase bandpass
phase_bandpass = [150 250];

% define how many standard deviations from mean for inclusion
std_above_mean = 3;

% define gauss
gauss = 1;

% plot?
plotFig = 1;

% inter ripple interval
InterRippleInterval = 0; % this is the time required between ripples. if ripple occurs within this time range (in sec),

% extract swr function - only look at goal zone
mazePos = [2 7];

% transform and smooth
[zPreSWRlfp,preSWRlfp,lfp_filtered] = preSWRfun(lfp,phase_bandpass,srate,gauss);

% swr fun - you can use SWRtimeIdx, plot lfp across one whole trial, then
% highlight swr events, similar to how Jadhav does it. This is because
% SWRtimeIdx is a cell array (organized by trials). You could concatenate
% across trials, plot the lfp for 1 whole trial, then use the SWRtimeIdx to
% pin point swr events since each indexed value corresponds to an lfp value
% included as a ripple. Furthermore, you could plot preSWRlfp.
[SWRevents,SWRtimes,SWRtimeIdx,SWRdurations,trials2rem] = extract_SWR_5(zPreSWRlfp,mazePos,Int,Timestamps,srate,phase_bandpass,std_above_mean,gauss,InterRippleInterval,plotFig);

% fig
ex_ripTime = Timestamps(SWRtimeIdx{1}{1}); % first trial, first swr event
ex_ripLFP  = lfp(SWRtimeIdx{1}{1}); % first trial, first swr event
ex_ripFil  = preSWRlfp(SWRtimeIdx{1}{1});
figure('color','w')
plot(ex_ripLFP,'b'); hold on; yyaxis right; plot(ex_ripFil)

%% get LFP data from reward well - use later
numTrials = size(Int,1); % define number of trials
clear X Y TS LFPtimes LFP
for triali = 1:numTrials
    LFPtimes{triali} = Timestamps(Timestamps > Int(triali,mazePos(1)) & Timestamps < Int(triali,mazePos(2)));
    LFP{triali}      = lfp(Timestamps > Int(triali,mazePos(1)) & Timestamps < Int(triali,mazePos(2)));
end

%{
figure('color','w');
goalEntryIdx_lfp = dsearchn(Timestamps',Int(1,2));
goalExitIdx_lfp  = dsearchn(Timestamps',Int(1,7));
xTimes_ts = Timestamps(goalEntryIdx_lfp:goalExitIdx_lfp);
xTimes_sec = linspace(0,(xTimes_ts(end)-xTimes_ts(1))/1e6,numel(goalEntryIdx_lfp:goalExitIdx_lfp));
subplot 211; plot(xTimes_sec,lfp(goalEntryIdx_lfp:goalExitIdx_lfp),'k'); axis tight; box off;
subplot 212; plot(xTimes_sec,lfp_filtered(goalEntryIdx_lfp:goalExitIdx_lfp),'k'); axis tight; box off;
%plot(preSWRlfp(goalEntryIdx_lfp:goalExitIdx_lfp),'k'); axis tight; box off;
for i = 1:length(SWRtimes{1})
    ripStart(i) = SWRtimes{1}{i}(1);
    ripEnd(i)   = SWRtimes{1}{i}(end);
end
ripStartIdx = dsearchn(xTimes_ts',ripStart');
ripEndIdx   = dsearchn(xTimes_ts',ripEnd');
xStart      = xTimes_sec(ripStartIdx); % get seconds
for i = 1:length(ripStartIdx)
    l1 = line([xStart(i) xStart(i)],[-2000 2000])
    l1.Color = 'b';
    l1.LineWidth = 2;
end
% plot a rectangle that encloses each event
%}

%% only include epochs with speed < 4cm/sec - use linear position for this
vt_name      = 'VT1.mat';
missing_data = 'interp';
vt_srate     = 30; % 30 samples/sec
measurements.stem     = 137; % in cm
measurements.goalArm  = 50;
measurements.goalZone = 37;
%measurements.retArm   = 130;

% get linear skeleton
Startup_linearSkeleton % add paths
[data] = get_linearSkeleton(datafolder,int_name,vt_name,missing_data,measurements);
idealTraj = data.idealTraj;
rmPaths_linearSkeleton % remove paths

% get linear position - use whole maze for plotting purposes
mazePos = [1 7]; 
[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data,mazePos);

% video tracking data
[ExtractedX, ExtractedY, TimeStamps_VT] = getVTdata(datafolder,missing_data,vt_name);

% get position data from entire run (excluding return arms)
numTrials = size(Int,1); % define number of trials
clear X Y TS LFPtimes LFP
for triali = 1:numTrials
    X{triali}  = ExtractedX(TimeStamps_VT >= Int(triali,mazePos(1)) & TimeStamps_VT <= Int(triali,mazePos(2)));
    Y{triali}  = ExtractedY(TimeStamps_VT >= Int(triali,mazePos(1)) & TimeStamps_VT <= Int(triali,mazePos(2)));
    TS{triali} = TimeStamps_VT(TimeStamps_VT >= Int(triali,mazePos(1)) & TimeStamps_VT <= Int(triali,mazePos(2)));
end

% get velocity
for triali = 1:numTrials
    
    % bc linearposition is organized by lefts/rights, we need to fix the
    % variable. If the trajectory is right, then store data. Erase the og
    % variables right so that we can keep pulling from the first element.
    if Int(triali,3) == 0
        linPos{triali} = linearPosition.right{1};
        linearPosition.right(1) = [];
    elseif Int(triali,3) == 1
        linPos{triali} = linearPosition.left{1};
        linearPosition.left(1) = [];
    end
    
    % get velocity, acceleration, and speed.
    trialDur = []; % initialize
    trialDur  = (TS{triali}(end)-TS{triali}(1))/1e6; % trial duration
    timingVar{triali} = linspace(0,trialDur,length(TS{triali})); % variable indicating length of trial duration
    [vel{triali},accel{triali}] = linearPositionKinematics(linPos{triali},timingVar{triali}); % get vel and acc
    
    % smooth speed according to the sampling rate (1second smoothing)
    speed{triali} = smoothdata(abs(vel{triali}),'gauss',vt_srate); % 1 second smoothing rate
end
    
%% apply velocity filter
% note that we want to apply a speed filter AFTER extraction of SWRs
% because past attempts revealed that if you extract speed first, when you
% extract the ripple, you may extract the center of the ripple. In other
% words, doing it this way ensures that we get entire ripple events (from
% event start to event end), then we can see if the rat was running too fast.
speedFilt = 5; % 5cm/sec
    
% now, extract vt timestamps ONLY after goal zone entry. Use this to
% extract speed
speedDurRipple = cell([1 numTrials]);
speedRem       = cell([1 numTrials]);
for triali = 1:numTrials
    
    % find goalzone entry
    GZentryIdx(triali)  = find(TS{triali} == Int(triali,2)); % vt timestamps == goal zone entry time
    timingEntry(triali) = timingVar{triali}(GZentryIdx(triali)); % get the actual second time for this - mostly plotting purpose
    
    % get speed after goal zone entry
    speedAfterEntry{triali} = speed{triali}(GZentryIdx(triali):end); % speed - get the speed after the goal entry
    TimesAfterEntry{triali} = TS{triali}(GZentryIdx(triali):end); % vt-data - get vt timestamps after goal zone entry (they should already be clipped by the end of goal zone occupancy)
    
    % find vt times around ripple evnts
    if isempty(SWRtimes{triali}) == 0 % only extract speed around events if there were any detected ripples
        for ripi = 1:length(SWRtimes{triali})
            % create an index to get speed
            idxSwr2Vt = dsearchn(TimesAfterEntry{triali}',SWRtimes{triali}{ripi}');
            % get speed
            speedDurRipple{triali}{ripi} = speedAfterEntry{triali}(idxSwr2Vt(1):idxSwr2Vt(end));
            % find instances where speed exceeds threshold
            speedRem_temp{triali}{ripi} = find(speedDurRipple{triali}{ripi} >= speedFilt);
        end
        % find non-empty arrays in speedRem - this means that there were swr
        % events where the rat was moving faster than what we want
        speedRem{triali} = find(~cellfun('isempty',speedRem_temp{triali})==1);
    end
end

% remove SWRs where speed was too high
for triali = 1:numTrials
    % you can only erase things that you actually have
    if isempty(SWRevents{triali}) == 0 && isempty(speedRem{triali}) == 0
        SWRevents{triali}(speedRem{triali})=[];
        SWRdurations{triali}(speedRem{triali})=[];
        SWRtimeIdx{triali}(speedRem{triali})=[];
        SWRtimes{triali}(speedRem{triali})=[];
    end
end

%% remove clipping artifacts
% sometimes data sucks

% initialize
lfpAroundRipple = cell([1 numTrials]);
lfpDuringRipple = cell([1 numTrials]);
numClippings    = cell([1 numTrials]);
% define this variable for lfp around ripples
time_around = [0.5*1e6 0.5*1e6];
% grab lfp 2 sec around ripple.
for triali = 1:numTrials
    if isempty(SWRtimes{triali}) == 0
        for swri = 1:length(SWRtimes{triali})

            % lfp around ripple
            lfpAroundRipple{triali}{swri} = lfp(Timestamps>(SWRtimes{triali}{swri}(1)-(time_around(1)*1e6))&Timestamps<(SWRtimes{triali}{swri}(1)+(time_around(2)*1e6)));

            % lfp during ripple
            lfpDuringRipple{triali}{swri} = lfp(find(Timestamps == SWRtimes{triali}{swri}(1)):find(Timestamps == SWRtimes{triali}{swri}(end)));

            % find number of clippings - only put the ripple data
            [~,~,numClippings{triali}(swri)] = detect_clipping(lfpDuringRipple{triali}{swri});

        end
    end
    % find cases where clippings occured
    remClip{triali} = find(numClippings{triali} > 0);
    % remove them
    % you can only erase things that you actually have
    if isempty(SWRevents{triali}) == 0 && isempty(remClip{triali})==0 
        SWRevents{triali}(remClip{triali})=[];
        SWRdurations{triali}(remClip{triali})=[];
        SWRtimeIdx{triali}(remClip{triali})=[];
        SWRtimes{triali}(remClip{triali})=[];
    end    
end

%% make a cool fig
trial = 2;

% plot
figure('color','w'); hold on;
subplot 411
    trialDur = []; % initialize
    trialDur  = (TS{trial}(end)-TS{trial}(1))/1e6; % trial duration
    timingVar{trial} = linspace(0,trialDur,length(TS{trial})); % variable indicating length of trial duration
    plot(timingVar{trial},linPos{trial},'k','LineWidth',2)
    xlabel('Start of trial to end of goal zone')
    ylabel('Linear Position (cm)')
    % find goalzone entry
    GZentryIdx  = find(TS{trial} == Int(trial,2));
    timingEntry = timingVar{trial}(GZentryIdx);
    % plot
    l1 = line([timingEntry timingEntry],[0 150])
    l1.Color = 'r';
    l1.LineStyle = '--'
    l1.LineWidth = 2;
    title('Red line indicates goal zone entry filter')
    box off; axis tight;
    
subplot 412
    plot(timingVar{trial},speed{trial},'k','LineWidth',2)
    xlabel('Start of trial to end of goal zone')
    ylabel('Speed (cm/sec)')
    box off; axis tight;
    % plot
    l1 = line([timingEntry timingEntry],[0 40])
    l1.Color = 'r';
    l1.LineStyle = '--'
    l1.LineWidth = 2;    
    xlimits = xlim;
    l2 = line([xlimits(1) xlimits(2)],[speedFilt speedFilt])
    l2.Color    = 'b';
    l2.LineStyle = '--';
    l2.LineWidth = 2;
    title('Blue line indicates speed filter')

    EntryIdx_lfp = []; ExitIdx_lfp = []; xTimes_ts = []; xTimes_sec = [];
   
    % stem entry to goal exit
    EntryIdx_lfp = dsearchn(Timestamps',Int(trial,1));
    GoalIdx_lfp  = dsearchn(Timestamps',Int(trial,2));
    ExitIdx_lfp  = dsearchn(Timestamps',Int(trial,7));
    
    % lfp timestamps (in raw format) from entry to exit
    xTimes_ts = Timestamps(EntryIdx_lfp:ExitIdx_lfp); % lfp timestamps from goal entry to exit
    
    %dsearchn(xTimes_ts',Timestamps(GoalIdx_lfp))
    
    % lfp timestamps (in seconds: 0 to N seconds) from entry to exit
    xTimes_sec = linspace(0,(xTimes_ts(end)-xTimes_ts(1))/1e6,numel(EntryIdx_lfp:ExitIdx_lfp));
    %xTimes_sec = linspace(0,timingVar{trial}(end),numel(EntryIdx_lfp:ExitIdx_lfp));
    
    % plot lfp data
    subplot 413; plot(xTimes_sec,lfp(EntryIdx_lfp:ExitIdx_lfp),'k'); axis tight; box off;
    subplot 414; plot(xTimes_sec,lfp_filtered(EntryIdx_lfp:ExitIdx_lfp),'k'); axis tight; box off;
    %plot(preSWRlfp(goalEntryIdx_lfp:goalExitIdx_lfp),'k'); axis tight; box off;
    
    % plot ripple events
    ripStart = []; ripEnd = []; ripStartIdx = []; ripEndIdx = []; xStart=[];
    for i = 1:length(SWRtimes{trial})
        ripStart(i) = SWRtimes{trial}{i}(1);
        ripEnd(i)   = SWRtimes{trial}{i}(end);
    end
    ripStartIdx = dsearchn(xTimes_ts',ripStart');
    ripEndIdx   = dsearchn(xTimes_ts',ripEnd');
    xStart      = xTimes_sec(ripStartIdx); % get seconds
    xCheck      = xTimes_ts(ripStartIdx);
    for i = 1:length(ripStartIdx)
        l1 = line([xStart(i) xStart(i)],[-2000 2000]);
        l1.Color = 'b';
        l1.LineWidth = 2;
    end 
    % instead of a line, try a rectangle

%% swr rate
% swr count
SWRcount = cellfun(@numel,SWRtimes);

% total time spent in zone of interest
for triali = 1:numTrials
    timeInZone(triali) = (TimesAfterEntry{triali}(end)-TimesAfterEntry{triali}(1))/1e6;
end

% get rate of events
SWRrate = SWRcount./timeInZone; % in Hz (swrs/sec)

figure('color','w')
histogram(SWRrate)



%% swr durations
swr_durations_all = horzcat(SWRdurations{:});
figure('color','w')
h1 = histogram(swr_durations_all);
h1.FaceColor = 'b';
box off
ylabel('# SWRs')
xlabel('SWR duration (ms)')
title('SWR events for all trials')

%% swr spike timing
cellNum    = 6;
clusters   = dir('TT*.txt');
spikeTimes = textread(clusters(cellNum).name);

% concat spikes
SWRtimes_all = horzcat(SWRtimes{:});

% define time window
timesAround = [0.5*1e6 0.5*1e6];

% plot fig?
plotFig = 1;

[FR,n,excludeCell] = PETH_SWR(spikeTimes,SWRtimes_all,timesAround,plotFig)

%{
%% visualize single trial power - this requires updating


% on 07-08-2020 I found that Re exhibits the same 130-160hz ripple, while
% pfc does not. This makes me question if 130-160 is actually a ripple or
% an artifact of theta.
       
% average across
% plot heat map https://www.pnas.org/content/pnas/112/46/E6379.full.pdf -
% fig 2c
params.tapers    = [5 9];
params.trialave  = 0;
params.err       = [2 .05];
params.pad       = 0;
params.fpass     = [0 300]; % [1 100]
params.movingwin = [0.05 0.01]; % was [0.25 0.01] %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
params.Fs        = srate;

clear pow_trials time_trials freq_trials
for z = 1:length(lfpAroundRipple)
    [pow_events{z},time_trials,freq_trials]=mtspecgramc(lfpAroundRipple{z},params.movingwin,params);
end

swrNum = 3;
% plot 1 trial
figure('color','w')
x_label = linspace(-0.5, 0.5, length(time_trials));
timeIdx = find(x_label > -0.2 & x_label < 0.2);
pcolor(x_label(timeIdx),freq_trials,pow_events{swrNum}(timeIdx,:)')
colormap(jet)
c = colorbar;   
%caxis([0.0548 0.0563])    
shading 'interp'
ylabel('frequency')
xlabel('time') 
title(['swr number ',num2str(swrNum)])
set(gca,'FontSize',10)
    
%% Four way SWR analysis plot (LFP, RippleBand, Avg Norm.Power, Avg Freq Norm. for time, Avg time Norm. for freq  

swrNum = 250;
%normalize across time
norm_pow = normalize(pow_events{swrNum},'range'); % normalized across time

x_label_pow = linspace(-time_around(1),time_around(2),length(time_trials));
x_label_lfp = linspace(-time_around(1),time_around(2),length(lfpAroundRipple{swrNum}));

%Raw LFP
figure('color','w')
subplot 421
plot(x_label_lfp,lfpAroundRipple{swrNum},'m')
box off
ylabel('Voltage')
title(['SWR Number ',num2str(swrNum)])

%Filtered ripple-band and plot hilbert transformation
filt_Ripple = skaggs_filter_var(lfpAroundRipple{swrNum}, phase_bandpass(1),...
    phase_bandpass(2), srate); % why do we filter again here?   
subplot 423
plot(x_label_lfp,zscore(filt_Ripple),'r')
box off
ylabel('Voltage')

% Session Avg power plot Normalized by time
subplot 223
freq_band = [0 300];
freq_idx = find(freq_trials >= freq_band(1) & freq_trials <= freq_band(2)); 
pcolor(x_label_pow,freq_trials(freq_idx),norm_pow(:,freq_idx)')
colormap(jet)
shading 'interp'
ylabel('frequency')
xlabel('Time around SWR onset') 
set(gca,'FontSize',10)
title('Power norm. by time')

% now do averages across frequencies of swr band (see the time resolution)
swr_band = [100 250];
freq_idx = find(freq_trials >= swr_band(1) & freq_trials <= swr_band(2));
freq_new = freq_trials(freq_idx); % get freqs
swr_pow  = norm_pow(:,freq_idx);
swr_pow_avg = mean(swr_pow,2); % average across frequencies, not time
subplot 222
plot(x_label_pow,swr_pow_avg,'b','LineWidth',2)
box off
xlabel('Time around SWR onset')
ylabel('Norm. Power of SWR freqs')
title(['Frequencies: ',num2str(swr_band(1)),'-',num2str(swr_band(2))])

% average across time (see the frequency resolution)
subplot 224
x_label = linspace(-0.5, 0.5, length(time_trials));
timeIdx = find(x_label > -0.1 & x_label < 0.1);
freq_idx = find(freq_trials >= swr_band(1) & freq_trials <= swr_band(2));
swr_pow_avg2 = mean(norm_pow(timeIdx,:),1); % averaged across time
plot(swr_pow_avg2(freq_idx),freq_trials(freq_idx),'k','LineWidth',2)
box off
ylabel('Frequency')
xlabel('Norm. Power')



%% ~~ power plotting both power gram and fre x pow ~~ %
% 3d matrix
clear pow_3d pow_mean
pow_3d   = cat(3,pow_events{:});
pow_mean = mean(pow_3d,3);

figure('color','w');
subplot 311
    x_label_pow = linspace(-time_around(1),time_around(2),length(time_trials));
    pcolor(x_label_pow,freq_trials,log10(pow_mean'))
    colormap(jet)
    %c = colorbar;   
    %caxis([0.0548 0.0563])    
    shading 'interp'
    ylabel('frequency')
    xlabel('time') 
    ylabel('SWR event avg. power (db)')
    set(gca,'FontSize',10)
    title('SWR averaged')
subplot 312
    x_label_pow = linspace(-time_around(1),time_around(2),length(time_trials));
    pcolor(x_label_pow,freq_trials,(normalize(log10(pow_mean),'range'))')
    colormap(jet)
    %c = colorbar;   
    %caxis([0.0548 0.0563])    
    shading 'interp'
    ylabel('frequency')
    xlabel('time') 
    ylabel('SWR event avg. power (db)')
    set(gca,'FontSize',10)
    title('Normalize SWR power')
    
% look at freq x power
clear freqXpower freq_freqXpow
params.fpass = [0 250];
for z = 1:length(lfpAroundRipple)
    [freqXpower{z},freq_freqXpow]=mtspectrumc(lfpAroundRipple{z},params);
end
% average
freqXpow_cat  = log10(horzcat(freqXpower{:}));
freqXpow_mean = mean(freqXpow_cat,2);
freqXpow_std  = stderr(freqXpow_cat');

subplot 313
shadedErrorBar(freq_freqXpow,freqXpow_mean,freqXpow_std,'k',1)
ylabel('Power (log10)')
xlabel('Frequency')
box off

%% plot histogram of ripples
figure('color','w')
histogram(SWRdurations)
box off
ylabel('SWR count')
xlabel('SWR duration (ms)')
ylimits = ylim;
l1 = line([mean(SWRdurations) mean(SWRdurations)],[ylimits(1) ylimits(2)]);
l1.LineStyle = '--';
l1.LineWidth = 2;
l1.Color     = 'k';
%}