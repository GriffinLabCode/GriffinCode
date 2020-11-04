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


function [linearPositionSmooth,linearPosition,position_lin,linearPosUncorrected] = get_linearPosition(idealTraj,position_data,vt_srate)

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
    
    % consider first half of the data
    idx_start = dsearchn(position_data{i}(1:2,1:round(length(position_data{i})/2))',startTrajPos'); 
    
    % consider second half of the data
    idx_end   = dsearchn(position_data{i}(1:2,round(length(position_data{i})/2):end)',endTrajPos');
    idx_end   = idx_end+(round(length(position_data{i})/2)-1);    
    
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
    
end

% -- this needs to be completed if you want to use return arm -- %

% store data
linearPosUncorrected = linearPosition;

% detect large changes in linear position bins, and fix them
for i = 1:numTrials
    
    next = 0;
    while next == 0
        
        % get difference
        linearDiff = [];
        linearDiff = abs(diff(linearPosition{i}));

        % define x axis
        xLabel = linspace(0,length(linearPosition{i}),length(linearPosition{i}));

        % remove bad elements and linearly interpolate data - this is set
        % as variations that exceed 10cm.
        badElements = linearDiff > 5;
        if isempty(find(badElements > 0))
            next = 1;
        end
        
        % find elements surrounding the badElements and consider them bad
        % also
        idxBad = find(badElements == 1);
        for ii = 1:length(idxBad)
            
            if idxBad(ii)-1 > 0
                badElements(idxBad(ii)-1) = 1;
            end
            
            if idxBad(ii)+1 < length(linearPosition)
                badElements(idxBad(ii)+1) = 1;
            end
        end
                
        %badElements = zeros([1 length(badElementsTemp)+1]); badElements(2:end) = badElementsTemp;
        newY = linearPosition{i}(~badElements);
        newX = xLabel(~badElements);
        xq   = xLabel;
        newY = interp1(newX, newY, xq);
        
        % update linear position
        linearPosition{i} = [];
        linearPosition{i} = newY;

        %{
        % account for instances when the first data is messed up
        if isempty((isnan(linearPosition{i}(1:15)))) == 0
            % find first non nan value
            first_nonnan = find(~isnan(linearPosition{i}),1);
            % find value preceeding it
            size_nans = first_nonnan-1;
            % extract data of equal size from recorded points
            sample_ydata = linearPosition{i}(first_nonnan:first_nonnan+size_nans-1);
            % fill in sampled data points
            linearPosition{i}(1:first_nonnan-1)=0;
            linearPosition{i}(1:size_nans)=sample_ydata;
        end     
        
        if isempty((isnan(linearPosition{i}))) == 0
            % find nan
            nanIdx = find(isnan(linearPosition{i}));
            % find value preceeding it
            size_nans = nanIdx-1;
            % set equal
            linearPosition{i}(nanIdx) = linearPosition{i}(nanIdx-1);
        end
        %}
  
        if isempty(find(badElements > 0))
            next = 1;
        else
            disp(['Error detected on trial ',num2str(i)])
        end
        
        % in some situations, there are continued faulty positions
        idxBad = find(badElements == 1);
        
        % leave loop if no errors detected
        if isempty(idxBad)
            next = 1;
        else
            
            % use 8th of a sec surrounding the onsets to extract and correct
            idxCellBad = [];
            for ii = 1:length(idxBad)
                idxCellBad{ii} = idxBad(ii)-round(vt_srate/8):idxBad(ii)+round(vt_srate/8);
            end     
            
            % get an array of bad values
            idxArrayBad_temp = unique(horzcat(idxCellBad{:}))-1;
            
            % remove any values less than 1
            idxArrayBad = idxArrayBad_temp(idxArrayBad_temp > 0);
            
            % assign bad elements
            badElements(idxArrayBad) = 1;
 
            %{
            % in some situations, there are continued faulty positions
            idxCellBad = [];

            % create a cell array that allows us to assess this possibility
            for ii = 1:length(idxBad)-1
                idxCellBad{ii} = idxBad(ii):idxBad(ii+1);
            end    
        
            % now loop across the cell array, subtract the indices from a
            % known, 'good' value surrounding it. This good value, we'll
            % consider the corresponding index, because generally, when there
            % is a sustained error, its when locations overlap (like return arm
            % and stem).
            idxArrayBad = horzcat(idxCellBad{:});
            idxPositionBad = 1:length(linearPosition{i}(idxArrayBad));
            positionsBad = linearPosition{i}(idxArrayBad);
            diff_indexes = abs(positionsBad-idxPositionBad);

            % tag large outliers (anything over 100cm difference)
            largeOut = find(diff_indexes > 200);
            largeOutBack1 = (idxArrayBad(largeOut))-1;

            % tag as zeros
            badElements(largeOutBack1) = 1;
            %}
            
            newY = linearPosition{i}(~badElements);
            newX = xLabel(~badElements);
            xq   = xLabel;
            newY = interp1(newX, newY, xq);

            % update linear position
            linearPosition{i} = [];
            linearPosition{i} = newY;   
            
        end
    end
    
    % if any errors exist afterwards, they have to be continuous errors
    idxBad2 = find(linearDiff > 5);
    if isempty(idxBad2)
        % check the interpolation
        figure('color','w'); plot(linearPosUncorrected{i},'Color',[.5 .5 .5],'LineWidth',1.5); hold on;
        plot(linearPosition{i},'r','LineWidth',1.5);
        legend('Original','Interpolated','Location','Northwest')
        title(['Trial ' num2str(i)])
        pause;
        continue
    end
    
    linearPosition{i}(idxBad2(1):idxBad2(end)) = NaN;
    
    % interp
    xLabel = linspace(0,length(linearPosition{i}),length(linearPosition{i}));
    badElements = isnan(linearPosition{i});
    newY = linearPosition{i}(~badElements);
    newX = xLabel(~badElements);
    xq   = xLabel;
    linearPosition{i} = interp1(newX, newY, xq);    
    
    % check the interpolation
    figure('color','w'); plot(linearPosUncorrected{i},'Color',[.5 .5 .5]); hold on;
    plot(linearPosition{i},'r');
    legend('Original','Interpolated','Location','Northwest')
    title(['Trial ' num2str(i)])
    pause;
    
end

% -- smooth data -- %
for i = 1:numTrials

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