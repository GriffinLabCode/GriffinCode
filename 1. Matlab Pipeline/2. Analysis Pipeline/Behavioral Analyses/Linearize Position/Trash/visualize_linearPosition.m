%% linear position helper

function [linear_position_sm,position_data] = linearPosition_helper(datafolder,int_name,vt_name,missing_data,linearSkel_name)

% get vt data
[ExtractedX,ExtractedY,TimeStamps_VT] = getVTdata(datafolder,missing_data,vt_name);

% vt can vary a little bit, but we can easily define it
vt_srate = round(getVTsrate(TimeStamps_VT,'y'));

% define number of trials using int
load(int_name)
numTrials = size(Int,1);

% load linear position data
linearStruct = load(linearSkel_name); % load('linearPositionData_JS');
idealTraj = linearStruct.idealTraj;

try
    
    % define measurements variable    
    measurements = linearStruct.data.measurements;
    % define bin_size
    bin_size = linearStruct.data.bin_size;

catch
    measurements = linearStruct.measurements;
    bin_size = linearStruct.bin_size;    
end


% calculate converted distance in cm. This tells you how far the rat ran
conv_distance = round(measurements.total_distance*bin_size);
total_dist = conv_distance;

% define which measurements to use
meas2use = [measurements.stem measurements.goalArm];

% define which int measures to use
Int2use = [1 2]; % stem entry to gz entry

% define int lefts and rights
trials_left  = find(Int(:,3)==1); % lefts
trials_right = find(Int(:,3)==0); % rights

%% -- stem to gz -- %%

% get position data from stem entry to goal zone entry
numTrials  = size(Int,1);
prePosData = cell([1 size(Int,1)]);
for i = 1:numTrials
    stem2gzPosData{i}(1,:) = ExtractedX(TimeStamps_VT >= Int(i,1) & TimeStamps_VT <= Int(i,2));
    stem2gzPosData{i}(2,:) = ExtractedY(TimeStamps_VT >= Int(i,1) & TimeStamps_VT <= Int(i,2));
    stem2gzPosData{i}(3,:) = TimeStamps_VT(TimeStamps_VT >= Int(i,1) & TimeStamps_VT <= Int(i,2));
end

% get specific linear bins of interest for stem to goal zone entry
bins2use = [];
bins2use = 1:sum(meas2use);
for i = 1:numTrials
    idealTraj_Stem2GoalZone{i} = idealTraj{i}(:,bins2use);
end

%[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data,mazePos);
clear linearPos_stem2gz position_lin
[linearPos_stem2gz,position_stem2gz] = get_linearPosition(idealTraj_Stem2GoalZone,bins2use,stem2gzPosData);

%% -- gz entry to ra exit -- %%

% get position data from stem entry to goal zone entry
numTrials  = size(Int,1);
prePosData = cell([1 size(Int,1)]);
for i = 1:numTrials
    gz2raPosData{i}(1,:) = ExtractedX(TimeStamps_VT >= Int(i,2) & TimeStamps_VT <= Int(i,8));
    gz2raPosData{i}(2,:) = ExtractedY(TimeStamps_VT >= Int(i,2) & TimeStamps_VT <= Int(i,8));
    gz2raPosData{i}(3,:) = TimeStamps_VT(TimeStamps_VT >= Int(i,2) & TimeStamps_VT <= Int(i,8));
end

% get specific linear bins of interest for stem to goal zone entry
bins2use = [];
bins2use = sum(meas2use):total_dist;
for i = 1:numTrials
    idealTraj_gz2ra{i} = idealTraj{i}(:,bins2use);
end

% linear position
clear linearPos_gz2ra
[linearPos_gz2ra,position_gz2ra] = get_linearPosition(idealTraj_gz2ra,bins2use,gz2raPosData);

%% concatenate trajectories and position data
for i = 1:numTrials
    linear_position{i} = horzcat(linearPos_stem2gz{i},linearPos_gz2ra{i});
    position_data{i}   = horzcat(stem2gzPosData{i},gz2raPosData{i});
end

%% smooth data

for i = 1:numTrials
    % smooth linear position - this is important, especially if you're
    % using 1cm bins. Smoothing by the sampling rate seems to do the trick.
    linear_position_sm{i} = smoothdata(linear_position{i},'gauss',vt_srate);    
end

%% save data
% save data to datafolder
cd(datafolder)
save('linearPositionData.mat','linearPositionSmooth','linearPosition','position_lin','linearPosUncorrected','idealTraj','prePosData');





