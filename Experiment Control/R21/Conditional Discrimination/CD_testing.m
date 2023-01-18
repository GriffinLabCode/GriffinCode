%% Step 4

%% 
% sometimes if the session is not exceeding the time limit of 30 minutes,
% then the code will continue performing trials, but not save the data.
% Cheetah w%%

% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

%% confirm this is the correct code
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
confirm  = input(prompt,'s');

if ~contains(confirm,[{'y'} {'Y'}])
    error('This code does not match the target rat')
end

prompt = ['What day of CD TESTING is this? '];
CDday  = str2num(input(prompt,'s'));

disp(['Getting LFP names for ' targetRat])
cd(['X:\01.Experiments\R21\',targetRat,'\CD\baseline']);
load('baselineData')

% load in thresholds
disp('Getting threshold data')
cd(['X:\01.Experiments\R21\',targetRat,'\CD\thresholds']);
load('thresholds');

disp('Loading CD information')
cd(['X:\01.Experiments\R21\',targetRat,'\CD\conditionID']);
load('CDinfo')

% interface with cheetah setup
threshold.coh_duration = 0.5;
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);   
% do this twice to ensure reliable streaming
pause(5);
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);    

if srate > 2035 || srate < 2000
    error('Sampling rate is not correct')
end

%% coherence and real-time LFP extraction parameters

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
numTrials = 100; %24;
%umTrials = 24;

%% randomize delay durations
maxDelay = 20;
minDelay = 5;
delayDur = minDelay:1:maxDelay; % 5-45 seconds
rng('shuffle')

delayLenTrial = [];
next = 0;
while next == 0

    if numel(delayLenTrial) >= 100
        next = 1;
    else
        shortDuration  = randsample(minDelay:maxDelay/2,5,'true');
        longDuration   = randsample((maxDelay/2)+1:maxDelay,5,'true');
        
        % used for troubleshooting ->
        %shortDuration  = randsample(1:5,5,'true');
        %longDuration   = randsample(6:10,5,'true');        

        allDurations   = [shortDuration longDuration];
        interleaved    = allDurations(randperm(length(allDurations)));
        delayLenTrial = [delayLenTrial interleaved];
    end
end

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

% define LEDs for left/right/wood/mesh combinations
ledArduino.left  = 'D3';
ledArduino.right = 'D13';
ledArduino.wood  = 'D11';
ledArduino.mesh  = 'D5';
ON = 1; OFF = 0;

%writeline(s,doorFuns.closeAll);
%{
for i = 1:10000000
    readDigitalPin(a,irArduino.Delay)
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

%% trial set up - make sure that there are no more than 3 of each trial type
disp('Generating trial distribution')
left  = repmat('L',[numTrials/2 1]);
right = repmat('R',[numTrials/2 1]);
both  = [left; right];
both_shuffled = both;
for i = 1:1000
    % notice how it rewrites the both_shuffled variable
    both_shuffled = both_shuffled(randperm(numel(both_shuffled)));
end
trajectory = cellstr(both_shuffled);

disp('Ensuring that there are no more than 3 of each trial type')
next = 0;
while next == 0
    for i = 1:length(trajectory)-3
        if trajectory{i}==trajectory{i+1} && trajectory{i}==trajectory{i+2} && trajectory{i}==trajectory{i+3} && trajectory{i}==trajectory{i+3}
            % try a new shuffle
            both_shuffled = randsample(trajectory,numTrials,false);
            trajectory = cellstr(both_shuffled);           
            break
        end
        if i == length(trajectory)-3
            next = 1;
        end
    end
end
   
% add 1 to trajectory - the rat won't run on this trial
trajectory{end+1} = 'E';

%% delay duration
maxDelay = 20; % changed bc it takes time to flip the inserts
minDelay = 5; % 
delayDur = minDelay:1:maxDelay; % 5-45 seconds
rng('shuffle')

delayLenTrial = [];
next = 0;
while next == 0
    if numel(delayLenTrial) >= numTrials
        next = 1;
    else
        shortDuration  = randsample(minDelay:maxDelay/2,5,'true');
        longDuration   = randsample((maxDelay/2)+1:maxDelay,5,'true');
        allDurations   = [shortDuration longDuration];
        interleaved    = allDurations(randperm(length(allDurations)));
        delayLenTrial = [delayLenTrial interleaved];
    end
end
% the actual distribution of delays will be numtrial-1 because the first
% trial starts, then delays follow. On CD, there are 41 choices, but 40
% delays. On DA, there are 40 choices that could result in an error as the
% first trial is always rewarded
%delayLenTrial = delayLenTrial(1:numTrials-1);

% designate what 20% looks like
indicatorOUT = [];
for i = 1:10:100
    delays2pull = delayLenTrial(i:i+9);
    numExp = length(delays2pull)*.20;
    numCon = length(delays2pull)*.20;
    totalN = numExp+numCon;
    
    % randomly select which delay will be high and low
    %N1=1; N2=10;   % range desired
    %p=randperm(N1:N2);
        
    % high and low must happen before yoked
    next = 0;
    while next == 0
        idx = randperm(10,totalN);
        if idx(1) < idx(3) && idx(1) < idx(4) && idx(2) < idx(3) && idx(2) < idx(4)
            next = 1;
        end
    end
    
    % first is always high, second low, third, con h, 4 con L
    indicator = cellstr(repmat('Norm',[10 1]));
    
    % now replace
    indicator{idx(1)} = 'high';
    indicator{idx(2)} = 'low';
    indicator{idx(3)} = 'contH';
    indicator{idx(4)} = 'contL';
    
    % store indicator variable
    indicatorOUT = [indicatorOUT;indicator];
end  


%% start recording - make a noise when recording begins
% stream once more to ensure stream doesn't close
clearStream(LFP1name,LFP2name);
pause(windowDuration)
[succeeded, dataArray, timeStampArray, ~, ~, ...
numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

[succeeded, reply] = NlxSendCommand('-StartRecording');
load gong.mat;
sound(y);
pause(5)

%% trials
open_t  = [doorFuns.tLeftOpen doorFuns.tRightOpen];
close_t = [doorFuns.tLeftClose doorFuns.tRightClose];
maze_prep = [doorFuns.sbLeftOpen doorFuns.sbRightOpen ...
    doorFuns.tRightClose doorFuns.tLeftClose doorFuns.centralClose ...
    doorFuns.gzLeftClose doorFuns.gzRightClose];
pause(1);
writeline(s,maze_prep)

% mark session start
sStart = [];
sStart = tic;
sessEnd = 0;

c = clock;
session_start = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time  = session_start-session_start; % quick definitio of this so it starts the while loop

% neuralynx timestamp command
[succeeded, cheetahReply] = NlxSendCommand('-PostEvent "SessionStart" 700 3');

% neuralynx timestamp command
[succeeded, cheetahReply] = NlxSendCommand('-PostEvent "TrialStart" 700 2');
 
% tell the experimenter which trial is start
if condID == 0
    if trajectory{1} == 'L'
        writeDigitalPin(a,ledArduino.left,ON);
        writeDigitalPin(a,ledArduino.wood,ON);
    elseif trajectory{1} == 'R'
        writeDigitalPin(a,ledArduino.right,ON);
        writeDigitalPin(a,ledArduino.mesh,ON);
    end
elseif condID == 1
    if trajectory{1} == 'L'
        writeDigitalPin(a,ledArduino.left,ON);
        writeDigitalPin(a,ledArduino.mesh,ON);
    elseif trajectory{1} == 'R'
        writeDigitalPin(a,ledArduino.right,ON);
        writeDigitalPin(a,ledArduino.wood,ON);
    end
end


% run while loop to make sure inserts were flipped - two while loops for
% two floor inserts
next = 0;
while next == 0
    if readDigitalPin(a,irArduino.rGoalArm)==0 || readDigitalPin(a,irArduino.lGoalArm)==0
        pause(1);
        next = 1;
    end
end
next = 0;
while next == 0
    if readDigitalPin(a,irArduino.choicePoint)==0 
        pause(5);
        next = 1;
    end
end
% turn everything off
writeDigitalPin(a,ledArduino.left,OFF);
writeDigitalPin(a,ledArduino.mesh,OFF);
writeDigitalPin(a,ledArduino.right,OFF);
writeDigitalPin(a,ledArduino.wood,OFF);

% open central stem door to start session
writeline(s,doorFuns.centralOpen);

% make this array ready to track amount of time spent at choice
time2choice = []; detected = [];
coh = []; dataClean = []; dataDirty = []; % important to initiate these variables
yokH = []; yokL = [];
for triali = 1:numTrials

    % start out with this as a way to make sure you don't exceed 30
    % minutes of the session
    if toc(sStart)/60 > session_length
        %writeline(s,doorFuns.closeAll)
        %sessEnd = 1;            
        break % break out of for loop
    else        
        % set central door timeout value
        s.Timeout = .05; % 5 minutes before matlab stops looking for an IR break    

        % first trial - set up the maze doors appropriately
        writeline(s,[doorFuns.sbRightOpen doorFuns.sbLeftOpen doorFuns.centralOpen]);
    end

    % neuralynx timestamp command
    if triali > 1
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayExit" 102 2'); 
    end
    
    % set irTemp to empty matrix
    irTemp = []; 
    
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.choicePoint) == 0   % if central beam is broken
            tEntry = [];
            tEntry = tic;            
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPentry" 202 2');
            next = 1; % break out of the loop
        end
    end    
    
    % check which direction the rat turns at the T-junction
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.rGoalArm)==0

            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPexit" 202 2');
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Left" 312 2');
            
            % track the trajectory_text
            time2choice(triali) = toc(tEntry); % amount of time it took to make a decision
            trajectory_taken{triali} = 'L';
            %trajectory(triali)       = 0;            
            
            %pause(1);
            % Reward zone and eating
            % send to netcom 
            if triali > 1
                if trajectory_taken{triali} == 'L' && trajectory_taken{triali} == trajectory{triali}
                    disp('Correct')
                    accuracy_text{triali} = 'correct';
                    accuracy(triali) = 0;
                    % only reward on an alternation
                    writeline(s,rewFuns.right)                   
                else
                    accuracy_text{triali} = 'incorrect';
                    accuracy(triali) = 1;                    
                    disp('Error')
                end
            elseif triali == 1
                if trajectory_taken{triali} == 'L' && trajectory_taken{triali} == trajectory{triali}
                    disp('Correct')
                    accuracy_text{triali} = 'correct';
                    accuracy(triali) = 0;
                    % only reward on an alternation
                    writeline(s,rewFuns.right)                   
                else
                    accuracy_text{triali} = 'incorrect';
                    accuracy(triali) = 1;                    
                    disp('Error')
                end                
            end
            pause(5)
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.tLeftClose doorFuns.tRightOpen doorFuns.centralClose]);
            next = 1;

        elseif readDigitalPin(a,irArduino.lGoalArm)==0
            
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPexit" 202 2');
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Right" 322 2');
            
            % track the trajectory_text
            time2choice(triali) = toc(tEntry); % amount of time it took to make a decision
            trajectory_taken{triali} = 'R';
            %trajectory(triali)      = 1;            
            
            % Reward zone and eating
            % send to netcom 
            if triali > 1
                if trajectory_taken{triali} == 'R' && trajectory_taken{triali} == trajectory{triali}
                    disp('Correct')
                    accuracy_text{triali} = 'correct';
                    accuracy(triali) = 0;
                    % only reward on an alternation
                    writeline(s,rewFuns.left)                   
                else
                    accuracy_text{triali} = 'incorrect';
                    accuracy(triali)=1;
                    disp('Error')
                end
            elseif triali == 1
                if trajectory_taken{triali} == 'R' && trajectory_taken{triali} == trajectory{triali}
                    disp('Correct')
                    accuracy_text{triali} = 'correct';
                    accuracy(triali) = 0;
                    % only reward on an alternation
                    writeline(s,rewFuns.left)                   
                else
                    accuracy_text{triali} = 'incorrect';
                    accuracy(triali)=1;
                    disp('Error')
                end                 
            end                    

            pause(5)
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.tRightClose doorFuns.tLeftOpen doorFuns.centralClose]);
            next = 1;
        end
    end    

    % return arm
    next = 0;
    while next == 0
        
        if readDigitalPin(a,irArduino.lGoalZone) == 0
            
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "ReturnRight" 422 2');
            
            % close both for audio symmetry and do opposite doors first
            % with a slightly longer delay so the rats can have a fraction
            % of time longer to enter
            %pause(0.5)
            pause(0.5)
            writeline(s,[doorFuns.gzRightClose])
            pause(0.25)
            writeline(s,[doorFuns.gzLeftClose])
            
            next = 1;
            
        elseif readDigitalPin(a,irArduino.rGoalZone) == 0

            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "ReturnLeft" 412 2');            
            
            % close both for audio symmetry
            pause(0.5)
            writeline(s,[doorFuns.gzLeftClose])
            pause(0.25)
            writeline(s,[doorFuns.gzRightClose])          

            next = 1;
        end
    end

    next = 0;
    while next == 0   
        % track choice entry
        if readDigitalPin(a,irArduino.Delay)==0 
            disp('DelayEntry')
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayEntry" 102 2');  
            writeline(s,[doorFuns.tLeftClose doorFuns.tRightClose])
            %tEntry = [];
            %tEntry = tic;
            next = 1;

        end
    end

    % break out of the session if youre out of time
    if triali == numTrials || toc(sStart)/60 > session_length
        break % break out of for loop
    end       

    disp(['Time left on task = ',num2str(round(session_length-toc(sStart)/60)),'min'])
    if toc(sStart)/60 > session_length
        break % break out of for loop
    end         
    
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.Delay)==0
            % prep the maze
            writeline(s,maze_prep)
                
            % prep the maze for the next trial
            if condID == 0
                if trajectory{triali+1} == 'L'
                    writeDigitalPin(a,ledArduino.left,ON);
                    writeDigitalPin(a,ledArduino.wood,ON);
                elseif trajectory{triali+1} == 'R'
                    writeDigitalPin(a,ledArduino.right,ON);
                    writeDigitalPin(a,ledArduino.mesh,ON);
                elseif trajectory{triali+1} == 'E'
                    break
                end
            elseif condID == 1
                if trajectory{triali+1} == 'L'
                    writeDigitalPin(a,ledArduino.left,ON);
                    writeDigitalPin(a,ledArduino.mesh,ON);
                elseif trajectory{triali+1} == 'R'
                    writeDigitalPin(a,ledArduino.right,ON);
                    writeDigitalPin(a,ledArduino.wood,ON);
                elseif trajectory{triali+1} == 'E'
                    break
                end
            end

            if trajectory{triali+1} == 'E'
                break
            end
            
            % run while loop to make sure inserts were flipped - two while loops for
            % two floor inserts
            next1 = 0;
            while next1 == 0
                if readDigitalPin(a,irArduino.rGoalArm)==0 || readDigitalPin(a,irArduino.lGoalArm)==0
                    next1 = 1;
                end
            end
            next2 = 0;
            while next2 == 0
                if readDigitalPin(a,irArduino.choicePoint)==0 
                    next2 = 1;
                end
            end

            % turn everything off
            writeDigitalPin(a,ledArduino.left,OFF);
            writeDigitalPin(a,ledArduino.mesh,OFF);
            writeDigitalPin(a,ledArduino.right,OFF);
            writeDigitalPin(a,ledArduino.wood,OFF);  
            
            next = 1;
        end
    end  

    disp(['Time left on task = ',num2str(round(session_length-toc(sStart)/60)),'min'])
    if toc(sStart)/60 > session_length
        break % break out of for loop
    end 
    
    % begin delay pause and real-time coherence detection
    %delayLength = delayLenTrial(triali);

    % neuralynx timestamp command
    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CohDetectStart" 102 2');  
    
    % open these for storing
    if contains(indicatorOUT{triali},'Norm') || contains(indicatorOUT{triali},'NormHighFail') || contains(indicatorOUT{triali},'NormLowFail')
        disp(['Normal delay of ',num2str(delayLenTrial(triali))])
        pause(delayLenTrial(triali));

    elseif contains(indicatorOUT{triali},'high')
        dStart = [];
        dStart = tic;        
        pause(3.5);
        for i = 1:1000000000 % nearly infinite loop. This is needed for the first loop

            if i == 1
                clearStream(LFP1name,LFP2name);
                pause(windowDuration)
                [succeeded, dataArray, timeStampArray, ~, ~, ...
                numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

                % 2) store the data
                % now add and remove data to move the window
                dataWin    = dataArray;
            end

            try
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
                if cohDelta > cohTheta || percSat > noisePercent
                    detected{triali}(i)=1;
                    rejected = 1;
                    %disp('Rejected')  
                % accept if theta > delta and if minimal saturation
                elseif cohTheta > cohDelta && percSat < noisePercent
                    rejected = 0;
                    detected{triali}(i)=0;
                end

                % store data
                dataZStored{triali}{i} = zArtifact;
                dataStored{triali}{i}  = dataWin;
                cohOUT{triali}{i}      = coh;

                % if coherence is higher than your threshold, and the data is
                % accepted, then let the rat make a choice
                if cohTheta > cohHighThreshold && rejected == 0
                    met_high = 1;
                    indicatorOUT{triali} = 'highMET';                
                    break 
                % if you exceed 30s, break out
                elseif toc(dStart) > maxDelay
                    met_high = 0;
                    indicatorOUT{triali} = 'highFAIL'; 
                    break
                end 
            catch
                clearStream(LFP1name,LFP2name);
                pause(windowDuration)
                [succeeded, dataArray, timeStampArray, ~, ~, ...
                numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

                % 2) store the data
                % now add and remove data to move the window
                dataWin    = dataArray;
            end                
        end
        
        %yokH_store = yokH;
        %writeline(s,[doorFuns.sbRightOpen doorFuns.sbLeftOpen doorFuns.centralOpen]);                
        
        % IMPORTANT: Storing this for later
        cohEnd = toc(dStart);
        %disp(['Coh detect high end at ', num2str(cohEnd)])

        % now replace the delayLenTrial with coherence delay
        %delayLenTrial(triali) = cohEnd;
   
        % now identify yoked high, and replace with control delay        
        if met_high == 1
            % if coherence was met, replace the delay trial time with the
            % amount of time it took to finish the delay
            delayLenTrial(triali) = cohEnd; 
            yokH = [yokH cohEnd];
        elseif met_high == 0
            % if coherence wasn't met, replace the next yokeH with a 'Norm'
            % replace the next high with a 'norm'
            delayLenTrial(triali) = cohEnd; 
            idxRem = find(contains(indicatorOUT,'contH')==1);
            indicatorOUT{idxRem(1)}='NormHighFail';
        end
        
            %yokH = [yokH NaN];
        
    elseif contains(indicatorOUT{triali},'low')
        dStart = [];
        dStart = tic;
        pause(3.5);        
        for i = 1:1000000000 % nearly infinite loop. This is needed for the first loop

            if i == 1
                clearStream(LFP1name,LFP2name);
                pause(windowDuration)
                [succeeded, dataArray, timeStampArray, ~, ~, ...
                numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

                % 2) store the data
                % now add and remove data to move the window
                dataWin    = dataArray;
            end
            try
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

                % identify theta > delta or delta > theta
                % take averages
                %thetaIdx = find(f > thetaRange(1) & f < thetaRange(2));
                %thetaIdx = find(f > thetaRange(1) & f < thetaRange(2));

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
                if cohDelta > cohTheta || percSat > noisePercent
                    detected{triali}(i)=1;
                    rejected = 1;
                    %disp('Rejected')  
                % accept if theta > delta and if minimal saturation
                elseif cohTheta > cohDelta && percSat < noisePercent
                    rejected = 0;
                    detected{triali}(i)=0;
                end            

                % store data
                dataZStored{triali}{i} = zArtifact;
                dataStored{triali}{i}  = dataWin;
                cohOUT{triali}{i}      = coh;

                % if coherence is less than your threshold, and the data is
                % accepted, then let the rat make a choice
                if cohTheta < cohLowThreshold && rejected == 0
                    %writeline(s,[doorFuns.sbRightOpen doorFuns.sbLeftOpen doorFuns.centralOpen]); 
                    met_low = 1;
                    indicatorOUT{triali} = 'lowMET';
                    break
                % if you exceed 30s, break out
                elseif toc(dStart) > maxDelay
                    met_low = 0;
                    indicatorOUT{triali} = 'lowFAIL';
                    break
                end
            catch
                clearStream(LFP1name,LFP2name);
                pause(windowDuration)
                [succeeded, dataArray, timeStampArray, ~, ~, ...
                numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

                % 2) store the data
                % now add and remove data to move the window
                dataWin    = dataArray;
            end                
        end
        
        % IMPORTANT: Storing this for later
        cohEnd = toc(dStart);
        %disp(['Coh detect low end at ', num2str(cohEnd)])

        % now replace the delayLenTrial with coherence delay
        %delayLenTrial(triali) = cohEnd;
   
        % now identify yoked high, and replace with control delay
        if met_low == 1
            % if coherence was met, replace the delay trial time with the
            % amount of time it took to finish the delay
            delayLenTrial(triali) = cohEnd; 
            yokL = [yokL cohEnd];
        elseif met_low == 0
            % if coherence wasn't met, replace the next yokeH with a 'Norm'
            % replace the next high with a 'norm'
            delayLenTrial(triali) = cohEnd; 
            idxRem = find(contains(indicatorOUT,'contL')==1);
            indicatorOUT{idxRem(1)}='NormLowFail';
        end
        
    % only yoke up if you have options to pull from, if not then it'll
    % become a 'norm' trial
    elseif contains(indicatorOUT{triali},'contL')
        
        if isempty(yokL)==0
            % pause for yoked control
            %disp(['Pausing for low yoked control of ',num2str(yokL(1))])
            pause(yokL(1));
            indicatorOUT{triali} = 'yokeL_MET';
            delayLenTrial(triali) = yokL(1);            
            % delete so that next time, 1 is the updated delay
            yokL(1)=[];
        elseif isempty(yokL)==1
            %disp(['Normal delay of ',num2str(delayLenTrial(triali))])
            pause(delayLenTrial(triali));
            indicatorOUT{triali} = 'yokeL_FAIL';
        end
        
    elseif contains(indicatorOUT{triali},'contH')
        % if you have a yoke to pull from
        if isempty(yokH)==0
            %disp(['Pausing for high yoked control of ',num2str(yokH(1))])
            pause(yokH(1));
            indicatorOUT{triali} = 'yokeH_MET';  
            delayLenTrial(triali) = yokH(1);
            yokH(1)=[];
        % if you don't have a yoke to pull from
        elseif isempty(yokH)==1
            %disp(['Normal delay of ',num2str(delayLenTrial(triali))])
            pause(delayLenTrial(triali));
            indicatorOUT{triali} = 'yokeH_FAIL';          
        end        
    end   
       
end 
[succeeded, reply] = NlxSendCommand('-StopRecording');

% if this happens, it means that the session ended during the delay or
% directly after it
disp('Unlike DA, on CD, there are N trajectories, N correct choices, but N-1 delays');
if length(dataStored)==length(accuracy)
    dataStored(end)=[];
    dataZStored(end)=[];
end
% get amount of time past since session start
c = clock;
session_time_update = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time = session_time_update-session_start;

% END TIME
endTime = toc(sStart)/60;

%% compute accuracy array and create some figures
percentAccurate = ((numel(find(accuracy==0)))/(numel(accuracy)))*100;

%% ending noise - a fitting song to end the session
load handel.mat;
sound(y, 2*Fs);
%writeline(s,[doorFuns.closeAll])

%% save data
% save data
c = clock;
c_save = strcat(num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(1)),'_','EndTime',num2str(c(4)),num2str(c(5)));

prompt   = 'Please enter the rats name ';
rat_name = input(prompt,'s');

prompt   = 'Please enter the task ';
task_name = input(prompt,'s');

prompt   = 'Enter notes for the session ';
info     = input(prompt,'s');

prompt = 'Did the EIB come off the rats head during any delay trials? ';
eibOFF  = input(prompt,'s');
if contains(eibOFF,[{'y'} {'Y'}])
    eibSave = 'EIBfellOFF_trialsRemoved';
else
    eibSave = 'allTrialsGood';
end

prompt = 'Did the EIB come off at any OTHER point during the session? ';
eibOFF_session = input(prompt,'s');

%% VISUALIZE
clear plot
if contains(eibOFF,[{'y'} {'Y'}])
    figure('color','w');    
    for i = 1:length(dataStored)
        disp('If there are any flat lined data, the EIB came off')
        dataPlot = horzcat(dataStored{i}{:});
        subplot(4,10,i)
        plot(dataPlot(1,:));  
        title(['Trial',num2str(i)])
        axis tight;
    end
    prompt   = 'Identify any large magnitude events, enter those trials here: ';
    remTrial = str2num(input(prompt,'s')); 
    
    % save og data just to have it
    dataOG.dataZStored = dataZStored;
    dataOG.dataStored  = dataStored;
    dataOG.coh         = coh;
    dataOG.delayLenTrial = delayLenTrial;
    
    % remove trials where eib came off
    dataZStored(logical(trial2rem))=[];
    dataStored(logical(trial2rem))=[];
    coh(logical(trial2rem))=[];

end



save_var = strcat(rat_name,'_',task_name,'_',eibSave,'_',c_save);

place2store = ['X:\01.Experiments\R21\',targetRat];
cd(place2store);
save(save_var);

% what trials to exclude
clear prompt
prompt   = 'Enter trajectories to exclude ';
remTraj  = str2num(input(prompt,'s'));

disp('Saving excluded trajectories')
save('removeTrajectories','remTraj','save_var');

disp('Remember! There are N trajectories, but N-1 delays. Therefore, remove trial #1 when lining up BMI data');

%% provide modified variables to user
remChoices = remTraj;

numTrials = length(accuracy);
indicatorOUT(numTrials+1:end)=[];
delayLenTrial(numTrials+1:end)=[];

% indicatorOUT temp
tempInd = [];
tempInd = indicatorOUT;

% delay times 
delayTimes = [];
delayTimes = delayLenTrial;

% trial accuracies
accuracyNew  = []; 
accuracyNew  = accuracyNew;        

% remove
tempInd(remChoices)={'NaN'};
delayTimes(remChoices)=NaN;
accuracy(remChoices) =NaN;

% get indices
idxHigh = []; idxLow = []; idxYokedHigh = []; idxYokedLow = [];
idxHigh = find(contains(tempInd,'highMET')==1);
idxLow = find(contains(tempInd,'lowMET')==1);
idxYokedHigh = find(contains(tempInd,'yokeH_MET')==1);
idxYokedLow = find(contains(tempInd,'yokeL_MET')==1);
%idxNorm = find(contains(tempInd,[{'Norm'}, {'NormHighFail'} {'NormLowFail'}]));
idxNorm = find(contains(tempInd,[{'Norm'}]));

% find times and make sure everytihng lines up
delayHighTimes = []; delayHighYTimes = [];
delayHighTimes = delayTimes(idxHigh);
delayHighYTimes = delayTimes(idxYokedHigh);

delayLowTimes = []; delayLowYTimes = [];
delayLowTimes = delayTimes(idxLow);
delayLowYTimes = delayTimes(idxYokedLow);
delayNorm = delayTimes(idxNorm);    

% plot data to visualize
figure('color','w')
for i = 1:length(idxHigh)
    subplot(4,4,i)
    lfphighTemp = [];
    lfphighTemp = dataStored{idxHigh(i)};
    lfphighTemp = lfphighTemp{end};
    plot(lfphighTemp(1,:),'b')
    title(['Trial ',num2str(idxHigh(i))])
    ylabel('HPC')
    axis tight;
end
figure('color','w')
for i = 1:length(idxHigh)
    subplot(4,4,i)
    lfphighTemp = [];
    lfphighTemp = dataStored{idxHigh(i)};
    lfphighTemp = lfphighTemp{end};    
    plot(lfphighTemp(2,:),'r')
    axis tight;
    title(['Trial ',num2str(idxHigh(i))])
    ylabel('PFC')
end
idxHighRem2 = str2num(input('Which trials to remove? ','s'));
idxHigh(idxHighRem2) = [];

% plot data to visualize
figure('color','w')
for i = 1:length(idxLow)
    subplot(4,4,i)
    lfpLowTemp = [];
    lfpLowTemp = dataStored{idxLow(i)};
    lfpLowTemp = lfpLowTemp{end};
    plot(lfpLowTemp(1,:),'b')
    title(['Trial ',num2str(idxLow(i))])
    ylabel('HPC')
    axis tight;
end
figure('color','w')
for i = 1:length(idxLow)
    subplot(4,4,i)
    lfpLowTemp = [];
    lfpLowTemp = dataStored{idxLow(i)};
    lfpLowTemp = lfpLowTemp{end};    
    plot(lfpLowTemp(2,:),'r')
    axis tight;
    title(['Trial ',num2str(idxLow(i))])
    ylabel('PFC')
end
idxLowRem2 = str2num(input('Which trials to remove? ','s'));
idxLow(idxLowRem2) = [];

% do the same 
% remove any delay times that don't have an equally matched partner
% we're checking for equal delay High Times using the yoked
% condition because there can only be a yoked trial if there is a
% high trial
% however, it is possible that some trials could get removed. So we
% need to account for those too.
idxRemHigh = [];
for j = 1:length(delayHighYTimes)
    findYinHigh = find(delayHighTimes == delayHighYTimes(j));
    if isempty(findYinHigh)==1
        idxRemHigh(j) = 1;
    else
        idxRemHigh(j) = 0;
    end
end       
idxRemLow = [];
for j = 1:length(delayLowYTimes)
    findYinLow = find(delayLowTimes == delayLowYTimes(j));
    if isempty(findYinLow)==1
        idxRemLow(j) = 1;
    else
        idxRemLow(j) = 0;
    end
end   

% idxRemLow: if yoked time isn't found in experimental, remove the
% yoked time
% removal of the top two are mostly to check my work
delayLowYTimes(logical(idxRemLow))=[];
delayHighYTimes(logical(idxRemHigh))=[];
% remove from the index used above to get times
idxYokedHigh(logical(idxRemHigh))=[];
idxYokedLow(logical(idxRemLow))=[];

%----------------------------------------%

% do everything above, except switch variables
idxRemHigh = [];
for j = 1:length(delayHighTimes)
    findHighInY = find(delayHighYTimes == delayHighTimes(j));
    if isempty(findHighInY)==1
        idxRemHigh(j) = 1;
    else
        idxRemHigh(j) = 0;
    end
end       
idxRemLow = [];
for j = 1:length(delayLowTimes)
    findLowInY = find(delayLowYTimes == delayLowTimes(j));
    if isempty(findLowInY)==1
        idxRemLow(j) = 1;
    else
        idxRemLow(j) = 0;
    end
end   

% idxRemLow: if yoked time isn't found in experimental, remove the
% yoked time
delayLowTimes(logical(idxRemLow))=[];
delayHighTimes(logical(idxRemHigh))=[];
% remove from the index used above to get times
idxHigh(logical(idxRemHigh))=[];
idxLow(logical(idxRemLow))=[]; 

%----%
highTime  = delayHighTimes;
lowTime   = delayLowTimes;
lowYTime  = delayLowYTimes;
highYTime = delayHighYTimes;        
NormTime  = delayNorm;

% get choice accuracies
acc_high  = accuracy(idxHigh);
acc_low   = accuracy(idxLow);
acc_yHigh = accuracy(idxYokedHigh);
acc_yLow  = accuracy(idxYokedLow);   
acc_Norm  = accuracy(idxNorm);

% get alternation index
for i = 1:length(idxHigh)
    try
        altTrajHigh(i,:) = trajectory_taken(idxHigh(i)-1:idxHigh(i));
    catch
        altTrajHigh(i,:)=[{NaN'} {NaN}];
    end
    try
        altTrajHighY(i,:) = trajectory_taken(idxYokedHigh(i)-1:idxYokedHigh(i));
    catch
        altTrajHighY(i,:)=[{NaN} {NaN}];
    end
end
for i = 1:length(idxLow)
    try
        altTrajLow(i,:) = trajectory_taken(idxLow(i)-1:idxLow(i));
    catch
        altTrajLow(i,:)=[{NaN} {NaN}];
    end
    try
        altTrajLowY(i,:) = trajectory_taken(idxYokedLow(i)-1:idxYokedLow(i));
    catch
        altTrajLowY(i,:)=[{NaN} {NaN}];
    end
end
altTrajLow   = nan2empty(altTrajLow);
altTrajLowY  = nan2empty(altTrajLowY);
altTrajHigh  = nan2empty(altTrajHigh);
altTrajHighY = nan2empty(altTrajHighY);
[~,idxEmpty] = emptyCellErase(altTrajLow(:,1));
altTrajLow (idxEmpty,:)=[];
altTrajLowY(idxEmpty,:)=[];
[~,idxEmpty] = emptyCellErase(altTrajLowY(:,1));
% now do the same for high
altTrajHigh (idxEmpty,:)=[];
altTrajHighY(idxEmpty,:)=[];
[~,idxEmpty] = emptyCellErase(altTrajHigh(:,1));
altTrajHigh (idxEmpty,:)=[];
altTrajHighY(idxEmpty,:)=[];
[~,idxEmpty] = emptyCellErase(altTrajHighY(:,1));
altTrajHigh (idxEmpty,:)=[];
altTrajHighY(idxEmpty,:)=[];

% alternation index
for i = 1:size(altTrajHigh,1)
    if altTrajHigh{i,1} == altTrajHigh{i,2}
        altIdxHigh(i,:) = 0;
    elseif altTrajHigh{i,1} ~= altTrajHigh{i,2}
        altIdxHigh(i,:) = 1; % 1 = alternation
    end
    
    if altTrajHighY{i,1} == altTrajHighY{i,2}
        altIdxHighY(i,:) = 0;
    elseif altTrajHighY{i,1} ~= altTrajHighY{i,2}
        altIdxHighY(i,:) = 1; % 1 = alternation
    end    
end

for i = 1:size(altTrajLow,1)
    if altTrajLow{i,1} == altTrajLow{i,2}
        altIdxLow(i,:) = 0;
    elseif altTrajLow{i,1} ~= altTrajLow{i,2}
        altIdxLow(i,:) = 1; % 1 = alternation
    end
    
    if altTrajLowY{i,1} == altTrajLowY{i,2}
        altIdxLowY(i,:) = 0;
    elseif altTrajLowY{i,1} ~= altTrajLowY{i,2}
        altIdxLowY(i,:) = 1; % 1 = alternation
    end    
end

place2store = ['X:\01.Experiments\R21\',targetRat];
cd(place2store);
save_var = strcat(rat_name,'_',task_name,'_',eibSave,'_',c_save,'_CLEANED');
save(save_var);