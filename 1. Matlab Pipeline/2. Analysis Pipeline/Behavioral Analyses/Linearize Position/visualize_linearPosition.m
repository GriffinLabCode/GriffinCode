%% create and accept/reject linear position data
% script to accept/reject linear position data

clear; clc; close all;

% fix linear bins? This is only really important if bins overlap
fix_bins = 1;

% load int file and define the maze positions of interest
mazePos = [1 8];

% manually switch to the datafolder of interest
datafolder = pwd;

% get vt data
[ExtractedX,ExtractedY,TimeStamps_VT] = getVTdata(datafolder,'interp','VT1.mat');

% vt can vary a little bit, but we can easily define it
vt_srate = round(getVTsrate(TimeStamps_VT,'y'));

% define number of trials using int
load('Int_JS_fixed')
numTrials = size(Int,1);

% load linear position data
linearStruct = load('linearSkeleton_returns_final'); % load('linearPositionData_JS');
idealTraj = linearStruct.idealTraj;

% calculate converted distance in cm. This tells you how far the rat ran
conv_distance = round(linearStruct.data.measurements.total_distance*linearStruct.data.bin_size);
total_dist = conv_distance;

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
clear linearPosition linearPositionSmooth linearPosUncorrected position_lin
[linearPositionSmooth,linearPosition,position_lin,linearPosUncorrected] = get_linearPosition(idealTraj,prePosData,vt_srate,fix_bins);

% save data to datafolder
cd(datafolder)
save('linearPositionData.mat','linearPositionSmooth','linearPosition','position_lin','linearPosUncorrected','idealTraj','prePosData');





