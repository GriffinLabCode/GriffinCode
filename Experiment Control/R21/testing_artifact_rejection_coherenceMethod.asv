
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

disp(['Getting baseline data for ' targetRat])
cd(['X:\01.Experiments\R21\',targetRat,'\baseline alternative']);
load('baselineData')

disp(['Getting baseline data for ' targetRat])
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
success_lfp1 = []; success_lfp2 = []; time2extract = [];
time2extract = [];
data2use     = [];
coh          = [];
dataWin      = [];
cohAvg_data  = [];
coh          = [];

% prep for coherence
window = []; noverlap = []; 
fpass = [1:.5:20];

actualDataDuration = [];
time2cohAndSend = [];

% theta
thetaRange = [6 11];
deltaRange = [1 4];

%% test artifact rejection
dataStored = [];
dataClean = [];
dataDirty = [];

% define amount of time to do bowl stuff
totalDuration = 60*5; %5 min = 300 sec

% define for loop maximum
%totalLoop = (totalDuration/pauseTime);

% define a noise threshold in standard deviations
noiseThreshold = 4;

% define how much noise you're willing to accept
noisePercent = 1; % 5 percent

dataWin = []; window = []; noverlap = [];
for i = 1:1000000000 % nearly infinite loop. This is needed for the first loop

    clearStream(LFP1name,LFP2name);
    pause(windowDuration)
    [succeeded, dataArray, timeStampArray, ~, ~, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

    % detrend by removing third degree polynomial
    data_det=[];
    data_det(1,:) = detrend(dataArray(1,:),3);
    data_det(2,:) = detrend(dataArray(2,:),3);

    % calculate coherence
    coh = [];
    [coh,f] = mscohere(data_det(1,:),data_det(2,:),window,noverlap,fpass,srate);

    % perform logical indexing of theta and delta ranges to improve
    % performance speed
    cohAvg   = nanmean(coh(f > thetaRange(1) & f < thetaRange(2)));
    cohDelta = nanmean(coh(f > deltaRange(1) & f < deltaRange(2)));
    cohTheta = nanmean(coh(f > thetaRange(1) & f < thetaRange(2)));

    % determine if data is noisy
    zArtifact = [];
    zArtifact(1,:) = ((data_det(1,:)-baselineMean(1))./baselineSTD(1));
    zArtifact(2,:) = ((data_det(2,:)-baselineMean(2))./baselineSTD(2));

    idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
    percSat = (length(idxNoise)/length(zArtifact))*100;    
    
    % only include if theta coherence is higher than delta
    % if delta is higher than theta or if the percent saturation is greater
    % than what is required, reject
    % excluding high delta coherence states and noisy events
        if cohDelta > cohTheta
            output = 'delta > theta';
        else
            output = 'theta > delta';
        end
    if cohDelta > cohTheta || percSat > noisePercent
        detected(i)=1;
        rejected = 1;
        %disp('Rejected')  
    % if theta > delta, and the percent saturation is less than noise
    % threshold
    % only include theta coherence states and non-noisy events
    elseif cohTheta > cohDelta && percSat < noisePercent
        rejected = 0;
        detected(i)=0;
    end

    % store data
    dataStored{i}  = dataArray;
    cohOUT{i}      = coh;
            
    % if rejected, plot
    if rejected == 1
        figure('color','w')
        subplot 311;
            plot(data_det(1,:),'b')
            ylabel('HPC mV')
            title(['Rejected:', ' % sat. = ',num2str(percSat),', ',output])
        subplot 312;
            plot(data_det(2,:),'r')
            ylabel('PFC mV')
            xlabel('Samples')
            %close;
        subplot 313;
             plot(f,coh,'k','LineWidth',2)
             ylabel('Coherence')
             xlabel('Frequency')
             pause
             close;
    end
end



%% first, run a 5min session where the rats sitting in the bowl
dataStored = [];
dataClean = [];
dataDirty = [];

% define amount of time to do bowl stuff
totalDuration = 60*5; %5 min = 300 sec

% define for loop maximum
%totalLoop = (totalDuration/pauseTime);

% define a noise threshold in standard deviations
noiseThreshold = 4;

% define how much noise you're willing to accept
noisePercent = 5; % 5 percent

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
            dataStored = [dataStored dataWin]; % store this for trouble shooting
        end

        % 3) pull in 0.25 seconds of data
        % pull in data at shorter resolution   
        pause(pauseTime)
        [succeeded, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

        % 4) apply it to the initial array, remove what was there
        dataWin(:,1:length(dataArray))=[]; % remove 560 samples
        dataWin = [dataWin dataArray]; % add data

        % determine if data is noisy
        zArtifact = [];
        zArtifact(1,:) = ((dataArray(1,:)-baselineMean(1))./baselineSTD(1));
        zArtifact(2,:) = ((dataArray(2,:)-baselineMean(2))./baselineSTD(2));

        idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
        percSat = (length(idxNoise)/length(zArtifact))*100;
        if percSat > noisePercent
            cohAvg = NaN;
            dataDirty = [dataDirty;dataArray];
            disp('Artifact Detected - coherence not calculated')     
        else
            % calculate coherence
            [coh,f] = mscohere(dataWin(1,:),dataWin(2,:),window,noverlap,fpass,srate);
            cohAvg = nanmean(coh);
            
            % store data
            dataClean = [dataClean;dataArray];
        end
        
        % store coherence data
        cohAvg_data = [cohAvg_data cohAvg];

        % calculate the amount of data actually pulled in
        actualDataDuration(i) = length(dataWin)/srate;

        timing = toc(tStart);
        if timing/60 > 5
            next = 1;
            disp('Finished with bowl stuff')
            break
        end
        
        disp([num2str(5-toc(tStart)/60) ' minutes remaining'])
    end 
end
cohBowl = coh; detectedBowl = []; dataCleanBowl = []; dataDirtyBowl = [];
clear coh detected dataClean dataDirty

%% pull in example data
cd('X:\01.Experiments\R21\21-12');
load('21-12_DA1_11_11_2021_EndTime1235')

noiseEvents = find(detected{1}==1);

noisyData = dataZStored{1}(noiseEvents);
noisyData2 = dataStored{1}(noiseEvents);
noisyCoh  = coh{1}(noiseEvents);

for i = 1:length(noisyData)
    figure('color','w');
    subplot 311;
        plot(noisyData{i}(1,:));
    subplot 312;
        plot(noisyData{i}(2,:));
    subplot 313;
        plot(f,noisyCoh{i},'LineWidth',2)
        ylim([0 1])
    pause;
    close;
end

figure('color','w');
subplot 311;
    plot(noisyData{i}(1,1:2000));
subplot 312;
    plot(noisyData{i}(2,1:2000));
subplot 313;
    [coh2,f2] = mscohere(noisyData{i}(1,1:2000),noisyData{i}(2,1:2000),window,noverlap,fpass,srate);
    plot(f2,coh2,'LineWidth',2)
    ylim([0 1])
    

for i = 1:length(coh)
    idxGood    = find(detected{i}==0);
    idxPoor    = find(detected{i}==1);
    badCoh{i}  = vertcat(coh{i}{idxPoor});
    goodCoh{i} = vertcat(coh{i}{idxGood});
end
            
badCoh_all  = vertcat(badCoh{:});
goodCoh_all = vertcat(goodCoh{:});

badAvg   = nanmean(badCoh_all,1);
goodAvg  = nanmean(goodCoh_all,1);
badSerr  = stderr(badCoh_all,1);
goodSerr = stderr(goodCoh_all,1);

figure('color','w'); hold on;
s1 = shadedErrorBar(f,goodAvg,goodSerr,'b',1);
s2 = shadedErrorBar(f,badAvg,badSerr,'r',1);
ylabel('Coherence')
xlabel('Frequency (Hz)')
legend([s1.mainLine, s2.mainLine], 'Accepted LFP', 'Rejected LFP')
title('Importance of low-artifact LFP')







