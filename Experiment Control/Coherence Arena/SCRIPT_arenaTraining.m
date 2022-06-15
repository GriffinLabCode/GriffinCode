%% coherence arena training
% this code will interface with the coherence arena and deliver a reward
% following light presentation.
%
% Last thing to do is find a way to split the IR beam so that it sends a
% TTL to cheetah as well as a TTL to matlab
%

clear; clc
rng('shuffle')

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
arduinoIR  = '';

% which rat is this?
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

% what session is this?
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

% how long will the session be?
prompt = ['Enter the session duration (minutes): '];
sessionDur = num2str(input(prompt,'s'));

% whenever a light is triggered, a reward will be delivered. But there will
% not be overlap in reward deliveries (e.g. rats will only trigger the next
% trial by receiving the reward). An IR beam will need to be split in order
% to acheive this, with a TTL being sent to cheetah
sStart = tic; % start session timer

% while timer is less than the session duration, the task will continue
rewLatency = [];
while toc(sStart)/60 < sessionDur

    % pause for a random amount of time between 5s and 15s
    iti = randsample(5:.05:15,1,'true');
    pause(iti);
    
    % Light on = reward
    writeDigitalPin(a,arduinoLED,1)
    writeline(s,rewFuns.left)
    tStart = tic; % start a timer for reward latency
    
    % if the rats nose enters the reward area, turn off the light
    next = 0;
    while next == 0
        % check for IR break
        if readDigitalPin(a,arduinoIR)==0
            % if broken, turn off led, break out of loop and pause
            writeDigitalPin(a,arduinoLED,0);
            % latency between light on and reward reception
            rewLatency = horzcat(rewLatency,toc(tStart));
            next = 1;
        end
    end
end