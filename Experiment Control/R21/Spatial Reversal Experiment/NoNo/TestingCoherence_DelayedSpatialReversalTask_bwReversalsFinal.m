%% prep 1 - clear history, workspace, get working directory
% _____________________________________________________

% --- MAKE SURE YOU RUN STARTUP_EXPERIMENTCONTROL --- %

%______________________________________________________

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

cd(datafolder);
% interface with user
prompt     = ['Is today day 1 of SRT training? [y/n] '];
trainingDay = input(prompt,'s');

if contains(trainingDay,'n')
    prompt     = ['copy/paste the datafolder of the previous days testing session with the MATLAB data saved: '];
    datafolder = input(prompt,'s');
    prompt     = ['copy/paste the title of the previous days MATLAB data saved out: '];
    data2load  = input(prompt,'s'); 
    cd(datafolder);
    prevTrajData = load(data2load,'traj');
    prevTraj = prevTrajData.traj;  

    if contains(prevTraj,'R')
        traj='L';
    elseif contains(prevTraj,'L')
        traj='R';
    end        
else
    rng('shuffle');
    randArm = randsample([1,2],1);
    if randArm == 1
        traj='R';
    elseif randArm == 2
        traj='L';
    end
end

% load in thresholds
disp('Getting rat-specific data')
cd(['X:\01.Experiments\R21\',targetRat,'\thresholds']);
load('thresholds');
cd(['X:\01.Experiments\R21\',targetRat,'\baseline']);
load('baselineData');
cd(['X:\01.Experiments\R21\',targetRat]);
%load('SRT_testingDays')
%testingDay = testingConditions(dayTesting);

% interface with cheetah setup
threshold.coh_duration = 0.5;
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);    

if srate > 2035 || srate < 2000
    error('Sampling rate is not correct')
end

%% prep 2 - define parameters for the session

% how long should the session be?
session_length = 25; % minutes

% define a looping time - this is in minutes
amountOfTime = (70/60); %session_length; % 0.84 is 50/60secs, to account for initial pause of 10sec .25; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

%% experiment design prep.

% define number of trials
numTrials  = 200;

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

%{
for i = 1:10000000
    readDigitalPin(a,irArduino.choicePoint)
end
%}
%writeline(s,doorFuns.tRightClose)

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

%% delay lenghts
numTrials  = 200;

%% clean the stored data just in case IR beams were broken
s.Timeout = 1; % 1 second timeout

% close all maze doors - this gives problems with solenoid box
pause(0.25)
writeline(s,[doorFuns.centralClose doorFuns.sbLeftClose ...
    doorFuns.sbRightClose doorFuns.tLeftClose doorFuns.tRightClose]);

pause(0.25)
writeline(s,[doorFuns.gzLeftClose doorFuns.gzRightClose])

%% interface with cheetah
% downloaded location of github code - automate for github
github_download_directory = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21';
addpath(github_download_directory);

% connect to netcom - automate this for github
pathName   = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21\NetComDevelopmentPackage_v3.1.0\MATLAB_M-files';
serverName = '192.168.3.100';
connect2netcom(pathName,serverName)

% open a stream to interface with Nlx objects - this is required
[succeeded, cheetahObjects, cheetahTypes] = NlxGetDASObjectsAndTypes; % gets cheetah objects and types

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
time2choice = []; numRev = traj; endSess = 0;
for triali = 1:numTrials    
    disp(['Rewarded Trajectory: ',traj])
    trajRewarded{triali} = traj;

    if toc(sStart)/60 > session_length
        break
    end

    % set central door timeout value
    s.Timeout = .05; % 5 minutes before matlab stops looking for an IR break    

    % first trial - set up the maze doors appropriately
    writeline(s,[doorFuns.sbRightOpen doorFuns.sbLeftOpen doorFuns.centralOpen]);
    
    % set irTemp to empty matrix
    irTemp = []; 

    % t-beam
    
    %disp('Tracking choice-time')
    disp('Choice-entry')
    tEntry = [];
    tEntry = tic;
    
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.choicePoint) == 0   % if central beam is broken
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPentry" 202 2');
            next = 1; % break out of the loop
        end
    end    
    
    % check which direction the rat turns at the T-junction
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.rGoalArm)==0
            disp(['Chosen Trajectory: L'])

            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPexit" 202 2');
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Left" 312 2');
            
            % track the trajectory_text
            time2choice(triali) = toc(tEntry); % amount of time it took to make a decision
            trajectory_text{triali} = 'L';
            trajectory(triali)      = 0;            
            
            %pause(1);
            % Reward zone and eating
            % send to netcom 
            if contains(traj,'L')
                writeline(s,rewFuns.right)
            end
            
            pause(5)
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);
            %pause(5)
            %writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);

            % break while loop
            next = 1;

        elseif readDigitalPin(a,irArduino.lGoalArm)==0
             disp(['Chosen Trajectory: R'])

            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPexit" 202 2');
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Right" 322 2');
            
            % track the trajectory_text
            time2choice(triali) = toc(tEntry); % amount of time it took to make a decision
            trajectory_text{triali} = 'R';
            trajectory(triali)      = 1;            
            
            %pause(1);
            % Reward zone and eating
            % send to netcom 
            if contains(traj,'R')
                writeline(s,rewFuns.left)
            end             

            pause(5)
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tRightClose doorFuns.tLeftOpen]);
           % pause(5)
            %writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tRightClose doorFuns.tLeftOpen]);

            % break out of while loop
            next = 1;
        end
    end 
    
    % identify choice accuracy on last 10 trials
    if length(trajectory_text) >= 12
        if contains(traj,'R')
            % temp var
            tempVar = []; propCorrect = [];
            tempVar = trajectory_text(end-11:end);
            % find proportion of correct choices
            propCorrect = nanmean(contains(tempVar,'R'));
        elseif contains(traj,'L')
            % temp var
            tempVar = []; propCorrect = [];
            tempVar = trajectory_text(end-11:end);
            % find proportion of correct choices
            propCorrect = nanmean(contains(tempVar,'L'));
        end
        
        % once choice accuracy is reached per 10 trials, switch rewarded
        % arm - reversalTraj tells the user which trajectory the reversal
        % occured on
        
        % if reversaltraj is trajectory 15, it means that trajectory 15 was
        % the last rewarded trajectory for say, right sequences. And that
        % trajectory 16 will only be rewarded for left turns
        if propCorrect >= 0.8
            endSess = 1;
        else
            %reversalTraj(triali) = 0;
            endSess = 0;
        end
        disp(['Proportion correct: ',num2str(propCorrect)])
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
    writeline(s,doorFuns.centralClose);  
    
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
    
    if endSess == 1
        break
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
for i = 1:length(trajRewarded)
    if trajRewarded{i} == trajectory_text{i}
        accuracy(i) = 0;
    else
        accuracy(i) = 1;
    end
end
movingAcc=[]; time2ChoiceMov=[];
looper = 1:length(trajRewarded);
for i = 1:length(looper)
    try
        movingAcc(i) = 1-nanmean(accuracy(looper(i):looper(i)+9));
        time2ChoiceMov(i) = nanmean(time2choice(looper(i):looper(i)+9));
    catch
    end
end
idxRev=(find(reversalTraj==1));

figure('color','w'); hold on;
xVar = 1:length(movingAcc);
xVar = xVar+9;
plot(xVar,smoothdata(movingAcc,'gauss',5),'b','LineWidth',2)
plot(xVar,movingAcc,'k','LineWidth',1)
ylimits = ylim;
xlimits = xlim;
for i = 1:length(idxRev)
    line([idxRev(i) idxRev(i)],[ylimits(1) ylimits(2)],'Color','r','LineStyle','--')
end
xlabel('Trial')
ylabel('Choice Accuracy')
title('Spatial Reversal Task')
yyaxis right;
plot(xVar,time2ChoiceMov,'Color',[0.9100 0.4100 0.1700],'LineWidth',1)
ylabel('Time 2 choice')

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

if contains(testingDay,[{'E'} {'e'}])
    testingInfo = 'experimental';
else 
    testingInfo = 'control';
end
if contains(testingCond,'BW')
    addOn = 'BW';
elseif contains(testingCond,'MW')
    addOn = 'MW';
elseif contains(testingCond,'NA')
    addOn = 'NA';
end
save_var = strcat(rat_name,'_',task_name,'_',testingInfo,'_',addOn,'_',c_save);

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



