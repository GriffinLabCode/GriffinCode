% script for linearizing position getting neuronal data
clear; clc

% inputs
datafolder   = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-11-18'; 
int_name     = 'Int_file.mat';
vt_name      = 'VT1.mat';
missing_data = 'exclude';
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
mazePos = [1 2];
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

%% plot linear position by time and get velocity via differentiation
trial = 18;
figure('color','w'); hold on;
axisColors = [{'b'},{'r'}];
yyaxis left
    timeDiff  = (TS{trial}(end)-TS{trial}(1))/1e6; % in sec
    timingVar = linspace(0,timeDiff,length(TS{trial}));
    p1 = plot(timingVar,linearPosition_var{trial},axisColors{1},'LineWidth',2,'HandleVisibility','off');
    ylabel('Linear Position (cm)')
    xlabel('Time (sec) from stem entry to goal entry ');
    box off
% estimate instantaneous velocity
yyaxis right; hold on;
    %vel = diff(linearPosition_left{1})./(diff(TS{1}./1e6));
    %vel = gradient(linearPosition_left{1})./(gradient(TS{1}./1e6));
    [vel,accel] = linearPositionKinematics(linearPosition_var{trial},timingVar);   
    [smoothVel,windowVel] = smoothdata(vel,'gaussian',20);
    [smoothAcc,windowAcc] = smoothdata(accel,'gaussian',20);    
    %plot(timingVar(2:end),smoothVel,axisColors{2},'LineWidth',2)
    p2 = plot(timingVar,smoothVel,axisColors{2},'LineWidth',2,'HandleVisibility','off');   
    p3 = plot(timingVar,smoothAcc,'k','LineWidth',2);
    ylabel('Velocity (cm/sec)') 
ax = gca;
ax.YAxis(1).Color = axisColors{1};
ax.YAxis(2).Color = axisColors{2};
legend('Acceleration (cm/sec^2)')
legend box off
title(['Trial number ',num2str(trial)])

%% get spike data
cd(datafolder);

% load in our clusters
clusters = dir('TT*.txt');

% a way to define which cluster to look at
ci = 1;

% spike time stamps
spikeTimes = textread(clusters(ci).name);

% isolate the name of the cluster - unnecessary line
cluster = clusters(ci).name(1:end-4);

%% plot spike data on a trial-by-trial basis (includes linear position and time)
% this will allow us to correlate spiking to linear position, velocity, and
% acceleration. We will also develop code to track head-direction across
% time. These variables could be used in a glm as predictors?

% trial is defined above
trial_linearPos = []; trial_time = [];
trial_linearPos = linearPosition_var{trial};
trial_time      = TS{trial};

% get spikes occuring on all trials
spike_trials = [];
for triali = 1:numTrials
    spike_trials{triali} = spikeTimes(spikeTimes >= Int_var(triali,mazePos(1)) & spikeTimes <= Int_var(triali,mazePos(2)));    
end

% get spike occuring on the trial of interest
trial_spike = [];
trial_spike = spike_trials{trial};

% shape of timestamp data - this will be instantaneous spike
instSpk = [];
instSpk = NaN(size(TS{trial}));

% find nearest points
spkSearch = [];
spkSearch = dsearchn(trial_time',trial_spike);

% replace and create boolean spk data
instSpk(spkSearch) = 1;
instSpk(isnan(instSpk)==1)=0;
instSpk_idx  = find(instSpk == 1);
instSpk_time = timingVar(instSpk_idx); % use this to plot spks across time

% make time vector - instantaneous time intervals
instTime = [];
instTime = repmat(1/30,size(TS{trial})); % seconds sampling rate
    
% get instantaneous firing rate - this doesn't really make sense unless you
% collapse across specific bins
instFR = instSpk./instTime;

% figure
figure('color','w'); hold on;
p1 = plot(timingVar,linearPosition_var{trial},axisColors{1},'LineWidth',2,'HandleVisibility','off');
ylabel('Linear Position (cm)')
xlabel('Time (sec) from stem entry to goal entry ');
box off
for i = 1:length(instSpk_idx)
    l1 = line([instSpk_time(i) instSpk_time(i)], [180 200]);
    l1.Color = 'k';
end
% define t-junction loc
tjunction_time   = Int_var(trial,5);
locIdx4tjunction = find(TS{trial} == tjunction_time); % time is directly linked to linear pos
tjun_loc  = linearPosition_var{trial}(timeIdx4tjunction);
tjun_time = timingVar(timeIdx4tjunction);
% plot a line at T-junction
l2 = line([0 tjun_time], [tjun_loc tjun_loc]);
l2.Color = 'm';
% add text denoting t-junction
t1 = text([0], [tjun_loc+5],'T-junction entry');
t1.Color = 'm';

% -- smooth spikes to create a rate -- %

% smooth with N time resolution
resolution_time = 1; % 1/3 is 1/3 of a sec
time_interval   = round(resolution_time/instTime(1));
FR = smoothdata(instSpk,'gaussian',time_interval);
figure('color','w'); hold on;
plot(timingVar,FR,'c','LineWidth',2)
for i = 1:length(instSpk_idx)
    l1 = line([instSpk_time(i) instSpk_time(i)], [0 0.1]);
    l1.Color = 'k';
end
ylabel(['Inst. FR (smoothed with ',num2str(resolution_time),' sec. interval'])
xlabel('Time (sec) from stem entry to goal entry')
ylimits = ylim;
l2 = line([tjun_time tjun_time], [ylimits(1) ylimits(2)]);
l2.Color = 'r';
% add text denoting t-junction
t1 = text([tjun_time], [ylimits(2)],'T-junction entry');
t1.Color = 'm';

%% plotting everything so far
% -- subplots with firing rate, linear pos, acceleration, and velocity -- %
figure('color','w')
subplot 311
    p1 = plot(timingVar,linearPosition_var{trial},'k','LineWidth',2,'HandleVisibility','off');
    ylabel('Linear Position (cm)')
    l2 = line([0 tjun_time], [tjun_loc tjun_loc]);
    l2.Color = [.5 .5 .5];
    % add text denoting t-junction
    t1 = text([0], [tjun_loc+20],'T-junction entry');
    t1.Color = [.5 .5 .5];
    yyaxis right
    plot(timingVar,FR,'b','LineWidth',2)    
    ylabel(['Smoothed FR'])
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'b';
    box off
    
subplot 312
    p2 = plot(timingVar,smoothVel,'r','LineWidth',2,'HandleVisibility','off'); 
    ylabel('Velocity (cm/sec)')
    yyaxis right
    plot(timingVar,FR,'b','LineWidth',2)    
    ylabel(['Smoothed FR'])
    ax = gca;
    ax.YAxis(1).Color = 'r';
    ax.YAxis(2).Color = 'b';
    ylimits = ylim;
    l2 = line([tjun_time tjun_time], [ylimits(1) ylimits(2)]);
    l2.Color = [.5 .5 .5];
    % add text denoting t-junction
    t1 = text([tjun_time], [ylimits(2)],'T-junction entry');
    t1.Color = [.5 .5 .5];    
    box off

subplot 313
    p3 = plot(timingVar,smoothAcc,'m','LineWidth',2,'HandleVisibility','off'); 
    ylabel('Acceleration (cm/sec^2)')
    yyaxis right
    plot(timingVar,FR,'b','LineWidth',2)    
    ylabel(['Smoothed FR'])
    ax = gca;
    ax.YAxis(1).Color = 'm';
    ax.YAxis(2).Color = 'b';  
    box off
    xlabel('Time (sec) from stem entry to goal entry ');
    ylimits = ylim;
    l2 = line([tjun_time tjun_time], [ylimits(1) ylimits(2)]);
    l2.Color = [.5 .5 .5];
    % add text denoting t-junction
    t1 = text([tjun_time], [ylimits(2)],'T-junction entry');
    t1.Color = [.5 .5 .5]; 
    
%% plot spike data binned by linear position (ignores time)
% initialize some variables
binSpks = []; binTime = []; numSpks =[]; sumTime = []; FR = []; FRmat = [];
normFR = []; smoothFR = [];

% calculate instantaneous firing rate
for triali = 1:length(linearPosition_var)

    spks = [];
    spks = spikeTimes(spikeTimes >= TS{triali}(1) & spikeTimes <= TS{triali}(end));

    % shape of timestamp data
    spkForm = [];
    spkForm = NaN(size(TS{triali}));

    % find nearest points
    spkSearch = [];
    spkSearch = dsearchn(TS{triali}',spks);

    % replace and create boolean spk data
    spkForm(spkSearch) = 1;
    spkForm(isnan(spkForm)==1)=0;

    % make time vector
    timeForm = [];
    timeForm = repmat(1/30,size(TS{triali})); % seconds sampling rate

    % 30 samples per sec means i can divide each indiivudal point by 30.
    %clear binSpks binTime
    for i = 1:max(linearPosition_var{triali}) % loop across the number of bins
        binSpks{triali}{i} = spkForm(linearPosition_var{triali} == i);
        binTime{triali}{i} = timeForm(linearPosition_var{triali} == i);
    end

    % calculate firing rate per bin
    numSpks{triali} = cellfun(@sum,binSpks{triali});
    sumTime{triali} = cellfun(@sum,binTime{triali});

    % firing rate (spks/sec) - this is instantaneous firing rate
    FR{triali} = numSpks{triali}./sumTime{triali};
    
    % remove nans - why do we get them?
    %FR{triali} 
end

numLocations = numel(spikes);
prob_spks_given_location = numSpks{1}./numLocations;

% important for later
%{
% concatenate and smooth data
FRmat = vertcat(FR{:});
FRmat(find(isnan(FRmat)==1))=0;

% smooth
VidSrate = 30;
gauss_width = 60; 
gauss_timeWidth = gauss_width*(1/VidSrate); % this is in seconds
n = -(gauss_width-1)/2:(gauss_width-1)/2;
alpha       = 4; % std = (N)/(alpha*2) -> https://www.mathworks.com/help/signal/ref/gausswin.html
w           = gausswin(gauss_width,alpha);
stdev = (gauss_width-1)/(2*alpha);
y = exp(-1/2*(n/stdev).^2);

% convolve data with gaussian - remove a certain path to avoid mixing up
% functions
clear smoothFR normFR
for i = 1:length(FR)
    % smooth data
    smoothFR(i,:) = conv(FRmat(i,:),w,'same');
    % normalize firing
    normFR(i,:) = normalize(smoothFR(i,:),'range');
end

% store data
FRdata.normFR{nn-2}{ci}       = normFR;
FRdata.smoothFR{nn-2}{ci}     = smoothFR;
FRdata.numSpikes{nn-2}{ci}    = numSpks;
FRdata.FR{nn-2}{ci}           = FRmat;
%}