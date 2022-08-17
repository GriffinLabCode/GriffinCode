
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

prompt   = ['Define HPC LFP name'];
LFP1name = input(prompt,'s');
prompt   = ['Define PFC LFP name'];
LFP2name = input(prompt,'s');

disp(['Getting baseline data for ' targetRat])
%cd(['C:\Users\jstout\Desktop\Data 2 Move\',targetRat,'\step1-definingBaseline']);
%load('step1_baselineData','LFP1name','LFP2name')
%LFP1name = 'HPC_green';
%%
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
fpass = [1:20];

actualDataDuration = [];
time2cohAndSend = [];

%% first, run a 5min session where the rats sitting in the bowl
data_det = [];

% define amount of time to do bowl stuff
totalDuration = 60*10; %5 min = 300 sec

next = 0;
while next == 0

    % Need to approximate idealized window lengths and true window lengths
    % clear stream  
    tStart = tic;
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
        %data_det=[];
        data_det{i}(1,:) = detrend(dataWin(1,:),3);
        data_det{i}(2,:) = detrend(dataWin(2,:),3);        

        timing = toc(tStart);
        if timing/60 > 10
            next = 1;
            disp('Finished with bowl stuff')
            break
        end
        
        disp([num2str(10-toc(tStart)/60) ' minutes remaining'])
    end 
end

dataALL = horzcat(data_det{:});

% arrive at baselines for both signals
baselineMean = []; baselineSTD = [];
baselineMean(:,1) = mean(dataALL(1,:));
baselineSTD(:,1)  = std(dataALL(1,:));
baselineMean(:,2) = mean(dataALL(2,:));
baselineSTD(:,2)  = std(dataALL(2,:));

%% save outputs
% store data
cd(['X:\01.Experiments\R21\Learning To Use Coherence Experiment\'])
mkdir(['X:\01.Experiments\R21\' targetRat,'\baseline'])
cd(['X:\01.Experiments\R21\' targetRat,'\baseline'])

prompt = 'Are you ready to save? (y/n) - DO NOT SAVE OVER OLD DATA!';
answer = input(prompt,'s');
if contains(answer,[{'y'} {'Y'}])
    save('baselineData.mat','baselineMean','baselineSTD','LFP1name','LFP2name')
else
end