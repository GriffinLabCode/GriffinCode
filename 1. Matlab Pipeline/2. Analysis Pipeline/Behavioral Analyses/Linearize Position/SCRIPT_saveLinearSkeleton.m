%% Script meant for actively linearizing position data
clear; clc;
saveName     = 'linearSkeleton2'; % rename per round 
%datafolder  = '';
datafolder   = pwd;
int_name     = 'Int_JS_fixed'; % was Int_JS_fixed
vt_name      = 'VT1.mat';
missing_data = 'interp';
vt_srate     = 30; % 30 samples/sec

clear measurements
bin_size              = 1; % in cm
measurements.stem     = round(112/bin_size); % in cm was 137
measurements.goalArm  = round(56/bin_size);  % was 50
measurements.goalZone = round(29.21/bin_size); %round(42/bin_size);  % was 37
measurements.goalExit = round(12.7/bin_size);
%measurements.retArm   = %117; % was 130

% updated linear position code
Int_indicator.left  = 1;
Int_indicator.right = 0;
[data] = get_linearSkeleton(datafolder,int_name,vt_name,missing_data,measurements,Int_indicator);

load(int_name);
numTrials = size(Int,1);
idealTraj = cell([1 numTrials]);
for triali = 1:numTrials   
    if Int(triali,3) == 0 % right turn
        idealTraj{triali} = data.idealTraj.idealR;        
    elseif Int(triali,3) == 1 % left turn
        idealTraj{triali} = data.idealTraj.idealL;
    end
end

% calculate converted distance in cm. This tells you how far the rat ran
conv_distance = round(data.measurements.total_distance*bin_size);
total_dist = conv_distance;

% load int file and define the maze positions of interest
mazePos = [1 7]; % was [1 2]

% load position data
[ExtractedX, ExtractedY, TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% define int lefts and rights
trials_left  = find(Int(:,3)==1); % lefts
trials_right = find(Int(:,3)==0); % rights

%{
% get position data into one variable
numTrials  = size(Int,1);
prePosData = cell([1 size(Int,1)]);
for i = 1:numTrials
    prePosData{i}(1,:) = ExtractedX(TimeStamps >= Int(i,mazePos(1)) & TimeStamps <= Int(i,mazePos(2)));
    prePosData{i}(2,:) = ExtractedY(TimeStamps >= Int(i,mazePos(1)) & TimeStamps <= Int(i,mazePos(2)));
    prePosData{i}(3,:) = TimeStamps(TimeStamps >= Int(i,mazePos(1)) & TimeStamps <= Int(i,mazePos(2)));
end

%[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data,mazePos);
clear linearPosition position
[linearPosition,position] = get_linearPosition(idealTraj,prePosData);
%}

% select a random trial for left and right
left_select  = datasample(trials_left,1);
right_select = datasample(trials_right,1);

% plot and confirm that the skeleton is done correctly
figure('color','w')
subplot 211
    plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]); hold on;
    plot(idealTraj{left_select}(1,:),idealTraj{left_select}(2,:),'r','LineWidth',2)
    title('Random left trajectory (may be reversed on pos. data)')    
    box off
    ylim([-10 500])
subplot 212
    plot(ExtractedX,ExtractedY,'Color',[.8 .8 .8]); hold on;
    plot(idealTraj{right_select}(1,:),idealTraj{right_select}(2,:),'b','LineWidth',2)
    title('Random right trajectory (may be reversed on pos. data)')
    box off
    ylim([-20 550])    
    
prompt = 'Are you satisfied with the linear skeletons? [Y/N] ';
answer = input(prompt,'s');

% save data
if contains(answer,'Y') | contains(answer,'y')
    cd(datafolder);
    save(saveName,'idealTraj', 'data', 'bin_size');
    disp('linear position data saved to datafolder')
end
