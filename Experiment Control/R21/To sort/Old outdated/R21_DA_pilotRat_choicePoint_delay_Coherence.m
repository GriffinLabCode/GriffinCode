% DA task that incorporates coherence detection
% must have the matlab pipeline Startup run and startup_experimentControl

%% IF TROUBLESHOOTING
% load in the model_thresholds, and don't load in thresholds that is below

%% prep 1 - clear history, workspace, get working directory
% _____________________________________________________

% --- MAKE SURE YOU RUN STARTUP_EXPERIMENTCONTROL --- %

%______________________________________________________

% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir);

%% prep 2 - extract baseline parameters - CHANGE ME
dirParams = 'X:\01.Experiments\R21\R21 Pilot Rat\Parameters';
cd(dirParams);
load('Dandelion_baselineParameters');

%% prep 2 - define parameters for the session

% how long should the session be?
session_length = 30; % minutes

delay_length = 30; % seconds
numTrials    = 40;
pellet_count = 1;
timeout_len  = 60*15;

% define a looping time - this is in minutes
amountOfTime = (70/60); %session_length; % 0.84 is 50/60secs, to account for initial pause of 10sec .25; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

% what is below are variables that should be defined during the baseline
% epoch and loaded in
%{
% define LFPs to use
LFP1name = 'CSC6';  % hpc
LFP2name = 'CSC10'; % pfc

% define amount of data
amountOfData = 0.25;
%}

%% prep 3 - connect with cheetah
% set up function
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,amountOfData);

%% experiment design prep.
% 5 conditions:
% 1) low coherence, short duration
% 2) low coherence, long duration
% 3) high coherence, short duration
% 4) high coherence, long duration
% 5) no coherence, matched duration
numTrials = 40;

low_short  = repmat({'LS'},[numTrials/8 1]);
low_long   = repmat({'LL'},[numTrials/8 1]);
high_short = repmat({'HS'},[numTrials/8 1]);
high_long  = repmat({'HL'},[numTrials/8 1]);
control    = repmat({'NO'}, [numTrials/2 1]);

all  = [low_short; low_long; high_short; high_long; control];
trial_type = all;
for i = 1:1000
    % notice how it rewrites the both_shuffled variable
    trial_type = trial_type(randperm(numel(trial_type)));
end

%% auto maze prep.

% load directory specific path
%{
load('main_directory')
split_out = split(main_directory,'\');
split_out(end) = [];
split_out(end+1) = {'Automatic Maze Code'};
path_add = strjoin(split_out,'\');

% add path
%addpath(path_add);
%addpath 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21'
%}

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

irArduino.Treadmill = 'D9';

%{
for i = 1:10000000
    readDigitalPin(a,irArduino.Treadmill)
end
%}

%% coherence detection prep.

% set up with neuralynx
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,amountOfData);

% define sampling rate
params.Fs     = srate;

% define number of samples that correspond to the amount of data in time
numSamples2use = amountOfData*srate;

% define for loop - 70 total sec
looper = ceil((amountOfTime*60/amountOfData)); %ceil((amountOfTime*60)/amountOfData); % N minutes * 60sec/1min * (1 loop is about .250 ms of data)

% define total loop time
total_loop_time = amountOfTime*60; % in seconds

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

% reward dispensers need about 3 seconds to release pellets
for rewardi = 1:pellet_count
    writeline(s,rewFuns.right)
    pause(4)
    writeline(s,rewFuns.left)
    pause(4)
end

%% start recording - make a noise when recording begins
[succeeded, reply] = NlxSendCommand('-StartRecording');
load gong.mat;
sound(y);

%% trials
open_t  = [doorFuns.tLeftOpen doorFuns.tRightOpen];
close_t = [doorFuns.tLeftClose doorFuns.tRightClose];
maze_prep = [doorFuns.tLeftOpen doorFuns.tRightOpen ...
    doorFuns.gzLeftOpen doorFuns.gzRightOpen];

c = clock;
session_start = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time  = session_start-session_start; % quick definitio of this so it starts the while loop
while session_time < session_length
    for triali = 1:numTrials

        % set central door timeout value
        s.Timeout = timeout_len; % 5 minutes before matlab stops looking for an IR break    

        % first trial - set up the maze doors appropriately
        pause(0.25);
        writeline(s,maze_prep)

        % open central door to let rat off of treadmill
        pause(0.25);
        writeline(s,doorFuns.centralOpen)

        % set irTemp to empty matrix
        irTemp = []; 

        % central beam
        % while loop so that we continuously read the IR beam breaks
        next = 0;
        while next == 0
            irTemp = read(s,4,"uint8");            % look for IR beam breaks
            if irTemp == irBreakNames.central      % if central beam is broken
                % neuralynx timestamp command

                % close door
                writeline(s,doorFuns.centralClose) % close the door behind the rat
                next = 1;                          % break out of the loop
            end
        end

        % t-beam
        % check which direction the rat turns at the T-junction
        next = 0;
        while next == 0
            irTemp = [];
            irTemp = read(s,4,"uint8");         
            if irTemp == irBreakNames.tRight  
                % track the trajectory_text
                trajectory_text{triali} = 'R';
                trajectory(triali)      = 0;

                % close opposite door
                writeline(s,doorFuns.tLeftClose)  

                % open sb door
                pause(0.25)
                writeline(s,doorFuns.sbRightOpen)

                if triali > 1 && trajectory_text{triali} == 'R' && trajectory_text{triali-1} == 'L'
                    % reward dispensers need about 3 seconds to release pellets
                    for rewardi = 1:pellet_count
                        writeline(s,rewFuns.left)
                        pause(3)
                    end
                end

                % break while loop
                next = 1;

            elseif irTemp == irBreakNames.tLeft
                % track the trajectory_text
                trajectory_text{triali} = 'L';
                trajectory(triali)      = 1;            

                % close door
                writeline(s,doorFuns.tRightClose)

                % open sb door
                pause(0.25)            
                writeline(s,doorFuns.sbLeftOpen)

                if triali > 1 && trajectory_text{triali} == 'L' && trajectory_text{triali-1} == 'R'
                    % reward dispensers need about 3 seconds to release pellets
                    for rewardi = 1:pellet_count
                        writeline(s,rewFuns.right)
                        pause(3)
                    end
                end             

                % break out of while loop
                next = 1;
            end
        end    

        % Reward zone and eating
        % send to netcom 


        % return arm
        next = 0;
        while next == 0
            irTemp = read(s,4,"uint8");         
            if irTemp == irBreakNames.gzRight 
                % send neuralynx command for timestamp

                % close both for audio symmetry
                writeline(s,doorFuns.gzLeftClose)
                pause(0.25)
                writeline(s,doorFuns.gzRightClose)
                pause(0.25)
                writeline(s,doorFuns.tRightClose)

                next = 1;                          
            elseif irTemp == irBreakNames.gzLeft
                % send neuralynx command for timestamp

                % close both for audio symmetry
                writeline(s,doorFuns.gzLeftClose)
                pause(0.25)
                writeline(s,doorFuns.gzRightClose)
                pause(0.25)
                writeline(s,doorFuns.tLeftClose)            

                next = 1;
            end
        end      

        % startbox
        next = 0;
        while next == 0
            s.Timeout = timeout_len;
            irTemp = read(s,4,"uint8");         
            if irTemp == irBreakNames.sbRight 
                % track animals traversal onto the treadmill
                next_tread = 0; % hardcode next as 0 - this value gets updated when criteria is met
                while next_tread == 0 
                    % try to see if the rat goes and checks out the other doors
                    % IR beam
                    s.Timeout = 0.1;
                    irTemp = read(s,4,"uint8");
                    % if rat enters the startbox, only close the door behind
                    % him if he has either checked out the opposing door or
                    % entered the center of the startbox zone. This ensures
                    % that the rat is in fact in the startbox
                    if readDigitalPin(a,irArduino.Treadmill) == 0
                        % close startbox door
                        pause(.25);                    
                        writeline(s,doorFuns.sbRightClose)
                        % tell the loop to move on
                        next_tread = 1;
                    elseif isempty(irTemp) == 0
                        if irTemp == irBreakNames.sbLeft
                            % close startbox door
                            pause(0.25)
                            writeline(s,doorFuns.sbRightClose)
                            % tell the loop to move on
                            next_tread = 1;
                        end
                    elseif isempty(irTemp)==1 && readDigitalPin(a,irArduino.Treadmill) == 1
                        next_tread = 0;
                    end
                end

                next = 1;
            elseif irTemp == irBreakNames.sbLeft 
                % track animals traversal onto the treadmill
                next_tread = 0; % hardcode next as 0 - this value gets updated when criteria is met
                while next_tread == 0 
                    % try to see if the rat goes and checks out the other doors
                    % IR beam
                    s.Timeout = 0.1;
                    irTemp = read(s,4,"uint8");
                    % if rat enters the startbox, only close the door behind
                    % him if he has either checked out the opposing door or
                    % entered the center of the startbox zone. This ensures
                    % that the rat is in fact in the startbox
                    if readDigitalPin(a,irArduino.Treadmill) == 0
                        % close startbox door
                        pause(.25);                    
                        writeline(s,doorFuns.sbLeftClose)
                        % tell the loop to move on
                        next_tread = 1;
                    elseif isempty(irTemp) == 0
                        if irTemp == irBreakNames.sbRight
                            % close startbox door
                            pause(0.25)
                            writeline(s,doorFuns.sbLeftClose)
                            % tell the loop to move on
                            next_tread = 1;
                        end
                    elseif isempty(irTemp)==1 && readDigitalPin(a,irArduino.Treadmill) == 1
                        next_tread = 0;
                    end
                end

                next = 1;
            end 
        end

        % reset timeout
        s.Timeout = timeout_len;

        % initialize some variables
        timeStamps = []; timeConv  = [];
        coh_met    = []; coh_store = [];
        dur_met    = []; dur_sum   = [];    
        % only during delayed alternations will you start the treadmill
        if delay_length > 1
 
            % pause
            disp('Initial delay pause = 20s')
            pause(20); % 20 sec

            % use tic toc to store timing for yoked control
            tStart = tic;

            % low coherence, short duration
            disp(['Trial type is ',trial_type{triali},'.'])

            if contains(trial_type{triali},low_short{1})
                [coh_trial{triali},timeConv{triali}] = lowCoherenceShortDuration(LFP1name,LFP2name,0,looper,amountOfData,s,doorFuns,params,srate,threshold,tStart);
            elseif contains(trial_type{triali},low_long{1})
                [coh_trial{triali},timeConv{triali}] = lowCoherenceLongDuration(LFP1name,LFP2name,0,looper,amountOfData,s,doorFuns,params,srate,threshold,tStart);
            elseif contains(trial_type{triali},high_short{1})
                [coh_trial{triali},timeConv{triali}] = highCoherenceShortDuration(LFP1name,LFP2name,0,looper,amountOfData,s,doorFuns,params,srate,threshold,tStart);
            elseif contains(trial_type{triali},high_long{1})
                [coh_trial{triali},timeConv{triali}] = highCoherenceLongDuration(LFP1name,LFP2name,0,looper,amountOfData,s,doorFuns,params,srate,threshold,tStart);
            elseif contains(trial_type{triali},'NO')

                % if there are no yolked controls to delay-match, then
                % just pause for the extra 10sec for a total of 30sec
                % delay
                try 
                    % find instances where there are no nans
                    idx_temp = find(isnan(delay_duration_manipulate)==0);
                    time2use = delay_duration_manipulate(idx_temp(1)); % use the very first value thats not a nan
                    whichMatch = trial_type{idx_temp(1)};

                    % pause for yolked time
                    disp(['Yolked control pause of ', num2str(time2use), ' to match a ',whichMatch, ' trial'])
                    pause(time2use);

                    % replace used time with a nan so it is not re-used later
                    delay_duration_manipulate(idx_temp(1)) = NaN;
                catch
                    % if no other conditions are met, then just wait for 30
                    % seconds
                    disp('No yolked controls to delay-match - pause for 10 sec. to make a total of 30s delay')
                    pause(10);    
                end
            end
        end

        % out time
        delay_duration_master(triali) = toc(tStart);

        % use this variable to have yolked controls. Here, we define a
        % delay_duration_manipulate variable. This variable will be used
        % for yolked controls. When the trial is a control, it will be NaN
        % so that the algorithm can detect non-nans. THe master duration
        % variable will house all time delays
        if contains(trial_type{triali},'NO')
            delay_duration_manipulate(triali) = NaN;
        else
            delay_duration_manipulate(triali) = delay_duration_master(triali); % this one will change            
        end
        
        % get amount of time past since session start
        c = clock;
        session_time_update = str2num(strcat(num2str(c(4)),num2str(c(5))));
        session_time = session_time_update-session_start;

        if session_time > session_length
            break
        end
        
    end 
        

end


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



