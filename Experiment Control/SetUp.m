
% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

%% prep 2 - define parameters for the session

% how long should the session be?
session_length = 30; % minutes

% define a looping time - this is in minutes
amountOfTime = (70/60); %session_length; % 0.84 is 50/60secs, to account for initial pause of 10sec .25; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

%% experiment design prep.

% define number of trials
numTrials  = 200;

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
irArduino.Delay       = 'D8';
irArduino.rGoalArm    = 'D10';
irArduino.lGoalArm    = 'D12';
irArduino.rGoalZone   = 'D7';
irArduino.lGoalZone   = 'D2';
irArduino.choicePoint = 'D6';

%{
for i = 1:10000000
    readDigitalPin(a,irArduino.choicePoint)
end
%}
%writeline(s,doorFuns.tRightClose)

%% interface with cheetah
% downloaded location of github code - automate for github
github_download_directory = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21';
addpath(github_download_directory);

% connect to netcom - automate this for github
pathName   = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21\NetComDevelopmentPackage_v3.1.0\MATLAB_M-files';
serverName = '192.168.3.100';
connect2netcom(pathName,serverName)

% open a stream to interface with Nlx objects - this is required
[succeeded, cheetahObjects, cheetahTypes] = NlxGetDASObjectsAndTypes; % gets cheetah objects and types

disp('MATLAB is ready for automaze and cheetah interactions')