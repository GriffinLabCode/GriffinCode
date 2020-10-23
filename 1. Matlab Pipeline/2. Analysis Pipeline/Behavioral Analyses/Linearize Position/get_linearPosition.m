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


function [linearPositionSmooth,linearPosition,position_lin] = get_linearPosition(idealTraj,position_data,vt_srate)

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
    
    idx_start = []; idx_end = [];
    % using the trajectory skeleton, we derived the start and end of the
    % trajectory. Now, find the nearest cartesian points in the actual
    % position data. Maze orientation should not affect this
    %[minval,idx] = min(sum(abs(position_data{i}(1:2,:)-startTrajPos)));
    %[minval,idx] = min(sum(abs(position_data{i}(1:2,:)-endTrajPos)));
    
    idx_start = dsearchn(position_data{i}(1:2,:)',startTrajPos');    
    idx_end   = dsearchn(position_data{i}(1:2,:)',endTrajPos');
        
    %{
    % if you stop at goal zone in your linear skeleton, we must account for
    % its entire occupancy
    if account4goalZone == 1
        % get rest of data from the linear position end point to the actual
        % end point
        real_end = []; idxSamples = []; restData = [];
        real_end      = length(position_data{i}(1,:));
        idxSamples    = [idx_end:real_end];
        restData(1,:) = position_data{i}(1,idxSamples);
        restData(2,:) = position_data{i}(2,idxSamples);
        
        % 3 bins finds bin for last linear bin, last actual position, and
        % the middle.
        restBinned = [];
        [~, restBinned(1,:)] = hist(restData(1,:),5);
        [~, restBinned(2,:)] = hist(restData(2,:),5);
        % the bin nearest to the final bin, but not the final bin, should
        % be good ( the final bin is the end linear position bin ).
        newEndTrajPos = [];
        newEndTrajPos = restBinned(:,4);
        
        % get new end
        idx_end_old = []; 
        idx_end_old = idx_end; 
        idx_end_add = dsearchn(position_data{i}(1:2,idx_end_old:real_end)',newEndTrajPos');
        
        % define idx_end to account for a slight bump in position
        idx_end = []; 
        idx_end = idx_end_old+idx_end_add;
    end 
   %}
    
    % timestamps
    time_start(i) = position_data{i}(3,idx_start);
    time_end(i)   = position_data{i}(3,idx_end);
     
    % does the timestamps index exceed the start of the Int file?
    
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

    % smooth linear position - this is important, especially if you're
    % using 1cm bins. Smoothing by the sampling rate seems to do the trick.
    linearPositionSmooth{i} = smoothdata(linearPosition{i},'gauss',vt_srate);
end

%{

for i = 1:numTrials
    figure('color','w'); hold on; 
    plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]);
    plot(prePosData{i}(1,:),prePosData{i}(2,:),'b','LineWidth',1);
    plot(position_lin.X{i},position_lin.Y{i},'r','LineWidth',1)
    pause;
end
%}

% errors occur when the actual trajectory is not as long as the expected
% trajectory. This needs to be handled.
%{
i = 1
figure()
plot(idealTraj{i}(1,:),idealTraj{i}(2,:),'Color',[.8 .8 .8]); hold on;
plot(position_lin.X{i},position_lin.Y{i},'r')


% missing positions in bins, plot position data with bins per trial
maxBins = cellfun(@max,linearPosition);
minBins = cellfun(@min,linearPosition);
%}

end