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

%% connect with cheetah

% connect to netcom - automate this for github
rootDir = getCurrentPath;
rootDir = strsplit(rootDir,'\');
rootDir(end)=[];
rootDir = join(rootDir,'\');
rootDir = rootDir{:};
rootDir = horzcat(rootDir,'\NetComDevelopmentPackage_v3.1.0\MATLAB_M-files');
serverName = '192.168.3.100';
connect2netcom(rootDir,serverName)

% open a stream to interface with Nlx objects - this is required
[succeeded, cheetahObjects, cheetahTypes] = NlxGetDASObjectsAndTypes; % gets cheetah objects and types

%% start recording - make a noise when recording begins
load gong.mat;
sound(y);
[succeeded, reply] = NlxSendCommand('-StartRecording');
pause(5)

%% trials

% mark session start
sStart = [];
sStart = tic;
sessEnd = 0;
c = clock;
session_start = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time  = session_start-session_start; % quick definitio of this so it starts the while loop

tracker = 'S';
while toc(sStart)/60 < session_length

    if readDigitalPin(a,irArduino.rGoalArm)==0
        if contains(tracker,[{'R'} {'S'}])
            writeline(s,rewFuns.right)
            disp('Left reward')
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Left" 312 2');        
            %pause(5)
            % break while loop
            next = 1;
            tracker = 'L';
        end
    elseif readDigitalPin(a,irArduino.lGoalArm)==0
        if contains(tracker,[{'L'} {'S'}])
            writeline(s,rewFuns.left)
            disp('Right reward')
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Right" 322 2');

            %pause(5)
            % break out of while loop
            tracker = 'R';
            next = 1;
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



