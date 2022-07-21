
clear; clc
rng('shuffle')

% get directory that houses this code
codeDir = getCurrentPath();

% what session is this?
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

% interface with cheetah setup
LFP1name = 'HPC_red';
LFP2name = 'PFC_black'; % IN THIS CASE, BOTH SIGNALS WERE THE SAME
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

% now check for zero lag over 10000 iterations
for i = 1:1000
        try
            % 3) pull in 0.25 seconds of data
            % pull in data at shorter resolution   
            pause(pauseTime)
            [succeeded, dataArray, timeStampArray, ~, ~, ...
            numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

            % 4) apply it to the initial array, remove what was there
            dataWin(:,1:length(dataArray))=[]; % remove 560 samples
            dataWin = [dataWin dataArray]; % add data
            lagSample(i,:) = numel(find(dataWin(1,:)-dataWin(2,:))>0);
            disp('Worked')
        catch
            clearStream(LFP1name,LFP2name);
            pause(windowDuration)
            [succeeded, dataArray, timeStampArray, ~, ~, ...
            numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

            % 2) store the data
            % now add and remove data to move the window
            dataWin    = dataArray;
            lagSample(i,:) = numel(find(dataWin(1,:)-dataWin(2,:))>0);
            disp('Fail')
        end 
        disp(['Iteration ',num2str(i),'/1000'])
end
numLags=numel(find(lagSample >0));
figure('color','w')
pie([numLags 1000])
place2store = getCurrentPath;
cd(place2store)
save('data_extractionLag','lagSample','numLags')


