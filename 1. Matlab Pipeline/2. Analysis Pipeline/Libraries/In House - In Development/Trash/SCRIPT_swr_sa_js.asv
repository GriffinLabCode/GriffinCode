% only include if data is > 50 spikes surrounding a ripple
clear; clc; close all 
    
%% Load and isolate desired session data 
datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Usher\Saline\Saline';
lfpName    = 'CSC7';
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

% extract swr function
mazePos = [2 7];

% transform and smooth
[zPreSWRlfp] = preSWRfun(lfp,phase_bandpass,srate,gauss);

% swr fun
[SWRevents,SWRtimes,SWRtimeIdx,SWRdurations,trials2rem] = extract_SWR_5(zPreSWRlfp,mazePos,Int,Timestamps,srate,phase_bandpass,std_above_mean,gauss,InterRippleInterval,plotFig);

% int new
Int_new = Int;
Int_new(trials2rem,:)=[]; % remove

%% get LFP data from reward well
%mazePos = [1 7];
numTrials = size(Int_new,1); % define number of trials
clear X Y TS LFPtimes LFP
for triali = 1:numTrials
    LFPtimes{triali} = Timestamps(Timestamps > Int(triali,mazePos(1)) & Timestamps < Int(triali,mazePos(2)));
    LFP{triali}      = lfp(Timestamps > Int(triali,mazePos(1)) & Timestamps < Int(triali,mazePos(2)));
end

%% only include epochs with speed < 4cm/sec
vt_name      = 'VT1.mat';
missing_data = 'exclude';
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

% get linear position
mazePos = [1 7]; % was [1 2]
[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data,mazePos);

% video tracking data
[ExtractedX, ExtractedY, TimeStamps_VT] = getVTdata(datafolder,missing_data,vt_name);

% get LFP data from reward well
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
    
    % get velocity and acceleration
    trialDur = []; % initialize
    trialDur  = (TS{triali}(end)-TS{triali}(1))/1e6; % trial duration
    timingVar{triali} = linspace(0,trialDur,length(TS{triali})); % variable indicating length of trial duration
    [vel{triali},accel{triali}] = linearPositionKinematics(linPos{triali},timingVar{triali}); % get vel and acc
    speed{triali} = smoothdata(abs(vel{triali}),'gauss',vt_srate); % 1 second smoothing rate
end
    
%% apply velocity filter
speedFilt = 5; % 5cm/sec

% plot
figure('color','w'); hold on;
subplot 211
    plot(timingVar{1},linPos{1},'k','LineWidth',2)
    xlabel('Start of trial to end of goal zone')
    ylabel('Linear Position (cm)')
    % find goalzone entry
    GZentryIdx = find(TS{1} == Int(1,2));
    timingEntry = timingVar{1}(GZentryIdx);
    % plot
    l1 = line([timingEntry timingEntry],[0 150])
    l1.Color = 'r';
    l1.LineStyle = '--'
    l1.LineWidth = 2;
    title('Red line indicates goal zone entry filter')
    box off; axis tight;
subplot 212
    plot(timingVar{1},speed{1},'k','LineWidth',2)
    xlabel('Start of trial to end of goal zone')
    ylabel('Speed (cm/sec)')
    % find goalzone entry
    GZentryIdx = find(TS{1} == Int(1,2));
    timingEntry = timingVar{1}(GZentryIdx);
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

% find speed after goal zone
    
% get pointer variable (index) for goal zone entry.
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
            lfpAroundRipple{swri} = lfp(Timestamps>(SWRtimes{triali}{swri}(1)-(time_around(1)*1e6))&Timestamps<(SWRtimes{triali}{swri}(1)+(time_around(2)*1e6)));

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

%% visualize single trial power
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
