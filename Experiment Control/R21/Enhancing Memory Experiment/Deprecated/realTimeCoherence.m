

function [coh,trueDelayLength,dataStored,dataZStored] = realTimeCoherence(LFP1name,LFP2name,delayLength)

% initialize some variables
dataWin      = [];
cohAvg_data  = [];
coh          = [];

% prep for coherence
window = []; noverlap = []; 
fpass = [1:20];

% define a noise threshold in standard deviations
noiseThreshold = 4;

% define how much noise you're willing to accept
noisePercent = 1; % 5 percent

% define pauseTime as 250ms and windowDuration as 1.25 seconds
pauseTime      = 0.25;
windowDuration = 1.25;

dStart = [];
dStart = tic;
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

    % determine if data is noisy
    zArtifact = [];
    zArtifact(1,:) = ((data_det(1,:)-baselineMean(1))./baselineSTD(1));
    zArtifact(2,:) = ((data_det(2,:)-baselineMean(2))./baselineSTD(2));

    idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
    percSat = (length(idxNoise)/length(zArtifact))*100;
    if percSat > noisePercent
        detected{triali}(i)=1;
        %disp('Artifact Detected - coherence not calculated')     
    else
        detected{triali}(i)=0;
    end

    % calculate coherence
    [coh{triali}{i},f] = mscohere(data_det(1,:),data_det(2,:),window,noverlap,fpass,srate);
   % cohAvg = nanmean(coh);

    % store data
    dataZStored{triali}{i} = zArtifact;
    dataStored{triali}{i}  = dataWin;

    % store coherence data
    %cohAvg_data = [cohAvg_data cohAvg];

    % calculate the amount of data actually pulled in
    %actualDataDuration(i) = length(dataWin)/srate;

    if toc(dStart) > delayLength
        trueDelayLength = toc(dStart);
        break
    end
end  