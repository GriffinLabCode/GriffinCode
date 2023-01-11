%% prep 1 - clear history, workspace, get working directory
% _____________________________________________________

% --- MAKE SURE YOU RUN STARTUP_EXPERIMENTCONTROL --- %

%______________________________________________________

%% 
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

% load in condition information
disp('Loading CD information')
cd(['X:\01.Experiments\R21\',targetRat,'\CD\conditionID']);
load('CDinfo')

% enter which day of training
prompt = ['What day of FR training is this? '];
FRday  = str2num(input(prompt,'s'));
pause(2);

%% prep 2 - define parameters for the session

% how long should the session be?
session_length = 20; % minutes

% pellet count and machine timeout
pellet_count = 1;
timeout_len  = 60*15;

% define a looping time - this is in minutes
amountOfTime = (70/60); %session_length; % 0.84 is 50/60secs, to account for initial pause of 10sec .25; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

%% experiment design prep.

% define number of trials
numTrials  = 20;

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
irArduino.Delay     = 'D8';
irArduino.rGoalArm  = 'D10';
irArduino.lGoalArm  = 'D12';
irArduino.rGoalZone = 'D7';
irArduino.lGoalZone = 'D2';
irArduino.choicePoint = 'D6';

% define LEDs for left/right/wood/mesh combinations
ledArduino.left  = 'D3';
ledArduino.right = 'D13';
ledArduino.wood  = 'D11';
ledArduino.mesh  = 'D5';
ON = 1; OFF = 0;

%{
for i = 1:10000000
    readDigitalPin(a,irArduino.lGoalArm)
end

ledArduino.left = 'D3';
ledArduino.right = 'D13';
ledArduino.wood = 'D11';
ledArduino.mesh = 'D5';
ON = 1; OFF = 0;
writeDigitalPin(a,ledArduino.left,OFF);
writeDigitalPin(a,ledArduino.left,OFF);


writeDigitalPin(a,ledArduino.mesh,OFF);
writeDigitalPin(a,ledArduino.wood,OFF);
writeDigitalPin(a,ledArduino.right,OFF);

%}

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

%% trial set up - make sure that there are no more than 3 of each trial type
disp('Generating trial distribution')
left  = repmat('L',[numTrials/2 1]);
right = repmat('R',[numTrials/2 1]);
both  = [left; right];
both_shuffled = both;
for i = 1:1000
    % notice how it rewrites the both_shuffled variable
    both_shuffled = both_shuffled(randperm(numel(both_shuffled)));
end
trajectory = cellstr(both_shuffled);

disp('Ensuring that there are no more than 3 of each trial type')
next = 0;
while next == 0
    for i = 1:length(trajectory)-3
        if trajectory{i}==trajectory{i+1} && trajectory{i}==trajectory{i+2} && trajectory{i}==trajectory{i+3} && trajectory{i}==trajectory{i+3}
            % try a new shuffle
            both_shuffled = randsample(trajectory,numTrials,false);
            trajectory = cellstr(both_shuffled);           
            break
        end
        if i == length(trajectory)-3
            next = 1;
        end
    end
end
   
% add 1 to trajectory - the rat won't run on this trial
trajectory{end+1} = 'E';

% update the numTrials variable
numTrials = length(trajectory);

%% delay duration
maxDelay = 20; % changed bc it takes time to flip the inserts
minDelay = 5; % 
delayDur = minDelay:1:maxDelay; % 5-45 seconds
rng('shuffle')

delayLenTrial = [];
next = 0;
while next == 0
    if numel(delayLenTrial) >= numTrials
        next = 1;
    else
        shortDuration  = randsample(minDelay:maxDelay/2,5,'true');
        longDuration   = randsample((maxDelay/2)+1:maxDelay,5,'true');
        allDurations   = [shortDuration longDuration];
        interleaved    = allDurations(randperm(length(allDurations)));
        delayLenTrial = [delayLenTrial interleaved];
    end
end
% the actual distribution of delays will be numtrial-1 because the first
% trial starts, then delays follow. On CD, there are 41 choices, but 40
% delays. On DA, there are 40 choices that could result in an error as the
% first trial is always rewarded
delayLenTrial = delayLenTrial(1:numTrials-1);

%% start recording - make a noise when recording begins
load gong.mat;
sound(y);
pause(5)

%% trials
open_t  = [doorFuns.tLeftOpen doorFuns.tRightOpen];
close_t = [doorFuns.tLeftClose doorFuns.tRightClose];
maze_prep = [doorFuns.sbLeftOpen doorFuns.sbRightOpen ...
    doorFuns.tRightClose doorFuns.tLeftClose doorFuns.centralClose ...
    doorFuns.gzLeftClose doorFuns.gzRightClose];
writeline(s,maze_prep)

% mark session start
sStart = [];
sStart = tic;
sessEnd = 0;
c = clock;
session_start = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time  = session_start-session_start; % quick definitio of this so it starts the while loop

% tell the experimenter which trial is start
if condID == 0
    if trajectory{1} == 'L'
        writeDigitalPin(a,ledArduino.left,ON);
        writeDigitalPin(a,ledArduino.wood,ON);
    elseif trajectory{1} == 'R'
        writeDigitalPin(a,ledArduino.right,ON);
        writeDigitalPin(a,ledArduino.mesh,ON);
    end
elseif condID == 1
    if trajectory{1} == 'L'
        writeDigitalPin(a,ledArduino.left,ON);
        writeDigitalPin(a,ledArduino.mesh,ON);
    elseif trajectory{1} == 'R'
        writeDigitalPin(a,ledArduino.right,ON);
        writeDigitalPin(a,ledArduino.wood,ON);
    end
end

% run while loop to make sure inserts were flipped - two while loops for
% two floor inserts
next = 0;
while next == 0
    if readDigitalPin(a,irArduino.rGoalArm)==0 || readDigitalPin(a,irArduino.lGoalArm)==0
        pause(1);
        next = 1;
    end
end
next = 0;
while next == 0
    if readDigitalPin(a,irArduino.choicePoint)==0 
        pause(5);
        next = 1;
    end
end
% turn everything off
writeDigitalPin(a,ledArduino.left,OFF);
writeDigitalPin(a,ledArduino.mesh,OFF);
writeDigitalPin(a,ledArduino.right,OFF);
writeDigitalPin(a,ledArduino.wood,OFF);

% open central stem door to start session
writeline(s,doorFuns.centralOpen);

for triali = 1:numTrials
    
    % start out with this as a way to make sure you don't exceed 30
    % minutes of the session
    if triali == numTrials || toc(sStart)/60 > session_length
        writeline(s,[doorFuns.centralClose doorFuns.tLeftClose doorFuns.tRightClose])
        %sessEnd = 1;            
        break % break out of for loop
    end      
    
    

    % set central door timeout value
    s.Timeout = .2;%timeout_len; % 5 minutes before matlab stops looking for an IR break    

    % first trial - set up the maze doors appropriately
    if trajectory{triali} == 'R'
        writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightClose doorFuns.centralOpen]);
    elseif trajectory{triali} == 'L'
        writeline(s,[doorFuns.sbRightOpen doorFuns.sbLeftClose doorFuns.centralOpen]);
    end   
    %pause(0.5);     

    % set irTemp to empty matrix
    irTemp = []; 

    % t-beam
    % check which direction the rat turns at the T-junction
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.rGoalArm)==0

            % Reward zone and eating
            % send to netcom 
            for rewardi = 1:pellet_count
                %pause(0.25)
                writeline(s,rewFuns.right)
                %pause(0.25)
            end    

            pause(5)
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);

            %pause(5)
            %writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);

            % break while loop
            next = 1;

        elseif readDigitalPin(a,irArduino.lGoalArm)==0

            % Reward zone and eating
            % send to netcom 
            for rewardi = 1:pellet_count
                %pause(0.25)
                writeline(s,rewFuns.left)
                %pause(0.25)
            end                       

            pause(5)
            %writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.tRightClose doorFuns.tLeftOpen]);
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.tRightClose doorFuns.tLeftOpen]);
            
            %pause(5)
            %writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tRightClose doorFuns.tLeftOpen]);

            % break out of while loop
            next = 1;
        end
    end    

    % return arm
    next = 0;
    while next == 0
        %irTemp = read(s,4,"uint8");  

        if readDigitalPin(a,irArduino.lGoalZone)==0
            % send neuralynx command for timestamp

            % close both for audio symmetry
            pause(0.5)
            writeline(s,[doorFuns.gzRightClose])
            pause(0.25)
            writeline(s,[doorFuns.gzLeftClose])
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);
            
            next = 1;                          
        elseif readDigitalPin(a,irArduino.rGoalZone)==0
            % send neuralynx command for timestamp

            % close both for audio symmetry
            pause(0.5)
            writeline(s,[doorFuns.gzLeftClose])
            pause(0.25)
            writeline(s,[doorFuns.gzRightClose])
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);            

            next = 1;
        end

    end  
    writeline(s,doorFuns.centralClose);
    
    % startbox beam
    % return arm
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.Delay)==0
            % prep the maze
            writeline(s,maze_prep)
                
            % prep the maze for the next trial
            if condID == 0
                if trajectory{triali+1} == 'L'
                    writeDigitalPin(a,ledArduino.left,ON);
                    writeDigitalPin(a,ledArduino.wood,ON);
                elseif trajectory{triali+1} == 'R'
                    writeDigitalPin(a,ledArduino.right,ON);
                    writeDigitalPin(a,ledArduino.mesh,ON);
                elseif trajectory{triali+1} == 'E'
                    break
                end
            elseif condID == 1
                if trajectory{triali+1} == 'L'
                    writeDigitalPin(a,ledArduino.left,ON);
                    writeDigitalPin(a,ledArduino.mesh,ON);
                elseif trajectory{triali+1} == 'R'
                    writeDigitalPin(a,ledArduino.right,ON);
                    writeDigitalPin(a,ledArduino.wood,ON);
                elseif trajectory{triali+1} == 'E'
                    break
                end
            end

            if trajectory{triali+1} == 'E'
                break
            end
            
            % run while loop to make sure inserts were flipped - two while loops for
            % two floor inserts
            next1 = 0;
            while next1 == 0
                if readDigitalPin(a,irArduino.rGoalArm)==0 || readDigitalPin(a,irArduino.lGoalArm)==0
                    next1 = 1;
                end
            end
            next2 = 0;
            while next2 == 0
                if readDigitalPin(a,irArduino.choicePoint)==0 
                    next2 = 1;
                end
            end

            % turn everything off
            writeDigitalPin(a,ledArduino.left,OFF);
            writeDigitalPin(a,ledArduino.mesh,OFF);
            writeDigitalPin(a,ledArduino.right,OFF);
            writeDigitalPin(a,ledArduino.wood,OFF);  
    
            if triali == numTrials-1 || toc(sStart)/60 > session_length || trajectory{triali+1} == 'E'
                next = 1;
            else  
                disp(['Pausing for ',num2str((delayLenTrial(triali))),' seconds'] )
                pause(delayLenTrial(triali));
                next = 1;
            end
        end
    end
    if triali == numTrials-1 || toc(sStart)/60 > session_length || trajectory{triali+1} == 'E'
        break % break out of for loop
    end      
end 

% get amount of time past since session start
c = clock;
session_time_update = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time = session_time_update-session_start;

%% ending noise - a fitting song to end the session
load handel.mat;
sound(y, 2*Fs);
writeline(s,[doorFuns.centralClose])

%% save data
% save data
c = clock;
c_save = strcat(num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(1)),'_','EndTime',num2str(c(4)),num2str(c(5)));

prompt   = 'Please enter the rats name ';
rat_name = input(prompt,'s');

prompt   = 'Please enter the task ';
task_name = input(prompt,'s');

prompt   = 'Enter notes ';
notes    = input(prompt,'s');

%prompt   = 'Enter the directory to save the data ';
%dir_name = input(prompt,'s');

save_var = strcat(rat_name,'_',task_name,'_',c_save);

try
    place2store = (['X:\01.Experiments\R21\',targetRat,'\CD\ForcedRuns']);
    cd(place2store);
    save(save_var);
catch
    mkdir(['X:\01.Experiments\R21\',targetRat,'\CD\ForcedRuns']);
    place2store = (['X:\01.Experiments\R21\',targetRat,'\CD\ForcedRuns']);
    cd(place2store);
    save(save_var);
end


%% clean maze

% close doors
writeline(s,doorFuns.closeAll);            

next = 0;
while next == 0
    
    % open doors and stop treadmill
    prompt = ['Are you finished cleaning (ie treadmill, walls, floors clean)? '];
    cleanUp = input(prompt,'s');

    if contains(cleanUp,[{'Y'} {'y'}])
        next = 1;
    else
        disp('Clean the maze!!!')
    end
end



