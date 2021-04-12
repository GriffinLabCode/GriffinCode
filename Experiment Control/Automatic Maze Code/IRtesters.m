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

%% testing IR

% first clear out IR
maze.Timeout = 10; % second timeout
next = 0; % set while loop variable
while next == 0
   irTemp = read(maze,4,"uint8"); % look for stored data
   if isempty(irTemp) == 1     % if there are no stored ir beam breaks
       next = 1;               % break out of the while loop
       disp('IR record empty - ignore the warning')
   else
       disp('IR record not empty')
       disp(irTemp)
   end
end



