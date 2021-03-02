% Alternation task
% written by John Stout

clear; clc

% load directory specific path
load('main_directory')
split_out = split(main_directory,'\');
split_out(end) = [];
split_out(end+1) = {'Automatic Maze Code'};
path_add = strjoin(split_out,'\');

% add path
addpath(path_add);
addpath 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21'

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

% close doors
close_all = [doorFuns.centralClose doorFuns.sbLeftClose ...
    doorFuns.sbRightClose doorFuns.tLeftClose doorFuns.tRightClose ...
    doorFuns.gzRightClose doorFuns.gzLeftClose];

writeline(s,close_all)










