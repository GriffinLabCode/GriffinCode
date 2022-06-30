%% Generate Figures for Stout, George, Hallock, and Griffin paper
% this code is meant for reproduction purposes and requires all functions
% in the folder along with this code
clear; clc;
place2store = getCurrentPath;
cd(place2store);

%% fig 1 (see below for threshold figure)
load('data_ratNames')

%% fig 2
% coherogram
load('data_coherogram');

f = [1:.5:20];
timeAxis = linspace(-5,5,32);
figure('color','w'); 
    subplot 221;
        pcolor(timeAxis,f,coh_high_rat); shading interp
        title('High coherence')
        ylabel('Frequency')
        %colorbar
        axisScaleHigh = caxis;
        ylimits = ylim;
        colorbar
    subplot 222;
        pcolor(timeAxis,f,coh_highY_rat); shading interp
        title('High yoked')
        caxis([0 .7])
        caxis(axisScaleHigh)
        colorbar
    subplot 223;
        pcolor(timeAxis,f,coh_low_rat); shading interp
        title('Low coherence')
        axisScaleLow = caxis;
        colorbar
    subplot 224;
        pcolor(timeAxis,f,coh_lowY_rat); shading interp
        title('Low yoked')
        xlabel('Time(s) around trial onset')
        caxis(axisScaleLow)
        colorbar

% fig 1e - behavior
load('data_choiceAccuracy_coherence')
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

% granger
load('data_granger')
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
multiBarPlot(mat,[{'HPC -> PFC'} {'PFC -> HPC'}],'Norm. Diff Granger Prediction (High - Low)')
ylim([-0.1 0.4])
        
% theta gamma coupling
clear; clc;
load('data_thetaGamma')
mat = horzcat(rat_modhigh',rat_modlow');
multiBarPlot(mat,[{'High coh'} {'Low coh'}],'Theta-gamma coupling (MI)')
[h,p,ci,stat]=ttest(mat(:,1),mat(:,2))

% power
clear; clc;
load('data_powerAnalysis')
mat = [];
mat = horzcat(normDiffHpc',normDiffPfc');
multiBarPlot(mat,[{'HPC'} {'PFC'}],'Norm 6-11Hz Power (High-Low)')
ylim([-0.1 0.25])
[h,p,ci,stat]=ttest(mat(:,1),0)
[h,p,ci,stat]=ttest(mat(:,2),0)
[h,p,ci,stat]=ttest(mat(:,1),mat(:,2))

% behavioral analyses
load('data_offlineBehavior')
% timespent to choice
matPlot = [];
matPlot = horzcat(tsCP_high_avg',tsCP_highY_avg',tsCP_low_avg',tsCP_lowY_avg');
multiBarPlot(matPlot,[{'High'} {'Delay Matched Control'} {'Low'} {'Delay Matched Control'}],'Time-spent at CP (sec)')
[h,p,ci,stat]=ttest(tsCP_high_avg,tsCP_highY_avg)
[h,p,ci,stat]=ttest(tsCP_low_avg,tsCP_lowY_avg)

% normalized idphi
matPlot = [];
matPlot = horzcat(idphi_high_avg',idphi_highY_avg',idphi_low_avg',idphi_lowY_avg');
multiBarPlot(matPlot,[{'High'} {'Delay Matched Control'} {'Low'} {'Delay Matched Control'}],'Mean Norm. IdPhi')
[h,p,ci,stat]=ttest(idphi_high_avg,idphi_highY_avg)
[h,p,ci,stat]=ttest(idphi_low_avg,idphi_lowY_avg)

% normalized distance
matPlot = [];
matPlot = horzcat(dist_high_avg',dist_highY_avg',dist_low_avg',dist_lowY_avg');
multiBarPlot(matPlot,[{'High'} {'Delay Matched Control'} {'Low'} {'Delay Matched Control'}],'Mean Norm. Dist')
[h,p,ci,stat]=ttest(dist_high_avg,dist_highY_avg)
[h,p,ci,stat]=ttest(dist_low_avg,dist_lowY_avg)

% time 2 threshold - notice that yoked data ('Y') have the exact same delay
% durations
load('data_time2threshold')
data = []; xlabels = [];
data{1} = timeHigh; data{2} = timeLow;
xlabels{1} = 'High'; xlabels{2} = 'Low';
multiBarPlot(data,xlabels,'Time 2 threshold (sec)','n')
ylim([8 14]);
[h,p,ci,stat]=ttest(timeHigh,timeLow)

%% Fig 3
clear;
disp('Fig 3 data - clearing workspace')
rats{1} = '1202'; % int1 and int3 are DA
rats{2} = '1203'; % skip 1203-14, cd came first. 1203-13, da then cd, no third
rats{3} = '1206'; % sess1 had no cd end, 1206-3 had cd->da, 1206-5 cd->da, -07 cd->da, -09 cd->da
place2store = getCurrentPath;
cd(place2store);
load('data_2016data_thresholds');
load('data_2016data_SFC');

% do stuff
sfcHpcHigh = sfcHpcHigh(:);
sfcHpcLow  = sfcHpcLow(:);
sfcPfcHigh = sfcPfcHigh(:);
sfcPfcLow  = sfcPfcLow(:);

sfcHpcHigh = vertcat(sfcHpcHigh{:});
sfcHpcLow  = vertcat(sfcHpcLow{:});
sfcPfcHigh = vertcat(sfcPfcHigh{:});
sfcPfcLow  = vertcat(sfcPfcLow{:});

% remove nan
nanRem1 = find(isnan(sfcHpcLow(:,1)));
nanRem2 = find(isnan(sfcHpcHigh(:,1)));
nanRem3 = find(isnan(sfcPfcLow(:,1)));
nanRem4 = find(isnan(sfcPfcHigh(:,1)));
nanRem = unique(horzcat(nanRem1,nanRem2,nanRem3,nanRem4));
sfcHpcHigh(nanRem,:)=[];
sfcHpcLow(nanRem,:)=[];
sfcPfcHigh(nanRem,:)=[];
sfcPfcLow(nanRem,:)=[];

frequencies = logspace(0,2); % 10^0 to 10^2: 1:100
figure('color','w'); hold on;
s1=shadedErrorBar(frequencies,nanmean(sfcHpcHigh,1),stderr(sfcHpcHigh,1),'k',0);
s2=shadedErrorBar(frequencies,nanmean(sfcHpcLow,1),stderr(sfcHpcLow,1),'r',0);
ylim([0.01 0.06])
ylabel('SFC')
xlabel('Frequency (Hz)')
title('PFC unit to HPC theta')
legend([s1.mainLine, s2.mainLine],'High Coh. Epochs','Low Coh. Epochs')

figure('color','w'); hold on;
s1=shadedErrorBar(frequencies,nanmean(sfcHpcHigh,1),stderr(sfcHpcHigh,1),'k',0);
s2=shadedErrorBar(frequencies,nanmean(sfcHpcLow,1),stderr(sfcHpcLow,1),'r',0);
ylim([0.01 0.06])
xlim([1 20])
ylabel('SFC')
xlabel('Frequency (Hz)')
title('PFC unit to HPC theta')
legend([s1.mainLine, s2.mainLine],'High Coh. Epochs','Low Coh. Epochs')

figure('color','w'); hold on;
s1 = shadedErrorBar(frequencies,nanmean(sfcPfcHigh,1),stderr(sfcPfcHigh,1),'k',0);
s2 = shadedErrorBar(frequencies,nanmean(sfcPfcLow,1),stderr(sfcPfcLow,1),'r',0);
ylim([0.01 0.06])
ylabel('SFC')
xlabel('Frequency (Hz)')
title('PFC unit to PFC theta')
legend([s1.mainLine, s2.mainLine],'High Coh. Epochs','Low Coh. Epochs')

figure('color','w'); hold on;
s1=shadedErrorBar(frequencies,nanmean(sfcPfcHigh,1),stderr(sfcPfcHigh,1),'k',0);
s2=shadedErrorBar(frequencies,nanmean(sfcPfcLow,1),stderr(sfcPfcLow,1),'r',0);
ylim([0.01 0.06])
xlim([1 20])
ylabel('SFC')
xlabel('Frequency (Hz)')
title('PFC unit to PFC theta')
legend([s1.mainLine, s2.mainLine],'High Coh. Epochs','Low Coh. Epochs')

% get theta
fTheta = find(frequencies > 6 & frequencies < 11);

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

%% extended figs
clear;
load('data_ratNames')

% fig 1 with histology
load('data_ratFreqXCoherencePlots')
figure('color','w'); hold on;
f = [1:.5:20];
for i = 1:length(rats)
    subplot(1,length(rats),i)
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
    if i==length(rats)
        legend([s1.mainLine, s2.mainLine],'High Coh. Epochs','Low Coh. Epochs')
    end
end
load('data_ratContributions')
figure('color','w');
for i = 1:length(sessN)
    subplot(1,8,i)
    if i == 1
        ylabel('Number of ...')
    end
    hold on;
    b = bar([1,2,3],[sessN(i) trialN_high(i) trialN_low(i)]);
    b.Parent.XTickLabel = [{'Sessions'} {'High Trials'} {'Low Trials'}];
    b.Parent.XTickLabelRotation = 45;
    b.Parent.XTick = [1 2 3];
    ylim([0 22]);
    title(rats{i})
end

% fig 2a
% this variable shows delay and choice accuracy (0 = correct, 1 = error)
% for all trials per rat
load('data_delayXaccuracy')
figure('color','w')
errorbar(1:length(looper)-1,mean(ratAcc,1),stderr(ratAcc,1),'k','LineWidth',2);
xlim([0 7])
box off
ylabel('Choice Accuracy')
xlabel('Delay Duration Bin - check looper variable')

% fig 2b - filtering out break through artifacts
load('data_choiceAccuracy_coherenceExtendedData')
multiBarPlot([ratHighFiltered' ratHighYFiltered' ratLowFiltered' ratLowYFiltered'],[{'High'} {'High Control'} {'Low'} {'Low Control'}],'% Accurate');
[h,p,ci,stat]=ttest(ratHighFiltered,ratHighYFiltered)
p=p*2
[h,p,ci,stat]=ttest(ratLowFiltered,ratLowYFiltered)
p=p*2
title('Filtered for artifacts')

%% Other figs related to threshold
load('data_ratThetaCohDistributions');

% formatting....
cohSB_cache = cohSB_cache_all;

for i = 1:length(cohSB_cache)
    cohSB_cache{i}.clean_cXf_mat_all = vertcat(cohSB_cache{i}.clean_cXf_mat{:});
    cohSB_cache{i}.dirty_cXf_mat_all = vertcat(cohSB_cache{i}.dirty_cXf_mat{:});
end

% frequencies
ftheta     = [6 11];
idxTheta   = find(f > 6 & f < 11);
idxDelta   = find(f > 1 & f <  4);

% use this variable ->>>> cohSB_cache{1, 1}.clean_cXf_mat
deltaEvents = []; thetaEvents = [];
for i = 1:length(cohSB_cache)
    for sessi = 1:length(cohSB_cache{i}.clean_cXf_mat)
        try
            deltaEvents{i}{sessi} = nanmean(cohSB_cache{i}.clean_cXf_mat{sessi}(:,idxDelta),2);
            thetaEvents{i}{sessi} = nanmean(cohSB_cache{i}.clean_cXf_mat{sessi}(:,idxTheta),2);
            % find epochs where theta is greater than delta
            theta2deltaIDX{i}{sessi} = find(thetaEvents{i}{sessi} > deltaEvents{i}{sessi});
        end
    end
    %deltaCoh{i} = nanmean(cohSB_cache{i}.clean_cXf_mat_all(:,idxDelta),2);
    %thetaCoh{i} = nanmean(cohSB_cache{i}.clean_cXf_mat_all(:,idxTheta),2);
end

% use the theta2deltaIDX to get coherence data to keep from clean
for i = 1:length(theta2deltaIDX)
    for sessi = 1:length(theta2deltaIDX{i})
        cleanKeep{i}{sessi} = cohSB_cache{i}.clean_cXf_mat{sessi}(theta2deltaIDX{i}{sessi},:);
        deltaKeep{i}{sessi} = cohSB_cache{i}.clean_cXf_mat{sessi};   
        deltaKeep{i}{sessi}(theta2deltaIDX{i}{sessi},:)=[];        
    end
end

% create matrix per rat
for i = 1:length(cleanKeep)
    cleanKeepMat{i} = vertcat(cleanKeep{i}{:});
    deltaKeepMat{i} = vertcat(deltaKeep{i}{:});    
end

% get averages within each rat
for i = 1:length(cleanKeepMat)
    cleanFxC_avg{i} = nanmean(cleanKeepMat{i},1);
    cleanFxC_sem{i} = stderr(cleanKeepMat{i},1);    
    deltaFxC_avg{i} = nanmean(deltaKeepMat{i},1);
    deltaFxC_sem{i} = stderr(deltaKeepMat{i},1);       
end

% collapse
cleanFxC = vertcat(cleanFxC_avg{:});
deltaFxC = vertcat(deltaFxC_avg{:});

% averages
cleanFxC_ratAvg = nanmean(cleanFxC,1);
cleanFxC_ratSEM = stderr(cleanFxC,1);
deltaFxC_ratAvg = nanmean(deltaFxC,1);
deltaFxC_ratSEM = stderr(deltaFxC,1);

figure('color','w'); hold on;
s1 = shadedErrorBar(f,cleanFxC_ratAvg,cleanFxC_ratSEM,'k',0);
s2 = shadedErrorBar(f,deltaFxC_ratAvg,deltaFxC_ratSEM,'r',0);
ylabel(['Coherence (N = ',num2str(numel(rats)), ' rats)'])
xlabel('Frequency (Hz)')
box off
legend([s1.mainLine, s2.mainLine],'Theta > delta','delta > theta')

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on;
    s1 = shadedErrorBar(f,nanmean(cleanKeepMat{i},1),stderr(cleanKeepMat{i},1),'k',0);
    s2 = shadedErrorBar(f,nanmean(deltaKeepMat{i},1),stderr(deltaKeepMat{i},1),'r',0);
    legend([s1.mainLine, s2.mainLine],'Theta>Delta','Delta>=Theta')
    ylabel('Coherence')
    xlabel('Frequency')
    box off;
    ylim([0 1])
    title(rats{i})
end

%% rejected LFP
for i = 1:length(cohSB_cache)
    % first generate distributions
    cohOUT{i}.SB_cXf_avg   = nanmean(cohSB_cache{i}.clean_cXf_mat_all,1);
    cohOUT{i}.SB_cXf_ser   = stderr(cohSB_cache{i}.clean_cXf_mat_all,1);
    cohOUT{i}.SB_cXf_theta =  nanmean(cohSB_cache{i}.clean_cXf_mat_all(:,idxTheta),2);
    
    cohOUT{i}.d_cXf_avg   = nanmean(cohSB_cache{i}.dirty_cXf_mat_all,1);
    cohOUT{i}.d_cXf_ser   = stderr(cohSB_cache{i}.dirty_cXf_mat_all,1);
    cohOUT{i}.d_cXf_theta = nanmean(cohSB_cache{i}.dirty_cXf_mat_all(:,idxTheta),2);    
    %cohOUT{i}.B_cXf_avg   = nanmean(cohB_cache{i}.clean_cXf_mat_all,1);
    %cohOUT{i}.B_cXf_ser   = stderr(cohB_cache{i}.clean_cXf_mat_all,1);
end

figure('color','w')
dataLabels = [];
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on
    data = [];
    data{1} = cohOUT{i}.SB_cXf_theta;
    data{2} = cohOUT{i}.d_cXf_theta;
    xRange     = [0:.05:1];
    colors{1}  = 'b'; colors{2} = 'r'; 
    %dataLabels = [{'Accepted LFP'} {'Rejected LFP'}];
    distType   = 'normal';
    [y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
    xlabel('psd')
    xlabel('Coherence')
    box off;
    xlim([0 1])
    title(rats{i})
    if i == length(rats)
        legend('Accepted LFP','Rejected LFP')
    end
end

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on;
    s1 = shadedErrorBar(f,cohOUT{i}.SB_cXf_avg,cohOUT{i}.SB_cXf_ser,'k',0);
    s2 = shadedErrorBar(f,cohOUT{i}.d_cXf_avg,cohOUT{i}.d_cXf_ser,'r',0);
    
    ylabel('Coherence')
    xlabel('Frequency')
    box off;
    ylim([0 1])
    title(rats{i})
    if i == length(cohSB_cache)
        legend([s1.mainLine, s2.mainLine],'Accepted','Artifact Reject')
    end
end

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on;
    s1 = shadedErrorBar(f,nanmean(cleanKeepMat{i},1),stderr(cleanKeepMat{i},1),'k',0);
    s2 = shadedErrorBar(f,cohOUT{i}.d_cXf_avg,cohOUT{i}.d_cXf_ser,'r',0);
    
    ylabel('Coherence')
    xlabel('Frequency')
    box off;
    ylim([0 1])
    title(rats{i})
    if i == length(cohSB_cache)
        legend([s1.mainLine, s2.mainLine],'Accepted+theta>delta','Artifact Reject')
    end
end

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on;
    s1 = shadedErrorBar(f,nanmean(cleanKeepMat{i},1),stderr(cleanKeepMat{i},1),'k',0);
    s2 = shadedErrorBar(f,cohOUT{i}.SB_cXf_avg,cohOUT{i}.SB_cXf_ser,'r',0);
    %s2 = shadedErrorBar(f,cohOUT{i}.d_cXf_avg,cohOUT{i}.d_cXf_ser,'k',0);
    
    ylabel('Coherence')
    xlabel('Frequency')
    box off;
    ylim([0 1])
    title(rats{i})
    if i == length(cohSB_cache)
        legend([s1.mainLine, s2.mainLine],'Accepted+theta>delta','Accepted-theta>delta')
    end
end

%% theta distributions
cleanDist = []; dirtyDist = [];
idxTheta = find(f>6 & f<11);

for i = 1:length(cleanKeep)
    cleanDist{i} = nanmean(cleanKeepMat{i}(:,idxTheta),2);
    %dirtyDist{i} = nanmean(deltaMat(:,idxTheta),2);
end
zCleanDist = cellfun(@zscore_NaN,cleanDist,'UniformOutput',false);

figure('color','w')
data       = [];
data{1}    = zCleanDist{1}; data{2} = zCleanDist{2}; data{3} = zCleanDist{3};
data{4}    = zCleanDist{4}; data{5} = zCleanDist{5}; data{6} = zCleanDist{6};
data{7}    = zCleanDist{7}; data{8} = zCleanDist{8}; 
xRange     = [-3:.05:3];
colors{1}  = [1 0 0.4]; colors{2} = [1 0 0.6];  colors{3} = [1 0 0.8]; colors{4} = [1 0 1]; 
colors{5}  = [0 0 0.4]; colors{6} = [0 0 0.6];  colors{7} = [0 0 0.8]; colors{8} = [0 0 1];
dataLabels = rats;
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
ylabel('Probability density')
xlabel('Zscored Mean Coherence (6-11hz)')    

% rat thresholds (from source data excel sheet)
thresholds = ...
[0.327652859	0.659788045
0.249763179	0.598518389
0.324692162	0.642919971
0.282522878	0.624187571
0.147143742	0.505152442
0.290164691	0.615244002
0.210008374	0.564926501
0.372312814	0.682366719];

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on;
    histogram(cleanDist{i},'FaceColor',[.6 .6 .6])
    title(rats{i})
    ylimits = ylim;
    xlimitx = xlim;
    line([thresholds(i,1) thresholds(i,1)],[ylimits(1) ylimits(2)],'Color','r','LineStyle','--','LineWidth',2)
    line([thresholds(i,2) thresholds(i,2)],[ylimits(1) ylimits(2)],'Color','b','LineStyle','--','LineWidth',2)
    
    if i == length(rats)
        xlabel('Coherence')
        ylabel('# Events')
    end
    xlim([0 1])
end

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on
    data = [];
    data{1} = cohOUT{i}.SB_cXf_theta;
    data{2} = cohOUT{i}.d_cXf_theta;
    histogram(data{1},'FaceColor','b')
    histogram(data{2},'FaceColor','r')
    legend('Accepted LFP','Rejected LFP')
    box off
    xlim([0 1])
    title(rats{i})
end