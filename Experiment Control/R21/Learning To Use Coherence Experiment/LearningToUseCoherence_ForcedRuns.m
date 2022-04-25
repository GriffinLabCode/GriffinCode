%% This code was generated to test whether rats can "learn" to use coherence to control the maze

% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

% 'X:\01.Experiments\R21\Learning To Use Coherence Experiment'

%% confirm this is the correct code
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
confirm  = input(prompt,'s');

if ~contains(confirm,[{'y'} {'Y'}])
    error('This code does not match the target rat')
end

prompt = ['What session of Learning to use coherence is this? '];
DAday  = str2num(input(prompt,'s'));

% get baseline
disp(['Getting LFP names for ' targetRat])
cd(['X:\01.Experiments\R21\Learning To Use Coherence Experiment\',targetRat,'\baseline']);
load('baselineData')

% get threshold
disp('Getting threshold data')
cd(['X:\01.Experiments\R21\Learning To Use Coherence Experiment\',targetRat,'\thresholds']);
load('thresholds');

%% prep 2 - define parameters for the session

% how long should the session be?
session_length = 30; % minutes

% pellet count and machine timeout
pellet_count = 1;
timeout_len  = 60*15;

% define a looping time - this is in minutes
amountOfTime = (70/60); %session_length; % 0.84 is 50/60secs, to account for initial pause of 10sec .25; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

%% experiment design prep.

% define number of trials
numTrials  = 100;

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
% digital ports for reverse maze
irArduino.Delay       = 'D8';
irArduino.rGoalArm    = 'D10';
irArduino.lGoalArm    = 'D12';
irArduino.rGoalZone   = 'D7';
irArduino.lGoalZone   = 'D2';
irArduino.choicePoint = 'D6';
%{
for i = 1:10000000
    readDigitalPin(a,irArduino.rGoalZone)
end
%}

%% clean the stored data just in case IR beams were broken
s.Timeout = 1; % 1 second timeout
next = 0; % set while loop variable
while next == 0
   irTemp = read(s,4,"uint8"); % look for stored data
   if isempty(irTemp) == 1     % if there are no stored ir beam breaks
       next = 1;               % break out of the while loop
       disp('IR record empty - ignore the warning')
   else
       disp('IR record not empty')
       disp(irTemp)
   end
end

% close all maze doors - this gives problems with solenoid box
pause(0.25)
writeline(s,[doorFuns.centralClose doorFuns.sbLeftClose ...
    doorFuns.sbRightClose doorFuns.tLeftClose doorFuns.tRightClose]);

pause(0.25)
writeline(s,[doorFuns.gzLeftClose doorFuns.gzRightClose])

%% trial set up
left  = repmat('L',[numTrials/2 1]);
right = repmat('R',[numTrials/2 1]);
both  = [left; right];
both_shuffled = both;
for i = 1:1000
    % notice how it rewrites the both_shuffled variable
    both_shuffled = both_shuffled(randperm(numel(both_shuffled)));
end
trajectory = cellstr(both_shuffled);

% add 1 to trajectory - the rat won't run on this trial
trajectory{end+1} = 'E';

% update the numTrials variable
numTrials = length(trajectory);

%% some prep steps
threshold.coh_duration = 0.5;
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);    

% define pauseTime as 250ms and windowDuration as 1.25 seconds
pauseTime      = 0.25;
windowDuration = 1.25;

% Need to approximate idealized window lengths and true window lengths
% clear stream   
clearStream(LFP1name,LFP2name);
pause(windowDuration)
[succeeded, dataArray, timeStampArray, ~, ~, ...
numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% choose numOver - because the code isn't zero lag, there is some timeloss.
% Account for it
windowLength  = srate*windowDuration;    
trueWinLength = length(dataArray);
timeLoss      = trueWinLength-windowLength;
windowStep    = (srate*pauseTime)+timeLoss;

% initialize some variables
dataWin      = [];
cohAvg_data  = [];
coh          = [];

% prep for coherence
window = []; noverlap = []; 
fpass = [1:.5:20];
deltaRange = [1 4];
thetaRange = [6 11];

actualDataDuration = [];
time2cohAndSend = [];

% define a noise threshold in standard deviations
noiseThreshold = 4;
% define how much noise you're willing to accept
noisePercent = 1; % 5 percent

%% start recording - make a noise when recording begins
[succeeded, reply] = NlxSendCommand('-StartRecording');
load gong.mat;
sound(y);
pause(5)

%% trials
open_t  = [doorFuns.tLeftOpen doorFuns.tRightOpen];
close_t = [doorFuns.tLeftClose doorFuns.tRightClose];
maze_prep = [doorFuns.sbLeftOpen doorFuns.sbRightOpen ...
    doorFuns.tRightClose doorFuns.tLeftClose doorFuns.centralOpen ...
    doorFuns.gzLeftClose doorFuns.gzRightClose];

% mark session start
sStart = [];
sStart = tic;
sessEnd = 0;

c = clock;
session_start = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time  = session_start-session_start; % quick definitio of this so it starts the while loop

% neuralynx timestamp command
[succeeded, cheetahReply] = NlxSendCommand('-PostEvent "SessionStart" 700 3');
writeline(s,doorFuns.centralOpen);

% neuralynx timestamp command
[succeeded, cheetahReply] = NlxSendCommand('-PostEvent "TrialStart" 700 2');
 
writeline(s,doorFuns.centralOpen);

for triali = 1:numTrials

    % start out with this as a way to make sure you don't exceed 30
    % minutes of the session
    if triali == numTrials || toc(sStart)/60 > session_length
        writeline(s,doorFuns.closeAll)
        %sessEnd = 1;            
        break % break out of for loop
    end        

    % set central door timeout value
    s.Timeout = .2;%timeout_len; % 5 minutes before matlab stops looking for an IR break    

    % first trial - set up the maze doors appropriately
    if trajectory{triali} == 'R'
        writeline(s,[doorFuns.sbRightOpen doorFuns.sbLeftClose doorFuns.centralOpen]);
    elseif trajectory{triali} == 'L'
        writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightClose doorFuns.centralOpen]);
    end   

    if triali > 1
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayExit" 102 2'); 
    end
    
    % set irTemp to empty matrix
    irTemp = []; 
    
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.choicePoint) == 0   % if central beam is broken         
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPentry" 202 2');
            next = 1; % break out of the loop
        end
    end       
    
    % t-beam
    % check which direction the rat turns at the T-junction
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.rGoalArm)==0

            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPexit" 202 2');
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Left" 312 2');            
            
            % Reward zone and eating
            % send to netcom 
            for rewardi = 1:pellet_count
                %pause(0.25)
                writeline(s,rewFuns.right)
                %pause(0.25)
            end    

            pause(5)
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);
            %pause(5)
            %writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);

            % break while loop
            next = 1;

        elseif readDigitalPin(a,irArduino.lGoalArm)==0
            
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPexit" 202 2');
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Right" 322 2');
            
            % Reward zone and eating
            % send to netcom 
            for rewardi = 1:pellet_count
                %pause(0.25)
                writeline(s,rewFuns.left)
                %pause(0.25)
            end                       

            pause(5)
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tRightClose doorFuns.tLeftOpen]);
            %pause(5)
            %writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tRightClose doorFuns.tLeftOpen]);

            % break out of while loop
            next = 1;
        end
    end    

    % return arm
    next = 0;
    while next == 0
        %irTemp = read(s,4,"uint8");  

        if readDigitalPin(a,irArduino.lGoalZone)==0
            % send neuralynx command for timestamp
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "ReturnRight" 422 2');
            
            % close both for audio symmetry
            pause(0.5)
            writeline(s,[doorFuns.gzRightClose])
            pause(0.25)
            writeline(s,[doorFuns.gzLeftClose])
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);
            
            next = 1;                          
        elseif readDigitalPin(a,irArduino.rGoalZone)==0
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "ReturnLeft" 412 2');            

            % close both for audio symmetry
            pause(0.5)
            writeline(s,[doorFuns.gzLeftClose])
            pause(0.25)
            writeline(s,[doorFuns.gzRightClose])
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);            

            next = 1;
        end

    end  
    writeline(s,doorFuns.centralClose);
    
    % startbox beam
    % return arm
    cohMet = [];
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.Delay)==0
            writeline(s,doorFuns.closeAll)
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayEntry" 102 2');  

            dStart = tic;
            for i = 1:1000000000000000000000000000000000 % nearly infinite loop. This is needed for the first loop

                % this is a fail safe
                if cohMet == 1
                    writeline(s,doorFuns.centralOpen);
                    break
                end
                
                if i == 1
                    clearStream(LFP1name,LFP2name);
                    pause(windowDuration)
                    [succeeded, dataArray, timeStampArray, ~, ~, ...
                    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

                    % 2) store the data
                    % now add and remove data to move the window
                    dataWin    = dataArray;
                end

                % 3) pull in 0.25 seconds of data
                % pull in data at shorter resolution   
                pause(pauseTime)
                [succeeded, dataArray, timeStampArray, ~, ~, ...
                numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

                % 4) apply it to the initial array, remove what was there
                dataWin(:,1:length(dataArray))=[]; % remove 560 samples
                dataWin = [dataWin dataArray]; % add data

                % detrend by removing third degree polynomial
                data_det=[];
                data_det(1,:) = detrend(dataWin(1,:),3);
                data_det(2,:) = detrend(dataWin(2,:),3);

                % calculate coherence
                coh = [];
                [coh,f] = mscohere(data_det(1,:),data_det(2,:),window,noverlap,fpass,srate);

                % perform logical indexing of theta and delta ranges to improve
                % performance speed
                %cohAvg   = nanmean(coh(f > thetaRange(1) & f < thetaRange(2)));
                cohDelta = nanmean(coh(f > deltaRange(1) & f < deltaRange(2)));
                cohTheta = nanmean(coh(f > thetaRange(1) & f < thetaRange(2)));

                % determine if data is noisy
                zArtifact = [];
                zArtifact(1,:) = ((data_det(1,:)-baselineMean(1))./baselineSTD(1));
                zArtifact(2,:) = ((data_det(2,:)-baselineMean(2))./baselineSTD(2));
                idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
                percSat = (length(idxNoise)/length(zArtifact))*100;                

                % only include if theta coherence is higher than delta. Reject
                % if delta is greater than theta or if saturation exceeds
                % threshold
                if cohDelta > cohTheta || percSat > noisePercent || cohTheta < cohHighThreshold
                    cohMet = 0;
                    dataStored{triali}{i} = dataWin;
                    cohOUT{triali}{i}     = coh;
                    %rejected = 1;
                % accept if theta > delta and if minimal saturation
                elseif cohTheta > cohDelta && percSat < noisePercent && cohTheta > cohHighThreshold
                    cohMet = 1;
                    writeline(s,doorFuns.centralOpen);
                    delayDuration(triali) = toc(dStart);
                    % store data
                    dataStored{triali}{i}  = dataWin;
                    cohOUT{triali}{i}      = coh; 
                    next = 1;
                    disp(['Coherence of ',num2str(cohTheta),' met that of ', num2str(cohHighThreshold)])
                    break
                end

            end
        end
    end
    if triali == numTrials-1 || toc(sStart)/60 > session_length || trajectory{triali+1} == 'E'
        break % break out of for loop
    end      
end 
[succeeded, reply] = NlxSendCommand('-StopRecording');

% get amount of time past since session start
c = clock;
session_time_update = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time = session_time_update-session_start;

% END TIME
endTime = toc(sStart)/60;

%% ending noise - a fitting song to end the session
load handel.mat;
sound(y, 2*Fs);
writeline(s,[doorFuns.closeAll])

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

place2store = ['X:\01.Experiments\R21\Learning To Use Coherence Experiment\' targetRat,'\ForcedRuns'];
cd(place2store);
save(save_var);

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



