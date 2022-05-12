%% bowl tester

% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

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
irArduino.reward   = 'D7';
%{
for i = 1:10000000
    readDigitalPin(a,irArduino.rGoalZone)
end

irArduino.Delay       = 'D8';
irArduino.rGoalArm    = 'D10';
irArduino.lGoalArm    = 'D12';
irArduino.rGoalZone   = 'D7';
irArduino.lGoalZone   = 'D2';
irArduino.choicePoint = 'D6';
%}

% loop
lag = 0;
for i = 1:1000000
    % present treat
    writeline(s,rewFuns.right) 
    
    % lag
    pause(lag);
    if toc(sStart)/60 > 10
        break
    end
end    
    



