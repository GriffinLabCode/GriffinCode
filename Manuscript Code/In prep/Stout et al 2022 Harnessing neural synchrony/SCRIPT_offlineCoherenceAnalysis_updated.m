%% percent accuracy on DA so far
clear;
% theres like no theta on 21-15. I dont think we can include him

% define rat IDs
rats{1} = '21-12';
rats{2} = '21-13';
rats{3} = '21-14';
rats{4} = '21-33';
rats{5} = '21-15';
rats{6} = '21-16';
rats{7} = '21-21';
rats{8} = '21-37';

coh_high = []; coh_low = []; coh_yHigh = []; coh_yLow = []; coh_Norm = [];
for i = 1:length(rats)
    
    % get datafolders (session names) into a cell array
    Datafolders = ['X:\01.Experiments\R21\',rats{i},'\Sessions\DA testing\'];
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
    coh_high = []; coh_low = []; coh_yHigh = []; coh_yLow = []; coh_Norm = [];
    for sessi = 1:length(dir_content)
        try
          
            % define datafolder
            datafolder = [Datafolders,dir_content{sessi}];

            % load maze and matlab data
            cd(datafolder);
            dataINfolder = dir(datafolder);
            dataINfolder = extractfield(dataINfolder,'name');
            idxKeep = find(contains(dataINfolder,rats{i})==1);
            dataINfolder = dataINfolder(idxKeep);

            if length(dataINfolder) > 1
                error('Make sure there is only one .mat file name with your rat')
            end

            % pull in matlab data
            dataIN = load(dataINfolder{1},'accuracy','delayLenTrial','indicatorOUT','trajectory_text','percentAccurate');
            try remData = load('removeTrajectories');
            catch remData = [];
            end

            % eliminate trials
            % remove any trials after length of trials
            numTrials = length(dataIN.accuracy);
            dataIN.indicatorOUT(numTrials+1:end)=[];
            dataIN.delayLenTrial(numTrials+1:end)=[];

            % load int
            load('sequenceTable')
            sequenceTable.Remove(remData.remTraj)=1;
            sequenceTable([remData.remTraj],:)   = [];
            sequenceTable([1],:)                 = []; % remove first trial

            % eliminate the first trajectory
            %Int(1,:)=[];

            % another way to remove data - not needed for sequence table
            remChoices = [];
            try
                remChoices = remData.remTraj-1;                  
            catch
            end

            % indicatorOUT temp
            tempInd = [];
            tempInd = dataIN.indicatorOUT;
            % delay times 
            delayTimes = [];
            delayTimes = dataIN.delayLenTrial;
            % trial accuracies
            accuracy  = []; 
            accuracy  = dataIN.accuracy;        

            % remove
            tempInd(remChoices)    = [];
            delayTimes(remChoices) = [];
            accuracy(remChoices)   = [];
            
            % get indices
            idxHigh = []; idxLow = []; idxYokedHigh = []; idxYokedLow = [];
            idxHigh = find(contains(tempInd,'highMET')==1);
            idxLow = find(contains(tempInd,'lowMET')==1);
            idxYokedHigh = find(contains(tempInd,'yokeH_MET')==1);
            idxYokedLow = find(contains(tempInd,'yokeL_MET')==1);
            idxNorm = find(contains(tempInd,[{'Norm'}, {'NormHighFail'} {'NormLowFail'}]));

            % find times and make sure everytihng lines up
            delayHighTimes = []; delayHighYTimes = [];
            delayHighTimes = delayTimes(idxHigh);
            delayHighYTimes = delayTimes(idxYokedHigh);

            delayLowTimes = []; delayLowYTimes = [];
            delayLowTimes = delayTimes(idxLow);
            delayLowYTimes = delayTimes(idxYokedLow);
            delayNorm = delayTimes(idxNorm);

            % do the same 
            % remove any delay times that don't have an equally matched partner
            % we're checking for equal delay High Times using the yoked
            % condition because there can only be a yoked trial if there is a
            % high trial
            % however, it is possible that some trials could get removed. So we
            % need to account for those too.
            idxRemHigh = [];
            for j = 1:length(delayHighYTimes)
                findYinHigh = find(delayHighTimes == delayHighYTimes(j));
                if isempty(findYinHigh)==1
                    idxRemHigh(j) = 1;
                else
                    idxRemHigh(j) = 0;
                end
            end       
            idxRemLow = [];
            for j = 1:length(delayLowYTimes)
                findYinLow = find(delayLowTimes == delayLowYTimes(j));
                if isempty(findYinLow)==1
                    idxRemLow(j) = 1;
                else
                    idxRemLow(j) = 0;
                end
            end   

            % idxRemLow: if yoked time isn't found in experimental, remove the
            % yoked time
            % removal of the top two are mostly to check my work
            delayLowYTimes(logical(idxRemLow))=[];
            delayHighYTimes(logical(idxRemHigh))=[];
            % remove from the index used above to get times
            idxYokedHigh(logical(idxRemHigh))=[];
            idxYokedLow(logical(idxRemLow))=[];

            %----------------------------------------%

            % do everything above, except switch variables
            idxRemHigh = [];
            for j = 1:length(delayHighTimes)
                findHighInY = find(delayHighYTimes == delayHighTimes(j));
                if isempty(findHighInY)==1
                    idxRemHigh(j) = 1;
                else
                    idxRemHigh(j) = 0;
                end
            end       
            idxRemLow = [];
            for j = 1:length(delayLowTimes)
                findLowInY = find(delayLowYTimes == delayLowTimes(j));
                if isempty(findLowInY)==1
                    idxRemLow(j) = 1;
                else
                    idxRemLow(j) = 0;
                end
            end   

            % idxRemLow: if yoked time isn't found in experimental, remove the
            % yoked time
            delayLowTimes(logical(idxRemLow))=[];
            delayHighTimes(logical(idxRemHigh))=[];
            % remove from the index used above to get times
            idxHigh(logical(idxRemHigh))=[];
            idxLow(logical(idxRemLow))=[];   
            
            % get lfp data
            load(['X:\01.Experiments\R21\' rats{i} '\baseline\baselineData'],'LFP1name','LFP2name')
            lfpHPC        = getLFPdata(datafolder,LFP1name,'Events');
            [lfpPFC,lfpT] = getLFPdata(datafolder,LFP2name,'Events');

            % get LFP on all trials - we have to get 3 second around because I
            % didn't perform real-time lfp extraction on control trials to save
            % memory and hopefully improve computation
            % we're
            lfpPfcTrials = []; lfpHpcTrials = [];
            for triali = 1:size(sequenceTable,1)
                idxLFP = [];
                idxLFP = (dsearchn(lfpT',sequenceTable.DelayExit(triali))-(2000*5)):(dsearchn(lfpT',sequenceTable.DelayExit(triali))+(2000*5));
                
                lfpPfcTrials{triali} = lfpPFC(idxLFP);
                lfpHpcTrials{triali} = lfpHPC(idxLFP);
            end
            
            clear coh cohMat
            movingwin = [1.25 .25];
            srate = 2000;
            for triali = 1:size(sequenceTable,1)        
                cohMat{triali} = mscohere_movingWin(lfpPfcTrials{triali},lfpHpcTrials{triali},movingwin,srate);
            end
            timeAxis = linspace(-5,5,32);
                 
            % separate trials
            coh_high{sessi}  = cohMat(idxHigh);
            coh_low{sessi}   = cohMat(idxLow);
            coh_yHigh{sessi} = cohMat(idxYokedHigh);
            coh_yLow{sessi}  = cohMat(idxYokedLow);   
            coh_Norm{sessi}  = cohMat(idxNorm);        

            % feedback
            disp(['Completed with ',rats{i},' session ',num2str(sessi)])
        end
         
    end
    
    % concatenate
    coh_high_cat{i}  = nanmean(cellTo3D(horzcat(coh_high{:})),3);
    coh_low_cat{i}   = nanmean(cellTo3D(horzcat(coh_low{:})),3);
    coh_highY_cat{i} = nanmean(cellTo3D(horzcat(coh_yHigh{:})),3);
    coh_lowY_cat{i}  = nanmean(cellTo3D(horzcat(coh_yLow{:})),3);
    coh_norm_cat{i}  = nanmean(cellTo3D(horzcat(coh_Norm{:})),3);
    
    disp(['Completed with ',rats{i}])
end

% average across rats
coh_high_rat  = nanmean(cellTo3D((coh_high_cat)),3);
coh_low_rat   = nanmean(cellTo3D((coh_low_cat)),3);
coh_highY_rat = nanmean(cellTo3D((coh_highY_cat)),3);
coh_lowY_rat  = nanmean(cellTo3D((coh_lowY_cat)),3);
coh_norm_rat  = nanmean(cellTo3D((coh_norm_cat)),3);

% save data
place2store = getCurrentPath;
cd(place2store)
save('data_coherogram','coh_high_rat','coh_low_rat','coh_highY_rat','coh_lowY_rat');

f = [1:.5:20];
figure('color','w'); 
    subplot 121;
        pcolor(timeAxis,f,coh_high_rat); shading interp
        title('High coherence')
        ylabel('Frequency')
        %colorbar
        axisScaleHigh = caxis;
        ylimits = ylim;
        colorbar
        
    subplot 122;
        pcolor(timeAxis,f,coh_highY_rat); shading interp
        title('High yoked')
        caxis([0 .7])
        caxis(axisScaleHigh)
        colorbar
        
figure('color','w'); 
    subplot 121;
        pcolor(timeAxis,f,coh_low_rat); shading interp
        title('Low coherence')
        axisScaleLow = caxis;
        colorbar
        
    subplot 122;
        pcolor(timeAxis,f,coh_lowY_rat); shading interp
        title('Low yoked')
        xlabel('Time(s) around trial onset')
        caxis(axisScaleLow)
        colorbar
        
        
    subplot 133;
        pcolor(timeAxis,f,coh_norm_rat); shading interp  
        title('Random delay')
        caxis([0 .7])
