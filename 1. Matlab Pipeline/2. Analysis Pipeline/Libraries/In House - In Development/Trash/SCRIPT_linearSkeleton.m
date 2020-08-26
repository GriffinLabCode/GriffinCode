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
data.idealTraj = idealized_trajectory_2(data.pos,meas_distance);

% -- separate left and right trajectories -- %

% separate left/right trials
Int_left  = Int(Int(:,3)==1,:);
Int_right = Int(Int(:,3)==0,:);

% get position data
for triali = 1:size(Int_left,1)
    X.left{i} = ExtractedX(TimeStamps >= Int_left(1,i) & TimeStamps <= Int_left(1,8));
    Y.left{i} = ExtractedY(TimeStamps >= Int_left(1,i) & TimeStamps <= Int_left(1,8));
end

% -- linearize position -- %
for i = 1:numTrials
    
    % get coordinate points between ideal trajectory and real data
    linearPosition.left{i} = griddata(idealTraj.idealL(1,:),idealTraj.idealL(2,:),1:length(idealTraj.idealL(1,:)),X{i},Y{i},'nearest');

    % right
    linearPosition.right{i} = 
    
    % get distance
    %d{i} = sqrt((traj_skeleton(1,ceil(linPosBins{i}))-X{i}).^2 + (traj_skeleton(2,ceil(linPosBins{i}))-Y{i}).^2);

end


%{
% when defining this, keep in mind what int locations to consider
next = 0;
while next == 0
    clear idealTraj
    idealTraj = idealized_trajectory_2(pos);
    
    if numel(idealTraj.idealL) ~= numel(idealTraj.idealR)
        if numel(idealTraj.idealL) > numel(idealTraj.idealR)
            disp('try again - too many Left points')
            disp([num2str(numel(idealTraj.idealL)-numel(idealTraj.idealR))])
        else
            disp('try again - too many Right points')
            disp([num2str(numel(idealTraj.idealR)-numel(idealTraj.idealL))])            
        end
    else
        next = 1;
    end
end
%}

% save this somewhere, include idealTraj and convFact
prompt     = 'Enter a directory to save trajectory skeleton: ';
dir_save   = input(prompt,'s');
cd(dir_save);
save('trajectory_skeleton.mat','idealTraj','convFact');

% remove paths to avoid function conflicts
rmPaths_linearSkeleton

%{
% -- old -- %
% get all position data
numRuns = size(Int,1);
for triali = 1:numRuns
    posX{triali} = ExtractedX(TimeStamps >= Int(triali,1) & TimeStamps <= Int(triali,8));
    posY{triali} = ExtractedY(TimeStamps >= Int(triali,1) & TimeStamps <= Int(triali,8));
end
% get position data from left runs 
numLeft = size(Int_left,1);
for triali = 1:numLeft
    xLeft{triali} = ExtractedX(TimeStamps >= Int_left(triali,1) & TimeStamps <= Int_left(triali,8));
    yLeft{triali} = ExtractedY(TimeStamps >= Int_left(triali,1) & TimeStamps <= Int_left(triali,8));
end



figure(); plot(xLeft{1},yLeft{1})


linPosBins = griddata(traj_skeleton(1,:),traj_skeleton(2,:),1:meas_distance,xLeft{i},yLeft{i},'nearest');
%}