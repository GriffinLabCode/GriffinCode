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


function [linearPositionSmooth,linearPosition,position_lin,linearPosUncorrected] = get_linearPosition(idealTraj,position_data,vt_srate,fix_position)

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

% initialize variable
linearPositionSmooth = cell([1 numTrials]);

if fix_position == 1 | contains(fix_position,[{'y'} {'Y'}])
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
            else
                disp(['Error detected on trial ',num2str(i)])
            end

            %{
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



            if isempty(find(badElements > 0))
                next = 1;
            else
                disp(['Error detected on trial ',num2str(i)])
            end

            %}

            % in some situations, there are continued faulty positions
            idxBad = find(badElements == 1);

            % leave while loop if no errors detected
            if isempty(idxBad)

                % leave
                next = 1;          

            % for all other cases, do the following...
            else
                % check the first few and last few samples for nans
                findNans = find(isnan(linearPosition{i})==1);
                nanArray = findNans;
                for ii = 1:length(findNans)

                    % if there are events that are occuring in the begginging
                    if findNans(ii) == 1 | findNans(ii) == 2 | findNans(ii) == 3
                        linearPosition{i}(ii) = ii;
                        nanArray(ii) = 0;
                    end

                    % there are events occuring at the very end
                    if findNans(ii) == length(linearPosUncorrected{i}) | findNans(ii) == length(linearPosUncorrected{i})-1 | findNans(ii) == length(linearPosUncorrected{i})-2
                        linearPosition{i}(ii) = ii;
                        nanArray(ii) = 0;
                    end

                end

                % use 8th of a sec surrounding the onsets to extract and correct
                idxCellBad = [];
                for ii = 1:length(idxBad)
                    idxCellBad{ii} = idxBad(ii)-round(vt_srate/8):idxBad(ii)+round(vt_srate/8);
                end     

                % get an array of bad values
                idxArrayBad_temp = unique(horzcat(idxCellBad{:}))-1;

                % remove any values less than 1
                idxArrayBad = idxArrayBad_temp(idxArrayBad_temp > 0);

                % if you see that bins 1:3 are bad, just replace them with bins
                % 1:3. The effect will be negligable on your data
                idxArrayNew = idxArrayBad;
                for ii = 1:length(idxArrayBad)

                    % if there are events that are occuring in the begginging
                    if idxArrayBad(ii) == 1 | idxArrayBad(ii) == 2 | idxArrayBad(ii) == 3
                        linearPosition{i}(ii) = ii;
                        idxArrayNew(ii) = 0;
                    end

                    % there are events occuring at the very end
                    if idxArrayBad(ii) == length(linearPosUncorrected{i}) | idxArrayBad(ii) == length(linearPosUncorrected{i})-1 | idxArrayBad(ii) == length(linearPosUncorrected{i})-2
                        linearPosition{i}(ii) = ii;
                        idxArrayNew(ii) = 0;
                    end

                end
                % remove any zeros in the new idx
                idxArrayNew(idxArrayNew == 0)=[];

                % assign bad elements
                badElements(idxArrayNew) = 1;

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

                % this is weird, but do one spline interp
                newY = linearPosition{i}(~badElements);
                newX = xLabel(~badElements);
                xq   = xLabel;
                newY = interp1(newX, newY, xq, 'spline');

                % update linear position
                linearPosition{i} = [];
                linearPosition{i} = newY; 

                % then do one normal interp
                newY = linearPosition{i}(~badElements);
                newX = xLabel(~badElements);
                xq   = xLabel;
                newY = interp1(newX, newY, xq);

                % update linear position
                linearPosition{i} = [];
                linearPosition{i} = newY;         

            end

            % check for nans again and fix
            findNans  = find(isnan(linearPosition{i})==1);
            findNans2 = findNans;
            for ii = 1:length(findNans)

                % if there are events that are occuring in the begginging
                if findNans(ii) == 1 | findNans(ii) == 2 | findNans(ii) == 3
                    linearPosition{i}(ii) = ii;
                    findNans2(ii) = 0;
                end

                % there are events occuring at the very end
                if findNans(ii) == length(linearPosUncorrected{i}) | findNans(ii) == length(linearPosUncorrected{i})-1 | findNans(ii) == length(linearPosUncorrected{i})-2
                    linearPosition{i}(ii) = ii;
                    findNans2(ii) = 0;
                end

            end

            % remove any zeros in the new idx
            findNans2(findNans2 == 0)=[];

            % assign bad elements
            badElements(findNans2) = 1; 

            % this is weird, but do one spline interp
            newY = linearPosition{i}(~badElements);
            newX = xLabel(~badElements);
            xq   = xLabel;
            newY = interp1(newX, newY, xq, 'spline');        

        end

        % if any errors exist afterwards, they have to be continuous errors
        idxBad2 = find(linearDiff > 5);
        if isempty(idxBad2)

            % smooth linear position - this handles any nans present from
            % interpolation and also accounts for quick and not so important
            % variations in the rats head position
            linearPositionSmooth{i} = smoothdata(linearPosition{i},'gauss',vt_srate);

            % check the interpolation
            figure('color','w'); plot(linearPosUncorrected{i},'Color',[.5 .5 .5],'LineWidth',1.5); hold on;
            plot(linearPosition{i},'r','LineWidth',1.5);
            plot(linearPositionSmooth{i},'b','LineWidth',1.5);
            legend('Original','Interpolated','Interp and Smoothed','Location','Northwest')
            nanFind = find(isnan(linearPositionSmooth{i})==1);
            if isempty(nanFind)
                nanIndicator = 'No NaNs detected';
            else
                nanIndicator = 'NaNs detected';
            end
            title(['Trial ' num2str(i), ' | ',nanIndicator])
            pause;
            continue

        else

            % replace with nans
            linearPosition{i}(idxBad2(1):idxBad2(end)) = NaN;

            % interp
            xLabel = linspace(0,length(linearPosition{i}),length(linearPosition{i}));
            badElements = isnan(linearPosition{i});
            newY = linearPosition{i}(~badElements);
            newX = xLabel(~badElements);
            xq   = xLabel;
            linearPosition{i} = interp1(newX, newY, xq, 'spline');  

            % smooth linear position - this handles any nans present from
            % interpolation and also accounts for quick and not so important
            % variations in the rats head position
            linearPositionSmooth{i} = smoothdata(linearPosition{i},'gauss',vt_srate);

            % check the interpolation
            figure('color','w'); plot(linearPosUncorrected{i},'Color',[.5 .5 .5],'LineWidth',1.5); hold on;
            plot(linearPosition{i},'r','LineWidth',1.5);
            plot(linearPositionSmooth{i},'b','LineWidth',1.5);
            legend('Original','Interpolated','Interp and Smoothed','Location','Northwest')
            nanFind = find(isnan(linearPositionSmooth{i})==1);
            if isempty(nanFind)
                nanIndicator = 'No NaNs detected';
            else
                nanIndicator = 'NaNs detected';
            end
            title(['Trial ' num2str(i), ' | ',nanIndicator])
            pause;

        end

    end   
else
    % -- smooth data -- %
    for i = 1:numTrials

        % smooth linear position - this is important, especially if you're
        % using 1cm bins. Smoothing by the sampling rate seems to do the trick.
        linearPositionSmooth{i} = smoothdata(linearPosition{i},'gauss',vt_srate);

    end    
end
end