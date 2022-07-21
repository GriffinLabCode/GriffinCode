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

%% pulsing at theta
prompt = ['What frequency of light pulsing? (eg 8Hz for theta) '];
thetaPulse = str2num(input(prompt,'s'));
% 1sec/thetaPulse
thetaPulseTime=1/thetaPulse;

%% prep real time code
% load in thresholds
disp('Getting threshold data')
cd(['X:\01.Experiments\R21\Learning To Use Coherence Experiment\',targetRat,'\thresholds']);
load('thresholds');

% load in baselines
disp(['Getting baseline data for ' targetRat])
disp(['Getting LFP names for ' targetRat])
cd(['X:\01.Experiments\R21\Learning To Use Coherence Experiment\',targetRat,'\baseline']);
load('baselineData')

% interface with cheetah setup
threshold.coh_duration = 0.5;
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);    

if srate > 2035 || srate < 2000
    error('Sampling rate is not correct')
end

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

%% coherence arena
% whenever a light is triggered, a reward will be delivered. But there will
% not be overlap in reward deliveries (e.g. rats will only trigger the next
% trial by receiving the reward). An IR beam will need to be split in order
% to acheive this, with a TTL being sent to cheetah

% enough time for me to leave the room
disp('Exit room now')
pause(20);

[succeeded, reply] = NlxSendCommand('-StartRecording');
load gong.mat;
sound(y);
disp('Session starting')
sStart = tic; % start session timer

% turn off
writeDigitalPin(a,arduinoLED,0);

% while timer is less than the session duration, the task will continue
cohPlotMid = [];
cohPlotHigh = [];
cohPlotLow = [];
dataMetHigh = [];
dataMetMid = [];
dataMetLow = [];
starterVar = [];

next = 0;
while next == 0

    % if this variable is empty, it means that this is the first loop, so
    % therefore skip to the initial extraction
    if isempty(starterVar)==0
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
            disp('getting coherence')
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

            % if less than threshold
            if cohTheta > cohDelta && percSat < noisePercent && cohTheta < cohLowThreshold
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "ThetaPulseAtLowCoh" 102 2'); 
                % pulse at theta (8Hz)
                % pulse for 5seconds
               
                pStart = tic;
                while toc(pStart)<=1
                    writeDigitalPin(a,arduinoLED,0);
                    pause(thetaPulseTime/3) % titrated and video taped for 8flickers/sec
                    %pause(0.025);
                    writeDigitalPin(a,arduinoLED,1);
                    %pause(thetaPulseTime)
                end
                writeDigitalPin(a,arduinoLED,0); 
               
                
                % deliver reward
                %writeline(s,rewFuns.right) 
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Reward" 102 2'); 

                % save
                cohSaveLow    = horzcat(cohSave,cohMet);   % this will be used to test if coh mets increase with experience
                cohPlotLow    = vertcat(cohPlotMet,coh);       % this will be used for frequency x coherence plots
                dataMetLow    = vertcat(dataMet,data_det); % this will be used for follow up analyses;
            elseif cohTheta > cohDelta && percSat < noisePercent && cohTheta > cohHighThreshold
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "ThetaPulseAtHighCoh" 102 2'); 
                % pulse at theta (8Hz)
                % pulse for 5seconds
                %{
                pStart = tic;
                while toc(pStart)<=1
                    writeDigitalPin(a,arduinoLED,0);
                    pause(thetaPulseTime/3) % titrated and video taped for 8flickers/sec
                    %pause(0.025);
                    writeDigitalPin(a,arduinoLED,1);
                    %pause(thetaPulseTime)
                end
                writeDigitalPin(a,arduinoLED,0); 
                %}
                
                % deliver reward
                %writeline(s,rewFuns.right) 
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Reward" 102 2'); 

                % save
                %cohSaveHigh    = horzcat(cohSave,cohMet);   % this will be used to test if coh mets increase with experience
                cohPlotHigh    = vertcat(cohPlotMet,coh);       % this will be used for frequency x coherence plots
                dataMetHigh    = vertcat(dataMet,data_det); % this will be used for follow up analyses;
            elseif cohTheta > cohDelta && percSat < noisePercent && cohTheta < cohHighThreshold && cohTheta > cohLowThreshold
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "ThetaPulseAtMidCoh" 102 2'); 
                % pulse at theta (8Hz)
                % pulse for 5seconds
                pStart = tic;
                while toc(pStart)<=1
                    writeDigitalPin(a,arduinoLED,0);
                    pause(thetaPulseTime/3) % titrated and video taped for 8flickers/sec
                    %pause(0.025);
                    writeDigitalPin(a,arduinoLED,1);
                    %pause(thetaPulseTime)
                end
                writeDigitalPin(a,arduinoLED,0); 
                
                % deliver reward
                %writeline(s,rewFuns.right) 
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Reward" 102 2'); 

                % save
                %cohSaveMid    = horzcat(cohSave,cohMet);   % this will be used to test if coh mets increase with experience
                cohPlotMid    = vertcat(cohPlotMet,coh);       % this will be used for frequency x coherence plots
                dataMetMid    = vertcat(dataMet,data_det); % this will be used for follow up analyses;
                
            else
                % save coherence var
                %cohSaveNo  = horzcat(cohSave,cohMet);
                cohPlotNo  = vertcat(cohPlotNotMet,coh); 
                dataNotMet = vertcat(dataNotMet,data_det);
            end
        catch
            clearStream(LFP1name,LFP2name);
            pause(windowDuration)
            [succeeded, dataArray, timeStampArray, ~, ~, ...
            numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

            % 2) store the data
            % now add and remove data to move the window
            dataWin    = dataArray;
            
            % do this to move on
            %starterVar = 1;
        end
    else
        clearStream(LFP1name,LFP2name);
        pause(windowDuration)
        [succeeded, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

        % 2) store the data
        % now add and remove data to move the window
        dataWin    = dataArray;
        
        % do this to move on
        starterVar = 1;
                    
    end
    if size(cohPlotMid,1) > 50 && size(cohPlotHigh,1) > 50 && size(cohPlotLow,1) > 50
        next = 1;
    end
    numMid = size(cohPlotMid,1); numHigh = size(cohPlotHigh,1); numLow = size(cohPlotLow,1);
    %disp(['Time left = ' num2str(sessionDur-(toc(sStart)/60)),' minutes'])    
end
    
% save data
writeDigitalPin(a,arduinoLED,0);
[succeeded, reply] = NlxSendCommand('-StopRecording');
load handel.mat;
sound(y, 2*Fs);
cd('X:\01.Experiments\R21\Learning To Use Coherence Experiment\Coherence Arena')
c = clock;
c_save = strcat(num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(1)),'_','EndTime',num2str(c(4)),num2str(c(5)));
save(['data_',targetRat,'_',c_save])