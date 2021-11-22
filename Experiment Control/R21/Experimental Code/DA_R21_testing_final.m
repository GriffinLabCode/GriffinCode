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

prompt = ['What day of DA TESTING is this? '];
DAday  = str2num(input(prompt,'s'));

disp(['Getting baseline data for ' targetRat])
cd(['X:\01.Experiments\R21\',targetRat,'\baseline alternative']);
load('baselineData')

disp(['Getting LFP names for ' targetRat])
cd(['X:\01.Experiments\R21\',targetRat,'\baseline']);
load('baselineData','LFP1name','LFP2name')

% load in thresholds
disp('Getting threshold data')
cd(['X:\01.Experiments\R21\',targetRat,'\thresholds']);
load('thresholdData');

% interface with cheetah setup
threshold.coh_duration = 0.5;
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
maxDelay = 30;
minDelay = 5;
delayDur = minDelay:1:maxDelay; % 5-45 seconds
rng('shuffle')

delayLenTrial = [];
next = 0;
while next == 0

    if numel(delayLenTrial) >= 100
        next = 1;
    else
        shortDuration  = randsample(5:15,5,'true');
        longDuration   = randsample(16:30,5,'true');
        
        % used for troubleshooting ->
        %shortDuration  = randsample(1:5,5,'true');
        %longDuration   = randsample(6:10,5,'true');        

        allDurations   = [shortDuration longDuration];
        interleaved    = allDurations(randperm(length(allDurations)));
        delayLenTrial = [delayLenTrial interleaved];
    end
end

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
    indicator{idx(3)} = 'yokeH';
    indicator{idx(4)} = 'yokeL';
    
    % store indicator variable
    indicatorOUT = [indicatorOUT;indicator];

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

% close all maze doors - this gives problems with solenoid box
pause(0.25)
writeline(s,[doorFuns.centralClose doorFuns.sbLeftClose ...
    doorFuns.sbRightClose doorFuns.tLeftClose doorFuns.tRightClose]);

pause(0.25)
writeline(s,[doorFuns.gzLeftClose doorFuns.gzRightClose])

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
            trajectory_text{triali} = 'R';
            trajectory(triali)      = 0;            
            
            %pause(1);
            % Reward zone and eating
            % send to netcom 
            if triali > 1
                if contains(trajectory_text{triali-1},'L')
                    % only reward on an alternation
                    for rewardi = 1:pellet_count
                        %pause(0.25)
                       % writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightClose doorFuns.centralOpen]);
                        writeline(s,rewFuns.right)
                        %writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightClose doorFuns.centralOpen]);
                        %pause(0.25)
                    end    
                    
                end
            elseif triali == 1
                
                    for rewardi = 1:pellet_count
                        %pause(0.25)
                       % writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightClose doorFuns.centralOpen]);
                        writeline(s,rewFuns.right)
                        %writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightClose doorFuns.centralOpen]);
                        %pause(0.25)
                    end 
                    
            end
            pause(5)
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen doorFuns.centralClose]);
            %pause(5)
            %writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);

            % break while loop
            next = 1;

        elseif readDigitalPin(a,irArduino.lGoalArm)==0
            
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPexit" 202 2');
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Right" 322 2');
            
            % track the trajectory_text
            time2choice(triali) = toc(tEntry); % amount of time it took to make a decision
            trajectory_text{triali} = 'L';
            trajectory(triali)      = 1;            
            
            %pause(1);
            % Reward zone and eating
            % send to netcom 
            if triali > 1
                % only reward on an alternation
                if contains(trajectory_text{triali-1},'R')
                    
                    for rewardi = 1:pellet_count
                        %pause(0.25)
                       % writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightClose doorFuns.centralOpen]);
                        writeline(s,rewFuns.left)
                        %writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightClose doorFuns.centralOpen]);
                        %pause(0.25)
                    end    
                    
                end
            elseif triali == 1
                
                    for rewardi = 1:pellet_count
                        %pause(0.25)
                       % writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightClose doorFuns.centralOpen]);
                        writeline(s,rewFuns.left)
                        %writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightClose doorFuns.centralOpen]);
                        %pause(0.25)
                    end 
                    
            end                      

            pause(5)
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tRightClose doorFuns.tLeftOpen doorFuns.centralClose]);
           % pause(5)
            %writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tRightClose doorFuns.tLeftOpen]);

            % break out of while loop
            next = 1;
        end
    end    

    % return arm
    next = 0;
    while next == 0
        %irTemp = read(s,4,"uint8");  
        %l = readDigitalPin(a,irArduino.lGoalZone);
        %d = readDigitalPin(a,irArduino.Delay);
       % r = readDigitalPin(a,irArduino.rGoalZone);
        
        % track choice entry
        %{
        if d == 0 
            disp('Choice-entry')
            tEntry = [];
            tEntry = tic;
        end
        %}
        
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
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]); 
            
            next = 1;
            
        elseif readDigitalPin(a,irArduino.rGoalZone) == 0

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

    if toc(sStart)/60 > session_length
        break % break out of for loop
    end         
    
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
        end
        
        %yokH_store = yokH;
        %writeline(s,[doorFuns.sbRightOpen doorFuns.sbLeftOpen doorFuns.centralOpen]);                
        
        % IMPORTANT: Storing this for later
        cohEnd = toc(dStart);
        disp(['Coh detect high end at ', num2str(cohEnd)])

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
            idxRem = find(contains(indicatorOUT,'yokeH')==1);
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
                
        end
        
        % IMPORTANT: Storing this for later
        cohEnd = toc(dStart);
        disp(['Coh detect low end at ', num2str(cohEnd)])

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
            idxRem = find(contains(indicatorOUT,'yokeL')==1);
            indicatorOUT{idxRem(1)}='NormHighFail';
        end
        
    % only yoke up if you have options to pull from, if not then it'll
    % become a 'norm' trial
    elseif contains(indicatorOUT{triali},'yokeL')  
        
        if isempty(yokL)==0
            % pause for yoked control
            disp(['Pausing for low yoked control of ',num2str(yokL(1))])
            pause(yokL(1));
            indicatorOUT{triali} = 'yokL_MET';
            delayLenTrial(triali) = yokL(1);            
            % delete so that next time, 1 is the updated delay
            yokL(1)=[];
        elseif isempty(yokL)==1
            disp(['Normal delay of ',num2str(delayLenTrial(triali))])
            pause(delayLenTrial(triali));
            indicatorOUT{triali} = 'yokL_FAIL';
        end
        
    elseif contains(indicatorOUT{triali},'yokeH') && isempty(yokH)==0
        % if you have a yoke to pull from
        if isempty(yokH)==0
            disp(['Pausing for high yoked control of ',num2str(yokH(1))])
            pause(yokH(1));
            indicatorOUT{triali} = 'yokH_MET';  
            delayLenTrial(triali) = yokH(1);
            yokH(1)=[];
        % if you don't have a yoke to pull from
        elseif isempty(yokH)==1
            disp(['Normal delay of ',num2str(delayLenTrial(triali))])
            pause(delayLenTrial(triali));
            indicatorOUT{triali} = 'yokH_FAIL';          
        end        
    end    
       
end 
[succeeded, reply] = NlxSendCommand('-StopRecording');

% get amount of time past since session start
c = clock;
session_time_update = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time = session_time_update-session_start;

% END TIME
endTime = toc(sStart)/60;

%% compute accuracy array and create some figures
accuracy = [];
accuracy_text = cell(1, length(trajectory_text)-1);
for triali = 1:length(trajectory_text)-1
    if trajectory_text{triali} ~= trajectory_text{triali+1}
        accuracy(triali) = 0; % correct trial
        accuracy_text{triali} = 'correct';
    elseif trajectory_text{triali} == trajectory_text{triali+1}
        accuracy(triali) = 1; % incorrect trial
        accuracy_text{triali} = 'incorrect';
    end
end
percentAccurate = ((numel(find(accuracy==0)))/(numel(accuracy)))*100;

% perseveration index
for i = 2:length(trajectory_text)-1
    % if the previous trajectory equals the future trajectory and the
    % previous trajectory is the current trajectory and the current trajectory is the future trajectory
    if (trajectory(i-1) == trajectory(i+1))  && (trajectory(i-1) == trajectory(i)) && (trajectory(i) == trajectory(i+1))
        persev(i-1) = 1;
    else
        persev(i-1) = 0;
    end
end

% perseveration index - because of indexing (consideration of 3 consecutive
% turns = perseveration), we have to do numTrials-2
percentPerseveration = (sum(persev)/(numTrials-2))*100;

% turn bias
rTurn = numel(find(contains(trajectory_text,'R')==1));
lTurn = numel(find(contains(trajectory_text,'L')==1));
percentBias = ((abs(rTurn-lTurn))/(rTurn+lTurn))*100;
disp(['Rat performed at ', num2str(percentAccurate), '%', ' perseverated ', num2str(percentPerseveration), '%', ' with a turn bias of ',num2str(percentBias),'%'])

% moving window method for time2choice
winLength = 8; % trials
winStep   = 1;
avg_t = []; sem_t = [];
for i = 1:winStep:length(time2choice)
    if i == 1      
        % define a starter variable that will be saved for each loop and
        % modified each time
        starter(i) = 1;
        ender(i)   = winLength;

        % get data        
        avg_t = [avg_t nanmean(time2choice(starter(i):ender(i)))];
        sem_t = [sem_t stderr(time2choice(starter(i):ender(i)),1)];
        
		% -- enter your code here and save per each loop -- %
        
    else
        starter(i) = starter(i-1)+(winStep);
        ender(i)   = starter(i-1)+(winLength);

        % in the case where you've run out of data, break out of the loop
        if ender(i) > length(time2choice)
            starter(i) = [];
            ender(i)   = [];
            break
        end
        
        % get data        
        avg_t = [avg_t nanmean(time2choice(starter(i):ender(i)))];
        sem_t = [sem_t stderr(time2choice(starter(i):ender(i)),1)];        
           
		% -- enter your code here and save per each loop -- %
        
    end

end

% moving window method for choice accuracy
avg_c = []; sem_c = [];
for i = 1:winStep:length(accuracy)
    try
        if i == 1      
            % define a starter variable that will be saved for each loop and
            % modified each time
            starter(i) = 1;
            ender(i)   = winLength;

            % get data        
            choiceAcc_temp = ((numel(find(accuracy(starter(i):ender(i))==0)))/winLength)*100;
            avg_c = [avg_c choiceAcc_temp];

            % -- enter your code here and save per each loop -- %

        else
            starter(i) = starter(i-1)+(winStep);
            ender(i)   = starter(i-1)+(winLength);

            % in the case where you've run out of data, break out of the loop
            if ender(i) > length(time2choice)
                starter(i) = [];
                ender(i)   = [];
                break
            end

            % get data        
            choiceAcc_temp = ((numel(find(accuracy(starter(i):ender(i))==0)))/winLength)*100;
            avg_c = [avg_c choiceAcc_temp];

            % -- enter your code here and save per each loop -- %

        end
    end
end

figure('color','w')
subplot(3,3,1)
    bar(percentAccurate,'FaceColor',[.6 0 1])
    box off;
    ylim([0 100]); ylabel('Choice Accuracy')
subplot(3,3,2)
    bar(percentPerseveration,'FaceColor','r')
    box off;
    ylabel('% Perseveration')
subplot(3,3,3)
    bar(percentBias,'FaceColor',[1 0 .5])
    box off;
    ylabel('% Turn Bias')
subplot(3,1,2)
    plot(1:length(avg_c),avg_c,'Color',[.6 0 1],'LineWidth',2)
    ylabel('Choice Accuracy')
    xlabel(['Trial Moving Window (' num2str(winLength) ' trials in increments of ' num2str(winStep) ' trial'])
    box off;       
subplot(3,1,3)
    shadedErrorBar(1:length(avg_t),avg_t,sem_t,'k',1)
    ylabel('Time Spent at CP (sec)')
    xlabel(['Trial Moving Window (' num2str(winLength) ' trials in increments of ' num2str(winStep) ' trial'])
    box off;

figure('Color','w');
scatter(1:length(time2choice),time2choice)
lsline
[r,p] = corrcoef(1:length(time2choice),time2choice);

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
    for i = 1:length(dataStored)
        disp('If there are any flat lined data, the EIB came off')
        dataPlot = horzcat(dataStored{i}{:});
        figure('color','w');
        subplot 211;
        plot(dataPlot(1,:));
        subplot 212;
        plot(dataPlot(2,:));
        prompt   = 'Keep? ';
        keepTrial = input(prompt,'s'); 
        if contains(keepTrial,[{'n'} {'N'}])
            trial2rem(i)=1;
        else
            trial2rem(i)=0;
        end
        
        close;
    end

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







