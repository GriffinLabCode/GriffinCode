%% This code was generated to test whether rats can "learn" to use coherence to control the maze

% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

% 'X:\01.Experiments\R21\Learning To Use Coherence Experiment'

%% confirm this is the correct code
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
confirm  = input(prompt,'s');

if ~contains(confirm,[{'y'} {'Y'}])
    error('This code does not match the target rat')
end

prompt = ['What session of Learning to use coherence is this? '];
DAday  = str2num(input(prompt,'s'));

disp(['Getting baseline data for ' targetRat])
cd(['X:\01.Experiments\R21\',targetRat,'\baseline alternative']);
load('baselineData')

disp(['Getting LFP names for ' targetRat])
cd(['X:\01.Experiments\R21\',targetRat,'\baseline']);
load('baselineData','LFP1name','LFP2name')

%% prep 2 - define parameters for the session

% how long should the session be?
session_length = 30; % minutes

% pellet count and machine timeout
pellet_count = 1;
timeout_len  = 60*15;

% define a looping time - this is in minutes
amountOfTime = (70/60); %session_length; % 0.84 is 50/60secs, to account for initial pause of 10sec .25; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

%% experiment design prep.

% define number of trials
numTrials  = 100;

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

%{
for i = 1:10000000
    readDigitalPin(a,irArduino.rGoalZone)
end
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

c = clock;
session_start = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time  = session_start-session_start; % quick definitio of this so it starts the while loop
writeline(s,doorFuns.centralOpen);

for triali = 1:numTrials

    % start out with this as a way to make sure you don't exceed 30
    % minutes of the session
    if triali == numTrials || toc(sStart)/60 > session_length
        writeline(s,doorFuns.closeAll)
        %sessEnd = 1;            
        break % break out of for loop
    end        

    % set central door timeout value
    s.Timeout = .2;%timeout_len; % 5 minutes before matlab stops looking for an IR break    

    % first trial - set up the maze doors appropriately
    if trajectory{triali} == 'R'
        writeline(s,[doorFuns.sbRightOpen doorFuns.sbLeftClose doorFuns.centralOpen]);
    elseif trajectory{triali} == 'L'
        writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightClose doorFuns.centralOpen]);
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
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);
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
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tRightClose doorFuns.tLeftOpen]);
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
            writeline(s,doorFuns.closeAll)
            
            if triali == numTrials-1 || toc(sStart)/60 > session_length || trajectory{triali+1} == 'E'
                next = 1;
            else            
                pause(10);
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

place2store = ['X:\01.Experiments\R21\Experimental Cohort\Training Data'];
cd(place2store);
save(save_var);

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



