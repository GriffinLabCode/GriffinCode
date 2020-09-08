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
resolution_time = 1; % time of smoothing
resolution_pos  = 6; % cm smoothing

% get linearized fr for all clusters
smoothFR = []; instFR = []; numSpks = []; sumTime = []; instSpk = []; instTime = [];
for ci = 1:length(clusters)
    
    % spike time stamps
    spikeTimes = textread(clusters(ci).name);

    for triali = 1:numTrials
        
        % get spiketimes
        spks = [];
        spks = spikeTimes(spikeTimes >= Int_var(triali,mazePos(1)) & spikeTimes <= Int_var(triali,mazePos(2)));       
        
        % how much time in consideration?
        totalTime = (TS{triali}(end)-TS{triali}(1))/1e6;
        
        % get neuronal activity per bin, across time (not avged within bin)
        [smoothFR_time{ci}{triali},~,instSpk{ci}{triali},...
            ~,instSpk_time{ci}{triali}] = ...
            inst_neuronal_activity(spks,TS{triali},vt_srate,totalTime,resolution_time);        

        % get neuronal activity linearized (avg activity per bin)
        [smoothFR_pos{ci}{triali},~,numSpks_pos{ci}{triali},sumTime_pos{ci}{triali},...
            ~,instTime{triali}] = linearizedFR(spks,TS{triali},linearPosition.left{triali},vt_srate,resolution_pos);
                
        % replace nans with zero
        smoothFR_time{ci}{triali}(isnan(smoothFR_time{ci}{triali})==1)=0;
        instSpk{ci}{triali}(isnan(instSpk{ci}{triali})==1)=0;
        smoothFR_pos{ci}{triali}(isnan(smoothFR_pos{ci}{triali})==1)=0;
        numSpks_pos{ci}{triali}(isnan(numSpks_pos{ci}{triali})==1)=0;        
    end
end

%% create rate maps
% since the bayesian decoder should be trained on a trial-by-trial basis,
% we'll make a linearized rate map for each trial
ratesCat_time = vertcat(smoothFR_time{:});
ratesCat_pos  = vertcat(smoothFR_pos{:});
spksCat_time  = vertcat(instSpk{:});

% get number of neurons
numNeurons = length(clusters);

for i = 1:numTrials
    rate_maps_time{i} = vertcat(ratesCat_time{1:numNeurons,i});
    rate_maps_pos{i}  = vertcat(ratesCat_pos{1:numNeurons,i});
    spks_time{i}      = vertcat(spksCat_time{1:numNeurons,i});
end

%% figure to make sense of some stuff
% plot to show difference between rate_maps_time and rate_maps_pos. Note
% that we're using the a single trial '{trial}' and the first neuron across linear
% bins '(1,:)'
trial = 1; % define which trial to look at
figure('color','w'); 
subplot 311;
    plot(rate_maps_pos{trial}(1,:),'r','LineWidth',2); axis tight; box off;
    ylabel('Smoothed FR'); xlabel('Linear Position (cm sized bins)');
    title('Firing Rates grouped by position')
subplot 312;
    timingVar = linspace(0,size(rate_maps_time{trial},2)/vt_srate,size(rate_maps_time{trial},2));
    plot(timingVar*1000,rate_maps_time{trial}(1,:),'r','LineWidth',2); axis tight; box off;
    ylabel('Smoothed FR'); xlabel('Time (ms)');
    title('Firing Rates grouped by time')
subplot 313;
    plot(timingVar*1000,linearPosition.left{trial},'k','LineWidth',2);
    ylabel('Linear Position (cm)'); xlabel('Time (ms)'); axis tight; box off;
    title('Time informs us on linear position, and linear position informs us on time')

%% one way to view "rate maps"

% -- lets define our expected FR per bin - this is where we apply the poisson cdf -- %

% get avg fr - this is for position
rateMap_3Dpos  = cat(3,rate_maps_pos{:});
rateMap_avgPos = mean(rateMap_3Dpos,3); % avg in the third dimension (trials)
rateMap_norm   = (normalize(rateMap_avgPos','range'))'; % normalize across linear bins - purely for visualizing

% make figure
figure('color','w'); imagesc(rateMap_norm); ax = gca; ax.YTick = [1:numNeurons]; 
xlabel(['Linearized Pos (cm): Int columns ',num2str(mazePos(1)),' through ',num2str(mazePos(2))]); 
ylabel('Neuron Number'); shading interp; c = colorbar;
ylabel(c,'Normalized Smoothed Firing Rate');

%% bayesian decoding
% these variables are named like those in Shin et al., 2019

%{
% -- start by doing this for one trial and one neuron, 
        then we will do it for all neurons and multiply the products, then
        make for loop to do it across all trials. -- %
%}

% define the trial to look at
trial = 1; 

% the expected FR should be the firing rate expected given that you observe
% the rat in position "x" - since we care about position, using the
% rate_maps_pos variable.
expectedFRs = rate_maps_pos{trial}(1,:); % 1 trial, 1 neuron

% define tau and get the number of samples that is equivalent to it
tau = 500; % ms
numSamplesInTau = tau*vt_srate*(1/1000); % Nms * 30 samples/sec * (1sec/1000ms) = M samples

% group neuronal activity based on tau - get data every 15 samples. Now
% we're interested in time, so we will use instSpk variable, which is
% spikes across time (see 2nd figure in script)
spikes_temp = spks_time{trial}(1,:);
numElements = numel(spikes_temp);
loopingIdx  = 1:15:numElements;
for ii = 1:numel(loopingIdx)-1
    % need to sum the spikes within the tau window. Note that you have to
    % do this complicated line below because tau may not evenly fit into
    % the length of the data. For example 272 (number
    % of example data points)/ 15 (tau in samples) = 18.13. We need an
    % integer in order to group the data, not a floating point number.
    spikes(ii) = sum(spikes_temp(loopingIdx(ii):loopingIdx(ii+1)-1));
end

% now that we have (at least I think) the variables we need, we should be
% able to apply the formula

% tau*expectedFR^spikes

    