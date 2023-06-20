%% Spike field coherence on high/low coherence epochs
clear; clc
rats{1} = 'BabyGroot'; % DNMP
rats{2} = 'Meusli';
rats{3} = 'Groot';
place2store = getCurrentPath;
addpath(place2store);
trialsLfpHpc = []; trialsLfpPfc =[]; trialsLfpTs =[];

for rati = 1:length(rats)

    % get datafolders (session names) into a cell array
    Datafolders = ['X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\' rats{rati},'\'];        
    dir_content = [];
    dir_content = dir(Datafolders);
    if isempty(dir_content)
        continue
    end
    dir_content = extractfield(dir_content,'name');
    remIdx = contains(dir_content,'.mat') | contains(dir_content,'.');
    dir_content(remIdx)=[];
    rem2 = contains(dir_content,'DA');
    dir_content(rem2)=[];

    % loop across
    for sessi = 1:length(dir_content)

        % define datafolder
        datafolder = [Datafolders,dir_content{sessi}];        
        cd(datafolder)
        
        % load int
        load('Int_file');

        % choice accuracy
        if isempty(Int)
            continue
            disp('Session skipped')
        end

        % get lfp
         [hpcSignal,vmtSignal,pfcSignal] = ...
             ratNames2LFP_entrainment(rats{rati});

        % finally, get lfp
        lfpHpc = []; lfpPfc = []; lfpRe = []; lfpTimes = []; srate = [];             
        lfpPfc = getLFPdata(datafolder,pfcSignal,'Events');            
        lfpRe = getLFPdata(datafolder,vmtSignal,'Events');        
        [lfpHpc,lfpTimes,srate] = getLFPdata(datafolder,hpcSignal,'Events');    

        % if datasets arent the same size or if timings are off, skip
        if numel(lfpHpc) ~= numel(lfpPfc)
            disp('Issue with LFP and/or LFP timings. Session skipped')
            continue
        end
        
        % get spike data - the ISI will be wrong if there are stop/starts
        disp('Loading unit data')
        spkTimes = []; clusterID = [];
        [spkTimes,clusterID] = getSpikeData(datafolder,'TT','Events');

        % filter signals for noise
        lfpPfc = notchfilt(lfpPfc,srate);
        lfpRe  = notchfilt(lfpRe,srate);
        lfpHpc = notchfilt(lfpHpc,srate);
        
        % only include when the rat was on the task
        lfpPfc = lfpPfc(lfpTimes>Int(1,1) & lfpTimes<Int(end,end));
        lfpRe  = lfpRe(lfpTimes>Int(1,1) & lfpTimes<Int(end,end));
        lfpHpc = lfpHpc(lfpTimes>Int(1,1) & lfpTimes<Int(end,end));
        lfpTimes = lfpTimes(lfpTimes>Int(1,1) & lfpTimes<Int(end,end));
        
        % filter spikes for task
        for clusti = 1:length(clusterID)
            spkTimes{clusti} = spkTimes{clusti}(spkTimes{clusti}>Int(1,1)...
                & spkTimes{clusti}<Int(end,end)); %this was an error on 6/20. Fixed
        end        
        
        % remove neurons spiking < 50 times
        spkCounts = cellfun(@numel,spkTimes);
        spkTimes(spkCounts<50)=[];
        clusterID(spkCounts<50)=[];
                
        % get boolean spike trains
        spikeLFPbool = []; spikeLFPidx = [];
        for clusti = 1:length(clusterID)
            disp(['Working with cluster',num2str(clusti)])
            [spikeLFPbool(clusti,:),spikeLFPidx{clusti}] = ...
                getSpikeLFPidx(lfpTimes,spkTimes{clusti});
        end
        
        % epoch data, then get PFC average
        C = []; epochData = []; dC = []; % delta coherence
        [C,~,~,dC,epochData] = getThetaCoherenceEpochs(lfpPfc,lfpHpc,srate);
        
        % times when delta < theta
        cT = C(C>dC);
        
        % zscore transform
        zCoh = [];
        zCoh = zscore(cT);
        
        % define high/low thresh
        thresholdHigh = cT(dsearchn(zCoh',1));
        thresholdLow  = cT(dsearchn(zCoh',-1));

        % create spkLFP
        spkLFP = [];
        spkLFP(1,:) = lfpPfc;
        spkLFP(2,:) = lfpHpc;
        spkLFP(3,:) = lfpRe;
        spkLFP(4,:) = lfpTimes;
        spkLFP = vertcat(spkLFP,spikeLFPbool);
        
        % now get coherence thresholds using the spkLFP variable which
        % contains all signals and spike data
        disp('Getting high/low coherence data')
        cohInd = [1 2]; % compare signals 1 and 2
        cohThresholds = [thresholdHigh thresholdLow];
        signalInd = [1:3];
        plotfig = 'n';
        deltaThresh = 'y';
        datahigh = []; datalow = [];
        [datahigh,datalow,~,~,~] = getHighAndLowCohData(spkLFP,cohInd,signalInd,cohThresholds,srate,plotfig,deltaThresh);

        % outputs
        datahigh = emptyCellErase(datahigh);
        datalow  = emptyCellErase(datalow);
        
        % save dataSpkLFP variable        
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).data.dataHighCoh   = datahigh;
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).data.dataLowCoh    = datalow;
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).data.info.preprocessing = 'data was filtered for task performance. data was cleaned via notchfilter';
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).data.info.variable = 'row1 = pfc, row2 = hpc, row3 = vmt, row4 = timestamps, rows5:end are boolean spike trains for units. Epochs not meeting high or low coh criterion were discarded.';
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).data.info.unitHandling = 'Clusters are from Stout and Griffin, 2020. Here, they were removed if spiking < 50. Clusters were filtered to only include task performance';        
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).data.clusterNames  = clusterID;

        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).distributions.thetaC = C;
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).distributions.thetaC_aboveDelta = cT;
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).distributions.thetaC_aboveDelta_zscore = zCoh;
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).distributions.info.thetaC = 'getThetaCoherenceEpochs.m was used to get theta coherence values over time';
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).distributions.info.thetaC_aboveDelta = 'Theta coherence values were filtered to exclude times when delta > theta coh';
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).distributions.info.thetaC_aboveDelta_zscore = 'The distribution of theta>delta coherence scores were z-scored';      
        
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).thresholds.high = thresholdHigh;
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).thresholds.high = thresholdLow;
        dataSpkLFP.(['rat',num2str(rati)]).(['session',num2str(sessi)]).thresholds.info = 'z-scored theta>delta coh distribution used to generate high/low coh @ 1/-1std from the mean';

        disp(['Finished with ' rats{rati} ' session', num2str(sessi)])
    end
    disp(['Finished with ' rats{rati}])
end
%cd('C:\Users\uggriffin\Documents\BACKUP - Stout 2023 - dissertation\Stout et al 2022 Harnessing neural synchrony\data');
cd('X:\07. Manuscripts\In preparation\Harnessing neural synchrony');
disp('Saving spkLFP data...')
save('data_spkLFP_entrainment','dataSpkLFP');

