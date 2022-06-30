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
    a = arduino('COM7','Uno','Libraries','Adafruit\MotorShieldV2');
end
arduinoLED = 'D13';
arduinoIR  = 'D8';

%{
for i = 1:100000000
    readDigitalPin(a,arduinoIR)
end
%}

% what session is this?
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

% how long will the session be?
prompt = ['Enter the session duration (minutes): '];
sessionDur = str2num(input(prompt,'s'));

% whenever a light is triggered, a reward will be delivered. But there will
% not be overlap in reward deliveries (e.g. rats will only trigger the next
% trial by receiving the reward). An IR beam will need to be split in order
% to acheive this, with a TTL being sent to cheetah
disp('Session starting')
sStart = tic; % start session timer

% turn off
writeDigitalPin(a,arduinoLED,0);

% while timer is less than the session duration, the task will continue
rewLatency = [];
probeLatency = [];
while toc(sStart)/60 < sessionDur

    % probe trials occur after every 10 trials
    if isempty(rewLatency)==0
        probeTrialIdx = floor(numel(rewLatency)/10) == ceil(numel(rewLatency)/10);
    else
        probeTrialIdx = 0;
    end
    
    % pause for a random amount of time between 5s and 15s - only pause if
    % the rat isn't in the reward zone
    next = 0;
    while next == 0
        if readDigitalPin(a,arduinoIR)==1
            iti = randsample(10:.05:20,1,'true');
            disp(['Pausing for ITI of ',num2str(iti), 'sec'])
            pause(iti);

            % Light on = reward
            if probeTrialIdx==0
                % on all trials (except probe), deliver reward
                writeline(s,rewFuns.right)   
                writeDigitalPin(a,arduinoLED,1)                
            elseif probeTrialIdx==1
                % on probe trials, do not deliver reward
                writeDigitalPin(a,arduinoLED,1)
            end
            tStart = tic; % start a timer for reward latency
            
            next=1;
        end
    end

    % if the rats nose enters the reward area, turn off the light       
    next = 0;
    while next == 0
        % check for IR break
        if readDigitalPin(a,arduinoIR)==0 % change to 0 when ready to test
            % if broken, turn off led, break out of loop and pause
            writeDigitalPin(a,arduinoLED,0);
            % latency between light on and reward reception
            rewLatency = horzcat(rewLatency,toc(tStart));                
            next = 1;
        end
    end
    
    % if the rats nose exits the reward area, continue      
    next = 0;
    while next == 0
        % check for IR break
        if readDigitalPin(a,arduinoIR)==1 % change to 0 when ready to test
            next = 1;
        end
    end    
        
    disp(['Time left = ' num2str(sessionDur-(toc(sStart)/60)),' minutes'])
end

cd('X:\01.Experiments\R21\Learning To Use Coherence Experiment\Coherence Arena')
c = clock;
c_save = strcat(num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(1)),'_','EndTime',num2str(c(4)),num2str(c(5)));
save(['data_',targetRat,'_',c_save])
