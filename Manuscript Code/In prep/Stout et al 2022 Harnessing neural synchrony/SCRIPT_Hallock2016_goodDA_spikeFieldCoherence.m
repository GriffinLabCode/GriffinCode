%% Spike field coherence on high/low coherence epochs
clear; clc
rats{1} = '1202'; % int1 and int3 are DA
rats{2} = '1203'; % skip 1203-14, cd came first. 1203-13, da then cd, no third
rats{3} = '1206'; % sess1 had no cd end, 1206-3 had cd->da, 1206-5 cd->da, -07 cd->da, -09 cd->da

place2store = getCurrentPath;
cd(place2store);
load('data_2016data_thresholds');

getData = 0; % set to 0 to load
if getData == 1
    for rati = 1:length(rats)

        % get datafolders (session names) into a cell array
        Datafolders = ['X:\01.Experiments\Completed Studies\mPFC-Hippocampus_DualTask\' rats{rati},'\'];
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
            %sessi=randsample(length(dir_content),1)

            % define datafolder
            datafolder = [Datafolders,dir_content{sessi}];        
            cd(datafolder)

            % load sessioninfo
            try
                sessInfo = [];
                sessInfo = load('Sessioninfo');        
            catch
                continue
            end

            Int = []; IntDA = [];
            try
                if contains(dir_content{sessi},'1203-14')
                    IntDA = load('Intervals','Int2');
                    if sessInfo.percentCorrect2 >=.75 
                        Int = IntDA.Int2;
                    end
                elseif contains(dir_content{sessi},'1203-13')
                    IntDA = load('Intervals','Int1');
                    if sessInfo.percentCorrect1 >=.75 
                        Int = IntDA.Int1;
                    end
                elseif contains(dir_content{sessi},'1203-15')
                    IntDA = load('Intervals','Int1');
                    if sessInfo.percentCorrect1 >=.75 
                        Int = IntDA.Int1;
                    end
                elseif contains(dir_content{sessi},'1203-5')
                    IntDA = load('Intervals','Int1');
                    if sessInfo.percentCorrect1 >=.75 
                        Int = IntDA.Int1;
                    end
                elseif contains(dir_content{sessi},[{'1206-3'} {'1206-5'} {'1206-7'} {'1206-9'}])
                    IntDA = load('Intervals','Int2');
                    if sessInfo.percentCorrect2 >=.75 
                        Int = IntDA.Int2;
                    end
                elseif contains(dir_content{sessi},[{'1206-1'} {'1206-2'} {'1206-4'} {'1206-6'} {'1206-8'}])    
                    IntDA = load('Intervals','Int1');
                    if sessInfo.percentCorrect1 >=.75 
                        Int = IntDA.Int1;
                    end
                elseif contains(dir_content{sessi},'1202')
                    IntDA = load('Intervals','Int1','Int3');  
                    %choiceacc = percentCorrect1;
                    if sessInfo.percentCorrect1 >= .75 && sessInfo.percentCorrect3 >= .75
                        Int = IntDA.Int1;
                        Int(end+1,:)=NaN;
                        Int = vertcat(Int,IntDA.Int3);
                    elseif sessInfo.percentCorrect1 >=.75 && sessInfo.percentCorrect3 < .75
                        Int = IntDA.Int1;
                    elseif sessInfo.percentCorrect1 < .75 && sessInfo.percentCorrect3 >= .75
                        Int = IntDA.Int3;
                    end
                elseif contains(dir_content{sessi},'1203') && ~contains(dir_content{sessi},[{'1203-13'} {'1203-14'} {'1203-15'} {'1203-5'}])
                    IntDA = load('Intervals','Int1','Int3');  
                    %choiceacc = percentCorrect1;
                    if sessInfo.percentCorrect1 >= .75 && sessInfo.percentCorrect3 >= .75
                        Int = IntDA.Int1;
                        Int(end+1,:)=NaN;
                        Int = vertcat(Int,IntDA.Int3);
                    elseif sessInfo.percentCorrect1 >=.75 && sessInfo.percentCorrect3 < .75
                        Int = IntDA.Int1;
                    elseif sessInfo.percentCorrect1 < .75 && sessInfo.percentCorrect3 >= .75
                        Int = IntDA.Int3;
                    end
                end
            catch
                disp('Fail')
                continue
            end

            % choice accuracy
            if isempty(Int)
                continue
                disp('Session skipped')
            end

            %disp(num2str(sessi))
        %end
            % get lfp - had to build this wild if statement to handle various
            % csc definitions for pfc/hpc lfps
            hpcPoss = []; pfcPoss = []; hpcID = []; pfcID = [];
            filesInFolder = [];
            filesInFolder = dir(datafolder);
            filesInFolder = extractfield(filesInFolder,'name');        
            if contains(rats{rati},'1202')

                % search for HPC cscs
                hpcPoss{1} = 'CSC11.mat'; 
                hpcPoss{2} = 'CSC8.mat';

                % do the same for PFC
                pfcPoss{1} = 'CSC3.mat'; 
                pfcPoss{2} = 'CSC2.mat';
                pfcPoss{3} = 'CSC1.mat';

            elseif contains(rats{rati},'1203')

                % search for HPC cscs
                %hpcPoss{1} = 'CSC11.mat'; 
                hpcPoss{1} = 'CSC8.mat';

                % do the same for PFC
                pfcPoss{1} = 'CSC3.mat'; 
                %pfcPoss{2} = 'CSC2.mat';
                %pfcPoss{3} = 'CSC1.mat';
            elseif contains(rats{rati},'1206')

                % search for HPC cscs
                %hpcPoss{1} = 'CSC11.mat'; 
                hpcPoss{1} = 'CSC5.mat';

                % do the same for PFC
                pfcPoss{1} = 'CSC9.mat'; 
                %pfcPoss{2} = 'CSC2.mat';
                %pfcPoss{3} = 'CSC1.mat';
            end

            % now get LFP
            try
                hpcID = [];
                for k = 1:length(hpcPoss)
                    hpcID = filesInFolder(find(contains(filesInFolder,hpcPoss{k})));
                    if isempty(hpcID) == 0
                        break
                    end
                end
                hpcID = hpcID{1};

                pfcID = [];
                for k = 1:length(pfcPoss)
                    pfcID = filesInFolder(find(contains(filesInFolder,pfcPoss{k})));
                    if isempty(pfcID) == 0
                        break
                    end                    
                end
                pfcID = pfcID{1};
            catch
                continue
            end

            % rat 1202 and sess 3 had a weird csc error
            if contains(rats{rati},'1202')
                if contains(dir_content{sessi},'1202-3')
                    disp('Skipping session')
                    continue
                end
            end

            event_boundaries = [];
            try event_boundaries(1,1) = sessInfo.start1; event_boundaries(1,2) = sessInfo.end1; end
            try event_boundaries(2,1) = sessInfo.start2; event_boundaries(2,2) = sessInfo.end2; end
            try event_boundaries(3,1) = sessInfo.start3; event_boundaries(3,2) = sessInfo.end3; end

            % finally, get lfp - converted around event boundaries
            lfpHpc = []; lfpPfc = []; lfpTimesHpc = []; lfpTimesPfc = [];
            [lfpHpc,lfpTimesHpc] = getLFPdata(datafolder,hpcID,'Events',event_boundaries);    
            [lfpPfc,lfpTimesPfc,srate] = getLFPdata(datafolder,pfcID,'Events',event_boundaries);

            % if datasets arent the same size or if timings are off, skip
            if numel(lfpHpc) ~= numel(lfpPfc) || isempty(find((lfpTimesHpc-lfpTimesPfc)>0))==0
                disp('Issue with LFP and/or LFP timings. Session skipped')
                continue
            end

            % get spike data - the ISI will be wrong if there are stop/starts
            [spkTimes,clusterID,spikeDuration,ISI,sessFR] = getSpikeData(datafolder,'TT','Events');

            if contains(rats{rati},'1203')
                clustersHPC = [];
                for k = 1:length(clusterID)
                    if contains(clusterID{k},[{'TT11'} {'TT15'} {'TT9'} {'TT8'}])
                        clustersHPC(k) = 1;
                    else
                        clustersHPC(k) = 0;
                    end
                end
                clusterHPC  = clusterID(find(clustersHPC==1));
                spkTimesHPC = spkTimes(find(clustersHPC==1));

                % only examine PFC neurons
                spkTimes(find(clustersHPC==1))=[];
                clusterID(find(clustersHPC==1))=[];
                spikeDuration(find(clustersHPC==1))=[];
                ISI(find(clustersHPC==1))=[];
                sessFR(find(clustersHPC==1))=[];
            end   

            % store spike variables
            spkTimesData{sessi,rati} = spkTimes;
            spikeDurData{sessi,rati} = spikeDuration;

            % get spike times during data in consideration                                
            idxEnd = [];
            idxEnd = find(isnan(Int(:,1))==1);
            if isempty(idxEnd)==1
                for clusti = 1:length(spkTimes)
                    spkTemp = [];
                    spkTemp = spkTimes{clusti}(find(spkTimes{clusti} > Int(1,1) & spkTimes{clusti} < Int(end,8)));
                    % fr
                    clustFR{sessi,rati}(clusti)  = (numel(spkTemp))/((Int(end,8)-Int(1,1))/1e6);
                    clustISI{sessi,rati}(clusti) = ((nanmean(diff(spkTemp)))/1e6)*1000;
                end     
            else
                for clusti = 1:length(spkTimes)
                    spkTemp = [];
                    spkTemp = spkTimes{clusti}(find(spkTimes{clusti} > Int(1,1) & spkTimes{clusti} < Int(idxEnd-1,8)));
                    % fr
                    clustFR{sessi,rati}{clusti}  = (numel(spkTemp))/((Int(idxEnd-1,8)-Int(1,1))/1e6);
                    clustISI{sessi,rati}{clusti} = nanmean((diff(spkTemp)./1e6).*1000);
                end            
            end
            clustNames{sessi,rati} = clusterID;

            %ISI{sessi,i} = ISI;

            % clusters identified by henry that he used
            %{
            if contains(rats{i},'1202')
                clustersKeep = [];
                for k = 1:length(clusterID)
                    if contains(clusterID{k},[{'TT2'} {'TT3'} {'TT6'} {'TT7'}])
                        clustersKeep(k) = 1;
                    else
                        clustersKeep(k) = 0;
                    end
                end
            end
            %}

            trialsLfpHpc = []; trialsLfpPfc =[]; trialsLfpTs =[];
            clear lfpTemp
            for delayi = 2:size(Int,1)

                % index of lfp
                if isnan(Int(delayi,1))==0
                    timingIdx = 30*2035; % this gives us an index of delay duration in samples as the srate is 2035
                    lfpIdxHpc = []; lfpIdxPfc = [];
                    lfpIdxHpc = dsearchn(lfpTimesHpc',Int(delayi,1));
                    lfpIdxPfc = dsearchn(lfpTimesPfc',Int(delayi,1));

                    % -30s to stem entry
                    lfpPfcTrial = []; lfpHpcTrial = [];
                    lfpHpcTrial = lfpHpc(lfpIdxHpc-timingIdx:lfpIdxHpc);
                    lfpPfcTrial = lfpPfc(lfpIdxPfc-timingIdx:lfpIdxPfc);
                    lfpHpcTimesTrials = lfpTimesHpc(lfpIdxHpc-timingIdx:lfpIdxHpc);
                    lfpPfcTimesTrials = lfpTimesPfc(lfpIdxPfc-timingIdx:lfpIdxPfc);

                    % store trial data
                    trialsLfpHpc{delayi} = lfpHpcTrial;
                    trialsLfpPfc{delayi} = lfpPfcTrial;
                    trialsLfpTs{delayi}  = lfpHpcTimesTrials;

                    % loop across lfp, calculate coherence
                    overlap = round(0.25*2035,-1); % to round up to 510
                    window  = round(1.25*2035,-1); % 2540
                    looperIdx = [];
                    looperIdx = 1:overlap:timingIdx; % 500samples selected for 250ms overlap

                    for k = 1:length(looperIdx)
                        if looperIdx(k) < timingIdx-window
                            % get lfp in moving windows
                            lfpTemp{delayi}{k}(1,:) = lfpHpcTrial(looperIdx(k):looperIdx(k)+window);
                            lfpTemp{delayi}{k}(2,:) = lfpPfcTrial(looperIdx(k):looperIdx(k)+window);
                            % detrend
                            lfpTemp{delayi}{k}(1,:) = detrend(lfpTemp{delayi}{k}(1,:),3);
                            lfpTemp{delayi}{k}(2,:) = detrend(lfpTemp{delayi}{k}(2,:),3);
                            lfpTemp{delayi}{k}(3,:) = lfpHpcTimesTrials(looperIdx(k):looperIdx(k)+window);
                            lfpTemp{delayi}{k}(4,:) = lfpPfcTimesTrials(looperIdx(k):looperIdx(k)+window);
                        end
                    end
                end
            end

            % collapse data in order to define mean and std
            lfpCol = [];
            lfpCol = horzcat(lfpTemp{:});
            lfpCol2 = []; 
            lfpCol2 = horzcat(lfpCol{:});

            % define mean and std
            distMeanPFC = nanmean(lfpCol2(2,:));
            distMeanHPC = nanmean(lfpCol2(1,:));
            distStdPFC  = nanstd(lfpCol2(2,:));
            distStdHPC  = nanstd(lfpCol2(1,:));       

            deltaRange = [1 4];
            thetaRange = [6 11];
            for delayi = 1:length(lfpTemp)
                for iti = 1:length(lfpTemp{delayi})

                    % determine if data is noisy
                    noiseThreshold = 4; % std
                    noisePercent   = 1; % percent

                    % zscore transform
                    zArtifact = [];
                    zArtifact(1,:) = ((lfpTemp{delayi}{iti}(1,:)-distMeanHPC)./distStdHPC);
                    zArtifact(2,:) = ((lfpTemp{delayi}{iti}(2,:)-distMeanPFC)./distStdPFC);
                    idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
                    percSat = (length(idxNoise)/length(zArtifact))*100;           

                    if percSat < 1
                        %pause;
                        % calculate coherence
                        coh = [];
                        [coh,f] = mscohere(lfpTemp{delayi}{iti}(1,:),lfpTemp{delayi}{iti}(2,:),[],[],[1:0.5:20],2035);

                        % perform logical indexing of theta and delta ranges to improve
                        % performance speed
                        cohDelta = nanmean(coh(f > deltaRange(1) & f < deltaRange(2)));
                        cohTheta = nanmean(coh(f > thetaRange(1) & f < thetaRange(2)));  

                        if cohTheta > cohDelta

                            % high coherence
                            if cohTheta > highThreshold(rati)
                                %pause;
                                % store lfp and spike data
                                for clusti = 1:length(spkTimes)
                                    spksHigh{sessi,rati}{delayi}{clusti,iti} = spkTimes{clusti}(find(spkTimes{clusti} >= lfpTemp{delayi}{iti}(3,1) & spkTimes{clusti} <= lfpTemp{delayi}{iti}(3,end)));
                                end
                                % store lfp
                                lfpHighCoh{sessi,rati}{delayi}{iti} = lfpTemp{delayi}{iti};


                                % get spike-triggered LFP
                                % ------- Spike triggered LFP ------- %

                                % now lets get lfp surrounding spike data - this is
                                % the part where we don't want duplicates. Before
                                % it didn't matter because everything was
                                % normalized by epoch and we could consider zeros

                            elseif cohTheta < lowThreshold(rati)
                                % store lfp and spike data
                                for clusti = 1:length(spkTimes)
                                    spksLow{sessi,rati}{delayi}{clusti,iti} = spkTimes{clusti}(find(spkTimes{clusti} >= lfpTemp{delayi}{iti}(3,1) & spkTimes{clusti} <= lfpTemp{delayi}{iti}(3,end)));
                                end
                                % store lfp
                                lfpLowCoh{sessi,rati}{delayi}{iti} = lfpTemp{delayi}{iti};

                                % ----- %

                                % do the same for low coh
                                %{
                                % get rid of all data that has no spikes
                                spksLowTemp = [];
                                spksLowTemp = emptyCellErase(spksLow{sessi,i});
                                % concatenate data, we don't need to preserve trial
                                % structure
                                spksLowTemp = horzcat(spksLowTemp{:});
                                % change empties to nans
                                spksLowTemp = empty2nan(spksLowTemp);
                                % once again concatenate while preserving neuron
                                spksLowTemp = cellcat(spksLowTemp,'vertcat','col');
                                % loop across neurons, only keep unique timestamps
                                % per neuron
                                for m = 1:length(spksLowTemp)
                                    % remove nans
                                    spksLowTemp{m}(isnan(spksLowTemp{m}))=[];
                                    spksLowTemp{m} = unique(spksLowTemp{m});
                                end
                                % to preserve paired-based analyses, any empty
                                % arrays set to nan
                                spksLowTemp = empty2nan(spksLowTemp);
                                % now loop across spk data, and get spike triggered
                                % lfp across a 300ms window
                                samAround = round(.15*2035); % # samples in 150ms
                                for m = 1:length(spksLowTemp) % looping over neurons
                                    % get an index of lfp timestamps occuring on
                                    % spikes
                                    if isnan(spksLowTemp{m})==0
                                        disp('dsearchn')
                                        idx = []; idx = dsearchn(lfpTimesPfc',spksLowTemp{m});
                                        disp('dsearchn complete')
                                        %idx2 = []; idx2 = dsearchn(lfpTimesHpc',spksLowTemp{m});                            
                                        % get index of lfp surrounding spikes
                                        idxEdges = []; idxEdges = [idx-samAround idx+samAround];
                                        %idxEdges2 = []; idxEdges2 = [idx2-samAround idx2+samAround];                            
                                        % use the indices to get LFP data
                                        for j = 1:size(idxEdges,1) % looping over spikes
                                            stlPfcLow{sessi,i}{m}(j,:) = lfpPfc(idxEdges(j,1):idxEdges(j,2));
                                            stlHpcLow{sessi,i}{m}(j,:) = lfpHpc(idxEdges(j,1):idxEdges(j,2));
                                        end 
                                        % the data above is stored such that session is
                                        % on rows, rat is on columns, then inside each
                                        % element, there are m neurons with j spikes
                                    end
                                end 
                                %}
                            end                 
                        end
                    end
                end
            end

            try
                % -- high coherence data -- %

                % get rid of all data that has no spikes
                spksHighTemp = [];
                spksHighTemp = emptyCellErase(spksHigh{sessi,rati});
                % concatenate data, we don't need to preserve trial
                % structure
                spksHighTemp = horzcat(spksHighTemp{:});
                % change empties to nans
                spksHighTemp = empty2nan(spksHighTemp);
                % once again concatenate while preserving neuron
                spksHighTemp = cellcat(spksHighTemp,'vertcat','col');
                % loop across neurons, only keep unique timestamps
                % per neuron
                for m = 1:length(spksHighTemp)
                    % remove nans
                    spksHighTemp{m}(isnan(spksHighTemp{m}))=[];
                    spksHighTemp{m} = unique(spksHighTemp{m});
                end
                % to preserve paired-based analyses, any empty
                % arrays set to nan
                spksHighTemp = empty2nan(spksHighTemp);
                % concatenate across spikes
                spksHighTemp = vertcat(spksHighTemp{:});
                spksHighTemp(isnan(spksHighTemp))=[];
                % get an index of spk times in the LFP - first concatenate trial
                % data to save a god foresaken amount of dsearchn time
                trialsLfpHpc = horzcat(trialsLfpHpc{:});
                trialsLfpPfc = horzcat(trialsLfpPfc{:});
                trialsLfpTs  = horzcat(trialsLfpTs{:});
                % now get spikes corresponding to LFP timestamps
                sidx = [];
                sidx = dsearchn(trialsLfpTs',spksHighTemp);

                % now perform morlet wavelet convolution over various frequencies
                % and calculate sfc
                frequencies = logspace(0,2); % 10^0 to 10^2: 1:100
                nCycle = 6; srate = 2035; % constants
                %tic;
                lfp1 = single(trialsLfpHpc); % set to single type (32bit)
                lfp2 = single(trialsLfpPfc);
                for wavei = 1:length(frequencies)
                    % get complex morlet wavelets for hpc and pfc at frequency
                    % wavei
                    [asHpc] = getMorletWaveletConv(lfp1,frequencies(wavei),nCycle,srate);
                    [asPfc] = getMorletWaveletConv(lfp2,frequencies(wavei),nCycle,srate);
                    % now perform spike field coherence across the various analytical
                    % signals
                    anglesHpc = angle(asHpc(sidx)); % phase of lfp at each spike as extracted via morlet wavelet convolution, as 
                    anglesPfc = angle(asPfc(sidx)); % phase of lfp at each spike as extracted via morlet wavelet convolution, as             
                    sfcHpcHigh{sessi,rati}(wavei) = abs(mean(exp(1i*anglesHpc))); % Length of the average vector (like power)
                    sfcPfcHigh{sessi,rati}(wavei) = abs(mean(exp(1i*anglesPfc))); % Length of the average vector (like power)        
                end
                %toc
                % took about 17s
                %{
                figure('color','w')
                plot(frequencies,sfcHpc,'b'); hold on;
                plot(frequencies,sfcPfc,'k');
                ylabel('Spike field coherence')
                xlabel('Frequecy (Hz)')
                %} 

                % -- low coherence data -- %

                % get rid of all data that has no spikes
                spksLowTemp = [];
                spksLowTemp = emptyCellErase(spksLow{sessi,rati});
                % concatenate data, we don't need to preserve trial
                % structure
                spksLowTemp = horzcat(spksLowTemp{:});
                % change empties to nans
                spksLowTemp = empty2nan(spksLowTemp);
                % once again concatenate while preserving neuron
                spksLowTemp = cellcat(spksLowTemp,'vertcat','col');
                % loop across neurons, only keep unique timestamps
                % per neuron
                for m = 1:length(spksLowTemp)
                    % remove nans
                    spksLowTemp{m}(isnan(spksLowTemp{m}))=[];
                    spksLowTemp{m} = unique(spksLowTemp{m});
                end
                % to preserve paired-based analyses, any empty
                % arrays set to nan
                spksLowTemp = empty2nan(spksLowTemp);
                % concatenate across spikes
                spksLowTemp = vertcat(spksLowTemp{:});
                spksLowTemp(isnan(spksLowTemp))=[];
                % now get spikes corresponding to LFP timestamps
                sidx = [];
                sidx = dsearchn(trialsLfpTs',spksLowTemp);

                % now perform morlet wavelet convolution over various frequencies
                % and calculate sfc
                frequencies = logspace(0,2); % 10^0 to 10^2: 1:100
                nCycle = 6; srate = 2035; % constants
                %tic;
                lfp1 = single(trialsLfpHpc); % set to single type (32bit)
                lfp2 = single(trialsLfpPfc);
                for wavei = 1:length(frequencies)
                    % get complex morlet wavelets for hpc and pfc at frequency
                    % wavei
                    [asHpc] = getMorletWaveletConv(lfp1,frequencies(wavei),nCycle,srate);
                    [asPfc] = getMorletWaveletConv(lfp2,frequencies(wavei),nCycle,srate);
                    % now perform spike field coherence across the various analytical
                    % signals
                    anglesHpc = angle(asHpc(sidx)); % phase of lfp at each spike as extracted via morlet wavelet convolution, as 
                    anglesPfc = angle(asPfc(sidx)); % phase of lfp at each spike as extracted via morlet wavelet convolution, as             
                    sfcHpcLow{sessi,rati}(wavei) = abs(mean(exp(1i*anglesHpc))); % Length of the average vector (like power)
                    sfcPfcLow{sessi,rati}(wavei) = abs(mean(exp(1i*anglesPfc))); % Length of the average vector (like power)        
                end        
            catch
                sfcHpcHigh{sessi,rati}=[];
                sfcPfcHigh{sessi,rati}=[];
                sfcHpcLow{sessi,rati}=[];
                sfcPfcLow{sessi,rati}=[];            
            end

        end

        disp(['Finished with ' rats{rati}])
    end
    cd(place2store);
    save('data_2016data_SFC_checker','sfcHpcHigh','sfcHpcLow','sfcPfcHigh','sfcPfcLow')
else
    load('data_2016data_SFC');
end
% do stuff
sfcHpcHigh = sfcHpcHigh(:);
sfcHpcLow  = sfcHpcLow(:);
sfcPfcHigh = sfcPfcHigh(:);
sfcPfcLow  = sfcPfcLow(:);

sfcHpcHigh = vertcat(sfcHpcHigh{:});
sfcHpcLow  = vertcat(sfcHpcLow{:});
sfcPfcHigh = vertcat(sfcPfcHigh{:});
sfcPfcLow  = vertcat(sfcPfcLow{:});

% normalize data across frequencies
sfcHpcHighN = normalize(sfcHpcHigh','range')';
sfcHpcLowN  = normalize(sfcHpcLow','range')';
sfcPfcHighN = normalize(sfcPfcHigh','range')';
sfcPfcLowN  = normalize(sfcPfcLow','range')';

% remove nan
nanRem1 = find(isnan(sfcHpcLow(:,1)));
nanRem2 = find(isnan(sfcHpcHigh(:,1)));
nanRem3 = find(isnan(sfcPfcLow(:,1)));
nanRem4 = find(isnan(sfcPfcHigh(:,1)));
nanRem = unique(horzcat(nanRem1,nanRem2,nanRem3,nanRem4));
sfcHpcHighN(nanRem,:)=[];
sfcHpcLowN(nanRem,:)=[];
sfcPfcHighN(nanRem,:)=[];
sfcPfcLowN(nanRem,:)=[];
sfcHpcHigh(nanRem,:)=[];
sfcHpcLow(nanRem,:)=[];
sfcPfcHigh(nanRem,:)=[];
sfcPfcLow(nanRem,:)=[];

frequencies = logspace(0,2); % 10^0 to 10^2: 1:100
figure('color','w'); hold on;
shadedErrorBar(frequencies,nanmean(sfcHpcHigh,1),stderr(sfcHpcHigh,1),'k',0)
shadedErrorBar(frequencies,nanmean(sfcHpcLow,1),stderr(sfcHpcLow,1),'r',0)
ylim([0.01 0.06])
figure('color','w'); hold on;
shadedErrorBar(frequencies,nanmean(sfcHpcHigh,1),stderr(sfcHpcHigh,1),'k',0)
shadedErrorBar(frequencies,nanmean(sfcHpcLow,1),stderr(sfcHpcLow,1),'r',0)
ylim([0.01 0.06])
xlim([1 20])

figure('color','w'); hold on;
shadedErrorBar(frequencies,nanmean(sfcPfcHigh,1),stderr(sfcPfcHigh,1),'k',0)
shadedErrorBar(frequencies,nanmean(sfcPfcLow,1),stderr(sfcPfcLow,1),'r',0)
ylim([0.01 0.06])
figure('color','w'); hold on;
shadedErrorBar(frequencies,nanmean(sfcPfcHigh,1),stderr(sfcPfcHigh,1),'k',0)
shadedErrorBar(frequencies,nanmean(sfcPfcLow,1),stderr(sfcPfcLow,1),'r',0)
ylim([0.01 0.06])
xlim([1 20])
% get theta
fTheta = find(frequencies >=6 & frequencies <=11);

avgPfcH = nanmean(sfcPfcHigh(:,fTheta),2);
avgPfcL = nanmean(sfcPfcLow(:,fTheta),2);
avgHpcH = nanmean(sfcHpcHigh(:,fTheta),2);
avgHpcL = nanmean(sfcHpcLow(:,fTheta),2);

sfcDiffPfc = (avgPfcH-avgPfcL)./(avgPfcH+avgPfcL);
sfcDiffHpc = (avgHpcH-avgHpcL)./(avgHpcH+avgHpcL);

mat = [];
mat = horzcat(sfcDiffPfc,sfcDiffHpc);
multiBarPlot(mat,[{'PFC'} {'HPC'}],'Norm. SFC (high-low)','n');
[h,p1,ci,stat]=ttest(mat(:,1),0); p1=p1*3;
[h,p2,ci,stat]=ttest(mat(:,2),0); p2=p2*3;
[h,p3,ci,stat]=ttest(mat(:,1),mat(:,2)); p3=p3*3;

%{
fGamma = find(frequencies >=30 & frequencies <=80);

avgPfcH = nanmean(sfcPfcHigh(:,fGamma),2);
avgPfcL = nanmean(sfcPfcLow(:,fGamma),2);
avgHpcH = nanmean(sfcHpcHigh(:,fGamma),2);
avgHpcL = nanmean(sfcHpcLow(:,fGamma),2);

sfcDiffPfc = (avgPfcH-avgPfcL)./(avgPfcH+avgPfcL);
sfcDiffHpc = (avgHpcH-avgHpcL)./(avgHpcH+avgHpcL);

mat = [];
mat = horzcat(sfcDiffPfc,sfcDiffHpc);
multiBarPlot(mat,[{'PFC'} {'HPC'}],'Norm. SFC (high-low)','n');
[h,p1]=ttest(mat(:,1),0); p1=p1*3;
[h,p2]=ttest(mat(:,2),0); p2=p2*3;
[h,p3]=ttest(mat(:,1),mat(:,2)); p3=p3*3;



%}