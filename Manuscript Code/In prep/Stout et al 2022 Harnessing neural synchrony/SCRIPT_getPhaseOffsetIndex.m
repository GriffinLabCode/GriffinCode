%% percent accuracy on DA so far
clear; close all;
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

rtLFP_high = []; rtLFP_low = []; coh_yHigh = []; coh_yLow = []; coh_Norm = [];

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
    rtLFP_high = []; rtLFP_low = [];
    for sessi = 1:length(dir_content)
        
            clear lfp_pf_cp lfp_hc_cp lfp_pfc lfp_hpc lfp_ts Int

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
            dataIN = load(dataINfolder{1},'accuracy','delayLenTrial','indicatorOUT','trajectory_text','percentAccurate','dataStored');
            try remData = load('removeTrajectories');
            catch remData = [];
            end

            % eliminate trials
            % remove any trials after length of trials
            numTrials = length(dataIN.accuracy);
            dataIN.indicatorOUT(numTrials+1:end)=[];
            dataIN.delayLenTrial(numTrials+1:end)=[];

            % remove choices
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
            % real time LFP
            rtLFP = [];
            rtLFP = dataIN.dataStored;
            
            % there are possibilities where rtLFP doesnt match in size with
            % accuracy. This is bc a trial may end on a "norm" or other
            % control where data isnt collected
            if numel(rtLFP) ~= numel(accuracy) && numel(rtLFP) < numel(accuracy)
                if contains(tempInd(end),[{'Norm'} {'yokeL_MET'} {'yokeH_MET'}])
                    while numel(rtLFP)~=numel(tempInd)
                        rtLFP{end+1} = [];
                    end
                end
            % there was a weird instance where this happened. everything
            % lined up though so its okay
            elseif numel(rtLFP) ~= numel(accuracy) && numel(rtLFP) > numel(accuracy)
                while numel(rtLFP)~=numel(tempInd)
                    rtLFP(end) = [];
                end
            end
                
            % remove
            tempInd(remChoices)    = [];
            delayTimes(remChoices) = [];
            accuracy(remChoices)   = [];
            rtLFP(remChoices)      = [];

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
   
            % separate trials
            rtLFP_high{sessi}  = rtLFP(idxHigh);
            rtLFP_low{sessi}   = rtLFP(idxLow);
            
            % feedback
            disp(['Completed with ',rats{i},' session ',num2str(sessi)])
        end

    rtLFP_high_cat{i}  = horzcat(rtLFP_high{:});
    rtLFP_low_cat{i}   = horzcat(rtLFP_low{:});
    
    disp(['Completed with ',rats{i}])
end

% now sort through data to get the final trials data
rtLFP_high_end = [];
for i = 1:length(rtLFP_high_cat)
    for ii = 1:length(rtLFP_high_cat{i})
        rtLFP_high_end{i}(ii) = rtLFP_high_cat{i}{ii}(end);
    end
end
rtLFP_low_end = [];
for i = 1:length(rtLFP_low_cat)
    for ii = 1:length(rtLFP_low_cat{i})
        rtLFP_low_end{i}(ii) = rtLFP_low_cat{i}{ii}(end);
    end
end


% --- temporary pause ---- %
% time to inspect data
%{
% completed on 4/28/22 at 9pm. Removed any trial with large freq artifact
for i = 1:length(rtLFP_high_end)
    for ii = 1:length(rtLFP_high_end{i})
        figure('color','w')
        subplot 211;
        plot(rtLFP_high_end{i}{ii}(1,:))
        subplot 212;
        plot(rtLFP_high_end{i}{ii}(2,:))
        answer = input('Remove? ','s');
        if contains(answer,'y')
            tagTrialHigh{i}(ii) = 1;
        else
            tagTrialHigh{i}(ii) = 0;
        end
        close;
    end
end
place2store = getCurrentPath();
cd(place2store)
save('taggedHighRemove','tagTrialHigh')
%}
%{
tagTrialLow = [];
for i = 1:length(rtLFP_low_end)
    for ii = 1:length(rtLFP_low_end{i})
        figure('color','w')
        subplot 211;
        plot(detrend(rtLFP_low_end{i}{ii}(1,:),3))
        subplot 212;
        plot(detrend(rtLFP_low_end{i}{ii}(2,:),3))
        answer = input('Remove? ','s');
        if contains(answer,'y')
            tagTrialLow{i}(ii) = 1;
        else
            tagTrialLow{i}(ii) = 0;
        end
        close;
    end
end
place2store = getCurrentPath();
cd(place2store)
save('taggedLowRemove','tagTrialLow')
%}
% --- continue --- %
place2store = getCurrentPath;
cd(place2store);
load('taggedHighRemove')
load('taggedLowRemove')

% use the cleaned data though
for i = 1:length(rtLFP_high_end)
    rtLFP_high_end{i}(tagTrialHigh{i} == 1)=[];
    rtLFP_low_end{i}(tagTrialLow{i} == 1)=[];
end

% detrend data
for i = 1:length(rtLFP_high_end)
    for ii = 1:length(rtLFP_high_end{i})
        rtLFP_high_det{i}{ii}(1,:) = detrend(rtLFP_high_end{i}{ii}(1,:),3);
        rtLFP_high_det{i}{ii}(2,:) = detrend(rtLFP_high_end{i}{ii}(2,:),3);
    end
end
for i = 1:length(rtLFP_low_end)
    for ii = 1:length(rtLFP_low_end{i})
        rtLFP_low_det{i}{ii}(1,:) = detrend(rtLFP_low_end{i}{ii}(1,:),3);
        rtLFP_low_det{i}{ii}(2,:) = detrend(rtLFP_low_end{i}{ii}(2,:),3);
    end
end

% get phase coherence
phaseCohHigh = []; phaseCohLow = [];
freqs = [6:11];
for i = 1:length(rtLFP_high_det)
    for ii = 1:length(rtLFP_high_det{i})
        for fi = 1:length(freqs)
            phaseCohHigh{i}{ii}(fi) = PhaseCoherence(freqs(fi),rtLFP_high_det{i}{ii},2000);
        end
    end
end



for i = 1:length(rtLFP_low_det)
    for ii = 1:length(rtLFP_low_det{i})
        for fi = 1:length(freqs)
            phaseCohLow{i}{ii}(fi) = PhaseCoherence(freqs(fi),rtLFP_low_det{i}{ii},2000);
        end
    end
end

% now lets take a look at this data

% first off, phase synchrony should be stronger on high coh than low coh
% trials
for i = 1:length(phaseCohHigh)
    phaseCohRatHigh{i}=vertcat(phaseCohHigh{i}{:});
    phaseCohRatLow{i}=vertcat(phaseCohLow{i}{:});
end

% average within rats
phaseCohRatHigh_avg = cellfun2(phaseCohRatHigh,'nanmean',{'1'});
phaseCohRatLow_avg  = cellfun2(phaseCohRatLow,'nanmean',{'1'});

phaseCohMatHigh = vertcat(phaseCohRatHigh_avg{:});
phaseCohMatLow  = vertcat(phaseCohRatLow_avg{:});

% figure
figure('color','w'); hold on;
shadedErrorBar(freqs,mean(phaseCohMatHigh,1),stderr(phaseCohMatHigh,1),'k',0);
shadedErrorBar(freqs,mean(phaseCohMatLow,1),stderr(phaseCohMatLow,1),'r',0);
axis tight;

% collapse signals
freqs = [1:20];
clear lfpColHigh phaseCohHigh
for i = 1:length(rtLFP_high_det)
    % collapse data
    lfpColHigh{i} = horzcat(rtLFP_high_det{i}{:});
    % phase coh
    for fi = 1:length(freqs)
        phaseCohHigh{i}(fi) = PhaseCoherence(freqs(fi),lfpColHigh{i},2000);
    end
end
clear lfpColLow phaseCohLow
for i = 1:length(rtLFP_low_det)
    % collapse data
    lfpColLow{i} = horzcat(rtLFP_low_det{i}{:});
    % phase coh
    for fi = 1:length(freqs)
        phaseCohLow{i}(fi) = PhaseCoherence(freqs(fi),lfpColLow{i},2000);
    end
end

% sort data
phaseCohHighMat = vertcat(phaseCohHigh{:});
phaseCohLowMat = vertcat(phaseCohLow{:});

% normalize to account for variability in sample size
phaseNormHigh = []; phaseNormLow = [];
for i = 1:length(phaseCohHigh)
    phaseNormHigh(i,:) = normalize(phaseCohHigh{i},'range');
    phaseNormLow(i,:)  = normalize(phaseCohLow{i},'range');
end

% smooth data
phaseNormHighS = []; phaseNormLowS = [];
for i = 1:length(phaseCohHigh)
    phaseNormHighS(i,:) = smoothdata(phaseNormHigh(i,:),'gaussian',2);
    phaseNormLowS(i,:)  = smoothdata(phaseNormLow(i,:),'gaussian',2);
end

figure('color','w'); hold on;
shadedErrorBar(freqs,mean(phaseCohHighMat,1),stderr(phaseCohHighMat,1),'k',0);
shadedErrorBar(freqs,mean(phaseCohLowMat,1),stderr(phaseCohLowMat,1),'r',0);
ylabel('Phase Coherence')
xlabel('Frequency')
axis tight

% between the 6-11Hz range is what we're interested in
idxTheta = find(freqs == 7);
phaseCohMatHigh_theta = mean(phaseCohHighMat(:,idxTheta),2);
phaseCohMatLow_theta  = mean(phaseCohLowMat(:,idxTheta),2);
figure('color','w')
multiBarPlot(horzcat(phaseCohMatHigh_theta,phaseCohMatLow_theta),[{'HighCoh'},{'LowCoh'}],'Phase Coherence','n');
[h,p]=ttest(phaseCohMatHigh_theta,phaseCohMatLow_theta)


% between the 6-11Hz range is what we're interested in
idxTheta = find(freqs == 7);
phaseCohMatHigh_theta = mean(phaseCohMatHigh(:,idxTheta),2);
phaseCohMatLow_theta  = mean(phaseCohMatLow(:,idxTheta),2);

% bar graph
figure('color','w')
multiBarPlot(horzcat(phaseCohMatHigh_theta,phaseCohMatLow_theta),[{'HighCoh'},{'LowCoh'}],'Phase Coherence','n');
[h,p]=ttest(phaseCohMatHigh_theta,phaseCohMatLow_theta)

