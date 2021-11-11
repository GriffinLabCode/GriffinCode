%% STEP 2)

%%
clear;

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
cd(['C:\Users\jstout\Desktop\Data 2 Move\',targetRat,'\step1-definingBaseline']);
load('step1_baselineData')

% interface with cheetah setup
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);    

if srate > 2035 || srate < 2000
    error('Sampling rate is not correct')
end

% location of data
dataStored = ['C:\Users\jstout\Desktop\Data 2 Move\',targetRat,'\step2-definingCoherence'];
mkdir(dataStored) % make folder
cd(dataStored)

%% run code
% initialize
coh      = [];
detected = [];
xVar     = [];

% use tic toc to store timing for yoked control
tStart = [];
tStart = tic;
dataClean = []; dataDirty = [];

next = 0;
while next == 0
attempt = 0;
while attempt == 0
    try

        % clear stream   
        clearStream(LFP1name,LFP2name);

        % pause 0.5 sec
        pause(0.5);

        % pull data
        [~, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

        if length(dataArray) ~= 1024
            attempt = 0;
        else 
            attempt = 1;
        end
    catch
        %coh = [coh NaN];
    end
end

%{
% filtering and detrending takes too long. 
coherence isn't below .
% notch filter
filtLFP = [];
filtLFP(1,:) = notchfilt(dataArray(1,:),srate);
filtLFP(2,:) = notchfilt(dataArray(2,:),srate);
%}

% detrend
data_det = [];
data_det(1,:) = detrend(dataArray(1,:)); 
data_det(2,:) = detrend(dataArray(2,:)); 
%disp('Real-time data detrended...')

% test for artifact
zArtifact = [];
zArtifact(1,:) = ((data_det(1,:)-baselineMean(1))./baselineSTD(1));
zArtifact(2,:) = ((data_det(2,:)-baselineMean(2))./baselineSTD(2));

noiseThreshold = 4;
idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
percSat = (length(idxNoise)/length(zArtifact))*100;
if percSat > 1
    detect_temp = [];
    detect_temp = 1;
    detected = [detected detect_temp]; % add nan to know this was ignored
    dataDirty = [dataDirty;data_det];
    disp('Artifact Detected - coherence not calculated')
    %{
    figure(2); 
    subplot 211;
    plot(zArtifact(1,:));
    subplot 212;
    plot(zArtifact(2,:));
    pause;
    close;
    %}
else   
    % frequencies
    fpass = [1:20];
    window = []; noverlap = [];
    % initialize
    coh_temp = [];
    % coherence
    [coh_temp,fcoh] = mscohere(data_det(1,:),data_det(2,:),window,noverlap,fpass,srate);
    % store
    coh  = [coh;coh_temp]; % add nan to know this was ignored 
    dataClean = [dataClean;data_det];
    %xVar = [xVar i];
    disp('Artifact not detected - coherence calculated')
    detect_temp = [];
    detect_temp = 0;
    detected    = [detected detect_temp]; % add nan to know this was ignored
    
%{
    fig = figure(1); hold on; box off
    fig.Color = 'w';
    subplot 311;  plot(dataArray(1,:),'b'); title('HPC')
    subplot 312;  plot(dataArray(2,:),'r'); title('PFC')
    subplot 313;
    stem(coh,'k','LineWidth',2)
    ylim([0 1]);
    %xlim([0 1])
    xlimits = xlim;
    l = line([xlimits(1) xlimits(2)],[.7 .7]);
    l.Color = [0 .5 0];
    l.LineStyle = '--';
    l.LineWidth = 1; 
    l2 = line([xlimits(1) xlimits(2)],[.3 .3]);
    l2.Color = 'r';
    l2.LineStyle = '--';
    l2.LineWidth = 1; 
    ylabel('Coherence')
    xlabel('Interval (0.5 sec)')
    pause();
    disp('Press Any Key To Continue')
    %}
end
    
disp([num2str(5-toc(tStart)/60) ' minutes remaining'])


if toc(tStart)/60 > 5
    next = 1;
    disp('THE END...')
    
end
    
end

dataClean_mean = nanmean(dataClean,1);
dataDirty_mean = nanmean(dataDirty,1);
figure; plot(dataClean_mean,'b'); hold on; plot(dataDirty_mean,'r');
figure; plot(dataDirty(4,:),'r')

% compute coherence averages
avgCoh = nanmean(coh,1);
stdCoh = stderr(coh,1);

figure('color','w')
shadedErrorBar(fcoh,avgCoh,stdCoh,'b',1)
ylabel('Mean Squared Coherence')
xlabel('Frequency')
title([targetRat,' | Step 2'])
box off

dataStored = ['C:\Users\jstout\Desktop\Data 2 Move\',targetRat,'\step2-definingCoherenceFrequency'];
mkdir(dataStored) % make folder
cd(dataStored)

% save everything
save('step2_definingCoherenceFrequencies.mat')