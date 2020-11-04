%% create and accept/reject linear position data
% this function is designed so that the user can manually accept/reject
% linear position variables. It is suggested that the users visualize their
% linear positions per session so that you know there are no issues with
% the code.
%
% -- INPUTS -- %
% datafolder: string containing datafolder directory
% linearPos_name: name of linear skeleton variable (use get_linearSkeleton
%                   if your data is from a T-maze and you have an int
%                   file). Use SCRIPT_saveLinearSkeleton for assistance.
% int_name: name of int file
% vt_name: video track name
% missing_data: how to handle missing vt data
%
% -- OUTPUTS -- %
% Outputs are saved and no returned
%
% written by John Stout

function [] = visualize_linearPosition(datafolder,linearPos_name,int_name,vt_name,missing_data)

load(linearPos_name);

[ExtractedX,ExtractedY,TimeStamps_VT] = getVTdata(datafolder,missing_data,vt_name);

% vt can vary a little bit, but we can easily define it
vt_srate = round(getVTsrate(TimeStamps_VT,'y'));

% define number of trials using int
load(int_name)
numTrials = size(Int,1);

% load linear position data
linearStruct = load(linearPos_name); % load('linearPositionData_JS');
idealTraj = linearStruct.idealTraj;

% calculate converted distance in cm. This tells you how far the rat ran
conv_distance = round(linearStruct.data.measurements.total_distance*linearStruct.data.bin_size);
total_dist = conv_distance;

% load int file and define the maze positions of interest
mazePos = [1 8];

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
[linearPositionSmooth,linearPosition,position_lin,linearPosUncorrected] = get_linearPosition(idealTraj,prePosData,vt_srate);

% save data to datafolder
cd(datafolder)
save('linearPositionData.mat','linearPositionSmooth','linearPosition','position_lin','linearPosUncorrected','idealTraj','prePosData');




