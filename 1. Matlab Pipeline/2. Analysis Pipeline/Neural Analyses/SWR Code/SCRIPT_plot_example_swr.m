%% extract cleaned swrs
% this code extracts swr events, accounts for false positive swrs using
% cortical lfp (if available), removes events that occur when speed is >
% 4cm/sec, and removes any SWRs that are clipping events.
%
% IMPORTANT: this data requires a few things: 
%               1) An Int file is created based on the assumed parameters
%                   from this pipeline
%               2) Each session that you will be including already has a
%                   the linear skeleton saved in the sessions datafolder
%
% -- INPUTS -- %
% datafolder: session specific datafolder
% swrParams: a struct with the following fields
%               phase_bandpass: should be [150 250]
%               std_above_mean: should be 3-6
%               gauss (1 for gaussian filter, 0 for no)
%               InterRippleInterval (try setting to 0 or 1), this is the
%                   time between ripples. if set to 1, then you do not include
%                   ripples if they co-occur within 1 sec.
%               mazePos: should be [2 7] for extracting goal zone  
% csc_hpc: the name of the hpc lfp
% csc_compare: the name of the lfp to detect false positives (note that
%               this should be defined, but if it the cortical lfp does not
%               exist, it will be ignored.
% int_name: name of int file
% vt_name: name of VT file
% missing_data: how to handle missing vt data. can be 'interp', 'exclude',
%                'ignore'. I do not know if 'exclude' will cause errors
%                with this function.
% linearPos_name: name of the linear skeleton variable
%
% -- OUTPUTS -- %
% swr_rate: rate of swrs 
% swr_durations: duration of swrs
% swr_count: number of swrs
% SWRtimes: timestamps of swrs
%
% written by John Stout and Suhaas Adiraju
clear;

% main Datafolder
datafolder  = 'X:\01.Experiments\RERh Inactivation Recording\Usher\Saline\Baseline';

% int name and vt name
int_name     = 'Int_JS_fixed';
vt_name      = 'VT1.mat';
missing_data = 'interp'; % interpolate missing data

% csc data names
csc_hpc     = 'HPC'; 
csc_compare = 'PFC';

% linear position name
linearPos_name = 'linearPositionData_JS';

% phase bandpass
swrParams.phase_bandpass = [150 250];
swrParams.std_above_mean = 3;
swrParams.gauss = 1;
swrParams.InterRippleInterval = 1; % this is the time required between ripples. if ripple occurs within this time range (in sec),
swrParams.mazePos = [2 7];

% -- get swrs and account for false positives if possible -- %
cd(datafolder);

% load int
load(int_name);

% load csc
data_hpc = load(csc_hpc);
try data_compare = load(csc_compare); end % this may not load if non existent

% calculate and define the sampling rate
totalTime  = (data_hpc.Timestamps(2)-data_hpc.Timestamps(1))/1e6; % this is the time between valid samples
numValSam  = size(data_hpc.Samples,1);     % this is the number of valid samples (512)
srate      = round(numValSam/totalTime); % this is the sampling rate

% -- on hpc data, get swrs: -- %

% convert lfp data
[Timestamps, lfp_hpc] = interp_TS_to_CSC_length_non_linspaced(data_hpc.Timestamps, data_hpc.Samples);     

% transform and smooth
[hpc_zPreSWRlfp,hpc_preSWRlfp,hpc_lfp_filtered] = preSWRfun(lfp_hpc,swrParams.phase_bandpass,srate,swrParams.gauss);

% swr fun
[hpc_SWRevents,hpc_SWRtimes,hpc_SWRtimeIdx,hpc_SWRdurations] = extract_SWR(hpc_zPreSWRlfp,swrParams.mazePos,Int,Timestamps,srate,swrParams.std_above_mean,swrParams.InterRippleInterval);

% this is going to be used to detect false positives when the data is
% available
if exist('data_compare') == 1
    % get lfp
    [~, lfp_compare] = interp_TS_to_CSC_length_non_linspaced(data_compare.Timestamps, data_compare.Samples);     
    % get pre swr data
    fp_zPreSWRlfp = preSWRfun(lfp_compare,swrParams.phase_bandpass,srate,swrParams.gauss);
    % get false positive events
    [~,fp_SWRtimes] = extract_SWR(fp_zPreSWRlfp,swrParams.mazePos,Int,Timestamps,srate,swrParams.std_above_mean,0);

    % can only do what is below if you actually have false positive events
    if isempty(fp_SWRtimes) == 0 
        % use pfc lfp to detect false positives and remove them from the dataset
        fp_data = fp_SWRtimes; real_data = hpc_SWRtimes;
        [swr2close] = getFalsePositiveSWRs(fp_data,real_data); % first input should be false positive, second input is removal

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

%% only include epochs with speed < 4cm/sec - use linear position for this
% get vt data
[ExtractedX,ExtractedY,TimeStamps_VT] = getVTdata(datafolder,missing_data,vt_name);

% vt can vary a little bit, but we can easily define it
vt_srate = round(getVTsrate(TimeStamps_VT,'y'));

% define number of trials using int
numTrials = size(Int,1);

% load linear position data
linearStruct = load(linearPos_name); % load('linearPositionData_JS');
idealTraj = linearStruct.idealTraj;

% calculate converted distance in cm. This tells you how far the rat ran
conv_distance = round(linearStruct.data.measurements.total_distance*linearStruct.bin_size);
total_dist = conv_distance;

% load int file and define the maze positions of interest
mazePos = [1 7];

% define int lefts and rights
trials_left  = find(Int(:,3)==1); % lefts
trials_right = find(Int(:,3)==0); % rights

% get position data into one variable
numTrials  = size(Int,1);
prePosData = cell([1 size(Int,1)]);
for i = 1:numTrials
    prePosData{i}(1,:) = ExtractedX(TimeStamps_VT >= Int(i,mazePos(1)) & TimeStamps_VT <= Int(i,mazePos(2)));
    prePosData{i}(2,:) = ExtractedY(TimeStamps_VT >= Int(i,mazePos(1)) & TimeStamps_VT <= Int(i,mazePos(2)));
    prePosData{i}(3,:) = TimeStamps_VT(TimeStamps_VT >= Int(i,mazePos(1)) & TimeStamps_VT <= Int(i,mazePos(2)));
end

%[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data,mazePos);
clear linearPosition position
[linearPosition,position] = get_linearPosition(idealTraj,prePosData);

% get velocity
timingVar = cell([1 numTrials]); accel = cell([1 numTrials]);
for triali = 1:numTrials
    
    % get velocity, acceleration, and speed.
    trialDur = []; % initialize
    trialDur  = (position.TS{triali}(end)-position.TS{triali}(1))/1e6; % trial duration
    timingVar{triali} = linspace(0,trialDur,length(position.TS{triali})); % variable indicating length of trial duration
    [vel{triali},accel{triali}] = linearPositionKinematics(linearPosition{triali},timingVar{triali}); % get vel and acc
    
    % smooth speed according to the sampling rate (1second smoothing)
    speed{triali} = smoothdata(abs(vel{triali}),'gauss',vt_srate); % 1 second smoothing rate
end
    
%% apply velocity filter
speedFilt = 4; % 4cm/sec
    
% now, extract vt timestamps ONLY after goal zone entry. Use this to
% extract speed
speedDurRipple = cell([1 numTrials]);
speedRem       = cell([1 numTrials]);
for triali = 1:numTrials
    
    % find goalzone entry
    GZentryIdx(triali)  = find(position.TS{triali} == Int(triali,2)); % vt timestamps == goal zone entry time
    timingEntry(triali) = timingVar{triali}(GZentryIdx(triali)); % get the actual second time for this - mostly plotting purpose
    
    % get speed after goal zone entry
    speedAfterEntry{triali} = speed{triali}(GZentryIdx(triali):end); % speed - get the speed after the goal entry
    TimesAfterEntry{triali} = position.TS{triali}(GZentryIdx(triali):end); % vt-data - get vt timestamps after goal zone entry (they should already be clipped by the end of goal zone occupancy)
    
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

%% sanity check - checks if speed overlapped with ripples (they shouldn't)
SCRIPT_swr_speed_sanityCheck;

%% plot example
trial = 1;
% note, its tricky to save the lfp data to import into illustrator
SCRIPT_swr_plot;

%% plot position of the example
figure('color','w'); hold on;
plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]);
plot(position.X{trial},position.Y{trial},'b');
gzEntryVT = find(TimeStamps_VT == Int(trial,2));
l1 = line([ExtractedX(gzEntryVT)-40 ExtractedX(gzEntryVT)+40],[ExtractedY(gzEntryVT) ExtractedY(gzEntryVT)])
l1.Color = 'r';
l1.LineStyle = '--';
l1.LineWidth = 1;
set(gcf,'Position',[300 250 300 250])

%% swr rate
% swr count
SWRcount = cellfun(@numel,SWRtimes);

% total time spent in zone of interest
for triali = 1:numTrials
    timeInZone(triali) = (TimesAfterEntry{triali}(end)-TimesAfterEntry{triali}(1))/1e6;
end

% get rate of events
swr_rate = SWRcount./timeInZone; % in Hz (swrs/sec)

%figure('color','w')
%histogram(SWRrate)

%% swr durations
swr_durations = horzcat(SWRdurations{:});
figure('color','w')
h1 = histogram(swr_durations);
h1.FaceColor = 'b';
box off
ylabel('# SWRs')
xlabel('SWR duration (ms)')
title('SWR events for all trials')

%% swr spike timing
cellNum    = 3;
clusters   = dir('TT*.txt');
spikeTimes = textread(clusters(cellNum).name);

% concat spikes
SWRtimes_all = horzcat(SWRtimes{:});

% define time window
timesAround = [0.5*1e6 0.5*1e6];

% plot fig?
plotFig = 1;

[FR,n,excludeCell] = PETH_SWR(spikeTimes,SWRtimes_all,timesAround,plotFig)
