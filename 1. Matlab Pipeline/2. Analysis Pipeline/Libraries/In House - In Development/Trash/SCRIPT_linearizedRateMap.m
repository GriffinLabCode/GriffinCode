% script for linearizing position getting neuronal data
clear; clc

% inputs
datafolder   = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-11-18'; 
int_name     = 'Int_file.mat';
vt_name      = 'VT1.mat';
missing_data = 'exclude';
vt_srate     = 30; % 30 samples/sec
measurements.stem     = 137; % in cm
measurements.goalArm  = 50;
%measurements.goalZone = 37;
%measurements.retArm   = 130;

% get linear skeleton
Startup_linearSkeleton % add paths
[data] = get_linearSkeleton(datafolder,int_name,vt_name,missing_data,measurements);
idealTraj = data.idealTraj;
rmPaths_linearSkeleton % remove paths

% get linear position
mazePos = [1 2]; % was [1 2]
[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data,mazePos);

%% load in int and position data

% load position data
[ExtractedX, ExtractedY, TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% focus on one trajectory for now
linearPosition_var = linearPosition.left;

% get int and vt data
load(int_name)

% -- plot to show what a 'linear skeleton' is -- %
figure('color','w');
plot(data.pos(1,:),data.pos(2,:),'Color',[.8 .8 .8]);
hold on;
p1 = plot(idealTraj.idealL(1,:),idealTraj.idealL(2,:),'m','LineWidth',0.2);
p1.Marker = 'o';
p1.LineStyle = 'none';
p2 = plot(idealTraj.idealR(1,:),idealTraj.idealR(2,:),'b','LineWidth',0.2);
p2.Marker = 'o';
p2.LineStyle = 'none';

% separate left/right trials
Int_left  = Int(Int(:,3)==1,:);
Int_right = Int(Int(:,3)==0,:);

% define int var for this script
Int_var = Int_left;

% get data
numTrials = length(linearPosition_var);
for triali = 1:numTrials
    X{triali}  = ExtractedX(TimeStamps >= Int_var(triali,mazePos(1)) & TimeStamps <= Int_var(triali,mazePos(2)));
    Y{triali}  = ExtractedY(TimeStamps >= Int_var(triali,mazePos(1)) & TimeStamps <= Int_var(triali,mazePos(2)));
    TS{triali} = TimeStamps(TimeStamps >= Int_var(triali,mazePos(1)) & TimeStamps <= Int_var(triali,mazePos(2)));
end

%% get spike data
cd(datafolder);

% load in our clusters
clusters = dir('TT*.txt');

% define a variable for gaussian smoothing. This tells the functions how
% many cm (or time points depending on the function) to smooth over
resolution_pos = 6; % cm smoothing

% get linearized fr for all clusters
smoothFR = []; FR = []; numSpks = []; sumTime = []; instSpk = []; instTime = [];
for ci = 1:length(clusters)
    
    % spike time stamps
    spikeTimes = textread(clusters(ci).name);

    for triali = 1:numTrials
        
        % get spiketimes
        spks = [];
        spks = spikeTimes(spikeTimes >= Int_var(triali,mazePos(1)) & spikeTimes <= Int_var(triali,mazePos(2)));       
        
        % get data across trials, organized by neuron
        [smoothFR{ci}{triali},FR{ci}{triali},numSpks{ci}{triali},sumTime{ci}{triali},...
            instSpk{ci}{triali},instTime{triali}] = linearizedFR(spks,TS{triali},linearPosition.left{triali},vt_srate,resolution_pos);
        
        % replace nans with zero
        smoothFR{ci}{triali}(isnan(smoothFR{ci}{triali})==1)=0;
        FR{ci}{triali}(isnan(smoothFR{ci}{triali})==1)=0;
        
    end
end

%% create rate maps
% since the bayesian decoder should be trained on a trial-by-trial basis,
% we'll make a linearized rate map for each trial
ratesCat   = vertcat(smoothFR{:});
numNeurons = length(clusters);

for i = 1:size(ratesCat,2)
    linear_rate_maps{i} = vertcat(ratesCat{1:numNeurons,i});
end

%% bayesian decoding

% use a variable x, then using lambda, our interested mean, we can estimate
% probability of poisson process using poisscdf - this is how we get the
% expected firing rate








    