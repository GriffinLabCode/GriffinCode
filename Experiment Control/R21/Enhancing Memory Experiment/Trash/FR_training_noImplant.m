%% prep 1 - clear history, workspace, get working directory
% _____________________________________________________

% --- MAKE SURE YOU RUN STARTUP_EXPERIMENTCONTROL --- %

%______________________________________________________

%% BUG
% sometimes if the session is not exceeding the time limit of 30 minutes,
% then the code will continue performing trials, but not save the data.
% Cheetah w%%

% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

% DA task that incorporates coherence detection
% must have the matlab pipeline Startup run and startup_experimentControl
%targetRat = '21-5';

%% confirm this is the correct code
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
confirm  = input(prompt,'s');

if ~contains(confirm,[{'y'} {'Y'}])
    error('This code does not match the target rat')
end

prompt = ['What day of FR training is this? '];
FRday  = str2num(input(prompt,'s'));

%% prep 2 - define parameters for the session

% how long should the session be?
session_length = 30; % minutes

delay_length = 0; % seconds
numTrials    = 12;
pellet_count = 1;
timeout_len  = 60*15;

% define a looping time - this is in minutes
amountOfTime = (70/60); %session_length; % 0.84 is 50/60secs, to account for initial pause of 10sec .25; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

%% experiment design prep.
rng('shuffle') % set to random

% define number of trials
numTrials  = 12;

% randomize delay durations
minDelay = 5;  % minimum delay duration set to 5 seconds
maxDelay = 15; % maximum delay duration set to 15 seconds
delay_durations = (maxDelay-minDelay).*rand(numTrials-1,1) + minDelay; % vector of values

%% auto maze prep.

% -- automaze set up -- %

% check port
if exist("s") == 0
    % connect to the serial port making an object
    s = serialport("COM6",19200);
end

% load in door functions
doorFuns = DoorActions;

% test reward wells
rewFuns = RewardActions;

% get IR information
irBreakNames = irBreakLabels;

% for arduino
if exist("a") == 0
    % connect arduino
    a = arduino('COM5','Uno','Libraries','Adafruit\MotorShieldV2');
end

% digital ports for reverse maze
irArduino.Treadmill = 'D9';
irArduino.rGoalArm  = 'D10';
irArduino.lGoalArm  = 'D11';
irArduino.rGoalZone = 'D7';
irArduino.lGoalZone = 'D2';


%{
for i = 1:10000000
    readDigitalPin(a,irArduino.lGoal)
end
%}

%% treadmill setup
% get treadmill
[treadFuns,treadSpeed] = TreadMillFuns;

% load treadmill functions and settings
[treadFuns,treadSpeeds] = TreadMillFuns;
targetSpeed = 10;
speedVector = 4:2:targetSpeed;

% make an empty array
speed_cell = cell(size(fieldnames(treadSpeeds),1)+1,1);

% fill the first cell with nan because there is no 1mpm rate
speed_cell{1} = NaN;

% make an array where its row index is the speed
speed_cell(2:end) = struct2cell(treadSpeeds);

%% coherence detection prep.

% define sampling rate
params.Fs     = srate;

% define number of samples that correspond to the amount of data in time
numSamples2use = threshold.coh_duration*srate;

% define for loop - 70 total sec
looper = ceil((amountOfTime*60/threshold.coh_duration)); %ceil((amountOfTime*60)/threshold.coh_duration); % N minutes * 60sec/1min * (1 loop is about .250 ms of data)

% define total loop time
total_loop_time = threshold.coh_duration*60; % in seconds

% this is the total amount of time coherence detection will proceed for...
total_window = 15; % total amount of time allowed for coherence to be detected

%% clean the stored data just in case IR beams were broken
s.Timeout = 1; % 1 second timeout
next = 0; % set while loop variable
while next == 0
   irTemp = read(s,4,"uint8"); % look for stored data
   if isempty(irTemp) == 1     % if there are no stored ir beam breaks
       next = 1;               % break out of the while loop
       disp('IR record empty - ignore the warning')
   else
       disp('IR record not empty')
       disp(irTemp)
   end
end

% close all maze doors - this gives problems with solenoid box
pause(0.25)
writeline(s,[doorFuns.centralClose doorFuns.sbLeftClose ...
    doorFuns.sbRightClose doorFuns.tLeftClose doorFuns.tRightClose]);

pause(0.25)
writeline(s,[doorFuns.gzLeftClose doorFuns.gzRightClose])

%% trial set up
left  = repmat('L',[numTrials/2 1]);
right = repmat('R',[numTrials/2 1]);
both  = [left; right];
both_shuffled = both;
for i = 1:1000
    % notice how it rewrites the both_shuffled variable
    both_shuffled = both_shuffled(randperm(numel(both_shuffled)));
end
trajectory = cellstr(both_shuffled);

% add 1 to trajectory - the rat won't run on this trial
trajectory{end+1} = 'E';

% update the numTrials variable
numTrials = length(trajectory);

%% start recording - make a noise when recording begins
[succeeded, reply] = NlxSendCommand('-StartRecording');
load gong.mat;
sound(y);
pause(5)

%% trials
open_t  = [doorFuns.tLeftOpen doorFuns.tRightOpen];
close_t = [doorFuns.tLeftClose doorFuns.tRightClose];
maze_prep = [doorFuns.sbLeftOpen doorFuns.sbRightOpen ...
    doorFuns.tRightClose doorFuns.tLeftClose doorFuns.centralOpen ...
    doorFuns.gzLeftClose doorFuns.gzRightClose];

% mark session start
sStart = [];
sStart = tic;
sessEnd = 0;
while toc(sStart)/60 < session_length || sessEnd == 0
    c = clock;
    session_start = str2num(strcat(num2str(c(4)),num2str(c(5))));
    session_time  = session_start-session_start; % quick definitio of this so it starts the while loop
    writeline(s,doorFuns.centralOpen);
    for triali = 1:numTrials-1

        % set this
        s.Timeout = timeout_len;
        
        % start out with this as a way to make sure you don't exceed 30
        % minutes of the session
        if triali == numTrials || toc(sStart)/60 > session_length
            writeline(s,doorFuns.closeAll)
            sessEnd = 1;            
            break % break out of for loop
        end        
       
        if trajectory{triali} == 'L'
            writeline(s,doorFuns.sbLeftOpen)
        elseif trajectory{triali} == 'R'
            writeline(s,doorFuns.sbRightOpen)    
        end
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');                                    

        % t-beam
        % check which direction the rat turns at the T-junction
        next = 0;
        while next == 0       
            if readDigitalPin(a,irArduino.rGoalArm)==0
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tRightBeam" 222 2');                                    

                % track the trajectory_text
                %trajectory_text{triali} = 'R';
                %trajectory(triali)      = 0;

                pause(0.25)
                writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);
                pause(0.25)
                writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);

                % break while loop
                next = 1;

            elseif readDigitalPin(a,irArduino.lGoalArm)==0
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tLeftBeam" 212 2');

                % track the trajectory_text
                %trajectory_text{triali} = 'L';
                %trajectory(triali)      = 1;            

                pause(0.25)
                writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tRightClose doorFuns.tLeftOpen]);
                pause(0.25)
                writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tRightClose doorFuns.tLeftOpen]);

                % break out of while loop
                next = 1;
            end
        end      
    
        % Reward zone and eating
        % send to netcom 
        if trajectory{triali} == 'R'
            % reward dispensers need about 3 seconds to release pellets
            for rewardi = 1:pellet_count
                pause(0.25)
                writeline(s,rewFuns.right)
                %pause(3)
            end
        elseif trajectory{triali} == 'L' 
            % reward dispensers need about 3 seconds to release pellets
            for rewardi = 1:pellet_count
                pause(0.25)
                writeline(s,rewFuns.left)
                %pause(3)
            end
        end          
        
        % return arm
        next = 0;
        while next == 0
            %irTemp = read(s,4,"uint8");  
            
            if readDigitalPin(a,irArduino.lGoalZone)==0
                % send neuralynx command for timestamp
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzRightBeam" 422 2');             

                % close both for audio symmetry
                pause(0.25)
                writeline(s,[doorFuns.gzLeftClose])
                pause(0.25)
                writeline(s,[doorFuns.gzRightClose])
                
                next = 1;                          
            elseif readDigitalPin(a,irArduino.rGoalZone)==0
                % send neuralynx command for timestamp
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzLeftBeam" 412 2');

                % close both for audio symmetry
                pause(0.25)
                writeline(s,[doorFuns.gzLeftClose])
                pause(0.25)
                writeline(s,[doorFuns.gzRightClose])

                next = 1;
            end

        end      

        % startbox beam
        %{
        s.Timeout = 0.001; % 1 second timeout
        next = 0; % set while loop variable
        while next == 0
           irTemp = read(s,4,"uint8"); % look for stored data
           if isempty(irTemp) == 1     % if there are no stored ir beam breaks
               next = 1;               % break out of the while loop
               disp('IR record empty - ignore the warning')
           else
               disp('IR record not empty')
               disp(irTemp)
           end
        end   
        %}
        next = 0;
        while next == 0
            s.Timeout = timeout_len;
            irTemp = read(s,4,"uint8");  
            if irTemp == irBreakNames.central
                next = 1;
            end
        end
        
        % treadmill and coherence stuff
        next = 0;
        while next == 0
            if readDigitalPin(a,irArduino.Treadmill)==0
                writeline(s,[doorFuns.tLeftClose doorFuns.tRightClose])
                pause(0.25)
                writeline(s,[doorFuns.tLeftClose doorFuns.tRightClose])

                % begin treadmill
                write(s,treadFuns.start,'uint8');

                % increase tread speed gradually
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayStart" 600 2');
                
                if FRday == 1
                    speedVector = [1 2 3 4];
                elseif FRday == 2
                    speedVector = [1 2 3 4 6];
                elseif FRday == 3 || FRday > 3
                    speedVector = [1 2 3 4 5 6 7 8];
                end
                
                for i = speedVector
                    % set treadmill speed
                    write(s,uint8(speed_cell{i}'),'uint8'); % add a second command in case the machine missed the first one
                    pause(0.25)
                end                

                % pause for random time interval during delay
                disp(['Pausing for delay of ',num2str(delay_durations(triali)) ' seconds'])
                pause(delay_durations(triali))

                % open doors and stop treadmill
                if trajectory{triali+1} == 'L'
                    writeline(s,[doorFuns.sbLeftOpen])
                elseif trajectory{triali+1} == 'R'
                    writeline(s,doorFuns.sbRightOpen)
                end
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');
                pause(0.25)
                write(s,treadFuns.stop,'uint8'); 
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayEnd" 601 2');                

                % break out of while loop and continue maze
                next = 1;
            end
        end

        if triali == numTrials || toc(sStart)/60 > session_length
            writeline(s,doorFuns.closeAll)
            sessEnd = 1;            
            break % break out of for loop
        end
    end 
    
end

% get amount of time past since session start
c = clock;
session_time_update = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time = session_time_update-session_start;


%% ending noise - a fitting song to end the session
load handel.mat;
sound(y, 2*Fs);

%% save data
% save data
c = clock;
c_save = strcat(num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(1)),'_','EndTime',num2str(c(4)),num2str(c(5)));

prompt   = 'Please enter the rats name ';
rat_name = input(prompt,'s');

prompt   = 'Please enter the task ';
task_name = input(prompt,'s');

%prompt   = 'Enter the directory to save the data ';
%dir_name = input(prompt,'s');

save_var = strcat(rat_name,'_',task_name,'_',c_save);

place2store = ['C:\Users\jstout\Desktop\Data 2 Move\APPROACH 3\', targetRat];
cd(place2store);
save(save_var);



