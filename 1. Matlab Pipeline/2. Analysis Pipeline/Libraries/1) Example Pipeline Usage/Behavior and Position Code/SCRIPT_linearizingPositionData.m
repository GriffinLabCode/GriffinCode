%% SCRIPT_linearizingPositionData
% Why does this matter? Why even linearize your data? 
% There are many reasons. First, getting metrics like velocity/acceleration
% are soooo much easier as we're working with only 1 dimension. But more
% importantly, we're reducing the dimensions of the data, which makes our
% data easier to interpret. For example, if you compare 2D position data,
% you could make a spike heat map over top of it. Very useful! But it is a
% lotttt easier to work with 1 dimensional spike data. We can actually look
% at spikes across linear bins and make sense of how neurons are active
% based on the position of the animal. Or use linear position to identify
% periods of immobility to more easially extract sharp wave ripple events.
% 
% Put simply, linearizing data is a verry simply dimensionality reduction
% technique

clear; clc;

% general inputs
datafolder   = 'X:\01.Experiments\RERh Inactivation Recording\Eric2\Muscimol\Muscimol';
int_name     = 'Int_VTE_JS.mat'; % Int file name
vt_name      = 'VT1.mat'; % VT file name
missing_data = 'interp'; % how to handle missing data
vt_srate     = 30; % 30 samples/sec - VT sampling rate

% linearizing inputs - make sure your measurements line up with how you
% define the maze locations
bin_size              = 1; % in cm - bins refer to linear bins on the maze
trueStemLength        = 112; % cm
trueGoalArmLength     = 56; %cm
measurements.stem     = round(trueStemLength/bin_size);    % convert to bins
measurements.goalArm  = round(trueGoalArmLength/bin_size); % convert to bins

%% get linear position
% step 1) define a linear skeleton
% step 2) fit position data to the linear skeleton bins

% -- step 1 -- %

% get linear skeleton - this has to be int specific. Your linear skeleton
% provides a backbone for binning your trial-by-trial data. "Stem" should
% be starting and ending point of stem (usually entry to T-junction
% intersection). Afterwards, just assign 1 single point for goal arm
Int_indicator.left  = 1; % tell the code what Int(:,3) is for left trials
Int_indicator.right = 0;
[skelData] = get_linearSkeleton(datafolder,int_name,vt_name,missing_data,measurements,Int_indicator);
idealTraj  = skelData.idealTrajOrganized; % this data is fit like the Int file

% This tells you how far the rat ran
%conv_distance = round(skelData.measurements.total_distance*bin_size);
total_dist = skelData.measurements.total_distance; % in cm

% -- step 2 -- %

% load int file and define the maze positions of interest
mazePos = [1 2]; % this MUST be consistent with what you did above

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
[linearPosition,position,trialTimes] = get_linearPosition(idealTraj,total_dist,prePosData,vt_srate);

% -- now lets check our work -- %

% plot linear position
figure('color','w')
plot(trialTimes{1},linearPosition{1},'k','LineWidth',2)
xlabel('Time (sec)')
ylabel('Linear Position')
ylimits = ylim;
box off

% identify choice point time
cpTimeIdx = find(position.TS{1} == Int(1,5));
cpTime = trialTimes{1}(cpTimeIdx);
cpPos  = linearPosition{1}(cpTimeIdx);
line([cpTime cpTime],[ylimits(1) ylimits(2)],'Color','r')

% this line tells me that ~110-112 is where CP entry is. 112 is prob the
% divergence point
cpEntry = linearPosition{1}(cpTimeIdx); % use the index. To make more sense do the following:
% figure; plot(linearPosition{1}); % Look at the x-axis! It's an index!

% plot position data to check what the rats up to
figure; plot(ExtractedX,ExtractedY);
hold on; plot(position.X{1}(1:cpTimeIdx),position.Y{1}(1:cpTimeIdx),'r','LineWidth',2)

% -- what if you find that a certain location on the plot might be a better
% indicator of where the rat is? For example, 112 may be a better CP based
% on the linear position data; - Notice how it flat lines!
figure('color','w')
plot(linearPosition{1})

% to get this data point:
newCPidx = find(linearPosition{1} == 112);
newCPidx = newCPidx(1); % we only need one instance of this variable

% now lets see what the rat was doing
figure; plot(ExtractedX,ExtractedY);
hold on; plot(position.X{1}(1:newCPidx),position.Y{1}(1:newCPidx),'r','LineWidth',2)

% notice that we've identified the divergence point as 112



