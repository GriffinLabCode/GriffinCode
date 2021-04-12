%% IR tester

%% some parameters set by the user
numTrials    = 12;
pellet_count = 1;
timeout_len  = 20;
treadmill    = 0; % set this to 1 if you want to use

%% prep.
% load directory specific path
load('main_directory')
split_out = split(main_directory,'\');
split_out(end) = [];
split_out(end+1) = {'\Experiment Control\Automatic Maze Code'};
path_add = strjoin(split_out,'\');

% add path
addpath(path_add);
addpath 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21'

if exist("maze") == 0
    % connect to the serial port making an object
    maze = serialport("COM6",19200);
end

% load in door functions
doorFuns = DoorActions;

% test reward wells
rewFuns = RewardActions;

% load treadmill functions and settings
[treadFuns,treadSpeeds] = TreadMillFuns;

% get IR information
irBreakNames = irBreakLabels;

% for arduino
if exist("a") == 0
    % connect arduino
    a = arduino('COM5','Uno','Libraries','Adafruit\MotorShieldV2');
end

irArduino.Treadmill = 'D9';

%% testing doors

disp('Closing Doors')
pause(2)
writeline(maze,doorFuns.closeAll);

disp('Opening Doors')
pause(2)
writeline(maze,doorFuns.openAll);

disp('Closing Doors')
pause(2)
writeline(maze,doorFuns.closeAll);

disp('Opening Doors')
pause(2)
writeline(maze,doorFuns.openAll);


