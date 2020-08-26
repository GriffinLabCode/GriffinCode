% this should be made into function and end after linear position?
clear

% addpaths
Startup_linearSkeleton

% note that if your maze location shifted session-to-session, you will need
% to define this session-by-session. If not, you can select one good
% example of trajectory data and use it for the rest.
datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-11-18'; 

% get vt data
[ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,'exclude','VT1.mat');

% define the convFact variable
data.measurements.convFact(1:2) = [2.09 2.04]; % left room is easy. its almost a perfect square. first col is x, second y

% convert x and y data
ExtractedX = ExtractedX./data.measurements.convFact(1);
ExtractedY = ExtractedY./data.measurements.convFact(2);

% load int file
int_name = 'Int_file';
load(int_name)

% what is the measured distance from stem entry to startbox entry?
data.measurements.stem     = 137;
data.measurements.goalArm  = 50;
data.measurements.goalZone = 37;
data.measurements.retArm   = 130;
data.measurements.total_distance = data.measurements.stem+data.measurements.goalArm...
    +data.measurements.goalZone+data.measurements.retArm;

% position data
data.pos(1,:) = ExtractedX;
data.pos(2,:) = ExtractedY;

% get linear skeleton
data.idealTraj = idealized_trajectory_2(data.pos,data.measurements.total_distance);

%% separate left and right trajectories

% separate left/right trials
Int_left  = Int(Int(:,3)==1,:);
Int_right = Int(Int(:,3)==0,:);

% get left trajectory position
for triali = 1:size(Int_left,1)
    data.X_left{triali} = ExtractedX(TimeStamps >= Int_left(triali,1) & TimeStamps <= Int_left(triali,8));
    data.Y_left{triali} = ExtractedY(TimeStamps >= Int_left(triali,1) & TimeStamps <= Int_left(triali,8));
end

% get right trajectory position
for triali = 1:size(Int_right,1)
    data.X_right{triali} = ExtractedX(TimeStamps >= Int_right(triali,1) & TimeStamps <= Int_right(triali,8));
    data.Y_right{triali} = ExtractedY(TimeStamps >= Int_right(triali,1) & TimeStamps <= Int_right(triali,8));
end

%% linearize position

% left linear position
numTrials = length(data.X_left);
for i = 1:numTrials
    
    % get coordinate points between ideal trajectory and real data
    data.linearPosition.left{i} = griddata(data.idealTraj.idealL(1,:),data.idealTraj.idealL(2,:),1:length(data.idealTraj.idealL(1,:)),data.X_left{i},data.Y_left{i},'nearest');

end

% right linear position
numTrials = length(data.X_right);
for i = 1:numTrials
    
    % get coordinate points between ideal trajectory and real data
    data.linearPosition.right{i} = griddata(data.idealTraj.idealR(1,:),data.idealTraj.idealR(2,:),1:length(data.idealTraj.idealR(1,:)),data.X_right{i},data.Y_right{i},'nearest');

end

% save this somewhere, include idealTraj and convFact
prompt     = 'Enter a directory to save trajectory skeleton: ';
dir_save   = input(prompt,'s');
cd(dir_save);
save('trajectory_skeleton.mat','idealTraj','convFact');

% remove paths to avoid function conflicts
rmPaths_linearSkeleton
