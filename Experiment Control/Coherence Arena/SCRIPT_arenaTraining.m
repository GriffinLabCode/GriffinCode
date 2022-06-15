%% coherence arena training
% this code will interface with the coherence arena and deliver a reward
% following light presentation.
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

% connect devices
if exist("s") == 0
    % connect to the serial port making an object
    s = serialport("COM6",19200);
end

% reward wells
rewFuns = RewardActions;

if exist("a") == 0
    % connect arduino
    a = arduino('COM3','Uno','Libraries','Adafruit\MotorShieldV2');
end
arduinoLED = 'D13';

% which rat is this?
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

% what session is this?
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

% how long will the session be?
prompt = ['Enter the session duration (minutes): '];
sessionDur = num2str(input(prompt,'s'));

% now, we will loop

% reward delivery
writeline(s,rewFuns.left)

% test LED
writeDigitalPin(a,arduinoLED,1)
writeDigitalPin(a,arduinoLED,0)