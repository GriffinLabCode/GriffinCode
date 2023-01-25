%% Step 4

%% 
% sometimes if the session is not exceeding the time limit of 30 minutes,
% then the code will continue performing trials, but not save the data.
% Cheetah w%%
rng('shuffle');
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

prompt = ['What day of CD TRAINING is this? '];
CDday  = str2num(input(prompt,'s'));


% load in condition information
disp('Loading CD information')
cd(['X:\01.Experiments\R21\',targetRat,'\CD\conditionID']);
load('CDinfo')

disp(['Getting LFP names for ' targetRat])
cd(['X:\01.Experiments\R21\',targetRat,'\CD\baseline']);
load('baselineData')

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
session_length = 10; % minutes

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

bmi = 0;
%writeline(s,doorFuns.closeAll);
%{
for i = 1:10000000
    readDigitalPin(a,irArduino.lGoalArm)
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
outr = randsample([1,2],1);
both = [];
for i = 1:round(1000/6)
    left  = repmat('L',[6 1]);
    right = repmat('R',[6 1]);
    if outr == 1
        both{i}  = [left; right];
    else
        both{i} = [right;left];
    end
end
both = vertcat(both{:});
trajectory = cellstr(both);

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

    disp(['Time left on task = ',num2str(round(session_length-toc(sStart)/60)),'min'])
    if toc(sStart)/60 > session_length
        break % break out of for loop
    end         
    
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.Delay)==0
            disp('DelayEntry')
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayEntry" 102 2');  
            %writeline(s,[doorFuns.tLeftClose doorFuns.tRightClose])            
            
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
    
    % begin delay pause and real-time coherence detection
    delayLength = delayLenTrial(triali);

    % neuralynx timestamp command
    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CohDetectStart" 102 2');  
    
    if bmi == 1
        dStart = [];
        dStart = tic;
        for i = 1:1000000000 % nearly infinite loop. This is needed for the first loop
            disp('Getting coherence');
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

                % determine if data is noisy
                zArtifact = [];
                zArtifact(1,:) = ((data_det(1,:)-baselineMean(1))./baselineSTD(1));
                zArtifact(2,:) = ((data_det(2,:)-baselineMean(2))./baselineSTD(2));

                idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
                percSat = (length(idxNoise)/length(zArtifact))*100;
                if percSat > noisePercent
                    detected{triali}(i)=1;
                    disp('Artifact Detected - coherence not calculated')     
                else
                    detected{triali}(i)=0;
                end

                % calculate coherence
                [coh{triali}{i},f] = mscohere(data_det(1,:),data_det(2,:),[],[],fpass,srate);
               % cohAvg = nanmean(coh);

                % store data
                dataZStored{triali}{i} = zArtifact;
                dataStored{triali}{i}  = dataWin;

                % store coherence data
                %cohAvg_data = [cohAvg_data cohAvg];

                % calculate the amount of data actually pulled in
                %actualDataDuration(i) = length(dataWin)/srate;

                if toc(dStart) > delayLength
                    break
                end
            catch
                disp('Caught potential failure')
                clearStream(LFP1name,LFP2name);
                pause(windowDuration)
                [succeeded, dataArray, timeStampArray, ~, ~, ...
                numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

                % 2) store the data
                % now add and remove data to move the window
                dataWin    = dataArray;            
            end
        end    
    else
        pause(delayLength)
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
prompt = 'Did the EIB come off at any OTHER point during the session? ';
eibOFF_session = input(prompt,'s');

if contains(eibOFF,[{'y'} {'Y'}])
    eibSave = 'EIBoffDelay_delaysRemoved';
elseif contains(eibOFF_session,[{'y'} {'Y'}])
    eibSave = 'EIBoffOnMaze_noDelaysRemoved';
else
    eibSave ='';
end

if percentAccurate > 70
    accPrompt = 'Above70Percent';
else
    accPrompt = 'Below70Percent';
end

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
    dataZStored(logical(remTrial))=[];
    dataStored(logical(remTrial))=[];
    coh(logical(remTrial))=[];

end

save_var = strcat(rat_name,'_',task_name,'_',accPrompt,'_',eibSave,'_',c_save);

place2store = ['X:\01.Experiments\R21\',targetRat];
cd(place2store);
save(save_var);

% what trials to exclude
clear prompt
prompt   = 'Enter trajectories to exclude ';
remTraj  = str2num(input(prompt,'s'));

disp('Saving excluded trajectories')
save('removeTrajectories','remTraj');

disp('Remember! There are N trajectories, but N-1 delays. Therefore, remove trial #1 when lining up BMI data');
