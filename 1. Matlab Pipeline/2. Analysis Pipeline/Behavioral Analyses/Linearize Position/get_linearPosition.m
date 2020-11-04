%% get linear position
% This code takes the linear skeleton and the parameters identified by your
% position_data variable (when to start/end) and estimates the linear
% distance (linear position) from start to finish. 
%
% *** It is highly recommended that you use a 1cm resolution. ***
%
% This code also rather exhaustively accounts for misplaced linear bins
% via interpolation and smoothing methods. A misplaced linear bin can occur
% if the 2D position of the animal overlaps. For example, the rat runs up
% the stem, sweeps his head into the return arm (while remaining on the
% stem), then continues forward. This will result in linear bins belonging
% to the return arm, when in reality they should be grouped into the stem.
% Interpolation rather nicely handles this issue. In some instances (like
% say the misplaced bins occur in the beginning or end of the trajectory),
% the bins are replaced with theoretical bins (first 3 and last 3 ideal
% bins). When interpolating, NaNs can be placed into the data, however
% smoothing removes the nans. Additionally, smoothing the data makes it so
% there are minimal noisy variations in head-position data.
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
% fix_position: set to 1, 'Y', or 'y' if you want to handle misplaced bins.
%                   this is only relevant in situations where you have
%                   overlapping bins, like in the case where return arm
%                   ends overlap just a little (if the rat sweeps his head
%                   around) with initial stem behavior
%
% -- OUTPUTS -- %
% linearPositionSmooth: linearized position smoothed using a gaussian
%                       weighted moving average
% linearPosition: linearized positions across all trials
% position_lin: updated position data
%
% IMPORTANT: it should be noted that on some trials, you may not get
%               position data in a linear bin. However, this can be
%               interpolated or when extracting spike data, can be gotten
%               around
%
% The use of idealTraj and griddata was taken from Van Der Meer code. The
% rest was written by John Stout.


function [linearPosition,position_lin] = get_linearPosition(idealTraj,linearBins,position_data)

% clip data based on linear skeleton
numTrials   = length(idealTraj);
position.X  = cell([1 numTrials]);
position.Y  = cell([1 numTrials]);
position.TS = cell([1 numTrials]);
for i = 1:numTrials
    
    % estimate start and end of trajectory using skeleton - this will clip the
    % data. This is really important to clip at goal zone correctly.
    startTrajPos  = idealTraj{i}(:,1);   % start coordinates
    endTrajPos    = idealTraj{i}(:,end); % end coordinates
    
    % consider first half of the data
    idx_start = []; idx_end = [];
    idx_start = dsearchn(position_data{i}(1:2,1:round(length(position_data{i})/2))',startTrajPos'); 
    %idx_start = 1;
    
    % consider second half of the data
    idx_end   = dsearchn(position_data{i}(1:2,round(length(position_data{i})/2):end)',endTrajPos');
    idx_end   = idx_end+(round(length(position_data{i})/2)-1);    

    % timestamps
    time_start(i) = position_data{i}(3,idx_start);
    time_end(i)   = position_data{i}(3,idx_end);

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
    linearPosition{i} = griddata(idealTraj{i}(1,:),idealTraj{i}(2,:),linearBins,position_lin.X{i},position_lin.Y{i},'nearest');

end


end