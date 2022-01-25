% script for linearizing position getting neuronal data
clear; clc

% inputs
datafolder   = 'X:\01.Experiments\RERh Inactivation Recording\Usher\Muscimol\Baseline';
int_name     = 'Int_VTE_JS.mat'; % 'Int2_JS'; % 'Int_file.mat';
vt_name      = 'VT1.mat';
missing_data = 'interp';
vt_srate     = 30; % 30 samples/sec
clear measurements
bin_size = 1; % in cm
measurements.stem     = round(112/bin_size); % in cm was 137
measurements.goalArm  = round(56/bin_size); % was 50
%measurements.goalZone = 29; % was 37
%measurements.retArm   = 130;

% get linear skeleton - this has to be int specific. In other words, give
% the file your int, and create N number of points that are only within the
% boundaries of the int file. Or get linear skeleton, then dsearch
% nposition and timestamps. Currently, this is working better, however, its
% still not perfect
Int_indicator.left  = 1;
Int_indicator.right = 0;
[data] = get_linearSkeleton(datafolder,int_name,vt_name,missing_data,measurements,Int_indicator);

% if you make the linear skeleton too long, then you will not get enough
% points in return. On the contrary, if you make the linear skeleton too
% short, you'll get enough points in return. How do I get around this? I
% could just use a linear skeleton, then somehow redefine the int. Like
% find int positions greater than linear skeleton start and end?
% Essentially, we need a consistent way for linear skeleton to be a
% controlled size, the size indicated by our measurements. This needs to be
% the case for every trial.

% put linear skeleton into a cell array and return its order to the correct
% trajectory sequence based on the int file. The variable name will be
% idealTraj and is a cell array for all trials
load(int_name);
numTrials = size(Int,1);
idealTraj = cell([1 numTrials]);
for triali = 1:numTrials   
    if Int(triali,3) == 0 % right turn
        idealTraj{triali} = data.idealTraj.idealR;        
    elseif Int(triali,3) == 1 % left turn
        idealTraj{triali} = data.idealTraj.idealL;
    end
end

% calculate converted distance in cm. This tells you how far the rat ran
conv_distance = round(data.measurements.total_distance*bin_size);
total_dist = conv_distance;

%% get linear position
% load int file and define the maze positions of interest
mazePos = [1 2]; % was [1 2]

% load position data
[ExtractedX, ExtractedY, TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% define int lefts and rights
trials_left  = find(Int(:,3)==1); % lefts
trials_right = find(Int(:,3)==0); % rights

% get position data into one variable
numTrials  = size(Int,1);
prePosData = cell([1 size(Int,1)]);
for i = 1:numTrials
    prePosData{i}(1,:) = ExtractedX(TimeStamps >= Int(i,mazePos(1)) & TimeStamps <= Int(i,mazePos(2)));
    prePosData{i}(2,:) = ExtractedY(TimeStamps >= Int(i,mazePos(1)) & TimeStamps <= Int(i,mazePos(2)));
    prePosData{i}(3,:) = TimeStamps(TimeStamps >= Int(i,mazePos(1)) & TimeStamps <= Int(i,mazePos(2)));
end

%[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data,mazePos);
clear linearPosition position
[linearPosition,position] = get_linearPosition(idealTraj,total_dist,prePosData);
%[linearPosition,position] = get_linearPosition(datafolder,idealTraj,Int,ExtractedX,ExtractedY,TimeStamps_VT,mazePos,stemOrientation,startStemPos);

%% get spike data
cd(datafolder);

% load in our clusters
clusters = dir('TT*.txt');

spks = [];
for ci = 1:length(clusters)
    
    % spike time stamps
    spikeTimes = textread(clusters(ci).name);
    
    % cell array of spiking data
    spikeCell{ci} = spikeTimes;

    for triali = 1:numTrials
        
        % get spiketimes
        %spks = [];
        spks{ci,triali} = (spikeTimes(spikeTimes >= (position.TS{triali}(1)-(5*1e6)) & spikeTimes <= (position.TS{triali}(1)+(5*1e6))))./1e6;       
    
        % anchor - this is the point to subtract all data from.
        anchorTimes(triali) = position.TS{triali}(1)./1e6;
        
    end
end



[relativeSpikeTimes] = getRelativeSpikeTimes(spks,anchorTimes);
totalDur = 5;
bin = .01;
edges = -totalDur:bin:totalDur;
nTrials = length(relativeSpikeTimes);

figure;
subplot(311)
for i = 1:nTrials
    n(:,i) = histc(relativeSpikeTimes{i},edges);
    plot(relativeSpikeTimes{i},i,'.k')
    axis([-5 5 0 nTrials])
    hold on
end

% assign tick height
ticks     = 0.4;
pre_time  = -5;
post_time = 5;

figure;
ylim = [0 nTrials+1]; % for plotting
xmin = pre_time; % for plotting
xmax = post_time; % for plotting
subplot(3,1,1); hold on;
%set(gca,'xlim',[xmin xmax],'ylim',ylim,...
    %'box','off','tickdir','out','ytick',[],'yticklabel',[]);
for i = 1:nTrials
    %n(:,i) = histc(relativeSpikeTimes{i},edges);
    %plot([relativeSpikeTimes{i} relativeSpikeTimes{i}],[i-ticks i+ticks],'k');
    if length(relativeSpikeTimes{i}) == 2
        for ii = 1:length(relativeSpikeTimes{i})
            line([relativeSpikeTimes{i}(ii) relativeSpikeTimes{i}(ii)],[i-ticks i+ticks],'Color','k')
        end
    else
        line([relativeSpikeTimes{i} relativeSpikeTimes{i}],[i-ticks i+ticks],'Color','k')
    end
%axis([-5 5 0 nTrials])
end








%{














% reorient
for i = 1:length(relativeSpikeTimes)
    relativeSpikeTimes{i} = relativeSpikeTimes{i}';
end

figure;
[xPoints, yPoints] = plotSpikeRaster(relativeSpikeTimes);



% Define parameters
nTrials=length(Int(:,1));
spksec=spk/1e6;
TrialStart = (Int(2:nTrials,1)-delay_length*1e6)/1e6;
TrialEnd = Int(2:nTrials,1)/1e6;
DelayCenter = (Int(2:nTrials,1)-(delay_length/2)*1e6)/1e6;
intsec = Int/1e6;
ntrials = size(Int,1);

edges = (-(delay_length/2):bin:delay_length/2);

for i = 2:nTrials
    s=spksec(find(spksec>TrialStart(i-1) & spksec<TrialEnd(i-1)));
    ev=DelayCenter(i-1);
    s0=s-ev; 
    n(:,i-1) = histc(s0,edges);
    if isempty(s)==0,subplot(311),plot(s0,i,'k.'), end
    axis([-(delay_length/2) delay_length/2 0 nTrials+1])
    hold on
end
%}

