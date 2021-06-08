%%
clear;

% connect to netcom
pathName = 'C:\Users\zgemzik\GriffinCode\Experiment Control\R21\NetComDevelopmentPackage_v3.1.0\MATLAB_M-files';
%serverName = '192.168.3.100'; %Dell Tower in room 153 IPv4 address
serverName = '192.168.3.100';
connect2netcom(pathName,serverName);

%% setup

% get cheetah objects to stream with
[succeeded, cheetahObjects, cheetahTypes] = NlxGetDASObjectsAndTypes; % gets cheetah objects and types
%[succeeded, cheetahReply] = NlxSendCommand('-StopAcquisition');    
%[succeeded, cheetahReply] = NlxSendCommand('-StartAcquisition');    

% open stream with video track data
NlxOpenStream('VT1'); %Open data stream of VT1(Video data)

% pull in data
[succeeded,  timeStampArray, locationArray, ...
    extractedAngleArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewVTData('VT1');
X = locationArray(2:2:length(locationArray));
Y = locationArray(1:2:length(locationArray));

% define startbox coordinates
minY = 200; addY = 280-minY;
minX = 100; addX = 225-minX;
SB_fld = [minX minY addX addY];

% this is required for the inpolygon function
XV_sb = [SB_fld(1)+SB_fld(3) SB_fld(1) SB_fld(1) SB_fld(1)+SB_fld(3) SB_fld(1)+SB_fld(3)];
YV_sb = [SB_fld(2) SB_fld(2) SB_fld(2)+SB_fld(4) SB_fld(2)+SB_fld(4) SB_fld(2)];

%% set up for trial types
numTrials = 32;

% DONT CHANGE FOR NOW
cut = 2;
numTrials_setup = numTrials/cut; % required for what is below

% run once
laser_delay_temp = cell([1 cut]);
for n = 1:cut
    redo = 1;
    while redo == 1
        % create possible laser and delay duration combos
        blue_short = repmat('Bs',[numTrials_setup/4 1]);
        blue_long  = repmat('Bl',[numTrials_setup/4 1]);
        red_short  = repmat('Rs',[numTrials_setup/4 1]);
        red_long   = repmat('Rl',[numTrials_setup/4 1]);  

        all  = [blue_short; blue_long; red_short; red_long];
        all_shuffled = all;
        for i = 1:1000
            % notice how it rewrites the both_shuffled variable
            all_shuffled = all_shuffled(randperm(numTrials_setup),:);
        end
        laser_delay_temp{n} = cellstr(all_shuffled);

        % no more than 3 turns in one direction
        idxBl = double(contains(laser_delay_temp{n},'Bl'));
        idxBs = double(contains(laser_delay_temp{n},'Bs'));
        idxRl = double(contains(laser_delay_temp{n},'Rl'));
        idxRs = double(contains(laser_delay_temp{n},'Rs'));   

        for i = 1:length(laser_delay_temp{n})-3
            if idxBl(i) == 1 && idxBl(i+1) == 1 && idxBl(i+2) == 1 && idxBl(i+3)==1
                redo = 1;
                break        
            elseif idxRl(i) == 1 && idxRl(i+1) == 1 && idxRl(i+2) == 1 && idxRl(i+3)==1
                redo = 1;
                break 
            elseif idxBs(i) == 1 && idxBs(i+1) == 1 && idxBs(i+2) == 1 && idxBs(i+3)==1
                redo = 1;
                break  
            elseif idxBl(i) == 1 && idxBl(i+1) == 1 && idxBl(i+2) == 1 && idxBl(i+3)==1
                redo = 1;
                break              
            else
                redo = 0;
            end
        end
    end
end

% concatenate arrays that contain trials that contain a controlled amount
% of laser types
laser_delay = [];
laser_delay = vertcat(laser_delay_temp{:});

%% checker
laserCheck = laser_delay(1:numTrials/cut);
check1 = numel(find(contains(laserCheck,'Rs')==1)) == numTrials_setup/4;
check2 = numel(find(contains(laserCheck,'Bs')==1)) == numTrials_setup/4;
check3 = numel(find(contains(laserCheck,'Rl')==1)) == numTrials_setup/4;
check4 = numel(find(contains(laserCheck,'Bl')==1)) == numTrials_setup/4;
if check1 ~= 1 || check2 ~= 1 || check3 ~= 1 || check4 ~= 1
    error('Something is wrong with number of laser types')
end

laserCheck = laser_delay(numTrials/cut+1:numTrials);
check1 = numel(find(contains(laserCheck,'Rs')==1)) == numTrials_setup/4;
check2 = numel(find(contains(laserCheck,'Bs')==1)) == numTrials_setup/4;
check3 = numel(find(contains(laserCheck,'Rl')==1)) == numTrials_setup/4;
check4 = numel(find(contains(laserCheck,'Bl')==1)) == numTrials_setup/4;
if check1 ~= 1 || check2 ~= 1 || check3 ~= 1 || check4 ~= 1
    error('Something is wrong with number of laser types')
end

%% set up

% within each trial, when the rat enters the startbox, and he just came
% from the return arm or the goal zone, turn on laser for a specific period
% of time

% parameters
short = 10; % seconds
long  = 30; % seconds

% for arduino
if exist("a") == 0
    % connect arduino
    a = arduino('COM4','Mega2560','Libraries','Adafruit\MotorShieldV2');
end

irArduino.stem = 'D4'; % define me
irArduino.lRet = 'D6'; % define me
irArduino.rRet = 'D8'; % define me

%{
% quick test arduino
for i = 1:10000000
    readDigitalPin(a,irArduino.lRet)
end
%}

%% Task

% variable prep.
trajectory_text = [];
accuracy_text   = [];
trajectory      = [];
accuracy        = [];

% automatically start recording
[succeeded, cheetahReply] = NlxSendCommand('-StartRecording');    
load gong.mat;
sound(y);
pause(5)

for triali = 1:numTrials+1
  
    % enter the stem
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.stem) == 0
            
            % spit out a timestamp to cheetah
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "choicePoint" 102 2');       

            % move on
            next = 1;
        else
            next = 0;
        end
    end
    
    % enter a return arm
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.retL) == 0 ||  readDigitalPin(a,irArduino.retR)
            
            if readDigitalPin(a,irArduino.reL)==0
                % spit out a timestamp to cheetah
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "choicePoint" 312 2');  
                
                % track the trajectory_text
                trajectory_text{triali} = 'L';
                trajectory(triali)      = 1;   
                
            elseif readDigitalPin(a,irArduino.reR)==0
                % spit out a timestamp to cheetah
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "choicePoint" 322 2');   
                
                % track the trajectory_text
                trajectory_text{triali} = 'R';
                trajectory(triali)      = 0;                  
            end
            
            % move on
            next = 1;
        else
            next = 0;
        end
    end    
    
    % track position data to detect when he enters the startbox polygon
    % taken from davids code for delay
    next = 0;
    while next == 0
        % use inpolygon to detect whether hes in the location you wanted.
        % take average and median to be safe
        [IN_all,ON_all]   = inpolygon(mean(X),mean(Y),XV_sb,YV_sb);
        [IN2_all,ON2_all] = inpolygon(double(median(X)),double(median(Y)), XV_sb,YV_sb);
        
        % if hes in or on the polygon (on average or based on median), move
        % break out of the while loop as he is in the delay, and begin the
        % next part of the for loop - laser stim
        if IN_all == 1 || ON_all == 1 || IN2_all == 1 || ON2_all == 1 
            next = 1;
        elseif IN_all == 0 || ON_all == 0 && IN2_all == 0 || ON2_all == 0
            next = 0;
        end
    end
    
    % start laser protocol
    if contains(laser_delay_temp{triali},'Bs')
        % trigger on and off Blue
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 2 2'); % ON
        pause(short); % PAUSE FOR SHORT DURATION
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 2 0'); % OFF
    elseif contains(laser_delay_temp{triali},'Bl')
        % trigger on and off Blue
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 2 2'); % ON
        pause(long); % PAUSE FOR LONG DURATION
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 2 0'); % OFF    
    elseif contains(laser_delay_temp{triali},'Rs')
        % trigger on and off Blue
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 2'); % ON
        pause(short); % PAUSE FOR SHORT DURATION
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 0'); % OFF  
    elseif contains(laser_delay_temp{triali},'Rl')
        % trigger on and off Blue
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 2'); % ON
        pause(long); % PAUSE FOR LONG DURATION
        NlxSendCommand('-SetDigitalIOPortValue AcqSystem1_0 0 0'); % OFF 
    end    
    
end

% session end
load handel.mat;
sound(y, 2*Fs);

% compute accuracy array
accuracy = [];
accuracy_text = cell(1, length(trajectory_text)-1);
for triali = 1:length(trajectory_text)-1
    if trajectory_text{triali} ~= trajectory_text{triali+1}
        accuracy(triali) = 0; % correct trial
        accuracy_text{triali} = 'correct';
    elseif trajectory_text{triali} == trajectory_text{triali+1}
        accuracy(triali) = 1; % incorrect trial
        accuracy_text{triali} = 'incorrect';
    end
end

%% save data
% save data
c = clock;
c_save = strcat(num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(1)),'_','EndTime',num2str(c(4)),num2str(c(5)));

prompt   = 'Please enter the rats name ';
rat_name = input(prompt,'s');

prompt   = 'Please enter the task ';
task_name = input(prompt,'s');

prompt   = 'Enter the directory to save the data ';
dir_name = input(prompt,'s');

save_var = strcat(rat_name,'_',task_name,'_',c_save);

cd(dir_name);
save(save_var);

