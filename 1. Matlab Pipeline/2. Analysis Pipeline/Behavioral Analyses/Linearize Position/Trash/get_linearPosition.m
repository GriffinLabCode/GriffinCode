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

function [linearPosition,position] = get_linearPosition(datafolder,idealTraj,Int,ExtractedX,ExtractedY,TimeStamps,mazePos,stemOrientation,startStemPos)

% get vt data
%[ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% -- this needs to be flexible, change me! -- %

%{
% define the convFact variable
data.measurements.convFact(1:2) = [2.09 2.04]; % left room is easy. its almost a perfect square. first col is x, second y

% converted
ExtractedX = ExtractedX./data.measurements.convFact(1);
ExtractedY = ExtractedY./data.measurements.convFact(2);
%}

% load int file
%load(int_name)

% get data
numTrials = size(Int,1);
for i = 1:numTrials
    x_data_temp{i}  = ExtractedX(TimeStamps >= Int(i,mazePos(1)) & TimeStamps <= Int(i,mazePos(2)));
    y_data_temp{i}  = ExtractedY(TimeStamps >= Int(i,mazePos(1)) & TimeStamps <= Int(i,mazePos(2)));
    ts_data_temp{i} = TimeStamps(TimeStamps >= Int(i,mazePos(1)) & TimeStamps <= Int(i,mazePos(2)));
end

% based on position of stem
if contains(stemOrientation,'x') | contains(stemOrientation,'X')
    %PosMidStem = 500;
    for i = 1:numTrials
        idx_mid = []; idx_mid = find(x_data_temp{i} >= startStemPos);
        x_data{i}  = x_data_temp{i}(idx_mid);
        y_data{i}  = y_data_temp{i}(idx_mid);
        ts_data{i} = ts_data_temp{i}(idx_mid);
    end
elseif contains(stemOrientation,'y') | contains(stemOrientation,'Y')
    %PosMidStem = 500;
    for i = 1:numTrials
        idx_mid = []; idx_mid = find(y_data_temp{i} >= startStemPos);
        x_data{i}  = x_data_temp{i}(idx_mid);
        y_data{i}  = y_data_temp{i}(idx_mid);
        ts_data{i} = ts_data_temp{i}(idx_mid);
    end    
end

% get left trajectory position
Int_left  = find(Int(:,3) == 1); %Int(Int(:,3)==1,:);
Int_right = find(Int(:,3) == 0); %Int(Int(:,3)==0,:);

position.X_left   = x_data(Int_left);
position.Y_left   = y_data(Int_left);
position.TS_left  = ts_data(Int_left);
position.X_right  = x_data(Int_right);
position.Y_right  = y_data(Int_right); 
position.TS_right = ts_data(Int_right);

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