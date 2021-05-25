%% linear position helper
%
% this function is meant to structure your data so that you can accurately
% get linear position data using T-maze position.
%
% One downside that is somewhat inevitable is that between goal exit and
% goal entry, there is going to be some missing data points. Smoothing
% seems to handle it well enough. This is a byproduct of a fail-safe coded
% into the get_linearPosition code that accounts for instances where you
% start your int file before you start your linear trajectory. 
%
% written by John Stout

function [linear_position,linear_position_sm,position_data,total_dist,bin_size] = linearPosition_helper_TmazeEdition(datafolder,int_name,vt_name,missing_data,linearSkel_name)

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

% define measurements and bin_size variables   
try   
    measurements = linearStruct.data.measurements;
    bin_size = linearStruct.bin_size;
catch
    measurements = linearStruct.measurements;
    bin_size = linearStruct.bin_size;    
end

% calculate converted distance in cm. This tells you how far the rat ran
conv_distance = round(measurements.total_distance*bin_size);
total_dist = conv_distance/bin_size;

% define which measurements to use
meas2use = [measurements.stem measurements.goalArm];

%% -- stem to gz -- %%

% get position data from stem entry to goal zone entry
numTrials  = size(Int,1);
prePosData = cell([1 size(Int,1)]);
for i = 1:numTrials
    stem2gzPosData{i}(1,:) = ExtractedX(TimeStamps_VT > Int(i,1) & TimeStamps_VT <= Int(i,2));
    stem2gzPosData{i}(2,:) = ExtractedY(TimeStamps_VT > Int(i,1) & TimeStamps_VT <= Int(i,2));
    stem2gzPosData{i}(3,:) = TimeStamps_VT(TimeStamps_VT > Int(i,1) & TimeStamps_VT <= Int(i,2));
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
    gz2raPosData{i}(1,:) = ExtractedX(TimeStamps_VT > Int(i,2) & TimeStamps_VT <= Int(i,8));
    gz2raPosData{i}(2,:) = ExtractedY(TimeStamps_VT > Int(i,2) & TimeStamps_VT <= Int(i,8));
    gz2raPosData{i}(3,:) = TimeStamps_VT(TimeStamps_VT > Int(i,2) & TimeStamps_VT <= Int(i,8));
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
    position_data.X{i} = horzcat(position_stem2gz.X{i},position_gz2ra.X{i});
    position_data.Y{i} = horzcat(position_stem2gz.Y{i},position_gz2ra.Y{i});
    position_data.TS{i} = horzcat(position_stem2gz.TS{i},position_gz2ra.TS{i});    
end

%% smooth data

for i = 1:numTrials
    % smooth linear position - this is important, especially if you're
    % using 1cm bins. Smoothing by the sampling rate seems to do the trick.
    linear_position_sm{i} = smoothdata(linear_position{i},'gauss',vt_srate);    
end

%{ 
% to visualize
for i = 1:length(linear_position_sm);
    figure(); plot(linear_position_sm{i},'k');
    pause;
end
%}

end




