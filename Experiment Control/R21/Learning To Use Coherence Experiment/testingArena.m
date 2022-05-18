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

servo1 = 'D4';

sStart = [];
sStart = tic;

% loop
lag = 5;
for i = 1:10
    % present treat
    writeline(s,rewFuns.right) 
    
    % lag
    pause(lag);

    %{
    if toc(sStart)/60 > 1
        disp(['time ' num2str(toc(sStart))])
        break
    end
    %}
    disp(['iteration ' num2str(i)])

end    
    


serv_C = servo(a,"D4");
serv_C_open   = .2; 
serv_C_closed = .8; 
                
writePosition(serv_C, serv_C_open);
pause(0.5)
writePosition(serv_C, serv_C_closed);
   

lag = 1;
for i = 1:100
    pause(lag)
    writePosition(serv_C, serv_C_open);
    pause(lag)
    writePosition(serv_C, serv_C_closed);
end

