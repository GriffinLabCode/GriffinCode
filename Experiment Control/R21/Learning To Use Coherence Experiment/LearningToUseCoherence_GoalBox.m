%% This code was generated to test whether rats can "learn" to use coherence to control the maze

% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

disp('This needs to be tested with 21-34. You will likely run into an error occassionally, so build that into the code')

disp('IR beam MUST BE PLUGGED INTO CHEETAH!!!! ' )

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
irArduino.reward   = 'D7';
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

%% session
session_length = 20; % minutes
rewardLag      = [];
sStart         = tic;
while toc(sStart)/60 < session_length
    for i = 1:1000000000000000000000000000000000 % nearly infinite loop. This is needed for the first loop

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
        cohDelta = nanmean(coh(f > deltaRange(1) & f < deltaRange(2)));
        cohTheta = nanmean(coh(f > thetaRange(1) & f < thetaRange(2)));

        % determine if data is noisy
        zArtifact      = [];
        zArtifact(1,:) = ((data_det(1,:)-baselineMean(1))./baselineSTD(1));
        zArtifact(2,:) = ((data_det(2,:)-baselineMean(2))./baselineSTD(2));
        idxNoise       = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
        percSat        = (length(idxNoise)/length(zArtifact))*100;                

        % only include if theta coherence is higher than delta. Reject
        % if delta is greater than theta or if saturation exceeds
        % threshold
        if cohTheta > cohDelta && percSat < noisePercent && cohTheta > cohHighThreshold
            
            % present treat
            writeline(s,rewFuns.right) 
            
            % send to neuralynx
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Reward" 202 2');
            
            % this lag tells you how long (from the start of the session) a
            % reward was delivered. To determine inter-reward intervals, we
            % can offline perform a derivative between lags
            rewardLag = [rewardLag toc(sStart)];
            
            % I don't need what is below for this experiment
            %dataStored{i}  = dataWin;
            %cohOUT{i}      = coh; 
            %next = 1;
            %disp('Coherence Met')
            break
        end

    end
end

% get amount of time past since session start
c = clock;
session_time_update = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time = session_time_update-session_start;

% END TIME
endTime = toc(sStart)/60;
[succeeded, reply] = NlxSendCommand('-StopRecording');

%% ending noise - a fitting song to end the session
load handel.mat;
sound(y, 2*Fs);

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



