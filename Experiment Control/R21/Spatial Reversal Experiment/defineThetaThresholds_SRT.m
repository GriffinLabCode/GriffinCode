%% defineThetaThresholds_LTUC

prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
confirm  = input(prompt,'s');

if ~contains(confirm,[{'y'} {'Y'}])
    error('This code does not match the target rat')
end

% load baseline data for real time detection on "clean" data
disp(['Getting baseline data for ' targetRat])
cd(['X:\01.Experiments\R21\',targetRat,'\baseline']);
load('baselineData')

% interface with cheetah setup
threshold.coh_duration = 0.5;
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);    

% prep for coherence
window = []; noverlap = [];
fpass = [1:.5:20];
deltaRange = [1 4];
thetaRange = [6 11];
noisePercent = 1;

% initialize variables
cohRej = [];
cohAcc = [];

tStart = tic;
next = 0;
while next == 0

    % if both are empty, its the first run
    if isempty(cohRej)==1 && isempty(cohAcc)==1
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
    zArtifact = [];
    zArtifact(1,:) = ((data_det(1,:)-baselineMean(1))./baselineSTD(1));
    zArtifact(2,:) = ((data_det(2,:)-baselineMean(2))./baselineSTD(2));

    idxNoise = find(zArtifact(1,:) > 4 | zArtifact(1,:) < -1*4 | zArtifact(2,:) > 4| zArtifact(2,:) < -1*4);
    percSat = (length(idxNoise)/length(zArtifact))*100;                

    % only include if theta coherence is higher than delta. Reject
    % if delta is greater than theta or if saturation exceeds
    % threshold
    if cohDelta > cohTheta || percSat > noisePercent
        cohRej = [cohRej cohTheta]; 
    % accept if theta > delta and if minimal saturation
    elseif cohTheta > cohDelta && percSat < noisePercent
        cohAcc = [cohAcc cohTheta];
    end            

    % run this for 15 minutes
    disp([num2str(10-toc(tStart)/60) ' minutes remaining'])
    if toc(tStart)/60 > 10
        next = 1;
    end

end

% perform with rat above to do the rest
%logAcc = zscore(log(cohAcc));
figure; histogram(cohAcc)
zCoh = zscore(cohAcc);
figure; histogram(zCoh)

% need to simply generate distribution, zscore for 1std above mean
cohHighThreshold = nanmean(cohAcc(dsearchn(zscore(cohAcc)',1)));
cohLowThreshold = nanmean(cohAcc(dsearchn(zscore(cohAcc)',-1)));

% save
mkdir(['X:\01.Experiments\R21\' targetRat,'\thresholds'])
cd(['X:\01.Experiments\R21\' targetRat,'\thresholds'])

prompt = 'Are you ready to save? (y/n) - DO NOT SAVE OVER OLD DATA!';
answer = input(prompt,'s');
if contains(answer,[{'y'} {'Y'}])
    save('thresholds.mat','cohHighThreshold','cohLowThreshold','cohAcc','cohRej')
else
end