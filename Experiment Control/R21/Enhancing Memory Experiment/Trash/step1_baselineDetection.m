%% baseline detection
% this code is designed for a baseline recording, where the data will be
% applied to coherence_detection to identify outlier signals. We will only
% allow coherence to be triggered if the signal in the 0.5 second window is
% within 1 standard deviation range

clear; clc;

prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
confirm  = input(prompt,'s');

if ~contains(confirm,[{'y'} {'Y'}])
    error('This code does not match the target rat')
end

%% load rat specific data
threshold.coh_duration = 0.5;

disp(['Getting baseline data for ' targetRat])

% interface with user
prompt   = 'Enter LFP1 name (HPC) ';
LFP1name = input(prompt,'s');
prompt   = 'Enter LFP2 name (PFC) ';
LFP2name = input(prompt,'s'); 

% interface with cheetah setup
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);    

if srate > 2035 || srate < 2000
    error('Sampling rate is not correct')
end

% location of data
dataStored = ['C:\Users\jstout\Desktop\Data 2 Move\',targetRat,'\step1-definingBaseline'];
mkdir(dataStored) % make folder
cd(dataStored)

%% do stuff
% clear stream   
clearStream(LFP1name,LFP2name);

% after 10 minutes, pull data
numMin = 10;
for i = 1:numMin
    if i == 1
        disp('Beginning pause')
    end
    pauseTime = 1*60;
    pause(pauseTime)
    disp([num2str([numMin-i]), ' minutes remaining'])
end

% pull data
attempt = 0;
while attempt == 0
    try

        % clear stream   
        %clearStream(LFP1name,LFP2name);

        % pause 0.5 sec
        pause(0.5);

        % pull data
        [~, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

        attempt = 1;
    catch
    end
end

% detrend
data_det = [];
data_det(1,:) = detrend(dataArray(1,:),3); 
data_det(2,:) = detrend(dataArray(2,:)); 

% arrive at baselines for both signals
baselineMean = []; baselineSTD = [];
baselineMean(:,1) = mean(data_det(1,:));
baselineSTD(:,1)  = std(data_det(1,:));
baselineMean(:,2) = mean(data_det(2,:));
baselineSTD(:,2)  = std(data_det(2,:));

%% save outputs
cd(dataStored)
save('step1_baselineData.mat','baselineMean','baselineSTD','LFP1name','LFP2name','srate','targetRat','dataArray')
