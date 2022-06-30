%% percent accuracy on DA so far
clear;

% define rat IDs
rats{1} = '21-12';
rats{2} = '21-13';
rats{3} = '21-14';
rats{4} = '21-33';
rats{5} = '21-15';
rats{6} = '21-16';
rats{7} = '21-21';
rats{8} = '21-37';

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
        
        %dataIN = [];
        dataIN{i}{sessi} = load(dataINfolder{1},'accuracy','delayLenTrial','indicatorOUT','trajectory_text','percentAccurate');
        try remData{i}{sessi} = load('removeTrajectories');
        catch remData{i}{sessi} = [];
        end
        cohData{i}{sessi} = load(dataINfolder{1},'cohOUT');
        
        % feedback
        disp(['Completed with ',rats{i},' session ',num2str(sessi)])
         
    end
    
    disp(['Completed with ',rats{i}])
end

% we're tapping into learning. If rats breach 80% for two consecutive days,
% only include data before day 1 crit.
for i = 1:length(dataIN)
    for ii = 1:length(dataIN{i})
        % get perc acc
        percAcc{i}{ii} = dataIN{i}{ii}.percentAccurate;
    end
end

for i = 1:length(dataIN)
    for ii = 1:length(dataIN{i})
        % remove any trials after length of trials
        numTrials = length(dataIN{i}{ii}.accuracy);
        dataIN{i}{ii}.indicatorOUT(numTrials+1:end)=[];
        dataIN{i}{ii}.delayLenTrial(numTrials+1:end)=[];
        
        % remove any trials that had behaviors that would interfere with
        % our manipulation - this decision is made while we are blinded to
        % trial conditions
        
        remChoices = [];
        try
            remChoices = remData{i}{ii}.remTraj-1;                  
        catch
        end
        
        % indicatorOUT temp
        tempInd = [];
        tempInd = dataIN{i}{ii}.indicatorOUT;
        % delay times 
        delayTimes = [];
        delayTimes = dataIN{i}{ii}.delayLenTrial;
        % trial accuracies
        accuracy  = []; 
        accuracy  = dataIN{i}{ii}.accuracy;        
        
        % remove
        tempInd(remChoices)={'NaN'};
        delayTimes(remChoices)=NaN;
        accuracy(remChoices) =NaN;
                       
        % get indices
        idxHigh = []; idxLow = []; idxYokedHigh = []; idxYokedLow = [];
        idxHigh = find(contains(tempInd,'highMET')==1);
        idxLow = find(contains(tempInd,'lowMET')==1);
        idxYokedHigh = find(contains(tempInd,'yokeH_MET')==1);
        idxYokedLow = find(contains(tempInd,'yokeL_MET')==1);
        %idxNorm = find(contains(tempInd,[{'Norm'}, {'NormHighFail'} {'NormLowFail'}]));
        idxNorm = find(contains(tempInd,[{'Norm'}]));
        
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
        
        %----%
        highTime{i}{ii}  = delayHighTimes;
        lowTime{i}{ii}   = delayLowTimes;
        lowYTime{i}{ii}  = delayLowYTimes;
        highYTime{i}{ii} = delayHighYTimes;        
        NormTime{i}{ii}  = delayNorm;
        
        % get choice accuracies
        acc_high{i}{ii}  = accuracy(idxHigh);
        acc_low{i}{ii}   = accuracy(idxLow);
        acc_yHigh{i}{ii} = accuracy(idxYokedHigh);
        acc_yLow{i}{ii}  = accuracy(idxYokedLow);   
        acc_Norm{i}{ii}  = accuracy(idxNorm);
                
        % percent accurate
        %perc_high{i}(ii) = (numel(find(acc_high == 0))/numel(acc_high))*100;
        %perc_low{i}(ii)  = (numel(find(acc_low == 0))/numel(acc_low))*100;
        %perc_Yhigh{i}(ii) = (numel(find(acc_yHigh == 0))/numel(acc_yHigh))*100;
        %perc_Ylow{i}(ii)  = (numel(find(acc_yLow == 0))/numel(acc_yLow))*100;
        %perc_norm{i}(ii)  = (numel(find(acc_Norm == 0))/numel(acc_Norm))*100;
        
        % diff score
        %diffHigh{i}(ii) = (perc_high{i}(ii)-perc_Yhigh{i}(ii))./(perc_high{i}(ii)+perc_Yhigh{i}(ii));
        %diffLow{i}(ii)  = (perc_low{i}(ii)-perc_Ylow{i}(ii))./(perc_low{i}(ii)+perc_Ylow{i}(ii));
        
        % get coherence data
        coh = []; temp_cohHigh = []; temp_cohHigh = [];
        temp_cohLow = []; temp_cohHighY = []; temp_cohLowY = [];
        temp_norm = [];
        coh = cell([1 length(dataIN{i}{ii}.accuracy)]);
        coh(1:length(cohData{i}{ii}.cohOUT))=cohData{i}{ii}.cohOUT;
        % not every trial does coherence detection
        if contains(dataIN{i}{ii}.indicatorOUT(end),'Norm')
            coh{end+1}=[];
        end
        %coh(remChoices)=[];
       %idxCancel = find(remChoices > length(coh));
        %remChoices(idxCancel)=[];
        coh(remChoices) ={'NaN'};
        temp_cohHigh  = coh(idxHigh);
        temp_cohLow   = coh(idxLow); 
        %temp_cohHighY = coh(idxYokedHigh);
        %temp_cohLowY  = coh(idxYokedLow);
        %temp_norm     = coh(idxNorm);
        
        % get the final coherence data
        for m = 1:length(temp_cohHigh)
            cohHigh{i}{ii}(m,:) = temp_cohHigh{m}{end};
            %cohLow{i}{ii}  = temp_cohLow{m}{end};
        end
        for m = 1:length(temp_cohLow)
            %cohHigh{i}{ii} = temp_cohHigh{m}{end};
            cohLow{i}{ii}(m,:)  = temp_cohLow{m}{end};
        end        
        
    end
end

%% 
% collapse data across rats so that trials with like 3 trials aren't
% treated the same as trials with 9. For example, say on session 1, a rat
% gets 0/3 correct. But on session 2, he gets 9/9 correct. Averaging
% between sessions = 50%. Collapse->average = 66.9%
for i = 1:length(acc_high)
    cat_highAll{i} = horzcat(acc_high{i}{:});
    cat_lowAll{i} = horzcat(acc_low{i}{:});
    cat_highYAll{i} = horzcat(acc_yHigh{i}{:});
    cat_lowYAll{i} = horzcat(acc_yLow{i}{:});
    cat_normAll{i} = horzcat(acc_Norm{i}{:});   
end

for i = 1:length(acc_Norm)
    for ii = 1:length(acc_Norm{i})
        % concatenate all control trials
        contTrials{i}{ii} = [acc_yHigh{i}{ii} acc_yLow{i}{ii} acc_Norm{i}{ii}];
        accNormSess{i}(ii) = (numel(find(contTrials{i}{ii}==0))/(numel(contTrials{i}{ii})))*100;
    end
end

for i = 1:length(cat_highAll)
    ratHigh(i)  = ((numel(find(cat_highAll{i}==0)))/(numel(cat_highAll{i})))*100;
    ratHighY(i) = ((numel(find(cat_highYAll{i}==0)))/(numel(cat_highYAll{i})))*100;
    ratLow(i)   = ((numel(find(cat_lowAll{i}==0)))/(numel(cat_lowAll{i})))*100;
    ratLowY(i)  = ((numel(find(cat_lowYAll{i}==0)))/(numel(cat_lowYAll{i})))*100; 
    ratNorm(i)  = ((numel(find(cat_normAll{i}==0)))/(numel(cat_normAll{i})))*100; 
end
%{
data = []; xlabels = [];
data{1} = ratHigh; data{2} = ratHighY; data{3} = ratLow; data{4} = ratLowY; data{5} = ratNorm;
xlabels{1} = 'High'; xlabels{2} = 'Yoked H'; xlabels{3} = 'Low'; xlabels{4} = 'Yoked L'; xlabels{5} = 'Rand. Delay';
multiBarPlot(data,xlabels,'% Accuracy','n')
ylim([50 100]);
title(['N = ',num2str(length(rats)),' rats']);
[h,p,ci,stat]=ttest(ratHigh,ratHighY)
%}

data = []; xlabels = [];
data{1} = ratHigh; data{2} = ratHighY; data{3} = ratLow; data{4} = ratLowY;
xlabels{1} = 'High'; xlabels{2} = 'Yoked H'; xlabels{3} = 'Low'; xlabels{4} = 'Yoked L';
multiBarPlot(data,xlabels,'% Accuracy','n')
ylim([50 100]);
title(['N = ',num2str(length(rats)),' rats']);
[h,p,ci,stat]=ttest(ratHigh,ratHighY)
p*2

[h,p,ci,stat]=ttest(ratLow,ratLowY)
p*2

% -- time -- %
for i = 1:length(lowTime)
    for ii =1:length(lowTime{i})
        lowTime{i}{ii}    = change_row_to_column(lowTime{i}{ii});
        highTime{i}{ii}   = change_row_to_column(highTime{i}{ii});
        lowYTime{i}{ii}   = change_row_to_column(lowYTime{i}{ii});
        highYTime{i}{ii}  = change_row_to_column(highYTime{i}{ii});
        NormTime{i}{ii}   = change_row_to_column(NormTime{i}{ii});
    end
end
timeLow = []; timeHigh = []; timeHighY = []; timeLowY = []; timeNorm =[];
for i = 1:length(lowTime)
    timeLow{i}   = vertcat(lowTime{i}{:});
    timeHigh{i}  = vertcat(highTime{i}{:});
    timeHighY{i} = vertcat(highYTime{i}{:});
    timeLowY{i}  = vertcat(lowYTime{i}{:});
    timeNorm{i}  = vertcat(NormTime{i}{:});
end
timeLow   = cellfun(@nanmean,timeLow);
timeHigh  = cellfun(@nanmean,timeHigh);
timeLowY  = cellfun(@nanmean,timeLowY);
timeHighY = cellfun(@nanmean,timeHighY);
timeNorm  = cellfun(@nanmean,timeNorm);

data = []; xlabels = [];
data{1} = timeHigh; data{2} = timeHighY; data{3} = timeLow; data{4} = timeLowY; data{5} = timeNorm;
xlabels{1} = 'High'; xlabels{2} = 'Yoked H'; xlabels{3} = 'Low'; xlabels{4} = 'Yoked L'; xlabels{5} = 'Rand. Delay';
multiBarPlot(data,xlabels,'Delay Time(s)')
ylim([0 30]);
title(['N = ',num2str(length(rats)),' rats']);

data = []; xlabels = [];
data{1} = timeHigh; data{2} = timeLow;
xlabels{1} = 'High'; xlabels{2} = 'Low';
multiBarPlot(data,xlabels,'Delay Time(s)','n')
ylim([0 30]);
title(['N = ',num2str(length(rats)),' rats']);
[h,p]=ttest(timeHigh,timeLow)

%% number of trials included and number of sessions
for i = 1:length(acc_high)
    sessN(i) = length(acc_high{i});    
    trialN_high(i) = length(horzcat(acc_high{i}{:}));
    trialN_low(i)  = length(horzcat(acc_low{i}{:}));
end

figure('color','w');
for i = 1:length(sessN)
    subplot(1,length(cohHigh),i)
    if i == 1
        ylabel('Number of ...')
    end
    hold on;
    b = bar([1,2,3],[sessN(i) trialN_high(i) trialN_low(i)]);
    b.Parent.XTickLabel = [{'Sessions'} {'High Trials'} {'Low Trials'}];
    b.Parent.XTickLabelRotation = 45;
    b.Parent.XTick = [1 2 3];
    %bar(2,trialN_high(i));
    %bar(3,trialN_low(i));
    ylim([0 22]);
    title(rats{i})
    
end

%% coherence
f = [1:.5:20];
cohHighAll = horzcat(cohHigh{:});
cohLowAll  = horzcat(cohLow{:});

cohHighMat = vertcat(cohHighAll{:});
cohLowMat  = vertcat(cohLowAll{:});

cohHighAvg = nanmean(cohHighMat,1);
cohLowAvg  = nanmean(cohLowMat,1);
cohHighSEM = stderr(cohHighMat,1);
cohLowSEM  = stderr(cohLowMat,1);

f = [1:.5:20];
figure('color','w'); hold on;
s1 = shadedErrorBar(f,cohHighAvg,cohHighSEM,'b',0);
s2 = shadedErrorBar(f,cohLowAvg,cohLowSEM,'r',0);
xlabel('Frequency (Hz)')
ylabel('Coherence')
legend([s1.mainLine s2.mainLine],'High','Low')
box off
title('preliminary results collapsed across trials')

%% per rat
f = [1:.5:20];
for i = 1:length(cohHigh)
    cohHighRat{i} = vertcat(cohHigh{i}{:});
    cohLowRat{i}  = vertcat(cohLow{i}{:});
end

figure('color','w'); hold on;
f = [1:.5:20];
for i = 1:length(cohHigh)
    subplot(1,length(cohHigh),i)
    hold on;
    cohHighAvg = nanmean(cohHighRat{i},1);
    cohLowAvg  = nanmean(cohLowRat{i},1);
    cohHighSEM = stderr(cohHighRat{i},1);
    cohLowSEM  = stderr(cohLowRat{i},1);

    try
        s1 = shadedErrorBar(f,cohHighAvg,cohHighSEM,'b',0);
        s2 = shadedErrorBar(f,cohLowAvg,cohLowSEM,'r',0);
        xlabel('Frequency (Hz)')
        ylabel('Coherence')
        %legend([s1.mainLine s2.mainLine],'High','Low')
        box off
        ylim([0 1])
    catch
    end
        title(rats{i})
end

%% filter data according to checked LFP
place2store = getCurrentPath;
cd(place2store)
load('taggedHighRemove')
load('taggedLowRemove')

cat_highAllOG  = cat_highAll;
cat_highAllYOG = cat_highYAll;
cat_lowAllOG   = cat_lowAll;
cat_lowAllYOG  = cat_lowYAll;
for i = 1:length(cat_highAll)
    cat_highAll{i}(tagTrialHigh{i}==1)=[];
    cat_highYAll{i}(tagTrialHigh{i}==1)=[];
    cat_lowAll{i}(tagTrialLow{i}==1)=[];
    cat_lowYAll{i}(tagTrialLow{i}==1)=[];    
end

ratHighFiltered = []; catHighYFiltered = [];
for i = 1:length(cat_highAll)
    ratHighFiltered(i)  = ((numel(find(cat_highAll{i}==0)))/(numel(cat_highAll{i})))*100;
    ratHighYFiltered(i) = ((numel(find(cat_highYAll{i}==0)))/(numel(cat_highYAll{i})))*100;
    ratLowFiltered(i)  = ((numel(find(cat_lowAll{i}==0)))/(numel(cat_lowAll{i})))*100;
    ratLowYFiltered(i) = ((numel(find(cat_lowYAll{i}==0)))/(numel(cat_lowYAll{i})))*100;    
end
[h,p,ci,stat]=ttest(ratHighFiltered,ratHighYFiltered)
p=p*2
[h,p,ci,stat]=ttest(ratLowFiltered,ratLowYFiltered)
p=p*2
multiBarPlot([ratHighFiltered' ratHighYFiltered' ratLowFiltered' ratLowYFiltered'],[{'High'} {'High Control'} {'Low'} {'Low Control'}],'% Accurate');

