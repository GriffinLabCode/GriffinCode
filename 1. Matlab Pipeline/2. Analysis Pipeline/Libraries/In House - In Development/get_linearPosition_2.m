%% separate left and right trajectories
%
% -- INPUTS -- %
% datafolder: string containing directory of data
% idealTraj: the trajectory skeleton obtained from get_linearSkeleton
% position_data: a cell array where each cell is a trial, and within each
%                   cell there is a 3xN array. The first row is X data,
%                   second row is Y data, third row is TimeStamps. Note
%                   that this is refering to video tracking position data.
%                       -> position_data{1}(1,:) would give you the
%                           x position data for all timestamps "(1,:)" in
%                           trial 1 "{1}"
%
% -- OUTPUTS -- %
% linearPosition: linearized positions across all trials
% position_lin: updated position data
%
% The use of idealTraj and griddata was taken from Van Der Meer code. The
% rest was written by John Stout.

function [linearPosition,position_lin] = get_linearPosition_2(datafolder,idealTraj,position_data)

% clip data based on linear skeleton
numTrials   = length(idealTraj);
position.X  = cell([1 numTrials]);
position.Y  = cell([1 numTrials]);
position.TS = cell([1 numTrials]);
for i = 1:numTrials
    % estimate start and end of trajectory using skeleton - this will clip the
    % data
    startTrajPos  = round(idealTraj{i}(:,1));   % start coordinates
    endTrajPos    = round(idealTraj{i}(:,end)); % end coordinates
    
    idx_start = []; idx_end = [];
    % using the trajectory skeleton, we derived the start and end of the
    % trajectory. Now, find the nearest cartesian points in the actual
    % position data. Maze orientation should not affect this
    idx_start = dsearchn(position_data{i}(1:2,:)',startTrajPos');
    idx_end   = dsearchn(position_data{i}(1:2,:)',endTrajPos');
    
    % now use the index to get position data. This is the updated position
    % data
    position_lin.X{i}  = position_data{i}(1,idx_start:idx_end);
    position_lin.Y{i}  = position_data{i}(2,idx_start:idx_end);
    position_lin.TS{i} = position_data{i}(3,idx_start:idx_end);
end

% linear position
linearPosition = cell([1 numTrials]);
for i = 1:numTrials
    
    % get coordinate points between ideal trajectory and real data
    linearPosition{i} = griddata(idealTraj{i}(1,:),idealTraj{i}(2,:),1:length(idealTraj{i}(1,:)),position_lin.X{i},position_lin.Y{i},'nearest');

end

end