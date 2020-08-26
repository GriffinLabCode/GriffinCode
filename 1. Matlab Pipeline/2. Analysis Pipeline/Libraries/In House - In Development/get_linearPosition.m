%% separate left and right trajectories
% -- INPUTS -- %
% datafolder: string containing directory of data
% idealTraj: the trajectory skeleton obtained from get_linearSkeleton
% int_name: int file name
% vt_name: video track file name
% missing_data: can be 'ignore', 'exclude', or 'interp'
%
% -- OUTPUTS -- %
% linearPosition: linearized positions across all trials
% position: position coordinate data
%
% written by John Stout with major insight from van der meer code

function [linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data)

% get vt data
[ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% -- this needs to be flexible, change me! -- %
%{
% define the convFact variable
data.measurements.convFact(1:2) = [2.09 2.04]; % left room is easy. its almost a perfect square. first col is x, second y

% converted
ExtractedX = ExtractedX./data.measurements.convFact(1);
ExtractedY = ExtractedY./data.measurements.convFact(2);
%}

% load int file
load(int_name)

% separate left/right trials
Int_left  = Int(Int(:,3)==1,:);
Int_right = Int(Int(:,3)==0,:);

% get left trajectory position
for triali = 1:size(Int_left,1)
    position.X_left{triali} = ExtractedX(TimeStamps >= Int_left(triali,1) & TimeStamps <= Int_left(triali,8));
    position.Y_left{triali} = ExtractedY(TimeStamps >= Int_left(triali,1) & TimeStamps <= Int_left(triali,8));
end

% get right trajectory position
for triali = 1:size(Int_right,1)
    position.X_right{triali} = ExtractedX(TimeStamps >= Int_right(triali,1) & TimeStamps <= Int_right(triali,8));
    position.Y_right{triali} = ExtractedY(TimeStamps >= Int_right(triali,1) & TimeStamps <= Int_right(triali,8));
end

%% linearize position

% left linear position
numTrials = length(position.X_left);
for i = 1:numTrials
    
    % get coordinate points between ideal trajectory and real data
    linearPosition.left{i} = griddata(idealTraj.idealL(1,:),idealTraj.idealL(2,:),1:length(idealTraj.idealL(1,:)),position.X_left{i},position.Y_left{i},'nearest');

end

% right linear position
numTrials = length(position.X_right);
for i = 1:numTrials
    
    % get coordinate points between ideal trajectory and real data
    linearPosition.right{i} = griddata(idealTraj.idealR(1,:),idealTraj.idealR(2,:),1:length(idealTraj.idealR(1,:)),position.X_right{i},position.Y_right{i},'nearest');

end

end