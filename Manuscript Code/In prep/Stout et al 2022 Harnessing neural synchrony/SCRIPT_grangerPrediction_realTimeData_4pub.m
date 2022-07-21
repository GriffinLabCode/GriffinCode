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

% plot some figs
figure('color','w'); 
subplot 211;
plot(rtLFP_high_det{6}{1}(1,:),'b'); 
box off; axis off;
set(gca, 'XTick', []);
set(gca, 'YTick', []);
xlim([0 2000])

subplot 212;
plot(rtLFP_high_det{6}{1}(2,:),'b'); 
box off; %axis off;
%set(gca, 'XTick', []);
set(gca, 'YTick', []);
xlim([0 2000])
[c,f] = mscohere(rtLFP_high_det{6}{2}(1,:),rtLFP_high_det{6}{2}(2,:),[],[],[0.1:.5:20],2000);
idx = find(f > 6 & f < 11);
nanmean(c(idx));

figure('color','w'); 
subplot 211;
plot(rtLFP_low_det{6}{2}(1,:),'r'); 
box off; axis off;
set(gca, 'XTick', []);
set(gca, 'YTick', []);
xlim([0 2000])

subplot 212;
plot(rtLFP_low_det{6}{2}(2,:),'r'); 
box off; %axis off;
%set(gca, 'XTick', []);
set(gca, 'YTick', []);
xlim([0 2000])
[c,f] = mscohere(rtLFP_low_det{6}{2}(1,:),rtLFP_low_det{6}{2}(2,:),[],[],[0.1:.5:20],2000);
idx = find(f > 6 & f < 11);
nanmean(c(idx));
% consider trials as independent - advantageous especially given that the
% data were controlled for in the time domain
%{
srate        = 2000;
orderRuns    = 20;
clear optimalorder
rtLFP_det = horzcat(rtLFP_low_det,rtLFP_high_det);
for i = 1:length(rtLFP_det)
    for ii = 1:length(rtLFP_det{i})
        [optimalorder{i}(ii),~] = bic_optimalorder(rtLFP_det{i}{ii}(1,:),rtLFP_det{i}{ii}(2,:),srate,orderRuns);
    end
end
orders = horzcat(optimalorder{:});
order_time = orders*(1000/2034);
% set model order
moAvg = round(nanmean(orders));
%}
moAvg = 8; % determined on 4-28-22
srate = 2000;
gcPFC2HPC_high = []; gcHPC2PFC_high = [];
for i = 1:length(rtLFP_high_det)
    for ii = 1:length(rtLFP_high_det{i})
        [gcPFC2HPC_high{i}{ii}, gcHPC2PFC_high{i}{ii}, frequencies] = GCspectral(rtLFP_high_det{i}{ii}(1,:),rtLFP_high_det{i}{ii}(2,:), moAvg, srate);
    end
    disp(['Finished with rat # ',num2str(i), ' high data'])
end
gcPFC2HPC_low = []; gcHPC2PFC_low = [];
for i = 1:length(rtLFP_low_det)
    for ii = 1:length(rtLFP_low_det{i})
        [gcPFC2HPC_low{i}{ii}, gcHPC2PFC_low{i}{ii}, frequencies] = GCspectral(rtLFP_low_det{i}{ii}(1,:),rtLFP_low_det{i}{ii}(2,:), moAvg, srate);
    end
    disp(['Finished with rat # ',num2str(i), ' low data'])
end

% make freq x gp
gcP2Hhigh_rf1 = []; gcH2Phigh_rf1 = [];
for i = 1:length(gcPFC2HPC_high)
    gcP2Hhigh_rf1{i} = vertcat(gcPFC2HPC_high{i}{:});
    gcH2Phigh_rf1{i} = vertcat(gcHPC2PFC_high{i}{:});
end
gcP2Hlow_rf1 = []; gcH2Plow_rf1 = [];
for i = 1:length(gcPFC2HPC_high)
    gcP2Hlow_rf1{i} = vertcat(gcPFC2HPC_low{i}{:});
    gcH2Plow_rf1{i} = vertcat(gcHPC2PFC_low{i}{:});
end

% get avg
gcP2Hhigh_rfAvg = cellfun2(gcP2Hhigh_rf1,'nanmean',{'1'});
gcH2Phigh_rfAvg = cellfun2(gcH2Phigh_rf1,'nanmean',{'1'});
gcP2Hlow_rfAvg  = cellfun2(gcP2Hlow_rf1,'nanmean',{'1'});
gcH2Plow_rfAvg  = cellfun2(gcH2Plow_rf1,'nanmean',{'1'});

% mat
gcP2Hhigh_mat = vertcat(gcP2Hhigh_rfAvg{:});
gcH2Phigh_mat = vertcat(gcH2Phigh_rfAvg{:});
gcP2Hlow_mat  = vertcat(gcP2Hlow_rfAvg{:});
gcH2Plow_mat  = vertcat(gcH2Plow_rfAvg{:});

figure('color','w'); hold on;
freqIdx = find(frequencies > 0 & frequencies < 100);
shadedErrorBar(frequencies(freqIdx),nanmean(gcP2Hhigh_mat(:,freqIdx),1),stderr(gcP2Hhigh_mat(:,freqIdx),1),'b',0);
shadedErrorBar(frequencies(freqIdx),nanmean(gcP2Hlow_mat(:,freqIdx),1),stderr(gcP2Hlow_mat(:,freqIdx),1),'r',0);
title('PFC2HPC')

figure('color','w'); hold on;
freqIdx = find(frequencies > 0 & frequencies < 100);
shadedErrorBar(frequencies(freqIdx),nanmean(gcH2Phigh_mat(:,freqIdx),1),stderr(gcH2Phigh_mat(:,freqIdx),1),'b',0);
shadedErrorBar(frequencies(freqIdx),nanmean(gcH2Plow_mat(:,freqIdx),1),stderr(gcH2Plow_mat(:,freqIdx),1),'r',0);
title('HPC2PFC')

idxTheta = find(f >= 6 & f <= 11);
% get data for excel - this extraction makes more sense than above
p2hthetaHigh=nanmean(gcP2Hhigh_mat(:,idxTheta),2);
h2pthetaHigh=nanmean(gcH2Phigh_mat(:,idxTheta),2);
p2hthetaLow=nanmean(gcP2Hlow_mat(:,idxTheta),2);
h2pthetaLow=nanmean(gcH2Plow_mat(:,idxTheta),2);
data4excel = horzcat(p2hthetaHigh,p2hthetaLow,h2pthetaHigh,h2pthetaLow);
diffP2Htheta = (p2hthetaHigh-p2hthetaLow)./(p2hthetaHigh+p2hthetaLow);
diffH2Ptheta = (h2pthetaHigh-h2pthetaLow)./(h2pthetaHigh+h2pthetaLow);
[h,p,ci,stat]=ttest(diffP2Htheta,0)
p*3
[h,p,ci,stat]=ttest(diffH2Ptheta,0)
p*3
[h,p,ci,stat]=ttest(diffH2Ptheta,diffP2Htheta)
p*3

mat = [];
mat = horzcat(diffH2Ptheta,diffP2Htheta);
multiBarPlot(mat,[{'HPC -> PFC'} {'PFC -> HPC'}],'Norm. Diff (High - Low)')
ylim([-0.1 0.4])


%{
% --- everything below concatenates data --- %

% concatenate LFP into a single vector for each rat
rtLFP_high_rdy = []; rtLFP_low_rdy = [];
for i = 1:length(rtLFP_high_end)
    rtLFP_high_rdy{i} = horzcat(rtLFP_high_det{i}{:});
end
for i = 1:length(rtLFP_low_end)
    rtLFP_low_rdy{i} = horzcat(rtLFP_low_det{i}{:});
end

% for the sake of bic, we must concatenate high and low data
for i = 1:length(rtLFP_high_rdy)
    rtLFP_4bic{i} = horzcat(rtLFP_high_rdy{i},rtLFP_low_rdy{i});
end

% run BIC
srate     = 2000;
orderRuns = 50;
for i = 1:length(rtLFP_4bic)
    [optimalorder{i},bic_val{i}] = bic_optimalorder(rtLFP_4bic{i}(1,:),rtLFP_4bic{i}(2,:),srate,orderRuns);
end
orders = cell2mat(optimalorder);
order_time = orders*(1000/2034);
% set model order
moAvg = round(nanmean(orders));

% average to apply for all rats
% 21-12 lfp1 = hpc
% 21-13 lfp1 = hpc
% 21-14 lfp1 = hpc
% 21-15 lfp1 = hpc
% 21-16 lfp1 = hpc
% 21-21 lfp1 = hpc
% 21-33 lfp1 = hpc
% 21-37 lfp1 = hpc
for i = 1:length(rtLFP_4bic)
    [gcPFC2HPC_high{i}, gcHPC2PFC_high{i}, frequencies] = GCspectral(rtLFP_high_rdy{i}(1,:),rtLFP_high_rdy{i}(2,:), moAvg, srate);
end
for i = 1:length(rtLFP_4bic)
    [gcPFC2HPC_low{i}, gcHPC2PFC_low{i}, frequencies] = GCspectral(rtLFP_low_rdy{i}(1,:),rtLFP_low_rdy{i}(2,:), moAvg, srate);
end

thetaIdx = find(frequencies > 6 & frequencies < 11);

for i = 1:length(rtLFP_4bic)
    pfc2hpc_highTheta(i) = nanmean(gcPFC2HPC_high{i}(thetaIdx));
    pfc2hpc_lowTheta(i)  = nanmean(gcPFC2HPC_low{i}(thetaIdx));
    hpc2pfc_highTheta(i) = nanmean(gcHPC2PFC_high{i}(thetaIdx));
    hpc2pfc_lowTheta(i)  = nanmean(gcHPC2PFC_low{i}(thetaIdx));
end

diffpfc2hpc = (pfc2hpc_highTheta-pfc2hpc_lowTheta)./(pfc2hpc_highTheta+pfc2hpc_lowTheta);
diffhpc2pfc = (hpc2pfc_highTheta-hpc2pfc_lowTheta)./(hpc2pfc_highTheta+hpc2pfc_lowTheta);
multiBarPlot([diffpfc2hpc',diffhpc2pfc'],[{'PFC2HPC'} {'HPC2PFC'}],'Diff score (high - low)')

LIhigh = hpc2pfc_highTheta./(pfc2hpc_highTheta+hpc2pfc_highTheta);
LIlow  = hpc2pfc_lowTheta./(pfc2hpc_lowTheta+hpc2pfc_lowTheta);

multiBarPlot([LIhigh',LIlow'],[{'High'} {'Low'}],'Lead Index')
[h,p]=ttest(LIhigh,0.5)

% distribution of lead index
distIdx = find(frequencies > 0 & frequencies < 100);
for i = 1:length(gcHPC2PFC_high)
    LIhighDist{i} = gcHPC2PFC_high{i}(distIdx)./(gcPFC2HPC_high{i}(distIdx)+gcHPC2PFC_high{i}(distIdx));
    LIlowDist{i}  = gcHPC2PFC_low{i}(distIdx)./(gcPFC2HPC_low{i}(distIdx)+gcHPC2PFC_low{i}(distIdx));
end
LIhighMat = vertcat(LIhighDist{:});
LIlowMat  = vertcat(LIlowDist{:});

LIhighAvg = nanmean(LIhighMat,1);
LIlowAvg  = nanmean(LIlowMat,1);
LIhighSEM = stderr(LIhighMat,1);
LIlowSEM  = stderr(LIlowMat,1);

figure('color','w'); hold on;
shadedErrorBar(frequencies(distIdx),LIhighAvg,LIhighSEM,'b',0)
shadedErrorBar(frequencies(distIdx),LIlowAvg,LIlowSEM,'r',0)





%}
