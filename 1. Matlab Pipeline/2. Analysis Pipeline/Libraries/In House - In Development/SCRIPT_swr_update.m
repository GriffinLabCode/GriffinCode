% only include if data is > 50 spikes surrounding a ripple
clear; clc; %close all 
    
%% important variable names 
datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Usher\Muscimol\Baseline';
csc_hpc    = 'CSC7'; % CSC7 for usher
csc_pfc    = 'CSC6';
int_name   = 'Int_VTE_JS';

%% load data - prep. steps
cd(datafolder);

% load int
load(int_name);

% load csc
data_hpc = load(csc_hpc);
data_pfc = load(csc_pfc);

% calculate and define the sampling rate
totalTime  = (data_hpc.Timestamps(2)-data_hpc.Timestamps(1))/1e6; % this is the time between valid samples
numValSam  = size(data_hpc.Samples,1);     % this is the number of valid samples (512)
srate      = round(numValSam/totalTime); % this is the sampling rate

% define params
params.tapers    = [3 5];
params.trialave  = 0;
params.err       = [2 .05];
params.pad       = 0;
params.fpass     = [0 300]; % [1 100]
params.movingwin = [0.05 0.01]; % was [0.25 0.01] %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
params.Fs        = srate;

% convert lfp data
[Timestamps, lfp_pfc] = interp_TS_to_CSC_length_non_linspaced(data_pfc.Timestamps, data_pfc.Samples);     
[~, lfp_hpc] = interp_TS_to_CSC_length_non_linspaced(data_hpc.Timestamps, data_hpc.Samples);     

% look for theta
view_auto = 1;
if view_auto == 1
    thetaview(Int,Timestamps,lfp_pfc,params,view_auto);
    title([csc_pfc])
    thetaview(Int,Timestamps,lfp_hpc,params,view_auto);
    title([csc_hpc])
end

%% extract swrs for both csc's

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
[pfc_zPreSWRlfp,pfc_preSWRlfp,pfc_lfp_filtered] = preSWRfun(lfp_pfc,phase_bandpass,srate,gauss);
[hpc_zPreSWRlfp,hpc_preSWRlfp,hpc_lfp_filtered] = preSWRfun(lfp_hpc,phase_bandpass,srate,gauss);

% swr fun
[pfc_SWRevents,pfc_SWRtimes,pfc_SWRtimeIdx,pfc_SWRdurations,pfc_trials2rem] = extract_SWR_5(pfc_zPreSWRlfp,mazePos,Int,Timestamps,srate,phase_bandpass,std_above_mean,gauss,InterRippleInterval,plotFig);
[hpc_SWRevents,hpc_SWRtimes,hpc_SWRtimeIdx,hpc_SWRdurations,hpc_trials2rem] = extract_SWR_5(hpc_zPreSWRlfp,mazePos,Int,Timestamps,srate,phase_bandpass,std_above_mean,gauss,InterRippleInterval,plotFig);

% use pfc lfp to detect false positives and remove them from the dataset
fp_data = pfc_SWRtimes; real_data = hpc_SWRtimes;
[swr2close] = remFalsePositiveSWRs(fp_data,real_data); % first input should be false positive, second input is removal

% remove
numTrials = size(Int,1);
for triali = 1:numTrials
    if isempty(hpc_SWRevents{triali}) == 0 && isempty(swr2close{triali}) == 0
        hpc_SWRdurations{triali}(swr2close{triali}) = [];
        hpc_SWRevents{triali}(swr2close{triali}) = [];
        hpc_SWRtimeIdx{triali}(swr2close{triali}) = [];
        hpc_SWRtimes{triali}(swr2close{triali}) = [];
    end
end

% -- rename variables -- %
SWRtimeIdx   = hpc_SWRtimeIdx;
SWRtimes     = hpc_SWRtimes;
SWRdurations = hpc_SWRdurations;
SWRevents    = hpc_SWRevents;
lfp          = lfp_hpc;
preSWRlfp    = hpc_preSWRlfp;
lfp_filtered = hpc_lfp_filtered;

%% get LFP data from reward well - use later
numTrials = size(Int,1); % define number of trials
clear X Y TS LFPtimes LFP
for triali = 1:numTrials
    LFPtimes{triali} = Timestamps(Timestamps > Int(triali,mazePos(1)) & Timestamps < Int(triali,mazePos(2)));
    LFP{triali}      = lfp(Timestamps > Int(triali,mazePos(1)) & Timestamps < Int(triali,mazePos(2)));
end

%% only include epochs with speed < 4cm/sec - use linear position for this
vt_name      = 'VT1.mat';
missing_data = 'interp';
vt_srate     = 30; % 30 samples/sec
clear measurements
measurements.stem     = 112; % in cm was 137
measurements.goalArm  = 56; % was 50
measurements.goalZone = 29; % was 37
%measurements.retArm   = %117; % was 130

% get linear skeleton
Startup_linearSkeleton % add paths
[data] = get_linearSkeleton(datafolder,int_name,vt_name,missing_data,measurements);
idealTraj = data.idealTraj;
rmPaths_linearSkeleton % remove paths

% load position data
[ExtractedX, ExtractedY, TimeStamps_VT] = getVTdata(datafolder,missing_data,vt_name);

% get linear position - use whole maze for plotting purposes
mazePos = [1 7]; 
stemOrientation = 'x';

% define start position for stem
if contains(stemOrientation,'x') | contains(stemOrientation,'X')
    for triali = 1:numTrials
        startPos(triali) = ExtractedX(find(Int(triali,1) == TimeStamps_VT));
    end
elseif contains(stemOrientation,'y') | contains(stemOrientation,'Y')
    for triali = 1:numTrials
        startPos(triali) = ExtractedY(find(Int(triali,1) == TimeStamps_VT));
    end   
end
startStemPos = min(startPos); % in pixels

%[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data,mazePos);
clear linearPosition position
[linearPosition,position] = get_linearPosition(datafolder,idealTraj,Int,ExtractedX,ExtractedY,TimeStamps,mazePos,stemOrientation,startStemPos);

% get position data from entire run (excluding return arms)
numTrials = size(Int,1); % define number of trials
clear X Y TS
for triali = 1:numTrials
    X{triali}  = ExtractedX(TimeStamps_VT >= Int(triali,mazePos(1)) & TimeStamps_VT <= Int(triali,mazePos(2)));
    Y{triali}  = ExtractedY(TimeStamps_VT >= Int(triali,mazePos(1)) & TimeStamps_VT <= Int(triali,mazePos(2)));
    TS{triali} = TimeStamps_VT(TimeStamps_VT >= Int(triali,mazePos(1)) & TimeStamps_VT <= Int(triali,mazePos(2)));
end

% get velocity
linPos = cell([1 numTrials]); speed = cell([1 numTrials]);
timingVar = cell([1 numTrials]); accel = cell([1 numTrials]);
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

%% speed - swr sanity check
% will display if you have any issues
SCRIPT_swr_speed_sanityCheck;

%% make a cool fig
trial = 1;
SCRIPT_swr_plot;

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
