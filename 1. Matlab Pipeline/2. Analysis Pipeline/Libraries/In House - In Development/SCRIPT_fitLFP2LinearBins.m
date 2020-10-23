%% PSA_linearPosition
% power spectal

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
linearPos_name = 'linearSkeleton_Round2';

cd(datafolder);

% load int
load(int_name);

% load csc
data_hpc = load(csc_hpc);

% calculate and define the sampling rate
totalTime  = (data_hpc.Timestamps(2)-data_hpc.Timestamps(1))/1e6; % this is the time between valid samples
numValSam  = size(data_hpc.Samples,1);     % this is the number of valid samples (512)
srate      = round(numValSam/totalTime); % this is the sampling rate

% -- on hpc data, get swrs: -- %

% convert lfp data
[Timestamps, lfp_hpc] = interp_TS_to_CSC_length_non_linspaced(data_hpc.Timestamps, data_hpc.Samples);     

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
mazePos = [1 2];

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

    lfp_data{i}  = lfp_hpc(Timestamps >= Int(i,mazePos(1)) & Timestamps <= Int(i,mazePos(2)));
    lfp_times{i} = Timestamps(Timestamps >= Int(i,mazePos(1)) & Timestamps <= Int(i,mazePos(2)));
end

%[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data,mazePos);
clear linearPosition position
[linearPositionSmooth,linearPosition,position] = get_linearPosition(idealTraj,prePosData,vt_srate);

% get kinematics
timingVar = cell([1 numTrials]); accel = cell([1 numTrials]);
speed = cell([1 numTrials]); vel = cell([1 numTrials]);
for triali = 1:numTrials

    % get velocity, acceleration, and speed.
    trialDur = []; % initialize
    trialDur  = (position.TS{triali}(end)-position.TS{triali}(1))/1e6; % trial duration
    timingVar{triali} = linspace(0,trialDur,length(position.TS{triali})); % variable indicating length of trial duration
    [vel{triali},accel{triali}] = linearPositionKinematics(linearPositionSmooth{triali},timingVar{triali}); % get vel and acc
    
    % speed
    speed{triali} = abs(vel{triali}); %smoothdata(abs(vel{triali}),'gauss',vt_srate); % 1 second smoothing rate
end

%-- plot lfp by linear position --%

% need to interpolate linear position data to fit size of lfp


linearPosition{1}
lfp_times{1}
numBins = length(linearPosition{1})
extendedBins = linspace(1,numBins(end),length(lfp_times{1}));

linearPos_interp = interp1(1:numBins,linearPosition{1},extendedBins,'spline')



% mtspectrumc and cohspectrumc?
mtspectrumc(



