clear; clc
rats{1} = '1202'; % int1 and int3 are DA
rats{2} = '1203'; % skip 1203-14, cd came first. 1203-13, da then cd, no third
rats{3} = '1206'; % sess1 had no cd end, 1206-3 had cd->da, 1206-5 cd->da, -07 cd->da, -09 cd->da

place2store = getCurrentPath;
cd(place2store);
load('data_2016data_thresholds');

for i = 1:length(rats)
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

        if contains(rats{i},'1203')
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
        spkTimesData{sessi,i} = spkTimes;
        spikeDurData{sessi,i} = spikeDuration;

        % get spike times during data in consideration                                
        idxEnd = [];
        idxEnd = find(isnan(Int(:,1))==1);
        if isempty(idxEnd)==1
            for clusti = 1:length(spkTimes)
                spkTemp = [];
                spkTemp = spkTimes{clusti}(find(spkTimes{clusti} > Int(1,1) & spkTimes{clusti} < Int(end,8)));
                % fr
                clustFR{sessi,i}(clusti)  = (numel(spkTemp))/((Int(end,8)-Int(1,1))/1e6);
                clustISI{sessi,i}(clusti) = ((nanmean(diff(spkTemp)))/1e6)*1000;
            end     
        else
            for clusti = 1:length(spkTimes)
                spkTemp = [];
                spkTemp = spkTimes{clusti}(find(spkTimes{clusti} > Int(1,1) & spkTimes{clusti} < Int(idxEnd-1,8)));
                % fr
                clustFR{sessi,i}{clusti}  = (numel(spkTemp))/((Int(idxEnd-1,8)-Int(1,1))/1e6);
                clustISI{sessi,i}{clusti} = nanmean((diff(spkTemp)./1e6).*1000);
            end            
        end
        clustNames{sessi,i} = clusterID;
    end
end
