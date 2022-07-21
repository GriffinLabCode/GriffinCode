%% Neural representations on low/high coehrence
% Benchenane showed that PFC neuronal esembles become coordinated during
% high coherence state. But do their representations differ? It is possible
% that low coherence states are associated with parallel, independent
% processing.
%
% To test this idea, we will:
% 1) Define what high/low coherence is.
% 2) In delay, extract spiking during high and low coherence
% 3) train a classifier to predict spiking during high and low coherence
% if the classifier can predict spiking activity between high and low
% coherence states, then their underlying functions may differ

% does theta entrainment differ on low/high? maybe pfc entrains locally
% during low

% Use hallock 2016 data - our stout 2020 lfp isn't so good

%%
clear; clc
rats{1} = '1202'; % int1 and int3 are DA
rats{2} = '1203'; % skip 1203-14, cd came first. 1203-13, da then cd, no third
rats{3} = '1206'; % sess1 had no cd end, 1206-3 had cd->da, 1206-5 cd->da, -07 cd->da, -09 cd->da

% all rats except 1206 had this data somewhere in their folders.  ifigured
% out 1206 through deduction. session 1206-9 only has 2 CSCs, and in the
% LvR_unit excel sheet TT9 is pfc and there is no TT5 units. So it must be
% HPC
hpc_names{1} = 'CSC11';
hpc_names{2} = 'CSC8';
hpc_names{3} = 'CSC5';
pfc_names{1} = 'CSC3';
pfc_names{2} = 'CSC3';
pfc_names{3} = 'CSC9';

for i = 1:length(rats)
    
    % troubleshooting
    %i=randsample(3,1);
    
    % get datafolders (session names) into a cell array
    Datafolders = ['X:\01.Experiments\Completed Studies\mPFC-Hippocampus_DualTask\' rats{i},'\'];
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
        
        Int = [];
        try
            if contains(dir_content{sessi},'1203-14')
                IntDA = load('Intervals','Int2');
                Int = IntDA.Int2;
            elseif contains(dir_content{sessi},'1203-13')
                IntDA = load('Intervals','Int1');
                Int = IntDA.Int1;
            elseif contains(dir_content{sessi},'1203-15')
                IntDA = load('Intervals','Int1');
                Int = IntDA.Int1;
            elseif contains(dir_content{sessi},'1203-5')
                IntDA = load('Intervals','Int1');
                Int = IntDA.Int1;                
            elseif contains(dir_content{sessi},[{'1206-3'} {'1206-5'} {'1206-7'} {'1206-9'}])
                IntDA = load('Intervals','Int2');
                Int = IntDA.Int2;
            elseif contains(dir_content{sessi},[{'1206-1'} {'1206-2'} {'1206-4'} {'1206-6'} {'1206-8'}])    
                IntDA = load('Intervals','Int1');
                Int = IntDA.Int1;
            elseif contains(dir_content{sessi},'1202')
                IntDA = load('Intervals','Int1','Int3');  
                Int = IntDA.Int1;
                Int(end+1,:)=NaN;
                Int = vertcat(Int,IntDA.Int3);
            elseif contains(dir_content{sessi},'1203') && ~contains(dir_content{sessi},[{'1203-13'} {'1203-14'} {'1203-15'} {'1203-5'}])
                IntDA = load('Intervals','Int1','Int3');  
                Int = IntDA.Int1;
                Int(end+1,:)=NaN;
                Int = vertcat(Int,IntDA.Int3);
            end
        catch
            disp('Fail')
            continue
        end
        %disp(num2str(sessi))
    %end
        % get lfp - had to build this wild if statement to handle various
        % csc definitions for pfc/hpc lfps
        hpcPoss = []; pfcPoss = []; hpcID = []; pfcID = [];
        filesInFolder = [];
        filesInFolder = dir(datafolder);
        filesInFolder = extractfield(filesInFolder,'name');        
        if contains(rats{i},'1202')

            % search for HPC cscs
            hpcPoss{1} = 'CSC11.mat'; 
            hpcPoss{2} = 'CSC8.mat';

            % do the same for PFC
            pfcPoss{1} = 'CSC3.mat'; 
            pfcPoss{2} = 'CSC2.mat';
            pfcPoss{3} = 'CSC1.mat';

        elseif contains(rats{i},'1203')

            % search for HPC cscs
            %hpcPoss{1} = 'CSC11.mat'; 
            hpcPoss{1} = 'CSC8.mat';

            % do the same for PFC
            pfcPoss{1} = 'CSC3.mat'; 
            %pfcPoss{2} = 'CSC2.mat';
            %pfcPoss{3} = 'CSC1.mat';
        elseif contains(rats{i},'1206')

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
        if contains(rats{i},'1202')
            if contains(dir_content{sessi},'1202-3')
                disp('Skipping session')
                continue
            end
        end
        
        % load sessioninfo
        sessInfo = [];
        sessInfo = load('Sessioninfo');
        
        event_boundaries = [];
        try event_boundaries(1,1) = sessInfo.start1; event_boundaries(1,2) = sessInfo.end1; end
        try event_boundaries(2,1) = sessInfo.start2; event_boundaries(2,2) = sessInfo.end2; end
        try event_boundaries(3,1) = sessInfo.start3; event_boundaries(3,2) = sessInfo.end3; end

        % finally, get lfp
        lfpHpc = []; lfpPfc = []; lfpTimesHpc = []; lfpTimesPfc = [];
        [lfpHpc,lfpTimesHpc] = getLFPdata(datafolder,hpcID,'Events',event_boundaries);    
        [lfpPfc,lfpTimesPfc,srate] = getLFPdata(datafolder,pfcID,'Events',event_boundaries);

        if srate > 3000
            warning('Session exhibited srate > 3000')
            pause;
        end
        
        % get LFPs during delays
        clear lfpTemp
        for delayi = 2:size(Int,1)
            
            % index of lfp
            if isnan(Int(delayi,1))==0
                timingIdx = 30*2035; % this gives us an index of delay duration in samples as the srate is 2000
                lfpIdxHpc = []; lfpIdxPfc = [];
                lfpIdxHpc = dsearchn(lfpTimesHpc',Int(delayi,1));
                lfpIdxPfc = dsearchn(lfpTimesPfc',Int(delayi,1));

                % -30s to stem entry
                lfpPfcTrial = []; lfpHpcTrial = [];
                lfpHpcTrial = lfpHpc(lfpIdxHpc-timingIdx:lfpIdxHpc);
                lfpPfcTrial = lfpPfc(lfpIdxPfc-timingIdx:lfpIdxPfc);

                % loop across lfp, calculate coherence
                overlap = round(0.25*2035,-1); % to round up to 510
                window  = round(1.25*2035,-1); % 2540
                looperIdx = [];
                looperIdx = 1:overlap:timingIdx; % 500samples selected for 250ms overlap

                for k = 1:length(looperIdx)
                    if looperIdx(k) < timingIdx-window
                        % get lfp in moving windows - 2500 selected as 1.25s
                        % windows
                        lfpTemp{delayi}{k}(1,:) = lfpHpcTrial(looperIdx(k):looperIdx(k)+window);
                        lfpTemp{delayi}{k}(2,:) = lfpPfcTrial(looperIdx(k):looperIdx(k)+window);
                        % detrend
                        lfpTemp{delayi}{k}(1,:) = detrend(lfpTemp{delayi}{k}(1,:),3);
                        lfpTemp{delayi}{k}(2,:) = detrend(lfpTemp{delayi}{k}(2,:),3);
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
                    % calculate coherence
                    coh = [];
                    [coh,f] = mscohere(lfpTemp{delayi}{iti}(1,:),lfpTemp{delayi}{iti}(2,:),[],[],[1:0.5:20],2035);

                    % perform logical indexing of theta and delta ranges to improve
                    % performance speed
                    cohDelta = nanmean(coh(f > deltaRange(1) & f < deltaRange(2)));
                    cohTheta = nanmean(coh(f > thetaRange(1) & f < thetaRange(2)));  
                    
                    if cohTheta > cohDelta
                        cohData{i}{sessi}{delayi}(iti) = cohTheta;
                    end
                end
            end
        end
    end
    disp(['Finished with ' rats{i}])
end

% now generate rat dependent distributions to extract high/low coherence
% states
for rati = 1:length(cohData)
    cat1 = [];
    cat1 = horzcat(cohData{rati}{:});
    cat2 = [];
    cat2 = horzcat(cat1{:});
    cat2(cat2==0)=[]; % 0s are a product of a poorly designed loop above
    cohRat{rati} = cat2;
    cohLog{rati} = log10(cat2);
    cohLogZ{rati} = zscore(cohLog{rati});
    cohZ{rati}    = zscore(cohRat{rati});
end

xRange     = [-3:.05:3];
colors{1}  = [0 0 0.4]; colors{2} = [0 0 0.6];  colors{3} = [0 0 0.8]; colors{4} = [0 0 1];
dataLabels = rats;
distType   = 'normal';
[y,a] = plotCurves(cohZ,xRange,colors,dataLabels,distType);
ylabel('Probability density')
xlabel('Mean Coherence (6-11hz)')   
xlimits = xlim;
ylimits = ylim;
line([1 1],[ylimits(1) ylimits(2)],'Color','g','LineStyle','--')
line([-1 -1],[ylimits(1) ylimits(2)],'Color','r','LineStyle','--')
ylabel('Probability Density')
xlabel('zscored theta coherence (6-11Hz)')

% use zscore dist to identify non log transformed data
for rati = 1:length(cohZ)
    highThreshold(rati) = cohRat{rati}(dsearchn(cohZ{rati}',1));
    lowThreshold(rati)  = cohRat{rati}(dsearchn(cohZ{rati}',-1));
end

place2store = getCurrentPath();
cd(place2store)
save('data_2016data_thresholds','highThreshold','lowThreshold')


