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

% power analysis
params = getCustomParams;
params.Fs = 2000;
params.pad = 0;
params.fpass = [6:0.1:11];

for i = 1:length(rtLFP_high_det)
    for ii = 1:length(rtLFP_high_det{i})
       C_high{i}(ii) = nanmean(coherencyc(rtLFP_high_det{i}{ii}(1,:),rtLFP_high_det{i}{ii}(2,:),params));
    end
end
for i = 1:length(rtLFP_low_det)
    for ii = 1:length(rtLFP_low_det{i})
       C_low{i}(ii) = nanmean(coherencyc(rtLFP_low_det{i}{ii}(1,:),rtLFP_low_det{i}{ii}(2,:),params));
    end
end

% chronux doesnt really matter, although it does seem to indicate that low
% coherence was higher than expected when compared to mscohere this is
% because params.tapers parameters can be subjectively manipulated, which
% is why I stayed away from them
C_high_rat = cellfun(@nanmean,C_high);
C_low_rat = cellfun(@nanmean,C_low);
[h,p]=ttest(C_high_rat,C_low_rat)

% doesnt matter whether I used matlabs or chronux's power functions
hpcHigh = []; pfcHigh = [];
params.fpass = linspace(4,12,100);
params.tapers = [2 3];

bestFreq_hpcHigh = [];
bestFreq_pfcHigh = [];
for i = 1:length(rtLFP_high_det)
    for ii = 1:length(rtLFP_high_det{i})
        % power
        tempHpc = []; tempPfc = [];
        tempHpcSmooth=[]; tempPfcSmooth=[];        
        [tempHpc,f] = mtspectrumc(rtLFP_high_det{i}{ii}(1,:),params);
        % smooth data
        tempHpcSmooth=smoothdata(tempHpc,'gaussian');
        %figure; plot(f,tempHpcSmooth)
        %hold on; plot(f,tempHpc,'r')
        bestFreq_hpcHigh{i}(ii) = get_bestFrequency(tempHpcSmooth,f,[4 12]);

        tempPfc = mtspectrumc(rtLFP_high_det{i}{ii}(2,:),params);
        tempPfcSmooth=smoothdata(tempPfc,'gaussian');    
        bestFreq_pfcHigh{i}(ii) = get_bestFrequency(tempPfcSmooth,f,[4 12]);
        
    end
end

bestFreq_hpcLow = [];
bestFreq_pfcLow = [];
for i = 1:length(rtLFP_low_det)
    for ii = 1:length(rtLFP_low_det{i})
        % power
        tempHpc = []; tempPfc = [];
        tempHpcSmooth=[]; tempPfcSmooth=[];                
        [tempHpc,f] = mtspectrumc(rtLFP_low_det{i}{ii}(1,:),params);
        % smooth data
        tempHpcSmooth=smoothdata(tempHpc,'gaussian');
        %figure; plot(f,tempHpcSmooth)
        %hold on; plot(f,tempHpc,'r')
        bestFreq_hpcLow{i}(ii) = get_bestFrequency(tempHpcSmooth,f,[4 12]);

        tempPfc = mtspectrumc(rtLFP_low_det{i}{ii}(2,:),params);
        tempPfcSmooth=smoothdata(tempPfc,'gaussian');    
        bestFreq_pfcLow{i}(ii) = get_bestFrequency(tempPfcSmooth,f,[4 12]);

    end
end

% cellfun
hpcHigh_avg = cellfun(@nanmean,bestFreq_hpcHigh);
hpcLow_avg = cellfun(@nanmean,bestFreq_hpcLow);
pfcHigh_avg = cellfun(@nanmean,bestFreq_pfcHigh);
pfcLow_avg = cellfun(@nanmean,bestFreq_pfcLow);

normDiffHpc = (hpcHigh_avg-hpcLow_avg)./(hpcHigh_avg+hpcLow_avg);
normDiffPfc = (pfcHigh_avg-pfcLow_avg)./(pfcHigh_avg+pfcLow_avg);

mat = [];
mat = horzcat(normDiffHpc',normDiffPfc');
multiBarPlot(mat,[{'HPC'} {'PFC'}],'Max Theta Freq. (high-low)')
ylim([-0.025 0.1])
[h,p,ci,stat]=ttest(mat(:,1)); p=p*3;
[h,p,ci,stat]=ttest(mat(:,2)); p=p*3;
[h,p,ci,stat]=ttest(mat(:,1),mat(:,2)); p=p*3;
