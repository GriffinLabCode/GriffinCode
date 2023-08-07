%% Generate Figures for Stout, George, Kim, Hallock, and Griffin paper
% this code is meant for reproduction purposes and requires all functions
% in the folder along with this code
%
% behavioral analyses checked on 3/5/2023 for the final time.

disp('This code was generated for reproduction purposes and for sharing data/results')
disp('Additional data (raw formats) can be accessed through communication with Amy Griffin')
warning('Please ensure that the path with this script is added to your MATLAB paths or this code will not work')
disp('When you are ready to continue press any key...')
pause;

disp('Before you can successfully run this code, make sure you have the GriffinLab github code downloaded.')
helpAns = input(['Need help? [y/n] '],'s');
if contains(helpAns,'y')
    disp('1) Download gitbash.'); 
    disp('2) Open gitbash.')
    disp('3) enter: git clone https://github.com/GriffinLabCode/GriffinCode.')
    disp('4) When finished, find where the code was stored (prob on your C drive')
    disp('5) Open up MATLAB pipeline, find "startup"')
    disp('6) Run startup and follow prompt. You must enter the directory housing startup')
    disp('Youre ready to go if you see a list of addpaths in your command window')
    disp('Have fun!')
end

%% prep work
clear; clc;
sourceRoot = 'C:\Users\uggriffin\Documents\BACKUP - Stout 2023 - dissertation';
sourceFolder = '\Stout et al 2022 Harnessing neural synchrony';
sourceData = '\data';
sourceCode = '\code';
sourceRawCode = '\code for raw analysis';

disp('If running section-by-section, hit ctrl+c. Otherwise, press any key to continue...')
pause();

%% Initial loading
cd(horzcat(sourceRoot,sourceFolder,sourceData));
load('data_ratNames')
load('data_realTimeLFPsignals'); % generated from SCRIPT_power_realTimeData_FINAL or SCRIPT_grangerPrediction_realTimeData_4pub
disp('These data are the signals used to trigger trials in real time')
%clearvars -except sourceRoot sourceFolder sourceData sourceCode sourceRawCode

%% Coherogram
% coherogram
load('data_coherogram');
disp('Generating coherogram')

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
disp('Press any key to continue...')
pause;

%% Coherence triggered trials on behavior
load('data_lfp_bmi_filtered_3');
disp('Plotting behavioral data from trials triggered during coherence states')

% visualizing data - note that I filtered out low frequency, high amplitude
% events. My rationale is that some artifacts are just bad data, but some
% just mask good data. What is removed above was done so after looking for
% that "good" data, and so the data represented in the lfp_high and
% lfp_low, and the data represented in the "cat_" variables represent LFP
% and behavioral data on clean signals.
disp(['Please note that you can set plotBMIlfp to 1 if you want to see the '...
    'lfp data at the trial resolution']);
plotBMIlfp = 0;
if plotBMIlfp == 1
    for i = 1:length(lfp_high)
        figure('color','w')
        for ii = 1:length(lfp_high{i})
            subplot(round(length(lfp_high{i})/2),2,ii); hold on;
            plot(zscore(detrend(lfp_high{i}{ii}(1,:),3)),'k');
            plot(zscore(detrend(lfp_high{i}{ii}(2,:),3)),'b');
            title(['Idx ',num2str(ii)])
        end

        figure('color','w')
        for ii = 1:length(lfp_low{i})
            subplot(round(length(lfp_low{i})/2),2,ii); hold on;
            plot(zscore(detrend(lfp_low{i}{ii}(1,:),3)),'k');
            plot(zscore(detrend(lfp_low{i}{ii}(2,:),3)),'b');
            title(['Idx ',num2str(ii)])
        end   
    end
end

% get percent accurate
for i = 1:length(cat_highAll)
    ratHigh(i)  = ((numel(find(cat_highAll{i}==0)))/(numel(cat_highAll{i})))*100;
    ratHighY(i) = ((numel(find(cat_highYAll{i}==0)))/(numel(cat_highYAll{i})))*100;
    ratLow(i)   = ((numel(find(cat_lowAll{i}==0)))/(numel(cat_lowAll{i})))*100;
    ratLowY(i)  = ((numel(find(cat_lowYAll{i}==0)))/(numel(cat_lowYAll{i})))*100; 
    ratNorm(i)  = ((numel(find(cat_normAll{i}==0)))/(numel(cat_normAll{i})))*100; 
end

% plot data
data = []; xlabels = [];
data{1} = ratHigh; data{2} = ratHighY; data{3} = ratLow; data{4} = ratLowY;
xlabels{1} = 'High'; xlabels{2} = 'Yoked H'; xlabels{3} = 'Low'; xlabels{4} = 'Yoked L';
multiBarPlot(data,xlabels,'% Accuracy','n')
ylim([50 100]);

% planned comparisons
stat_test = 'ttest'; parametric = 'y'; numCorrections = [];
readStats(ratHigh,ratHighY,parametric,stat_test,'High V Yoked - planned',numCorrections);
readStats(ratLow,ratLowY,parametric,stat_test,'Low V Yoked - planned',numCorrections);

% not planned comparisons - test against random delay - testing to see if
% the manipulation helps them perform against what they would otherwise
% perform at. Confounded by delay duration
numCorrections = 4;
readStats(ratHigh,ratNorm,parametric,stat_test,'High v rand - not planned',numCorrections);
readStats(ratHighY,ratNorm,parametric,stat_test,'Yoked High v rand - not planned',numCorrections);
readStats(ratLow,ratNorm,parametric,stat_test,'Low v rand - not planned',numCorrections);
readStats(ratLowY,ratNorm,parametric,stat_test,'Yoked Low v rand - not planned',numCorrections);

%% BMI on CD
load('data_CD_BMI');
disp('These data were copy and pasted from the Excel sheet titled "CD_BMI"');

figure('color','w');
    multiBarPlot(mat(:,1:2),[{'High Coh.'} {'Yoked'}],'Percent Correct');
    ylim([50 100])
    xlimits = xlim;
    ylimits = ylim;
    line([xlimits(1) xlimits(2)],[mean(mat(:,3)) mean(mat(:,3))],'color','k','LineStyle','--')
    
% planned comparison
numCorrections = 0; parametric = 'y'; stat_test = 'ttest';
readStats(mat(:,1),mat(:,2),parametric,stat_test,'CD High v Yoked - planned',numCorrections);

% unplanned
numCorrections = 2; parametric = 'y'; stat_test = 'ttest';
readStats(mat(:,1),mat(:,3),parametric,stat_test,'CD High v Rand - unplanned',numCorrections);
readStats(mat(:,2),mat(:,3),parametric,stat_test,'CD Yoked v Rand - unplanned',numCorrections);

%% -- POWER -- %
clear;
disp('Running power spectrum analysis')
load('data_lfp_bmi_filtered_3');  

% power analysis
params = getCustomParams;
params.Fs = 2000;
params.fpass = [1 20];
params.tapers = [2 3];

% doesnt matter whether I used matlabs or chronux's power functions
hpcHigh = []; pfcHigh = [];
for i = 1:length(lfp_high)
    for ii = 1:length(lfp_high{i})
        if size(lfp_high{i}{ii},2) ~= 2560
            hpcHigh{i}(ii,:) = NaN([1 155]);
            pfcHigh{i}(ii,:) = NaN([1 155]);            
        else
        
            % power
            tempHpc = []; tempPfc = [];
            [tempHpc,f] = mtspectrumc(detrend(lfp_high{i}{ii}(1,:),3),params);
            hpcHigh{i}(ii,:) = log10(tempHpc);            
            tempPfc = mtspectrumc(detrend(lfp_high{i}{ii}(2,:),3),params);
            pfcHigh{i}(ii,:) = log10(tempPfc);
            
            % best frequency
             bestFreq_hpcHigh{i}(ii) = get_bestFrequency(tempHpc,f,[4 12]);
             bestFreq_pfcHigh{i}(ii) = get_bestFrequency(tempPfc,f,[4 12]);
        
        end
    end
end
hpcLow = []; pfcLow = [];
for i = 1:length(lfp_low)
    for ii = 1:length(lfp_low{i})
        if size(lfp_low{i}{ii},2) ~= 2560
            hpcLow{i}(ii,:) = NaN([1 155]);
            pfcLow{i}(ii,:) = NaN([1 155]);            
        else
        
            % power
            tempHpc = []; tempPfc = [];
            [tempHpc,f] = mtspectrumc(detrend(lfp_low{i}{ii}(1,:),3),params);
            hpcLow{i}(ii,:) = log10(tempHpc);            
            tempPfc = mtspectrumc(detrend(lfp_low{i}{ii}(2,:),3),params);
            pfcLow{i}(ii,:) = log10(tempPfc);  
            
            % best frequency
             bestFreq_hpcLow{i}(ii) = get_bestFrequency(tempHpc,f,[4 12]);
             bestFreq_pfcLow{i}(ii) = get_bestFrequency(tempPfc,f,[4 12]);
            
        end
    end
end

pPfcHigh = []; pHpcHigh = []; pPfcLow = []; pHpcLow = [];
for i = 1:length(pfcHigh)
    pPfcHigh(i,:) = nanmean((pfcHigh{i}),1);
    pHpcHigh(i,:) = nanmean((hpcHigh{i}),1);
end
for i = 1:length(pfcLow)
    pPfcLow(i,:) = nanmean((pfcLow{i}),1);
    pHpcLow(i,:) = nanmean((hpcLow{i}),1);
end
figure('color','w'); 
subplot 211;
hold on;
    shadedErrorBar(f,mean(pPfcHigh,1),stderr(pPfcHigh,1),'b',1)
    shadedErrorBar(f,mean(pPfcLow,1),stderr(pPfcLow,1),'r',1)
    axis tight
    %ylim([2.8 5.5])
subplot 212;
hold on;
    shadedErrorBar(f,mean(pHpcHigh,1),stderr(pHpcHigh,1),'b',1)
    shadedErrorBar(f,mean(pHpcLow,1),stderr(pHpcLow,1),'r',1)
    axis tight;
    ylabel('Power (log)')
    xlabel('Frequency')
    %ylim([2.8 5.5])

% get theta
idxTheta = find(f>6 & f<9);
pfcHighTheta = mean(pPfcHigh(:,idxTheta),2);
pfcLowTheta  = mean(pPfcLow(:,idxTheta),2);
hpcHighTheta = mean(pHpcHigh(:,idxTheta),2);
hpcLowTheta  = mean(pHpcLow(:,idxTheta),2);

data2plot = [];
data2plot = horzcat(pfcHighTheta,pfcLowTheta,hpcHighTheta,hpcLowTheta);
multiBarPlot(data2plot,[{'PFC High'} {'PFC Low'} {'HPC High'} {'HPC Low'}],'Log10 power')
ylim([3 6])

% read stats
stat_test = 'ttest'; parametric = 'y'; numCorrections = 2;
readStats(pfcHighTheta,pfcLowTheta,parametric,stat_test,'PFC High V Low',numCorrections);
readStats(hpcHighTheta,hpcLowTheta,parametric,stat_test,'HPC High V Low',numCorrections);

% testing for whether there was a change in peak frequency of theta
hpcHigh_avg = cellfun(@nanmean,bestFreq_hpcHigh);
hpcLow_avg = cellfun(@nanmean,bestFreq_hpcLow);
pfcHigh_avg = cellfun(@nanmean,bestFreq_pfcHigh);
pfcLow_avg = cellfun(@nanmean,bestFreq_pfcLow);

% plot data
data2plot = [];
data2plot = horzcat(pfcHigh_avg',pfcLow_avg',hpcHigh_avg',hpcLow_avg');
multiBarPlot(data2plot,[{'PFC High'} {'PFC Low'} {'HPC High'} {'HPC Low'}],'Best Frequency (4-12Hz)')
stat_test = 'ttest'; parametric = 'y'; numCorrections = 2;
readStats(pfcHigh_avg,pfcLow_avg,parametric,stat_test,'PFC Peak Theta High V Low',numCorrections);
readStats(hpcHigh_avg,hpcLow_avg,parametric,stat_test,'HPC Peak Theta V Low',numCorrections);

%% granger
if exist('lfp_high')==0
    load('data_lfp_bmi_filtered_3');  
end

generateModelOrder = 0;
if generateModelOrder == 1
    % get model order
    srate = 2000; orderRuns = 20;
    for i = 1:length(lfp_high)
        for ii = 1:length(lfp_high{i})
            signal1 = detrend(lfp_high{i}{ii}(1,:),3);
            signal2 = detrend(lfp_high{i}{ii}(2,:),3);        
            [optimalorder_high(i,ii),bic_val] = bic_optimalorder(signal1,signal2,srate,orderRuns);
        end
        disp(['Finished with rat # ',num2str(i), ' high data'])
    end
    for i = 1:length(lfp_low)
        for ii = 1:length(lfp_low{i})
            signal1 = detrend(lfp_low{i}{ii}(1,:),3);
            signal2 = detrend(lfp_low{i}{ii}(2,:),3);        
            [optimalorder_low(i,ii),bic_val] = bic_optimalorder(signal1,signal2,srate,orderRuns);
        end
        disp(['Finished with rat # ',num2str(i), ' low data'])
    end
    optimalorder_high = optimalorder_high(:);
    optimalorder_low  = optimalorder_low(:);
    optimalOrders = vertcat(optimalorder_high,optimalorder_low);

    % zeros aren't actually values generated from the code. They were
    % placeholders
    optimalOrders(optimalOrders==0)=[];
    moAvg = round(median(optimalOrders)); % non-normal distribution, looked poisson like with some outliers
    %figure; histogram(optimalOrders)
else
    % manually entered based on the code above
    moAvg = 7;
end

% GP
disp('Running bivariate granger prediction analysis using Forbes approach - Hallock et al., 2016')
srate = 2000;
gcPFC2HPC_high = []; gcHPC2PFC_high = [];
for i = 1:length(lfp_high)
    for ii = 1:length(lfp_high{i})
        signal1 = detrend(lfp_high{i}{ii}(1,:),3);
        signal2 = detrend(lfp_high{i}{ii}(2,:),3);           
        [gcPFC2HPC_high{i}{ii}, gcHPC2PFC_high{i}{ii}, frequencies] = GCspectral(detrend(lfp_high{i}{ii}(1,:),3),detrend(lfp_high{i}{ii}(2,:),3), moAvg, srate);
    end
    disp(['Finished with rat # ',num2str(i), ' high data'])
end
gcPFC2HPC_low = []; gcHPC2PFC_low = [];
for i = 1:length(lfp_low)
    for ii = 1:length(lfp_low{i})
        signal1 = detrend(lfp_low{i}{ii}(1,:),3);
        signal2 = detrend(lfp_low{i}{ii}(2,:),3);             
        [gcPFC2HPC_low{i}{ii}, gcHPC2PFC_low{i}{ii}, frequencies] = GCspectral(detrend(lfp_low{i}{ii}(1,:),3),detrend(lfp_low{i}{ii}(2,:),3), moAvg, srate);
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

idxTheta = find(frequencies > 6 & frequencies < 9);
% get data for excel - this extraction makes more sense than above
p2hthetaHigh=nanmean(gcP2Hhigh_mat(:,idxTheta),2);
h2pthetaHigh=nanmean(gcH2Phigh_mat(:,idxTheta),2);
p2hthetaLow=nanmean(gcP2Hlow_mat(:,idxTheta),2);
h2pthetaLow=nanmean(gcH2Plow_mat(:,idxTheta),2);
data4excel = horzcat(p2hthetaHigh,p2hthetaLow,h2pthetaHigh,h2pthetaLow);
diffP2Htheta = (p2hthetaHigh-p2hthetaLow)./(p2hthetaHigh+p2hthetaLow);
diffH2Ptheta = (h2pthetaHigh-h2pthetaLow)./(h2pthetaHigh+h2pthetaLow);

% set up function to output statistics
stat_test = 'ttest'; parametric = 'y'; numCorrections = 3;
readStats(diffP2Htheta,0,parametric,stat_test,'PFC2HPC',numCorrections);
readStats(diffH2Ptheta,0,parametric,stat_test,'HPC2PFC',numCorrections);
readStats(diffH2Ptheta,diffP2Htheta,parametric,stat_test,'HPC2PFC vs PFC2HPC',numCorrections);

mat = [];
mat = horzcat(diffH2Ptheta,diffP2Htheta);
multiBarPlot(mat,[{'HPC -> PFC'} {'PFC -> HPC'}],'Norm. Diff (High - Low)')
ylim([-0.1 0.6])

%% LFP around choice
clear;
load('data_time2choiceEntry');

% time to choice entry
t2cHigh = abs(cellfun(@mean,t2c_high_cat));
t2cLow  = abs(cellfun(@mean,t2c_low_cat));
t2clowY  = abs(cellfun(@mean,t2c_lowY_cat));
t2chighY  = abs(cellfun(@mean,t2c_highY_cat));

data2plot = []; data2plot = horzcat(t2cHigh',t2cLow');
multiBarPlot(data2plot,[{'High'} {'Low'}],'sec');

% I recognize that these aren't exactly the same trials as what is used in
% the behavioral data, but some of the data was shotty and I relied on good
% looking signals. Importantly, even when I didn't exclude any data, I
% still saw the effect, so any of the analyses that use their own rejection
% approaches can be considered just as important. Much of the artifacts
% were low in frequency 
load('data_bmi_lfp_timeAroundCP_5s');

% do high coherence events have stronger coherence at choice then low
% coherence events?
%f = [5:.05:30];
params = getCustomParams;
params.tapers = [2 3];
params.fpass = [5 50]; % 15 40 for beta, 5 30 for theta
params.Fs = 2000;
movingwin = [1.25 0.25];
cHigh = []; cLow = [];
for i = 1:length(lfp_high_filt)
    tempdata = []; tempdata = lfp_high_filt{i};
    for triali = 1:length(tempdata)
        tempPFC = tempdata{triali}(1,:);
        tempHPC = tempdata{triali}(2,:);
        cHigh{i}{triali} = cohgramc(tempPFC',tempHPC',movingwin,params);
    end
    tempdata = []; tempdata = lfp_low_filt{i};
    for triali = 1:length(tempdata)
        tempPFC = tempdata{triali}(1,:);
        tempHPC = tempdata{triali}(2,:);        
        [cLow{i}{triali},phi,S12,S1,S2,t,f] = cohgramc(tempPFC',tempHPC',movingwin,params);
    end
end

for i = 1:length(cHigh)
    cHighSess{i} = mean(cellTo3D(cHigh{i}),3);
    cLowSess{i}  = mean(cellTo3D(cLow{i}),3);
end

% trim data for times of interest
cMatHigh = cellTo3D(cHighSess);
cMatLow  = cellTo3D(cLowSess);
timeAxis = linspace(-5,5,numel(t));

% on avg, it took 2s to reach choice
cHighTrim = cMatHigh(timeAxis>=-2 & timeAxis<=.5,:,:);
cLowTrim  = cMatLow(timeAxis>=-2 & timeAxis<=.5,:,:);
timeTrim  = timeAxis(timeAxis>=-2 & timeAxis<=.5);

shadingAxis = [];
figure('color','w')
subplot 211; hold on;
    pcolor(timeTrim,f,mean(cHighTrim,3)');
    shading interp
   % ylim([10 30])
    colorbar;
    shadingAxis = caxis;
    axis tight;
    %caxis(shadingAxis)
    %xlim([-0.5 0.5])
    ylimits=ylim;
    line([0 0],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    title('High Coh Trials')
    
subplot 212; hold on;
    pcolor(timeTrim,f,mean(cLowTrim,3)');
    shading interp
    %ylim([10 30])
    colorbar;
    caxis(shadingAxis)
    axis tight;
    %xlim([-1 1])
    xlabel('Time Around CP entry')
    ylabel('Frequency (Hz)')
    ylimits = ylim;
    line([0 0],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    title('Low Coh Trials')
  
figure('color','w')
subplot 211; hold on;
    pcolor(timeTrim,f,mean(cHighTrim,3)');
    shading interp
   % ylim([10 30])
    colorbar;
    shadingAxis = caxis;
    axis tight;
    %xlim([-0.5 0.5])
    ylimits=ylim;
    line([0 0],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    title('High Coh Trials')
    ylim([6 15])
    
subplot 212; hold on;
    pcolor(timeTrim,f,mean(cLowTrim,3)');
    shading interp
    %ylim([10 30])
    colorbar;
    caxis(shadingAxis)
    axis tight;
    %xlim([-1 1])
    xlabel('Time Around CP entry')
    ylabel('Frequency (Hz)')
    ylimits = ylim;
    line([0 0],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    title('Low Coh Trials')    
    ylim([6 15])
    
figure('color','w')
    pcolor(timeTrim,f,(mean(cHighTrim,3)'-mean(cLowTrim,3)')./(mean(cHighTrim,3)'+mean(cLowTrim,3)'));
    shading interp
    colormap('jet')
    colorbar;
    ylimits = ylim;
    ylim([6 15])
    line([0 0],[ylimits(1) ylimits(2)],'Color','k','LineStyle','--')
    
% example signal
tempHigh = lfp_high_filt{1}{2};
tempLow  = lfp_low_filt{1}{2};
figure('color','w');
    idxFilt = find(xPlot > -2 & xPlot < 0.5);
    subplot 211; hold on;
        plot(xPlot(idxFilt),tempHigh(1,idxFilt),'k')
        plot(xPlot(idxFilt),tempHigh(2,idxFilt),'m');
        axis tight;
    subplot 212; hold on;
        plot(xPlot(idxFilt),tempLow(1,idxFilt),'k')
        plot(xPlot(idxFilt),tempLow(2,idxFilt),'m');
        axis tight;  
        
rhythm = [6 9];
tempH = []; tempL = [];
tempH = reshape(mean(cHighTrim(:,f>rhythm(1) & f<rhythm(2),:),2),[length(timeTrim) size(cHighTrim,3)]);
tempL = reshape(mean(cLowTrim(:,f>rhythm(1) & f<rhythm(2),:),2),[length(timeTrim) size(cHighTrim,3)]);
%tempH = reshape(mean(cHighTrim(:,rhythm7,:),2),[length(timeTrim) size(cHighTrim,3)]);
%tempL = reshape(mean(cLowTrim(:,rhythm7,:),2),[length(timeTrim) size(cHighTrim,3)]);
tempH = tempH';
tempL = tempL';

% plotting twice looks nice
figure('color','w'); hold on;
diffHvL = (tempH-tempL)./(tempH+tempL);
    %shadedErrorBar(timeTrim,mean(tempH,1),stderr(tempH,1),'b',1);
    %shadedErrorBar(timeTrim,mean(tempL,1),stderr(tempL,1),'r',1);
    shadedErrorBar(timeTrim,mean(diffHvL,1),stderr(diffHvL,1),'k',1);
    xlim([-2 0.5])
    %anova1(diffHvL)
    for i = 1:size(diffHvL,2)
        [h,p(i),ci{i},stat{i}]=ttest(diffHvL(:,i));
    end
    [~,~,~,padj] = fdr_bh(p);
    axis tight;
    
    % make a table for word
    tstat = []; 
    for i = 1:length(stat)
        tstat(:,i) = stat{i}.tstat;
    end
    timeTrim = timeTrim'; tstat = tstat'; p = p'; padj = padj';
    tableData = []; tableData = table(timeTrim,tstat,p,padj);
    
%% Behavioral analyses
% note that some of the analyses use different data. This is because
% procedures varied slightly between approaches. Importantly, even when I
% include all LFP data, I see a more significant effect (likely due to
% narrowing in on the effects). So this is just a natural consequence of
% performing so many different analyses and I dont think should make a big
% deal. If I saw any trending effect at the level of behavior (below), that
% would be different. But I saw no real evidence that there would be
% differences in overt behavior even if I went back and aligned the
% analyses with the choice accuracy result LFP rejections from above.
disp('Run SCRIPT_offlineBehavioralAnalysis to replicate on raw data')

% data
clearvars -except rats lfp_high lfp_low sourceRoot sourceFolder sourceData sourceCode sourceRawCode
load('data_offlineBehavior')
disp('Running behavioral analyses')

% time spent to choice
tsCP_high_avg  = cellfun(@nanmean,tsCP_high_cat);
tsCP_highY_avg = cellfun(@nanmean,tsCP_highY_cat);
tsCP_low_avg   = cellfun(@nanmean,tsCP_low_cat);
tsCP_lowY_avg  = cellfun(@nanmean,tsCP_lowY_cat);
matPlot = [];
matPlot = horzcat(tsCP_high_avg',tsCP_highY_avg',tsCP_low_avg',tsCP_lowY_avg');
multiBarPlot(matPlot,[{'High'} {'Delay Matched Control'} {'Low'} {'Delay Matched Control'}],'Time-spent at CP (sec)')

stat_test = 'ttest'; parametric = 'y'; numCorrections = 2;
readStats(tsCP_high_avg',tsCP_highY_avg',parametric,stat_test,'TimeSpent CP High v Yoked',numCorrections);
readStats(tsCP_low_avg',tsCP_lowY_avg',parametric,stat_test,'TimeSpent CP Low v Yoked',numCorrections);

% zidphi
idphi_high_avg  = cellfun(@nanmean,idphi_high_cat);
idphi_highY_avg = cellfun(@nanmean,idphi_highY_cat);
idphi_low_avg   = cellfun(@nanmean,idphi_low_cat);
idphi_lowY_avg  = cellfun(@nanmean,idphi_lowY_cat);
matPlot = [];
matPlot = horzcat(idphi_high_avg',idphi_highY_avg',idphi_low_avg',idphi_lowY_avg');
multiBarPlot(matPlot,[{'High'} {'Yoked'} {'Low'} {'Yoked'}],'zIdPhi')
stat_test = 'ttest'; parametric = 'y'; numCorrections = 2;
readStats(idphi_high_avg',idphi_highY_avg',parametric,stat_test,'IdPhi High v Yoked',numCorrections);
readStats(idphi_low_avg',idphi_lowY_avg',parametric,stat_test,'IdPhi Low v Yoked',numCorrections);

% norm distance
dist_high_avg  = cellfun(@nanmean,dist_high_cat);
dist_highY_avg = cellfun(@nanmean,dist_highY_cat);
dist_low_avg   = cellfun(@nanmean,dist_low_cat);
dist_lowY_avg  = cellfun(@nanmean,dist_lowY_cat);
matPlot = [];
matPlot = horzcat(dist_high_avg',dist_highY_avg',dist_low_avg',dist_lowY_avg');
multiBarPlot(matPlot,[{'High'} {'Yoked'} {'Low'} {'Yoked'}],'Mean Distance (Pixels)')
stat_test = 'ttest'; parametric = 'y'; numCorrections = 2;
readStats(dist_high_avg',dist_highY_avg',parametric,stat_test,'PFC Peak Theta High V Low',numCorrections);
readStats(dist_low_avg',dist_lowY_avg',parametric,stat_test,'PFC Peak Theta High V Low',numCorrections);

% time 2 threshold - notice that yoked data ('Y') have the exact same delay
% durations
load('data_lfp_bmi_filtered_3')
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

xlabels = [];
data2plot{1} = timeHigh; data2plot{2} = timeLow;
xlabels{1} = 'High'; xlabels{2} = 'Low';
multiBarPlot(data2plot,xlabels,'Time 2 threshold (sec)','n')
ylim([8 14]);
stat_test = 'ttest'; parametric = 'y'; numCorrections = 2;
readStats(timeHigh,timeLow,parametric,stat_test,'Time In Delay (high v low)',numCorrections);

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

%% extended figs
disp('Generating rat x coherence plots...')
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

%% Analysis of existing datasets
% raw processing can be observed in SCRIPT_analysis_v4
clearvars -except dataSpkLFP sourceRoot sourceFolder sourceData sourceCode sourceRawCode
cd(horzcat(sourceRoot,sourceFolder,sourceData));
disp('These analyses were performed on existing datasets from the lab')
disp('The general focus is on PFC-Re-HPC interaction and PFC SFC')
disp('loading data - be prepared for a potentially long wait')
load('data_spkLFP_cohData_v2','dataSpkLFP');
disp('In dataSpkLFP.processed.epoch variable, HPC = sig1, PFC = sig2, RE = sig3. PFC and HPC are switched in the processed.spksLFPs!')
disp('In dataSpkLFP.processed.spksLFPs variable, HPC = sig2, PFC = sig1, RE = sig3.')
disp('Rats 1-3 were sampled at 2034-2035 samples/sec, and rats 4-7 at 2000 samples/sec ')
disp('Rat #7 excluded due to poor LFP. Many of rat #6 sessions are removed below due to signal quality')
%{
% identify high coh epochs, ref back to processed.spksLFPs
% first need to actually identify high epochs
tempData = [];
ratID = fieldnames(dataSpkLFP);
for rati = 1:length(ratID)
    disp(['Working with rat',num2str(rati)])
    sessions = fieldnames(dataSpkLFP.(ratID{rati}));
    for sessi = 1:length(sessions)
        tempData{rati,sessi} = dataSpkLFP.(ratID{rati}).(sessions{sessi}).analysis.theta_coh;
        % collapse data
        tempData{rati,sessi} = tempData{rati,sessi}(:)';
        % remove empty arrays
        tempData{rati,sessi} = emptyCellErase(tempData{rati,sessi});
        % convert to type double
        tempData{rati,sessi} = cell2mat(tempData{rati,sessi});
    end
end

% lets create a distribution of high and low coherence per each session,
% then take an average just to account for cases where wires are changed
cohRat = [];
cohRat = cellcat(tempData,'horzcat','col')';

% zscore transform and identify +/- 1std from the mean
zCoh = [];
zCoh = cellfun(@zscore,cohRat,'UniformOutput',false);
for i = 1:length(zCoh)
    % get high and low coherence
    idxHigh = dsearchn(zCoh{i}',1);
    highCohThreshold(i) = cohRat{i}(idxHigh);
    idxLow  = dsearchn(zCoh{i}',-1);
    lowCohThreshold(i) = cohRat{i}(idxLow); 
end

% loop over variable, lets extract number of high and low coherence epochs
% per rat
ratID = fieldnames(dataSpkLFP);
for rati = 1:length(ratID)
    disp(['Working with rat',num2str(rati)])
    sessions = fieldnames(dataSpkLFP.(ratID{rati}));
    for sessi = 1:length(sessions)
        % temporary variable
        tempData = [];
        tempData = dataSpkLFP.(ratID{rati}).(sessions{sessi}).processed.epoch;
        for triali = 1:length(tempData)
            % get high and low coherence epochs
            lowEvents{rati,sessi}(triali)  = numel(find(contains(tempData{triali}(2,:),'lowCoh')));
            highEvents{rati,sessi}(triali) = numel(find(contains(tempData{triali}(2,:),'highCoh')));
        end
    end
end
lowEvents = empty2nan(lowEvents);
highEvents = empty2nan(highEvents);

figure('color','w')
for i = 1:6%length(cohRat)
    subplot(numel(cohRat),1,i)
    histogram(cohRat{i},'FaceColor',[.6 .6 .6])
    xlim([0 1])
    ylimits = ylim;
    line([lowCohThreshold(i) lowCohThreshold(i)],[ylimits(1) ylimits(2)],'color','r','LineWidth',1,'LineStyle','--')
    line([highCohThreshold(i) highCohThreshold(i)],[ylimits(1) ylimits(2)],'color','b','LineWidth',1,'LineStyle','--')

    box off
    title(['rat',num2str(i)])
end

trialLowE  = sum(cellfun(@sum,lowEvents),2,'omitnan');
trialHighE = sum(cellfun(@sum,highEvents),2,'omitnan');
numEpochs = horzcat(trialLowE,trialHighE);
    figure('color','w'); 
    b = bar(numEpochs) 
    b(1).FaceColor = 'r';
    b(2).FaceColor = 'b';
    ylabel('Number of epochs')
    xlabel('Rat ID')
    legend('Low Coh.', 'High Coh.')
    box off

thresholds = vertcat(lowCohThreshold,highCohThreshold)';
    figure('color','w'); 
    b = bar(thresholds) 
    b(1).FaceColor = 'r';
    b(2).FaceColor = 'b';
    ylabel('Coherence Mag.')
    xlabel('Rat ID')
    legend('Low Coh.', 'High Coh.')
    box off    

% num sessions
sessCount=[];
ratID = fieldnames(dataSpkLFP);
for rati = 1:length(ratID)
    disp(['Working with rat',num2str(rati)])
    sessions = fieldnames(dataSpkLFP.(ratID{rati}));
    sessCount(rati) = numel(sessions);
end
figure('color','w'); 
bar(sessCount,'FaceColor',[.6 .6 .6])
box off
ylabel('# sessions')
xlabel('Rat ID')
%}

%% loading stout + hallock data
disp('Loading and processing stout+hallock data...')
rng('shuffle');

% removing data due to corruption
dataSpkLFP = rmfield(dataSpkLFP,'rat7');

% rat 6, only keep sessions 6 and 7, the rest are so corrupted
rat6fields = [{'session1'} {'session2'} {'session3'} {'session4'} {'session5'} {'session8'}];
dataSpkLFP.rat6 = rmfield(dataSpkLFP.rat6,rat6fields);

disp('Cleaning up workspace')
clearvars -except dataSpkLFP sourceRoot sourceFolder sourceData sourceCode sourceRawCode

%% defining high/low coh states
disp('Defining high and low coh states using hallock and stout data')

% identify high coh epochs, ref back to processed.spksLFPs
% first need to actually identify high epochs
tempData = [];
ratID = fieldnames(dataSpkLFP);
for rati = 1:length(ratID)
    disp(['Working with rat',num2str(rati)])
    sessions = fieldnames(dataSpkLFP.(ratID{rati}));
    for sessi = 1:length(sessions)
        tempData{rati,sessi} = dataSpkLFP.(ratID{rati}).(sessions{sessi}).analysis.theta_coh;
        % collapse data
        tempData{rati,sessi} = tempData{rati,sessi}(:)';
        % remove empty arrays
        tempData{rati,sessi} = emptyCellErase(tempData{rati,sessi});
        % convert to type double
        tempData{rati,sessi} = cell2mat(tempData{rati,sessi});
    end
end

% lets create a distribution of high and low coherence per each session,
% then take an average just to account for cases where wires are changed
cohRat = [];
cohRat = cellcat(tempData,'horzcat','col')';

% zscore transform and identify +/- 1std from the mean
zCoh = [];
zCoh = cellfun(@zscore,cohRat,'UniformOutput',false);
for i = 1:length(zCoh)
    % get high and low coherence
    idxHigh = dsearchn(zCoh{i}',1);
    highCohThreshold(i) = cohRat{i}(idxHigh);
    idxLow  = dsearchn(zCoh{i}',-1);
    lowCohThreshold(i) = cohRat{i}(idxLow); 
end

% loop over variable, lets extract number of high and low coherence epochs
% per rat
ratID = fieldnames(dataSpkLFP);
for rati = 1:length(ratID)
    disp(['Working with rat',num2str(rati)])
    sessions = fieldnames(dataSpkLFP.(ratID{rati}));
    for sessi = 1:length(sessions)
        % temporary variable
        tempData = [];
        tempData = dataSpkLFP.(ratID{rati}).(sessions{sessi}).processed.epoch;
        for triali = 1:length(tempData)
            % get high and low coherence epochs
            lowEvents{rati,sessi}(triali)  = numel(find(contains(tempData{triali}(2,:),'lowCoh')));
            highEvents{rati,sessi}(triali) = numel(find(contains(tempData{triali}(2,:),'highCoh')));
        end
    end
end
lowEvents = empty2nan(lowEvents);
highEvents = empty2nan(highEvents);

figure('color','w')
for i = 1:length(cohRat)
    subplot(numel(cohRat),1,i)
    histogram(cohRat{i},'FaceColor',[.6 .6 .6])
    xlim([0 1])
    ylimits = ylim;
    line([lowCohThreshold(i) lowCohThreshold(i)],[ylimits(1) ylimits(2)],'color','r','LineWidth',1,'LineStyle','--')
    line([highCohThreshold(i) highCohThreshold(i)],[ylimits(1) ylimits(2)],'color','b','LineWidth',1,'LineStyle','--')

    box off
    title(['rat',num2str(i)])
end
title('Stout + Hallock data')

trialLowE  = sum(cellfun(@sum,lowEvents),2,'omitnan');
trialHighE = sum(cellfun(@sum,highEvents),2,'omitnan');
numEpochs = horzcat(trialLowE,trialHighE);
    figure('color','w'); 
    b = bar(numEpochs(1:6,:)) 
    b(1).FaceColor = 'r';
    b(2).FaceColor = 'b';
    ylabel('Number of epochs')
    xlabel('Rat ID')
    legend('Low Coh.', 'High Coh.')
    box off
    title('Stout + Hallock data')
thresholds = vertcat(lowCohThreshold,highCohThreshold)';
    figure('color','w'); 
    b = bar(thresholds(1:6,:)) 
    b(1).FaceColor = 'r';
    b(2).FaceColor = 'b';
    ylabel('Coherence Mag.')
    xlabel('Rat ID')
    legend('Low Coh.', 'High Coh.')
    box off    
    title('Stout + Hallock data')

% num sessions
sessCount=[];
ratID = fieldnames(dataSpkLFP);
for rati = 1:length(ratID)
    disp(['Working with rat',num2str(rati)])
    sessions = fieldnames(dataSpkLFP.(ratID{rati}));
    sessCount(rati) = numel(sessions);
end
figure('color','w'); 
bar(sessCount(1:6),'FaceColor',[.6 .6 .6])
box off
ylabel('# sessions')
xlabel('Rat ID')
title('Stout + Hallock data')
save('data_stoutHallockThresholds','thresholds');

%% coh over delay
% removed appropriate rats, did not do coh  detect, but can replicate when
% i do
load_delayXcoherence=1;
disp('The code below is also represented in the "data_cohProcessed_12102022" "C" variable.')
disp('This code was written prior to the "getHighAndLowCohData" function which can plot figures for the user.')
disp('For the sake of time, the code below was not updated to use that function, but the backbone is the same')

if load_delayXcoherence == 0
    thetaC = [];
    ratID = fieldnames(dataSpkLFP);
    for rati = 1:length(ratID)
        disp(['Working with rat',num2str(rati)])
        sessions = fieldnames(dataSpkLFP.(ratID{rati}));
        for sessi = 1:length(sessions)
            % temporary variable
            tempData = [];
            tempData = dataSpkLFP.(ratID{rati}).(sessions{sessi}).processed.spksLFPs;

            if rati > 3
                looper = 1:length(tempData);
            else 
                looper = 2:length(tempData);
            end
            for triali = looper
                if rati > 3
                    srate = 2000;
                    % for stout rats, remove the first 10sec cause this
                    % wasn't delay
                    tempData{triali}(:,1:10*srate)=[];
                else
                    srate = 2035;
                end
                f = [6:.5:11]; data1 = []; data2 = [];
                if isempty(tempData{triali})==0
                    data1 = tempData{triali}(1,:);
                    data2 = tempData{triali}(2,:);
                    [C,t,f] = mscohere_movingWin_updated(data1,data2,[1.25 0.25],srate,f);
                    thetaC{rati,sessi}(:,triali) = mean(C);
                end
                disp(['Finished with ',ratID{rati},' ',sessions{sessi},' trial',num2str(triali)])
            end
        end
    end
    info = 'Data was extracted during delay phase and coherence examined to identify how coherence varies across delay. Stout data examined only delay phase';
    cd(place2store);
    save('data_delayVaryCoh','thetaC','info')
else
    load('data_delayVaryCoh')
    load('data_stoutHallockThresholds');
    highCohThreshold = thresholds(:,2);
    lowCohThreshold  = thresholds(:,1);
end 
clearvars -except thetaC dataSpkLFP sourceRoot sourceFolder sourceData sourceCode sourceRawCode highCohThreshold lowCohThreshold
onlyHenry = 1; % cleaner dataset & same task

% present data over delays binned into first 3 bins and last 3 bins of
% the predictable delay phase
% remove trials with all zeros
thetaCog = thetaC;
if onlyHenry == 1
    thetaC(4:end,:)=[];
    highCohThreshold(4:end)=[];
    lowCohThreshold(4:end)=[];
end

% binning variable
delayBins = linspace(0,size(thetaC{1},1),30/5); % 5s bins
phighMat = []; plowMat = []; phighShuf = []; plowShuf = [];
for rowi = 1:size(thetaC,1)
    for coli = 1:size(thetaC,2)
        if isempty(thetaC{rowi,coli})==0
            % av over trials
            remTrials = [];
            remTrials = find(thetaC{rowi,coli}(1,:)==0);
            thetaC{rowi,coli}(:,remTrials)=[];            
            % get phigh and plow over trials
            tempdata = []; tempdata = thetaC{rowi,coli};
            phigh = []; plow = [];
            for bini = 1:length(delayBins)-1
                for triali = 1:size(tempdata,2)
                    % get temporary data at trial res
                    trialdata = [];
                    trialdata = tempdata(delayBins(bini)+1:delayBins(bini+1),triali);
                    
                    % get phigh and plow
                    phigh{bini}(triali) = (numel(find(trialdata > highCohThreshold(rowi))))/numel(trialdata);
                    plow{bini}(triali)  = (numel(find(trialdata < lowCohThreshold(rowi))))/numel(trialdata);
                
                end
            end
            phighMat{rowi}(coli,:) = cellfun(@nanmean,phigh);
            plowMat{rowi}(coli,:)  = cellfun(@nanmean,plow);
            
            % shuffled distribution
            rng('default');
            phigh = []; plow = [];
            for bini = 1:length(delayBins)-1
                for triali = 1:size(tempdata,2)
                    % shuffle 1000 times
                    disp('Shuffling')
                    for n = 1:1000
                        tempdata(:,triali) = randsample(tempdata(:,triali),size(tempdata,1));
                    end                                        
                    
                    % get temporary data at trial res
                    trialdata = [];
                    trialdata = tempdata(delayBins(bini)+1:delayBins(bini+1),triali);
                    
                    % get phigh and plow
                    phigh{bini}(triali) = (numel(find(trialdata > highCohThreshold(rowi))))/numel(trialdata);
                    plow{bini}(triali)  = (numel(find(trialdata < lowCohThreshold(rowi))))/numel(trialdata);
                
                end
            end
            phighShuf{rowi}(coli,:) = cellfun(@nanmean,phigh);
            plowShuf{rowi}(coli,:)  = cellfun(@nanmean,plow);            
            
        end
    end
end
phighMat = vertcat(phighMat{:});
plowMat  = vertcat(plowMat{:});
phighShuf = vertcat(phighShuf{:});
plowShuf  = vertcat(plowShuf{:});

delayX = linspace(0,30,30/5); % 5s bins
figure('color','w'); hold on;
shadedErrorBar(delayX(2:end),mean(phighMat,1),stderr(phighMat,1),'b',0)
%shadedErrorBar(delayX(2:end),mean(phighShuf,1),stderr(phighShuf,1),'r',0)
plot(delayX(2:end),mean(phighShuf,1),'r','LineWidth',1)
axis tight
ylim([0.05 0.18])

p=[];
for i = 1:size(phighMat,2)
    [h,p(i),ci{i},stat{i}] = ttest(phighMat(:,i),mean(phighShuf(i),1));
end
p = p.*(size(phighMat,2))


%{
for rowi = 1:size(thetaC,1)
    for coli = 1:size(thetaC,2)
        if isempty(thetaC{rowi,coli})==0
            % av over trials
            remTrials = [];
            remTrials = find(thetaC{rowi,coli}(1,:)==0);
            thetaC{rowi,coli}(:,remTrials)=[];
            thetaCavg{rowi,coli} = mean(thetaC{rowi,coli},2);
            % get first few sec
            crate = 4; % 4 epochs/sec
            % probability of high coh event in first half vs second half of
            % delay
            firstHalf = 1:round(length(thetaCavg{rowi,coli})/2);
            secHalf = round(length(thetaCavg{rowi,coli})/2):length(thetaCavg{rowi,coli});
            % temp coh
            for triali = 1:size(thetaC{rowi,coli},2)
                tempCoh = [];
                tempCoh = thetaC{rowi,coli}(:,triali);
                pFirst{rowi,coli}(triali)=numel(find(tempCoh(firstHalf)>highCohThreshold(rowi)))/numel(firstHalf);
                pSec{rowi,coli}(triali)=numel(find(tempCoh(secHalf)>highCohThreshold(rowi)))/numel(secHalf);
                pFirstL{rowi,coli}(triali)=numel(find(tempCoh(firstHalf)<lowCohThreshold(rowi)))/numel(firstHalf);
                pSecL{rowi,coli}(triali)=numel(find(tempCoh(secHalf)<lowCohThreshold(rowi)))/numel(secHalf);
            end

        end
    end
end
% avg probability of observing high coh event during first half vs
% second half of delay
avgPfirst  = cellfun(@mean,pFirst);
avgPsecond = cellfun(@mean,pSec);
avgPfirstL  = cellfun(@mean,pFirstL);
avgPsecondL = cellfun(@mean,pSecL);

% reorient
sessPfirst = avgPfirst(:);
sessPsecond = avgPsecond(:);
sessPfirstL = avgPfirstL(:);
sessPsecondL = avgPsecondL(:);

sessPfirst(isnan(sessPfirst))=[];
sessPsecond(isnan(sessPsecond))=[];
sessPfirstL(isnan(sessPfirstL))=[];
sessPsecondL(isnan(sessPsecondL))=[];

data2plot = [];
data2plot{1} = sessPfirst; data2plot{2} = sessPsecond;
multiBoxPlot(data2plot,[{'First Half'} {'Second Half'}],'Prob. High coh.','vertical','n')
multiBarPlot(data2plot,[{'First Half'} {'Second Half'}],'Prob. High coh.')    
stat_test = 'ttest'; parametric = 'y'; numCorrections = [];
readStats(sessPfirst,sessPsecond,parametric,stat_test,'p (high coh.)',numCorrections);

data2plot = [];
data2plot{1} = sessPfirstL; data2plot{2} = sessPsecondL;
multiBoxPlot(data2plot,[{'First Half'} {'Second Half'}],'Prob. Low coh.','vertical','n')
multiBarPlot(data2plot,[{'First Half'} {'Second Half'}],'Prob. Low coh.')    
readStats(sessPfirstL,sessPsecondL,parametric,stat_test,'p (high coh.)',numCorrections);

% -- plot example data -- %
rati = 2; sessi=1; triali=11;
%rati = 3; sessi=6; triali=6;
%rati = 5; sessi=3; triali=8;

% temporary variable
ratID = fieldnames(dataSpkLFP);
sessions = fieldnames(dataSpkLFP.(ratID{rati}));
tempData = [];
tempData = dataSpkLFP.(ratID{rati}).(sessions{sessi}).processed.spksLFPs;

% now compute coherence over moving windows
data = tempData{triali};
cohInd = [1 2]; % compute coherence between signals 1 and 2
cohThresholds = [highCohThreshold(rati) lowCohThreshold(rati)];
plotfig = 'y';
if rati > 3
    signalInd = [1:3]; % only rows 1:3 contain LFP data. The rest are units
    srate = 2000;
    % for stout rats, remove the first 10sec cause this
    % wasn't delay
    tempData{triali}(:,1:10*srate)=[];
else
    signalInd = [1:2];
    srate = 2035;
end
getHighAndLowCohData(tempData{triali},cohInd,signalInd,cohThresholds,srate,plotfig);
box off

%{
% generate time variable (this is from the getHighAndLowCohData code)
if rati > 3
    Fs = 2000;
    N = (Fs*20); % delay interval of 20s on DNMP (Stout et al., 2020)
    Nstep=round(0.25*Fs); % moving window of 0.25s (250ms)
    Nwin=round(Fs*1.25);  % number of samples in window
    winstart=1:Nstep:N-Nwin+1;
    nw=length(winstart);
    winmid=winstart+round(Nwin/2);
else
    % on DA, first trial is removed. In the struct
    %dataSpkLFPs, this is taken care of during analysis. For thetaC, its
    %already been taken care of. To align the two, you just need to subtract
    %a trial from the expected trial (this replicates to the function used
    %above)
    triali = triali-1; 
    Fs = 2035;
    N = (Fs*30); % delay interval of 30s on DA (Hallock et al., 2016)
    Nstep=round(0.25*Fs); % moving window of 0.25s (250ms)
    Nwin=round(Fs*1.25);  % number of samples in window
    winstart=1:Nstep:N-Nwin+1;
    nw=length(winstart);
    winmid=winstart+round(Nwin/2);
end
t=winmid/Fs;

figure('color','w');
stem(t,thetaC{rati,sessi}(:,triali),'k');
box off; hold on;
ylimits = ylim;
xlimits = xlim;
line([xlimits(1) xlimits(2)],[highCohThreshold(rati) highCohThreshold(rati)],'color','b','LineStyle','--')
line([xlimits(1) xlimits(2)],[lowCohThreshold(rati) lowCohThreshold(rati)],'color','r','LineStyle','--')    
ylabel('Coherence')
xlabel('Coh. Epoch')
title([ratID{rati},' session',num2str(sessi),' trial',num2str(triali)])
axis tight; ylim([0 .6])
%}

% artifact removal 4 replication
%{
% this approach is very exclusive and entirely removes instances where
% delta coh is greater than theta coh. I did this in the actual
% analyses, but maybe this isn't actually the best case scenario for
% these data. Instead, we will set thresholds for each rat and use
% them.

% does freuqency of high and low coh events vary over delay?
ratID = fieldnames(dataSpkLFP);
for rati = 1:length(ratID)
    disp(['Working with rat',num2str(rati)])
    sessions = fieldnames(dataSpkLFP.(ratID{rati}));
    for sessi = 1:length(sessions)
        tempdata = [];
        tempdata = dataSpkLFP.(ratID{rati}).(sessions{sessi}).processed.epoch;
        for triali = 1:length(tempdata)
            % remove first 1/3rd of epochs if working with stout 2022 data
            % bc 1st 10s is not delay, 20s after is
            tempdata2 = [];
            tempdata2 = tempdata{triali};                
            if rati > 3
                % remove
                numepoch = [];
                numepoch = size(tempdata2,2);
                idxRem = round(numepoch*(1/3));
                tempdata2(:,1:idxRem)=[];
            end

            % find high coh and low coh events
            firstHalf = 1:round(size(tempdata2,2)/2);
            secHalf   = round(size(tempdata2,2)/2):size(tempdata2,2);

            % get data
            cohFirst = []; cohSec = [];
            cohFirst = tempdata2(2,firstHalf);
            cohSec   = tempdata2(2,secHalf);

            % get prob of high and prob of low
            numLowB  = numel(find(contains(cohFirst,'lowCoh')));
            numHighB = numel(find(contains(cohFirst,'highCoh')));
            numLowA  = numel(find(contains(cohSec,'lowCoh')));
            numHighA = numel(find(contains(cohSec,'highCoh')));

            pLowF{rati,sessi}(triali) = numLowB/numel(cohFirst);
            pLowS{rati,sessi}(triali) = numLowA/numel(cohSec);
            pHighF{rati,sessi}(triali) = numHighB/numel(cohFirst);
            pHighS{rati,sessi}(triali) = numHighA/numel(cohSec);

        end
    end
end

% plot out
sessLowF = pLowF(:); % first half of delay
sessLowS = pLowS(:); % sec half of delay
sessHighF = pHighF(:); % first half of delay
sessHighS = pHighS(:); % sec half of delay

% remove empty arrays
sessLowF = emptyCellErase(sessLowF);
sessLowS = emptyCellErase(sessLowS);
sessHighF = emptyCellErase(sessHighF);
sessHighS = emptyCellErase(sessHighS);        

% get avgs
avgLowF  = cellfun(@mean,sessLowF);
avgLowS  = cellfun(@mean,sessLowS);
avgHighF = cellfun(@mean,sessHighF);
avgHighS = cellfun(@mean,sessHighS);

data = [];
data{1} = avgLowF;
data{2} = avgLowS;
xLabels = [{'Low Coh First'} {'Low Coh Last'}];
yLabel = 'avg probability of event';
orient = 'vertical';
outlier = 'n';
multiBoxPlot(data,xLabels,yLabel,orient,outlier)
[h,p]=ttest(data{1},data{2})

data = [];
data{1} = avgHighF;
data{2} = avgHighS;
xLabels = [{'High Coh First'} {'High Coh Last'}];
yLabel = 'avg probability of event';
orient = 'vertical';
outlier = 'n';
multiBoxPlot(data,xLabels,yLabel,orient,outlier)   
[h,p]=ttest(data{1},data{2})
%}
%}

% run an fft over your signal
for rowi = 1:size(thetaC,1)
    for coli = 1:size(thetaC,2)
        thetaAvg{rowi,coli} = mean(thetaC{rowi,coli},2);
    end
end
thetaAvg = thetaAvg(:);
thetaAvg = emptyCellErase(thetaAvg);
thetaAvg = horzcat(thetaAvg{:});

figure('color','w');
delayX = linspace(0,30,size(thetaAvg,1)); % 5s bins
shadedErrorBar(delayX,mean(thetaAvg,2),stderr(thetaAvg,2),'k',0);
box off
mean(lowCohThreshold)

% plot data as an oscillator
srate = 115/30;
exData = thetaC{1}(:);
figure; 
subplot 311; 
plot(exData-mean(exData))
subplot 312
plot(exData);
subplot 313
smoothEx = smoothdata(exData,'gauss',40);
plot(smoothEx)

[pxx,f] = periodogram(exData',[],[],srate)
figure; plot(f,log10(pxx))
xlim([0 0.04])

% -- autocorrelation -- %
% at the fifth lag, there is no sharing of data between lags
figure('color','w'); 
[acf,confAcf] = autocorr(exData,'NumLags',40)
[acf_shuff,confShuf] = autocorr(randsample(exData,length(exData)),'NumLags',40);

plot(0:40,acf,'k');
hold on; plot(0:40,acf_shuff,'r');

delayBins = linspace(0,size(thetaC{1},1),30/5); % 5s bins
acf = []; acf_shuff = [];
for rowi = 1:size(thetaC,1)
    for coli = 1:size(thetaC,2)
        if isempty(thetaC{rowi,coli})==0
            % av over trials
            remTrials = [];
            remTrials = find(thetaC{rowi,coli}(1,:)==0);
            thetaC{rowi,coli}(:,remTrials)=[];            
            % get phigh and plow over trials
            tempdata = []; tempdata = thetaC{rowi,coli};
            for triali = 1:size(tempdata,2)
                % get temporary data at trial res
                trialdata = [];
                trialdata = tempdata(:,triali);

                % autocorr
                [acf{rowi,coli}(triali,:),confAcf] = autocorr(trialdata,'NumLags',50);

            end

            % shuffled distribution
            rng('default');
            phigh = []; plow = [];
            for bini = 1:length(delayBins)-1
                for triali = 1:size(tempdata,2)
                    % shuffle 1000 times
                    disp('Shuffling')
                    for n = 1:1000
                        tempdata(:,triali) = randsample(tempdata(:,triali),size(tempdata,1));
                    end                                        
                    
                    % get temporary data at trial res
                    trialdata = [];
                    trialdata = tempdata(:,triali);
                    
                    % autocorr
                    [acf_shuff{rowi,coli}(triali,:),confAcf] = autocorr(trialdata,'NumLags',50);

                end
            end
        end
    end
end

for rowi = 1:size(acf,1)
    for coli = 1:size(acf,2)
        acf_avg{rowi,coli} = mean(acf{rowi,coli},1);
        acf_shuff_avg{rowi,coli} = mean(acf_shuff{rowi,coli},1);
    end
end
acf_avg = acf_avg(:);
acf_shuff_avg = acf_shuff_avg(:);
[~,remData] = emptyCellErase(acf_avg);
acf_avg(remData)=[];
acf_shuff_avg(remData)=[];

% collapse across sess
acf_sess = vertcat(acf_avg{:});
acf_sess_shuff = vertcat(acf_shuff_avg{:});

figure('color','w'); hold on;
shadedErrorBar(0:50,mean(acf_sess,1),stderr(acf_sess,1),'k',1);
shadedErrorBar(0:50,mean(acf_sess_shuff,1),stderr(acf_sess_shuff,1),'r',1);
ylabel('correlation')
xlabel('lag')

figure('color','w'); hold on;
shadedErrorBar(0:50,mean(acf_sess,1),stderr(acf_sess,1),'k',1);
%shadedErrorBar(0:50,mean(acf_sess_shuff,1),stderr(acf_sess_shuff,1),'r',1);
ylabel('correlation')
xlabel('lag')
xlim([0 10])

lag = 5;
[z,p] = ztest(mean(acf_sess_shuff(:,5)),mean(acf_sess(:,5)),std(acf_sess(:,5)));

for i = 1:10
    [h,p(i)] = ttest(acf_sess(:,i),mean(acf_sess_shuff(:,i)));
end
figure; plot(0:9,p.*5)

figure('color','w'); hold on;
    shadedErrorBar(0:50,mean(acf_sess,1),stderr(acf_sess,1),'k',1);
    plot(0:50,mean(acf_sess_shuff,1),'r','LineWidth',1);
    ylabel('correlation')
    xlabel('lag')
    xlim([0 9])
yyaxis right; 
    p(1:5)=NaN;
    plot(0:9,p.*4)
    xlimits = xlim;
    ylimits = ylim;
    line([xlimits(1) xlimits(2)],[0.05 0.05],'Color','r')
    ylabel('p-value')

%% prep signal data for analysis
clear datahigh datalow dataex C t
disp('Preprocessing stout and hallock data for analysis and generating a new variables to work with "datahigh" and "datalow".')
load_highLowCohData = 1; % setting to 1 bc it takes a long time
disp('Code here would be great for plotting example trials with coh epochs')
if load_highLowCohData == 0
    ratID = fieldnames(dataSpkLFP);
    for rati = 1:length(ratID) % rats 4:end have re
        disp(['Working with rat',num2str(rati)])
        sessions = fieldnames(dataSpkLFP.(ratID{rati}));

        % skip certain rats who don't have re lfp
        for sessi = 1:length(sessions)

            % temporary variable
            tempData = [];
            tempData = dataSpkLFP.(ratID{rati}).(sessions{sessi}).processed.spksLFPs;

            % dataSpkLFP....epoch has HPC as signal 1
            % dataSpkLFP....spksLFPs have HPC as signal 2
            % this got flipped in SCRIPT_processed2 by mistake

            % get high coh and low coh epochs
            if rati > 3
                looper = 1:length(tempData);
            else
                looper = 2:length(tempData);
            end
            for triali = looper

                % now compute coherence over moving windows
                data = tempData{triali};
                cohInd = [1 2]; % compute coherence between signals 1 and 2
                cohThresholds = [highCohThreshold(rati) lowCohThreshold(rati)];
                plotfig = 'n';
                if rati > 3
                    signalInd = [1:3]; % only rows 1:3 contain LFP data. The rest are units
                    srate = 2000;
                    % for stout rats, remove the first 10sec cause this
                    % wasn't delay
                    tempData{triali}(:,1:10*srate)=[];
                else
                    signalInd = [1:2];
                    srate = 2035;
                end
                [datahigh{rati,sessi}{triali},datalow{rati,sessi}{triali},dataex{rati,sessi}{triali},C{rati,sessi}{triali},t{rati}] = getHighAndLowCohData(data,cohInd,signalInd,cohThresholds,srate,plotfig);

                % now artifact reject datahigh and datalow
                %datahigh = emptyCellErase(datahigh);
                %datalow  = emptyCellErase(datalow);
                %dataex   = emptyCellErase(dataex);

                % get baselines
                pfc_mean = dataSpkLFP.(ratID{rati}).(sessions{sessi}).processed.baselineLFP.pfc_mean;
                pfc_std = dataSpkLFP.(ratID{rati}).(sessions{sessi}).processed.baselineLFP.pfc_std;
                hpc_mean = dataSpkLFP.(ratID{rati}).(sessions{sessi}).processed.baselineLFP.hpc_mean;
                hpc_std = dataSpkLFP.(ratID{rati}).(sessions{sessi}).processed.baselineLFP.hpc_std;

                % all variables are same size**
                for epochi = 1:length(datahigh{rati,sessi}{triali})
                    temphigh = []; templow = []; cthetaTemp = [];
                    temphigh   = datahigh{rati,sessi}{triali}{epochi};
                    templow    = datalow{rati,sessi}{triali}{epochi};
                    cthetaTemp = C{rati,sessi}{triali}(epochi);
                    if isempty(temphigh)==0
                        cdelta = []; zhigh = []; idxArtifact = []; percSat = [];                    
                        % identify if delta coh > theta coh (happens during
                        % artifacts)
                        cdelta = mean(mscohere(temphigh(1,:),temphigh(2,:),[],[],[1:.5:4],srate));
                        if cdelta > cthetaTemp
                            datahigh{rati,sessi}{triali}{epochi} = [];
                            disp('High epoch removed due to candidate artifact - delta > theta coh.')
                        end
                        % z transform signal data (sig1 = PFC)
                        zhigh(1,:) = (temphigh(1,:)-pfc_mean)/pfc_std;
                        zhigh(2,:) = (temphigh(2,:)-hpc_mean)/hpc_std;
                        % find artifacts
                        idxArtifact = find(zhigh(1,:) > 4 | zhigh(1,:) < -4 | zhigh(2,:) > 4 | zhigh(2,:) < -4);
                        percSat = numel(idxArtifact)/length(zhigh);
                        if percSat > 1
                            datahigh{rati,sessi}{triali}{epochi} = [];
                            disp('High epoch removed due to candidate artifact - extreme voltage')                    
                        end
                    end

                    if isempty(templow)==0
                        cdelta = []; zlow = []; idxArtifact = []; percSat = [];
                        % identify if delta coh > theta coh (happens during
                        % artifacts)
                        cdelta = mean(mscohere(templow(1,:),templow(2,:),[],[],[1:.5:4],srate));
                        if cdelta > cthetaTemp
                            datalow{rati,sessi}{triali}{epochi} = [];
                            disp('Low epoch removed due to candidate artifact - delta > theta coh.')
                        end
                        % z transform signal data (sig1 = PFC)
                        zlow(1,:) = (templow(1,:)-pfc_mean)/pfc_std;
                        zlow(2,:) = (templow(2,:)-hpc_mean)/hpc_std;
                        % find artifacts
                        idxArtifact = find(zlow(1,:) > 4 | zlow(1,:) < -4 | zlow(2,:) > 4 | zlow(2,:) < -4);
                        percSat = numel(idxArtifact)/numel(zlow);
                        if percSat > 1
                            datalow{rati,sessi}{triali}{epochi} = [];
                            disp('Low epoch removed due to candidate artifact - delta > theta coh.')                    
                        end
                    end                

                end
                disp(['Finished with ',ratID{rati},' ',sessions{sessi},' trial',num2str(triali)])
            end        
            disp(['Finished with rat',num2str(rati),' session',num2str(sessi)])
        end

    end
    save('data_cohProcessed_12102022','datahigh','datalow','C','t','dataex')
else
    load('data_cohProcessed_12102022')
end

%% preprocess
%clearvars -except dataSpkLFP datahigh datalow
clearvars -except datahigh datalow dataSpkLFP sourceRoot sourceFolder sourceData sourceCode sourceRawCode

% renanlysis 5-23-2023
preprocess_pfcrehc = 0;
if preprocess_pfcrehc == 1
    load('data_cohProcessed_12102022');
    for rowi = 1:size(datahigh,1)
        for coli = 1:size(datahigh,2)
            for triali = 1:length(datahigh{rowi,coli})
                if isempty(datahigh{rowi,coli}{triali})==0 && isempty(datalow{rowi,coli}{triali})==0
                    % remove empty
                    datahigh{rowi,coli}{triali} = emptyCellErase(datahigh{rowi,coli}{triali});
                    datalow{rowi,coli}{triali}  = emptyCellErase(datalow{rowi,coli}{triali});
                end
            end
        end
    end
    % collapse over trials to get all data as one array           
    for rowi = 1:size(datahigh,1)
        for coli = 1:size(datahigh,2)
            if isempty(datahigh{rowi,coli})==0 && isempty(datalow{rowi,coli})==0
                % remove empty
                datahigh{rowi,coli} = horzcat(datahigh{rowi,coli}{:});
                datalow{rowi,coli}  = horzcat(datalow{rowi,coli}{:});
            end
        end
    end
    % use og variables for sfc
    datahighog = datahigh; datalowog = datalow;
    datahigh = datahigh(4:end,:);
    datalow  = datalow(4:end,:);

    % now visually inspect and delete trials
    for rowi = 1:size(datahigh,1)
        for coli = 1:size(datahigh,2)
            figure('color','w');
            set(gcf, 'Position', get(0, 'Screensize'));
            tempdata = []; tempdata = datahigh{rowi,coli};
            idxrem = []; counter = 0;
            for figi = 1:length(tempdata)
                counter = counter+1;
                subplot(20,5,counter); hold on;
                plot(zscore(tempdata{figi}(1,:)),'b');
                plot(zscore(tempdata{figi}(2,:)),'r');
                plot(zscore(tempdata{figi}(3,:)),'k');
                title(['Index ',num2str(figi)],'FontSize',7)
                axis tight;
                if counter == 100 || figi == length(tempdata)
                    idxrem = horzcat(idxrem,str2num(input('Enter which indices to remove ','s')));
                    %pause;
                    close;
                    figure('color','w');
                    set(gcf, 'Position', get(0, 'Screensize'));  
                    counter = 0;
                end
            end
            % remove tagged trials
            datahighRem{rowi,coli} = idxrem;
            datahigh{rowi,coli}(idxrem)=[];
        end
    end
    save('data_high_cleaned','datahigh','datahighRem');

    % now visually inspect and delete trials
    for rowi = 1:size(datalow,1)
        for coli = 1:size(datalow,2)
            figure('color','w');
            set(gcf, 'Position', get(0, 'Screensize'));
            tempdata = []; tempdata = datalow{rowi,coli};
            idxrem = []; counter = 0;
            for figi = 1:length(tempdata)
                counter = counter+1;
                subplot(20,5,counter); hold on;
                plot(zscore(tempdata{figi}(1,:)),'b');
                plot(zscore(tempdata{figi}(2,:)),'r');
                plot(zscore(tempdata{figi}(3,:)),'k');
                title(['Index ',num2str(figi)],'FontSize',7)
                axis tight;
                if counter == 100 || figi == length(tempdata)
                    idxrem = horzcat(idxrem,str2num(input('Enter which indices to remove ','s')));
                    %pause;
                    close;
                    figure('color','w');
                    set(gcf, 'Position', get(0, 'Screensize'));  
                    counter = 0;
                end
            end
            % remove tagged trials
            datalowRem{rowi,coli} = idxrem;
            datalow{rowi,coli}(idxrem)=[];
        end
    end
    save('data_low_cleaned','datalow','datalowRem');
else
    load('data_high_cleaned');
    load('data_low_cleaned');
end
%{
% a check

% double clean
idxMet = [];
for rowi = 1:size(datahigh,1) % 6/13/23 did rat 1; 6/19 did rat 2;
    for coli = 1:size(datahigh,2)
        for epochi = 1:length(datahigh{rowi,coli})
            tempdata = []; tempdata = datahigh{rowi,coli}{epochi}(1,:);
            tempdata2 = []; tempdata2 = datahigh{rowi,coli}{epochi}(3,:);
            idxMet{rowi,coli}(epochi) = ~isempty(find(tempdata > 3500 | tempdata < -3500 | tempdata2 > 3500 | tempdata2 < -3500));
        end
    end
end
for rowi = 1:size(datahigh,1) % 6/13/23 did rat 1; 6/19 did rat 2;
    for coli = 1:size(datahigh,2)
        try datahigh{rowi,coli}(idxMet{rowi,coli})=[]; end
    end
end

% do the same for low coh
idxMet = [];
for rowi = 1:size(datalow,1) % 6/13/23 did rat 1; 6/19 did rat 2;
    for coli = 1:size(datalow,2)
        for epochi = 1:length(datalow{rowi,coli})
            tempdata = []; tempdata = datalow{rowi,coli}{epochi}(1,:);
            tempdata2 = []; tempdata2 = datalow{rowi,coli}{epochi}(3,:);
            idxMet{rowi,coli}(epochi) = ~isempty(find(tempdata > 3500 | tempdata < -3500 | tempdata2 > 3500 | tempdata2 < -3500));
        end
    end
end
for rowi = 1:size(datalow,1) % 6/13/23 did rat 1; 6/19 did rat 2;
    for coli = 1:size(datalow,2)
        try datalow{rowi,coli}(idxMet{rowi,coli})=[]; end
    end
end

% fix the data
datahigh = datahigh(:);
datalow  = datalow(:);
[~,idx] = emptyCellErase(datahigh);
datahigh(idx)=[];
datalow(idx)=[];
[~,idx] = emptyCellErase(datalow);
datalow(idx)=[];
datahigh(idx)=[];
sesshigh = datahigh;
sesslow = datalow;
%}

% reformat
sesshigh = datahigh(:);
sesslow  = datalow(:);
sesshigh = emptyCellErase(sesshigh);
sesslow  = emptyCellErase(sesslow);

%% PFC-RE-HPC power
% get params
params = getCustomParams;
params.Fs = 2000;
params.fpass = [0 20];
params.tapers = [2 3];

% high coh epochs
for i = 1:length(sesshigh)
    for epochi = 1:length(sesshigh{i})
        pfc = []; hpc = []; re = [];
        pfc = sesshigh{i}{epochi}(1,:);
        hpc = sesshigh{i}{epochi}(2,:);
        re  = sesshigh{i}{epochi}(3,:);
        
        % get power
        %[sPFhigh{i}{epochi},f] = pwelch(pfc,[],[],[1:.5:20],fs);
        %[sHChigh{i}{epochi},f] = pwelch(hpc,[],[],[1:.5:20],fs);
        %[sREhigh{i}{epochi},f] = pwelch(re,[],[],[1:.5:20],fs);
        
        sPFhigh{i}{epochi}     = mtspectrumc(pfc,params);
        sREhigh{i}{epochi}     = mtspectrumc(re,params);
        [sHChigh{i}{epochi},f] = mtspectrumc(hpc,params);
         
         % log10
         sPFhigh{i}{epochi} = log10(sPFhigh{i}{epochi});
         sREhigh{i}{epochi} = log10(sREhigh{i}{epochi});
         sHChigh{i}{epochi} = log10(sHChigh{i}{epochi});        

    end
    disp(['Finished with high coh epochs in session ',num2str(i)])
end

% low coh
for i = 1:length(sesslow)
    for epochi = 1:length(sesslow{i})
        pfc = []; hpc = []; re = [];
        pfc = sesslow{i}{epochi}(1,:);
        hpc = sesslow{i}{epochi}(2,:);
        re  = sesslow{i}{epochi}(3,:);

        % get power
        %[sPFlow{i}{epochi},f] = pwelch(pfc,[],[],[1:.5:20],fs);
        %[sHClow{i}{epochi},f] = pwelch(hpc,[],[],[1:.5:20],fs);
        %[sRElow{i}{epochi},f] = pwelch(re,[],[],[1:.5:20],fs);
        
        sPFlow{i}{epochi}     = mtspectrumc(pfc,params);
        sRElow{i}{epochi}     = mtspectrumc(re,params);
        [sHClow{i}{epochi},f] = mtspectrumc(hpc,params);
         
         % log10
         sPFlow{i}{epochi} = log10(sPFlow{i}{epochi});
         sRElow{i}{epochi} = log10(sRElow{i}{epochi});
         sHClow{i}{epochi} = log10(sHClow{i}{epochi}); 
    end
    disp(['Finished with low coh epochs in session ',num2str(i)])
end

% get power data into matrices
for i = 1:length(sPFhigh)
    try sPFhmat{i} = (mean(horzcat(sPFhigh{i}{:}),2)); end
    try sHChmat{i} = (mean(horzcat(sHChigh{i}{:}),2)); end
    try sREhmat{i} = (mean(horzcat(sREhigh{i}{:}),2)); end
 
    try sPFlmat{i} = (mean(horzcat(sPFlow{i}{:}),2)); end
    try sHClmat{i} = (mean(horzcat(sHClow{i}{:}),2)); end
    try sRElmat{i} = (mean(horzcat(sRElow{i}{:}),2)); end
end

sessPFhigh = horzcat(sPFhmat{:});
sessHChigh = horzcat(sHChmat{:});
sessREhigh = horzcat(sREhmat{:});
sessPFlow = horzcat(sPFlmat{:});
sessHClow = horzcat(sHClmat{:});
sessRElow = horzcat(sRElmat{:});    

figure('color','w'); 
subplot 311; hold on;
    shadedErrorBar(f,mean(sessPFhigh',1),stderr(sessPFhigh',1),'b',0)
    shadedErrorBar(f,mean(sessPFlow',1),stderr(sessPFlow',1),'r',0)
subplot 312; hold on;
    shadedErrorBar(f,mean(sessREhigh',1),stderr(sessREhigh',1),'b',0)
    shadedErrorBar(f,mean(sessRElow',1),stderr(sessRElow',1),'r',0)
subplot 313; hold on;
    shadedErrorBar(f,mean(sessHChigh',1),stderr(sessHChigh',1),'b',0)
    shadedErrorBar(f,mean(sessHClow',1),stderr(sessHClow',1),'r',0)
xlabel('Frequency (Hz')
ylabel('Power')

% get theta avg over trials
thetaf = find(f > 6 & f < 9);
thetaPFh = mean(sessPFhigh(thetaf,:),1);
thetaHCh = mean(sessHChigh(thetaf,:),1);
thetaREh = mean(sessREhigh(thetaf,:),1);
thetaPFl = mean(sessPFlow(thetaf,:),1);
thetaHCl = mean(sessHClow(thetaf,:),1);
thetaREl = mean(sessRElow(thetaf,:),1);

data2plot = [];
data2plot{1} = ((thetaPFh-thetaPFl)./(thetaPFh+thetaPFl))';
data2plot{2} = ((thetaREh-thetaREl)./(thetaREh+thetaREl))';
data2plot{3} = ((thetaHCh-thetaHCl)./(thetaHCh+thetaHCl))';
multiBarPlot(data2plot,[{'PFC'} {'RE'} {'HPC'}],'Log10 power')
ylim([-0.01 0.04])

% stats
stat_test = 'ttest'; parametric = 'y'; numCorrections = 3;
readStats(data2plot{1},0,parametric,stat_test,'Theta Pow. PFC High v Low',numCorrections);
readStats(data2plot{2},0,parametric,stat_test,'Theta Pow. RE High v Low',numCorrections);
readStats(data2plot{3},0,parametric,stat_test,'Theta Pow. HC High v Low',numCorrections);

% one way anova to test the effect of brain area on power
anova1(horzcat(data2plot{:}));

%% pfc-re coherence during pfc-hpc coherence
loadCohPFCREHPC = 1;
if loadCohPFCREHPC == 0
    % reran on 5-23-2023 after removing signals manually (preprocess
    % section)
    % high coh epochs
    for i = 1:length(sesshigh)
        for epochi = 1:length(sesshigh{i})
            pfc = []; hpc = []; re = [];
            pfc = sesshigh{i}{epochi}(1,:);
            hpc = sesshigh{i}{epochi}(2,:);
            re  = sesshigh{i}{epochi}(3,:);

            % coherence
            [Chigh_pfcre{i}{epochi}] = mscohere(pfc,re,[],[],[1:.5:20],2000);
            [Chigh_hpcre{i}{epochi}] = mscohere(hpc,re,[],[],[1:.5:20],2000);

        end
        disp(['Finished with high coh epochs in session ',num2str(i)])
    end

    % low coh
    for i = 1:length(sesslow)
        for epochi = 1:length(sesslow{i})
            pfc = []; hpc = []; re = [];
            pfc = sesslow{i}{epochi}(1,:);
            hpc = sesslow{i}{epochi}(2,:);
            re  = sesslow{i}{epochi}(3,:);

            % coherence
            [Clow_pfcre{i}{epochi}] = mscohere(pfc,re,[],[],[1:.5:20],2000);
            [Clow_hpcre{i}{epochi}] = mscohere(hpc,re,[],[],[1:.5:20],2000);

        end
        disp(['Finished with low coh epochs in session ',num2str(i)])
    end
    save('data_highCoh_pfcrehpc','Clow_pfcre','Clow_hpcre','Chigh_pfcre','Chigh_hpcre')
else
    disp('Loading coherence analysis (PFC-RE / RE-HPC) performed over high and low coh epochs bw PFC-HPC')
    load('data_highCoh_pfcrehpc')
end

% convert data into matrix format (epoch x frequency)
for sessi = 1:length(Chigh_hpcre)
    Chm_hpcre{sessi} = vertcat(Chigh_hpcre{sessi}{:});
    Chm_pfcre{sessi} = vertcat(Chigh_pfcre{sessi}{:});
    Clm_hpcre{sessi} = vertcat(Clow_hpcre{sessi}{:});
    Clm_pfcre{sessi} = vertcat(Clow_pfcre{sessi}{:});
end
Clmavg_hpcre = cellfun(@mean,Clm_hpcre,'UniformOutput',false);
Clmavg_pfcre = cellfun(@mean,Clm_pfcre,'UniformOutput',false);
Chmavg_hpcre = cellfun(@mean,Chm_hpcre,'UniformOutput',false);
Chmavg_pfcre = cellfun(@mean,Chm_pfcre,'UniformOutput',false);

% concatenate into matrix (sessions x freq)
Clmsess_hpcre = vertcat(Clmavg_hpcre{:});
Clmsess_pfcre = vertcat(Clmavg_pfcre{:});
Chmsess_hpcre = vertcat(Chmavg_hpcre{:});
Chmsess_pfcre = vertcat(Chmavg_pfcre{:});

figure('color','w'); f = [1:.5:20];
subplot 211; hold on;
    s1 = shadedErrorBar(f,mean(Chmsess_pfcre,1),stderr(Chmsess_pfcre,1),'b',0)
    s2 = shadedErrorBar(f,mean(Clmsess_pfcre,1),stderr(Clmsess_pfcre,1),'r',0)
    ylabel('Coherence')
    title('PFC-RE')
    %legend([s1.mainLine, s2.mainLine],'High PFC-HPC coh.','Low PFC-HPC coh.')
    axis tight;
    ylim([0.18 .7])
subplot 212; hold on;
    s1 = shadedErrorBar(f,mean(Chmsess_hpcre,1),stderr(Chmsess_hpcre,1),'b',0)
    s2 = shadedErrorBar(f,mean(Clmsess_hpcre,1),stderr(Clmsess_hpcre,1),'r',0)
    ylabel('Coherence')
    title('HPC-RE')
    %legend([s1.mainLine, s2.mainLine],'High PFC-HPC coh.','Low PFC-HPC coh.')
    axis tight;
    ylim([0.18 .7])
    
% difference
idxTheta = find(f>6 & f<9);
diffPFCRE = (mean(Chmsess_pfcre(:,idxTheta),2)-mean(Clmsess_pfcre(:,idxTheta),2))./(mean(Chmsess_pfcre(:,idxTheta),2)+mean(Clmsess_pfcre(:,idxTheta),2));
diffHPCRE = (mean(Chmsess_hpcre(:,idxTheta),2)-mean(Clmsess_hpcre(:,idxTheta),2))./(mean(Chmsess_hpcre(:,idxTheta),2)+mean(Clmsess_hpcre(:,idxTheta),2));

data2plot = [];
data2plot = horzcat(diffPFCRE,diffHPCRE);
multiBarPlot(data2plot,[{'PFC-RE'} {'HPC-RE'}],'Theta coherence')
ylim([-0.1 0.5])

% stats
stat_test = 'ttest'; parametric = 'y'; numCorrections = 3;
readStats(data2plot(:,1),0,parametric,stat_test,'Theta Coh. PFC-RE high v low',numCorrections);
readStats(data2plot(:,2),0,parametric,stat_test,'Theta Coh. HC-RE high v low',numCorrections);
readStats(data2plot(:,1),data2plot(:,2),parametric,stat_test,'Theta Coh. HC-RE v PF-RE',numCorrections);

%% multivariate granger prediction
clear;
startup_mvgc1;

% concatenate data - this can be removed
load('data_high_cleaned');
load('data_low_cleaned');
sesshigh = datahigh(:);
sesslow  = datalow(:);
sesshigh = emptyCellErase(sesshigh);
sesslow  = emptyCellErase(sesslow);

% get model order
loadMO = 1;
if loadMO == 0
    for sessi = 1:length(sesshigh)
        disp(['Model order for session #',num2str(sessi)])
        for epochi = 1:length(sesshigh{sessi})
            % get LFP signals (1 = pfc, 2 = hpc, 3 = re)
            tempdata = [];
            tempdata = sesshigh{sessi}{epochi}(1:3,:);
            srate = 2000;
            % get mvgc parameters
            mvgc_params = get_mvgc_parameters(tempdata,srate);
            % get model order
            [moBICh{sessi}(epochi)] = get_mvgc_modelOrder(tempdata,mvgc_params,0);
        end

        for epochi = 1:length(sesslow{sessi})
            % get LFP signals (1 = pfc, 2 = hpc, 3 = re)
            tempdata = [];
            tempdata = sesslow{sessi}{epochi}(1:3,:);
            srate = 2000;
            % get mvgc parameters
            mvgc_params = get_mvgc_parameters(tempdata,srate);
            % get model order
            [moBICl{sessi}(epochi)] = get_mvgc_modelOrder(tempdata,mvgc_params,0);        
        end
    end
    info = 'model order for mvgc pfc-re-hpc';
    save('data_modelOrders','moBICh','moBICl','info')
else
    load('data_modelOrders');
end

% get model order and run granger
moL = horzcat(moBICl{:});
moH = horzcat(moBICh{:});

figure('color','w')
subplot 211;
    hold on;
    histogram(moL,'FaceColor','r');
    histogram(moH,'FaceColor','b');  
    box off
    xlabel('model order (lag)')
subplot 212;
    hold on;
    %[n,m,N] = size(reDataHigh{1}{1}{1});
    m=2501; n=3; N = 1; % dimensions of example dataset
    srate=2000;   
    %[mvgc_params] = get_mvgc_parameters(reDataHigh{1}{1}{1},srate);
    m1 = m-1;
    dt = 1/srate;
    tvec = (0:m1)*dt;
    % now use model orders to get indices
    t_moL = tvec(moL);
    t_moH = tvec(moH);
    histogram(t_moL*1000,'FaceColor','r');
    histogram(t_moH*1000,'FaceColor','b');   
    xlabel('model order (ms)')

% get average model order
moAll = horzcat(moH, moL);
mo       = round(median(moAll));
moTime   = tvec(mo);
moTimems = moTime*1000;

% -- granger -- %
clearvars -except datahigh datalow sesshigh sesslow dataSpkLFP sourceRoot sourceFolder sourceData sourceCode sourceRawCode mo
loadGP = 0;
if loadGP == 0
    for sessi = 1:length(sesshigh)
        disp(['Granger prediction for session #',num2str(sessi)])
        for epochi = 1:length(sesshigh{sessi})
            % get LFP signals (1 = pfc, 2 = hpc, 3 = re)
            tempdata = [];
            tempdata = sesshigh{sessi}{epochi}(1:3,:);
            srate = 2000;
            % get mvgc parameters
            mvgc_params = get_mvgc_parameters(tempdata,srate);
            mvgc_params.acmaxlags = 1000;
            mvgc_params.fres      = 2000;            
            % mvgc granger prediction
            [gpH{sessi}{epochi},freqs] = get_mvgc_freqGranger(tempdata,mvgc_params,mo);
        end
        for epochi = 1:length(sesslow{sessi})
            % get LFP signals (1 = pfc, 2 = hpc, 3 = re)
            tempdata = [];
            tempdata = sesslow{sessi}{epochi}(1:3,:);
            srate = 2000;
            % get mvgc parameters
            mvgc_params = get_mvgc_parameters(tempdata,srate);
            mvgc_params.acmaxlags = 1000;
            mvgc_params.fres      = 2000;            
            % mvgc granger prediction
            [gpL{sessi}{epochi},freqs] = get_mvgc_freqGranger(tempdata,mvgc_params,mo);
        end        
    end
    save('data_mvgc_pfcrehpc','gpH','gpL','freqs','mvgc_params');
else
    disp('Loading mvgc data')
    load('data_mvgc_pfcrehpc');
end
%clearvars -except gpH gpL freqs datahigh datalow sesshigh sesslow dataSpkLFP sourceData sourceCode mo

% indicator variables - this granger output is column predictor, row
% predicted
pf = 1; % signal 1
hc = 2; % signal 2
re = 3; % signal 3
for sessi = 1:length(gpH)
    for epochi = 1:length(gpH{sessi})
        % col is predictor, row is receiver
        gpH_hc2pf{sessi}{epochi} = gpH{sessi}{epochi}{pf,hc}; %hc->pf
        gpH_hc2re{sessi}{epochi} = gpH{sessi}{epochi}{re,hc}; %hc->re
        gpH_re2pf{sessi}{epochi} = gpH{sessi}{epochi}{pf,re}; %re->pf
        gpH_re2hc{sessi}{epochi} = gpH{sessi}{epochi}{hc,re}; %re->hc
        gpH_pf2hc{sessi}{epochi} = gpH{sessi}{epochi}{hc,pf}; %pf->hc
        gpH_pf2re{sessi}{epochi} = gpH{sessi}{epochi}{re,pf}; %pf->re
    end
    for epochi = 1:length(gpL{sessi})
        % col is predictor, row is receiver
        gpL_hc2pf{sessi}{epochi} = gpL{sessi}{epochi}{pf,hc};
        gpL_hc2re{sessi}{epochi} = gpL{sessi}{epochi}{re,hc};
        gpL_re2pf{sessi}{epochi} = gpL{sessi}{epochi}{pf,re};
        gpL_re2hc{sessi}{epochi} = gpL{sessi}{epochi}{hc,re};
        gpL_pf2hc{sessi}{epochi} = gpL{sessi}{epochi}{hc,pf};
        gpL_pf2re{sessi}{epochi} = gpL{sessi}{epochi}{re,pf};
    end    
end

% reformat data so that each cell is a session, and each session contains a
% matrix that is epoch (row) x grager outputs/frequency (column)
for i = 1:length(gpH_re2pf)
    gpH_hc2pf{i} = horzcat(gpH_hc2pf{i}{:})';
    gpH_hc2re{i} = horzcat(gpH_hc2re{i}{:})';
    gpH_re2pf{i} = horzcat(gpH_re2pf{i}{:})';
    gpH_re2hc{i} = horzcat(gpH_re2hc{i}{:})';
    gpH_pf2hc{i} = horzcat(gpH_pf2hc{i}{:})';
    gpH_pf2re{i} = horzcat(gpH_pf2re{i}{:})';
    
    gpL_hc2pf{i} = horzcat(gpL_hc2pf{i}{:})';
    gpL_hc2re{i} = horzcat(gpL_hc2re{i}{:})';
    gpL_re2pf{i} = horzcat(gpL_re2pf{i}{:})';
    gpL_re2hc{i} = horzcat(gpL_re2hc{i}{:})';
    gpL_pf2hc{i} = horzcat(gpL_pf2hc{i}{:})';
    gpL_pf2re{i} = horzcat(gpL_pf2re{i}{:})';    
end

% get avgs
gpH_hc2pf_avg = cellfun(@mean,gpH_hc2pf,'UniformOutput',false);
gpH_hc2re_avg = cellfun(@mean,gpH_hc2re,'UniformOutput',false);
gpH_re2pf_avg = cellfun(@mean,gpH_re2pf,'UniformOutput',false);
gpH_re2hc_avg = cellfun(@mean,gpH_re2hc,'UniformOutput',false);
gpH_pf2hc_avg = cellfun(@mean,gpH_pf2hc,'UniformOutput',false);
gpH_pf2re_avg = cellfun(@mean,gpH_pf2re,'UniformOutput',false);

gpL_hc2pf_avg = cellfun(@mean,gpL_hc2pf,'UniformOutput',false);
gpL_hc2re_avg = cellfun(@mean,gpL_hc2re,'UniformOutput',false);
gpL_re2pf_avg = cellfun(@mean,gpL_re2pf,'UniformOutput',false);
gpL_re2hc_avg = cellfun(@mean,gpL_re2hc,'UniformOutput',false);
gpL_pf2hc_avg = cellfun(@mean,gpL_pf2hc,'UniformOutput',false);
gpL_pf2re_avg = cellfun(@mean,gpL_pf2re,'UniformOutput',false);

% get a new matrix with sessions as rows and granger prediction on columns
gpH_hc2pf_sess = cellcat(gpH_hc2pf_avg,'vertcat','col');
gpH_hc2re_sess = cellcat(gpH_hc2re_avg,'vertcat','col');
gpH_re2pf_sess = cellcat(gpH_re2pf_avg,'vertcat','col');
gpH_re2hc_sess = cellcat(gpH_re2hc_avg,'vertcat','col');
gpH_pf2hc_sess = cellcat(gpH_pf2hc_avg,'vertcat','col');
gpH_pf2re_sess = cellcat(gpH_pf2re_avg,'vertcat','col');

gpL_hc2pf_sess = cellcat(gpL_hc2pf_avg,'vertcat','col');
gpL_hc2re_sess = cellcat(gpL_hc2re_avg,'vertcat','col');
gpL_re2pf_sess = cellcat(gpL_re2pf_avg,'vertcat','col');
gpL_re2hc_sess = cellcat(gpL_re2hc_avg,'vertcat','col');
gpL_pf2hc_sess = cellcat(gpL_pf2hc_avg,'vertcat','col');
gpL_pf2re_sess = cellcat(gpL_pf2re_avg,'vertcat','col');

% get data out of the cell array
gpH_hc2pf_sess = gpH_hc2pf_sess{:};
gpH_hc2re_sess = gpH_hc2re_sess{:};
gpH_re2pf_sess = gpH_re2pf_sess{:};
gpH_re2hc_sess = gpH_re2hc_sess{:};
gpH_pf2hc_sess = gpH_pf2hc_sess{:};
gpH_pf2re_sess = gpH_pf2re_sess{:};

gpL_hc2pf_sess = gpL_hc2pf_sess{:};
gpL_hc2re_sess = gpL_hc2re_sess{:};
gpL_re2pf_sess = gpL_re2pf_sess{:};
gpL_re2hc_sess = gpL_re2hc_sess{:};
gpL_pf2hc_sess = gpL_pf2hc_sess{:};
gpL_pf2re_sess = gpL_pf2re_sess{:};

% difference score 
diffPF2HC = (gpH_pf2hc_sess-gpL_pf2hc_sess)./(gpH_pf2hc_sess+gpL_pf2hc_sess);
diffHC2PF = (gpH_hc2pf_sess-gpL_hc2pf_sess)./(gpH_hc2pf_sess+gpL_hc2pf_sess);
diffHC2RE = (gpH_hc2re_sess-gpL_hc2re_sess)./(gpH_hc2re_sess+gpL_hc2re_sess);
diffPF2RE = (gpH_pf2re_sess-gpL_pf2re_sess)./(gpH_pf2re_sess+gpL_pf2re_sess);
diffRE2PF = (gpH_re2pf_sess-gpL_re2pf_sess)./(gpH_re2pf_sess+gpL_re2pf_sess);
diffRE2HC = (gpH_re2hc_sess-gpL_re2hc_sess)./(gpH_re2hc_sess+gpL_re2hc_sess);

% index for getting theta
thetaIdx = find(freqs >6 & freqs <9);

% plot HC-RE interactions
figure('color','w');
subplot 131; hold on;
data2plot = [];
data2plot{1} = mean(diffHC2RE(:,thetaIdx),2); % get theta freqs out, then average over freqs
data2plot{2} = mean(diffRE2HC(:,thetaIdx),2); % get theta freqs out, then average over freqs
data2plot = horzcat(data2plot{:});
multiBarPlot(data2plot,[ {'HC2RE'} {'RE2HC'}],'Diff GC (high-low)','n',[],[.5 .5 .5],'n');
ylim([-.1 .4])
stat_test = 'ttest'; parametric = 'y'; numCorrections = 3;
readStats(data2plot(:,1),0,parametric,stat_test,'GP HC2RE',numCorrections);
readStats(data2plot(:,2),0,parametric,stat_test,'GP RE2HC',numCorrections);
readStats(data2plot(:,1),data2plot(:,2),parametric,stat_test,'HC2RE v RE2HC',numCorrections);

% plot RE-PF interactions
subplot 132; hold on;
data2plot = [];
data2plot{1} = mean(diffRE2PF(:,thetaIdx),2);
data2plot{2} = mean(diffPF2RE(:,thetaIdx),2);
data2plot = horzcat(data2plot{:});
multiBarPlot(data2plot,[{'RE2PF'}  {'PF2RE'}],'Diff GC (high-low)','n',[],[.5 .5 .5],'n');
ylim([-.1 .4])
stat_test = 'ttest'; parametric = 'y'; numCorrections = 3;
readStats(data2plot(:,1),0,parametric,stat_test,'GP RE2PF',numCorrections);
readStats(data2plot(:,2),0,parametric,stat_test,'GP PF2RE',numCorrections);
readStats(data2plot(:,1),data2plot(:,2),parametric,stat_test,'RE2PF v PF2RE',numCorrections);

% plot PF-HC interactions
subplot 133; hold on;
data2plot = [];
data2plot{1} = mean(diffPF2HC(:,thetaIdx),2);
data2plot{2} = mean(diffHC2PF(:,thetaIdx),2);
data2plot = horzcat(data2plot{:});
multiBarPlot(data2plot,[ {'PF2HC'}  {'HC2PF'}],'Diff GC (high-low)','n',[],[.5 .5 .5],'n');
ylim([-.1 .4])
stat_test = 'ttest'; parametric = 'y'; numCorrections = 3;
readStats(data2plot(:,1),0,parametric,stat_test,'GP PF2HC',numCorrections);
readStats(data2plot(:,2),0,parametric,stat_test,'GP HC2PF',numCorrections);
readStats(data2plot(:,1),data2plot(:,2),parametric,stat_test,'PF2HC v HC2PF',numCorrections);

%% spike phase analysis
loadSourceData = 1; % set this value to 0 if you want to rerun analyses that generated datahigh and datalow for entrainment
if loadSourceData == 0
    % this entrainment analysis uses LFP data and spiking data acquired across
    % the entire session (while the rat was on task)
    load('data_spkLFP_entrainment'); % updated on 6/20/23 due to a bug repair

    % fix the dataSpkLFP variable - in SCRIPT_formatEntrainment, I accidentally
    % rewrote the high threshold and defined it as low. This was performed
    % after the actual analysis and is NOT IMPORTANT for the actual splitting
    % of high and low coh data. The splitting procedure used the appropriate
    % thresholds. We're fixing a saving error.
    ratID = fieldnames(dataSpkLFP);
    disp('Correcting threshold storage');
    for rati = 1:length(ratID) % rats 4:end have re
        disp(['Working with rat',num2str(rati)])
        sessions = fieldnames(dataSpkLFP.(ratID{rati}));
        % skip certain rats who don't have re lfp
        for sessi = 1:length(sessions)

            % fix data
            zCoh = []; cT = [];
            zCoh = dataSpkLFP.(ratID{rati}).(sessions{sessi}).distributions.thetaC_aboveDelta_zscore;
            cT   = dataSpkLFP.(ratID{rati}).(sessions{sessi}).distributions.thetaC_aboveDelta;

            % define high/low thresh
            thresholdHigh = cT(dsearchn(zCoh',1));
            thresholdLow  = cT(dsearchn(zCoh',-1));        

            % temporary variable
            dataSpkLFP.(ratID{rati}).(sessions{sessi}).thresholds.low  = thresholdLow;
            dataSpkLFP.(ratID{rati}).(sessions{sessi}).thresholds.high = thresholdHigh;        
        end    
    end
    %save('data_spkLFP_entrainment','dataSpkLFP','-v7');

    % build datahigh and datalow variables
    datahigh = []; datalow = [];
    for rati = 1:length(ratID) % rats 4:end have re
        disp(['Working with rat',num2str(rati)])
        sessions = fieldnames(dataSpkLFP.(ratID{rati}));
        % skip certain rats who don't have re lfp
        for sessi = 1:length(sessions)
            % temporary variable
            datahigh{rati,sessi} = dataSpkLFP.(ratID{rati}).(sessions{sessi}).data.dataHighCoh;
            datalow{rati,sessi}  = dataSpkLFP.(ratID{rati}).(sessions{sessi}).data.dataLowCoh;
        end
    end

    % performed again on 6/21/23 after updated dataSpkLFP
    cleanData = 0;
    if cleanData == 1
        % for cleaning purposes
        estimateThresholds = 1;
        if estimateThresholds == 1
            % I will save a lot of time by simply applying the std threshold before
            % visualizing
            for rowi = 1:size(datahigh,1)
                for coli = 1:size(datahigh,2)
                    if ~isempty(datahigh{rowi,coli})

                        % filter #1 - identify noise
                        stdThresh = []; tempdata = []; tempdata = horzcat(datahigh{rowi,coli}{:});
                        [~,~,~,thresholdsH{rowi,coli}(1),stdThresh(1,1),stdThresh(1,2)] = filtLFPartifact(tempdata(1,:),2000);
                        [~,~,~,thresholdsH{rowi,coli}(2),stdThresh(2,1),stdThresh(2,2)] = filtLFPartifact(tempdata(2,:),2000);
                        [~,~,~,thresholdsH{rowi,coli}(3),stdThresh(3,1),stdThresh(3,2)] = filtLFPartifact(tempdata(2,:),2000);  
                        close all;

                        %{
                        satSum = []; tempdata = []; tempdata = datahigh{rowi,coli};
                        for figi = 1:length(tempdata)

                            % get data
                            data1 = []; data2 = []; data3 = [];
                            data1 = tempdata{figi}(1,:); % pfc
                            data2 = tempdata{figi}(2,:); % pfc            
                            data3 = tempdata{figi}(3,:); % vmt

                            % filter 1
                            sat(1) = (numel(find(data1>stdThresh(1,1) | data1<stdThresh(1,2))))/numel(data1)*100;
                            sat(2) = (numel(find(data2>stdThresh(2,1) | data1<stdThresh(2,2))))/numel(data2)*100;
                            sat(3) = (numel(find(data3>stdThresh(3,1) | data1<stdThresh(3,2))))/numel(data3)*100;
                            satSum(figi) = sum(sat);
                        end

                        % find percent removal, this can vary dependent on your
                        % determined thresholds and as such, requires input
                        percIdx = [];
                        percIdx = find(satSum > 0); % anything more than 0% saturation, remove

                        % remove tagged trials
                        datahigh{rowi,coli}(percIdx)=[];
                        %}
                        disp(['Finished with rat',num2str(rowi),' session ',num2str(coli)])
                    end
                end
            end
            save('data_fullSess_thresholdsH','thresholdsH');

            % low coh state visualization
            for rowi = 1:size(datalow,1)
                for coli = 1:size(datalow,2)
                    if ~isempty(datahigh{rowi,coli})
                        % filter #1 - identify noise
                        stdThresh = []; tempdata = []; tempdata = horzcat(datalow{rowi,coli}{:});
                        [~,~,~,thresholdsL{rowi,coli}(1),stdThresh(1,1),stdThresh(1,2)] = filtLFPartifact(tempdata(1,:),2000);
                        [~,~,~,thresholdsL{rowi,coli}(2),stdThresh(2,1),stdThresh(2,2)] = filtLFPartifact(tempdata(2,:),2000);
                        [~,~,~,thresholdsL{rowi,coli}(3),stdThresh(3,1),stdThresh(3,2)] = filtLFPartifact(tempdata(2,:),2000);  
                        close all;
                    end

                    %{
                    satSum = []; tempdata = []; tempdata = datalow{rowi,coli};
                    for figi = 1:length(tempdata)

                        % get data
                        data1 = []; data2 = []; data3 = [];
                        data1 = tempdata{figi}(1,:); % pfc
                        data2 = tempdata{figi}(2,:); % pfc            
                        data3 = tempdata{figi}(3,:); % vmt

                        % filter 1
                        sat(1) = (numel(find(data1>stdThresh(1,1) | data1<stdThresh(1,2))))/numel(data1)*100;
                        sat(2) = (numel(find(data2>stdThresh(2,1) | data1<stdThresh(2,2))))/numel(data2)*100;
                        sat(3) = (numel(find(data3>stdThresh(3,1) | data1<stdThresh(3,2))))/numel(data3)*100;
                        satSum(figi) = sum(sat);
                    end

                    % find percent removal, this can vary dependent on your
                    % determined thresholds and as such, requires input
                    percIdx = [];
                    percIdx = find(satSum > 0); % anything more than 0% saturation, remove

                    % remove tagged trials
                    datalow{rowi,coli}(percIdx)=[];
                    %}
                    disp(['Finished with rat',num2str(rowi),' session ',num2str(coli)])
                end
            end
            save('data_fullSess_thresholdsL','thresholdsL');
        else
            % use the threshold data, reconstruct the signals, reestimate the voltage
            % values corresponding to stds
            load('data_fullSess_thresholdsH'); load('data_fullSess_thresholdsL');
        end

        % get threshold values in volts
        for rowi = 1:size(datahigh,1)
            for coli = 1:size(datahigh,2)
                if ~isempty(datahigh{rowi,coli})

                    % get data
                    tempdata = []; tempdata = horzcat(datahigh{rowi,coli}{:});

                    % zscore it
                    tempdataZ = [];
                    tempdataZ(1,:) = zscore(tempdata(1,:));
                    tempdataZ(2,:) = zscore(tempdata(2,:));
                    tempdataZ(3,:) = zscore(tempdata(3,:));

                    % find lfp values corresponding to the threshold
                    for i = 1:size(tempdataZ,1)
                        idxHigh = dsearchn(tempdataZ(i,:)',thresholdsH{rowi,coli}(i));
                        idxLow  = dsearchn(tempdataZ(i,:)',-thresholdsH{rowi,coli}(i));
                        artifact_highCoh_pos{rowi,coli}(i) = tempdata(i,idxHigh(1)); % threshold for artifact detection
                        artifact_highCoh_neg{rowi,coli}(i) = tempdata(i,idxLow(1));     
                    end

                end
            end
        end
        for rowi = 1:size(datalow,1)
            for coli = 1:size(datalow,2)
                if ~isempty(datalow{rowi,coli})

                    % get data
                    tempdata = []; tempdata = horzcat(datalow{rowi,coli}{:});

                    % zscore it
                    tempdataZ = [];
                    tempdataZ(1,:) = zscore(tempdata(1,:));
                    tempdataZ(2,:) = zscore(tempdata(2,:));
                    tempdataZ(3,:) = zscore(tempdata(3,:));

                    % find lfp values corresponding to the threshold
                    for i = 1:size(tempdataZ,1)
                        idxHigh = dsearchn(tempdataZ(i,:)',thresholdsL{rowi,coli}(i));
                        idxLow  = dsearchn(tempdataZ(i,:)',-thresholdsL{rowi,coli}(i));
                        artifact_lowCoh_pos{rowi,coli}(i) = tempdata(i,idxHigh(1)); % threshold for artifact detection
                        artifact_lowCoh_neg{rowi,coli}(i) = tempdata(i,idxLow(1));     
                    end
                end
            end
        end
        save('data_fullSess_artifactValues','artifact_highCoh_neg','artifact_highCoh_pos','artifact_lowCoh_neg','artifact_lowCoh_pos');             

        % loop over data and remove what is needed
        percSat_high = []; percSat_low = [];
        for rowi = 1:size(datahigh,1)
            for coli = 1:size(datahigh,2)
                if ~isempty(datahigh{rowi,coli})
                    % artifact reject on high
                    for i = 1:length(datahigh{rowi,coli})
                        % get data
                        tempdata = []; tempdata = datahigh{rowi,coli}{i};
                        % check for artifact
                        for sigi = 1:3
                            numEvents(sigi) = numel(find(tempdata(sigi,:) > artifact_highCoh_pos{rowi,coli}(sigi) | tempdata(sigi,:) < artifact_highCoh_neg{rowi,coli}(sigi)));
                        end    
                        % percent sat
                        percSat_high{rowi,coli}(i) = (sum(numEvents)/size(tempdata,2))*100;
                    end
                    % artifact reject on low
                    for i = 1:length(datalow{rowi,coli})
                        % get data
                        tempdata = []; tempdata = datalow{rowi,coli}{i};
                        % check for artifact
                        for sigi = 1:3
                            numEvents(sigi) = numel(find(tempdata(sigi,:) > artifact_lowCoh_pos{rowi,coli}(sigi) | tempdata(sigi,:) < artifact_lowCoh_neg{rowi,coli}(sigi)));
                        end    
                        % percent sat
                        percSat_low{rowi,coli}(i) = (sum(numEvents)/size(tempdata,2))*100;
                    end            
                end
            end
            disp(['Finished with rat ',num2str(rowi)])
        end
        save('data_fullSess_saturation','percSat_high','percSat_low');
    else
        load('data_fullSess_saturation');
    end

    % filter out data
    for rowi = 1:size(datahigh,1)
        for coli = 1:size(datahigh,2)
            if ~isempty(datahigh{rowi,coli})
                idxRem = [];
                idxRem = find(percSat_high{rowi,coli}>1);
                datahigh{rowi,coli}(idxRem)=[];
            end
            if ~isempty(datalow{rowi,coli})
                idxRem = [];
                idxRem = find(percSat_low{rowi,coli}>1);
                datalow{rowi,coli}(idxRem)=[];
            end
        end
    end

    % PFC tts dont go outside of +/- ~2000mV. To be liberal, I'm using voltage
    % cutoffs of about 3500mV. Typically, artifacts are present beyond this
    % range from visual observation. The same seems to be true in VMT
    % recordings, which are the voltage range of cortical activity, but look
    % like hippocampus
    idxMet = [];
    for rowi = 1:size(datahigh,1) % 6/13/23 did rat 1; 6/19 did rat 2;
        for coli = 1:size(datahigh,2)
            for epochi = 1:length(datahigh{rowi,coli})
                tempdata = []; tempdata = datahigh{rowi,coli}{epochi}(1,:);
                tempdata2 = []; tempdata2 = datahigh{rowi,coli}{epochi}(3,:);
                idxMet{rowi,coli}(epochi) = ~isempty(find(tempdata > 3500 | tempdata < -3500 | tempdata2 > 3500 | tempdata2 < -3500));
            end
        end
    end
    for rowi = 1:size(datahigh,1) % 6/13/23 did rat 1; 6/19 did rat 2;
        for coli = 1:size(datahigh,2)
            try datahigh{rowi,coli}(idxMet{rowi,coli})=[]; end
        end
    end

    % do the same for low coh
    idxMet = [];
    for rowi = 1:size(datalow,1) % 6/13/23 did rat 1; 6/19 did rat 2;
        for coli = 1:size(datalow,2)
            for epochi = 1:length(datalow{rowi,coli})
                tempdata = []; tempdata = datalow{rowi,coli}{epochi}(1,:);
                tempdata2 = []; tempdata2 = datalow{rowi,coli}{epochi}(3,:);
                idxMet{rowi,coli}(epochi) = ~isempty(find(tempdata > 3500 | tempdata < -3500 | tempdata2 > 3500 | tempdata2 < -3500));
            end
        end
    end
    for rowi = 1:size(datalow,1) % 6/13/23 did rat 1; 6/19 did rat 2;
        for coli = 1:size(datalow,2)
            try datalow{rowi,coli}(idxMet{rowi,coli})=[]; end
        end
    end

    %{
    % checking data
    for rowi = 2:size(datahigh,1) % 6/13/23 did rat 1; 6/19 did rat 2;
        for coli = 1:size(datahigh,2)
            disp(['Working with session',num2str(coli)])

            % filter #2, theta coh > delta and beta coh
            figure('color','w');
            set(gcf, 'Position', get(0, 'Screensize'));
            tempdata = []; tempdata = datahigh{rowi,coli};
            idxrem = []; counter = 0;
            for figi = 1:length(tempdata)
                counter = counter+1;
                subplot(20,5,counter); hold on;

                % get data
                data1 = []; data2 = []; data3 = [];
                data1 = tempdata{figi}(1,:); % pfc
                data2 = tempdata{figi}(2,:); % pfc            
                data3 = tempdata{figi}(3,:); % vmt

                % filter 2
                cohDelta = mean(mscohere(data1,data2,[],[],[1:2],2000));
                cohTheta = mean(mscohere(data1,data2,[],[],[6:9],2000));
                cohBeta  = mean(mscohere(data1,data2,[],[],[10:16],2000));
                if ~(cohTheta > cohBeta && cohTheta > cohDelta)
                    cohMet(figi)=1; % coh theta is less than beta or delta
                else
                    cohMet(figi)=0;
                end

                % plot signals together
                plot(zscore(tempdata{figi}(1,:)),'b');
                plot(zscore(tempdata{figi}(2,:)),'r');
                plot(zscore(tempdata{figi}(3,:)),'k');
                axis off;

                % make title
                if cohTheta > cohBeta && cohTheta > cohDelta
                    title(['Index #',num2str(figi),'| include'],'FontSize',7)
                else
                    title(['Index #',num2str(figi),'| exclude'],'FontSize',7)
                end

                axis tight;
                if counter == 100 || figi == length(tempdata)

                    % index to remove data
                    idxrem = horzcat(idxrem,str2num(input('Enter which indices to remove ','s')));

                    %pause;
                    close;
                    figure('color','w');
                    set(gcf, 'Position', get(0, 'Screensize'));  
                    counter = 0;
                end
            end

            % find coherence threshold
            %cohRem = find(cohMet==1);

            % add to idxrem
            %idxrem = sort(unique(horzcat(idxrem,cohRem)));

            % remove tagged trials
            datahighRem{rowi,coli} = idxrem;
            %datahigh{rowi,coli}(idxrem)=[];
        end
    end

    % on 6/13/23, I cleaned rat1, clean rest of rats and do low coh
    % now visually inspect and delete trials
    for rowi = 1:size(datahigh,1) % 6/13/23 did rat 1; 6/19 did rat 2;
        for coli = 1:size(datahigh,2)
            disp(['Working with session',num2str(coli)])

            % filter #2, theta coh > delta and beta coh
            figure('color','w');
            set(gcf, 'Position', get(0, 'Screensize'));
            tempdata = []; tempdata = datahigh{rowi,coli};
            idxrem = []; counter = 0;
            for figi = 1:length(tempdata)
                counter = counter+1;
                subplot(20,5,counter); hold on;

                % get data
                data1 = []; data2 = []; data3 = [];
                data1 = tempdata{figi}(1,:); % pfc
                data2 = tempdata{figi}(2,:); % pfc            
                data3 = tempdata{figi}(3,:); % vmt

                % filter 2
                cohDelta = mean(mscohere(data1,data2,[],[],[1:2],2000));
                cohTheta = mean(mscohere(data1,data2,[],[],[6:9],2000));
                cohBeta  = mean(mscohere(data1,data2,[],[],[10:16],2000));
                if ~(cohTheta > cohBeta && cohTheta > cohDelta)
                    cohMet(figi)=1; % coh theta is less than beta or delta
                else
                    cohMet(figi)=0;
                end

                % plot signals together
                plot(zscore(tempdata{figi}(1,:)),'b');
                plot(zscore(tempdata{figi}(2,:)),'r');
                plot(zscore(tempdata{figi}(3,:)),'k');
                axis off;

                % make title
                if cohTheta > cohBeta && cohTheta > cohDelta
                    title(['Index #',num2str(figi),'| include'],'FontSize',7)
                else
                    title(['Index #',num2str(figi),'| exclude'],'FontSize',7)
                end

                axis tight;
                if counter == 100 || figi == length(tempdata)

                    % index to remove data
                    idxrem = horzcat(idxrem,str2num(input('Enter which indices to remove ','s')));

                    %pause;
                    close;
                    figure('color','w');
                    set(gcf, 'Position', get(0, 'Screensize'));  
                    counter = 0;
                end
            end

            % find coherence threshold
            %cohRem = find(cohMet==1);

            % add to idxrem
            %idxrem = sort(unique(horzcat(idxrem,cohRem)));

            % remove tagged trials
            datahighRem{rowi,coli} = idxrem;
            %datahigh{rowi,coli}(idxrem)=[];
        end
    end
    save('data_fullSess_highRem','datahighRem');

    % remove
    for rowi = 1:size(datahigh,1) % 6/13/23 did rat 1; 6/19 did rat 2;
        for coli = 1:size(datahigh,2)
            try
                datahigh{rowi,coli}(datahighRem{rowi,coli})=[];
            end
        end
    end

    % only look at pfc - looking at each trace separately might be best
    for rowi = 3:size(datahigh,1) % 6/13/23 did rat 1; 6/19 did rat 2;
        for coli = 1:size(datahigh,2)
            disp(['Working with session',num2str(coli)])

            % filter #2, theta coh > delta and beta coh
            figure('color','w');
            set(gcf, 'Position', get(0, 'Screensize'));
            tempdata = []; tempdata = datahigh{rowi,coli};
            idxrem = []; counter = 0;
            for figi = 1:length(tempdata)
                counter = counter+1;
                subplot(20,5,counter); hold on;

                % get data
                data1 = []; data2 = []; data3 = [];
                data1 = tempdata{figi}(2,:); % pfc
                data2 = skaggs_filter_var(data1,4,12,2000);
                %data2 = tempdata{figi}(2,:); % pfc            
                %data3 = tempdata{figi}(3,:); % vmt

                % filter 2
                %{
                cohDelta = mean(mscohere(data1,data2,[],[],[1:2],2000));
                cohTheta = mean(mscohere(data1,data2,[],[],[6:9],2000));
                cohBeta  = mean(mscohere(data1,data2,[],[],[10:16],2000));
                if ~(cohTheta > cohBeta && cohTheta > cohDelta)
                    cohMet(figi)=1; % coh theta is less than beta or delta
                else
                    cohMet(figi)=0;
                end
                %}

                % plot signals together
                plot(data1,'k'); hold on; 
                plot(data2,'m','LineWidth',1.25);
                %axis off;

                % make title
                title(['Index #',num2str(figi)],'FontSize',7)

                axis tight;
                if counter == 100 || figi == length(tempdata)

                    % index to remove data
                    idxrem = horzcat(idxrem,str2num(input('Enter which indices to remove ','s')));

                    %pause;
                    close;
                    figure('color','w');
                    set(gcf, 'Position', get(0, 'Screensize'));  
                    counter = 0;
                end
            end

            % find coherence threshold
            %cohRem = find(cohMet==1);

            % add to idxrem
            %idxrem = sort(unique(horzcat(idxrem,cohRem)));

            % remove tagged trials
            datahighRem2{rowi,coli} = idxrem;
            %datahigh{rowi,coli}(idxrem)=[];
            close all;
        end
    end
    save('data_fullSess_highRem2','datahighRem2');
    %}

    % fix the data
    datahigh = datahigh(:);
    datalow  = datalow(:);
    [~,idx] = emptyCellErase(datahigh);
    datahigh(idx)=[];
    datalow(idx)=[];
    [~,idx] = emptyCellErase(datalow);
    datalow(idx)=[];
    datahigh(idx)=[];
    % save
    save('data_coh_entrainment','datahigh','datalow',"-v7.3");
else
    load('data_coh_entrainment');
end

% number of epochs
numEpochHigh = []; numEpochLow = [];
numEpochHigh = cellfun(@numel,datahigh);
numEpochLow  = cellfun(@numel,datalow);
numEpochs    = vertcat(numEpochHigh,numEpochLow);
figure; histogram(numEpochs,20)
data2plot = horzcat(numEpochHigh,numEpochLow);
figure('color','w'); multiBarPlot(data2plot,[{'High'} {'Low'}],'#Epochs');

% dont worry about epoch exclusion. Spike counts are more important and
% will take care of this.
%{
idxRem = find(numEpochHigh<100 | numEpochLow<100);
datahigh(idxRem)=[];
datalow(idxRem)=[];
%}

% entrainment
rerunSFC = 0;
if rerunSFC == 1
    % I have a powerpoint in the data folder showing the importance of
    % these parameters. They provide consistent results with interp method,
    % so long as theta:delta ratio is set. This makes sense bc the interp
    % method only works with theta phase it can estimate, while hilbert can
    % estimate anything. 4-12Hz was used to account for the fact that theta
    % can vary a bit over time and to better capture the shape of the
    % oscillation. I've noticed that restricting this too much almost
    % forces the data to 8hz shape when it may not be.
    srate = 2000;
    lowpass = 10; highpass = 30; % JW2005; Hallock 2016; (4-12Hz theta, 15-20Hz beta)
    filterThetaDelta = 'y';     % Hallock2016
    phaseMethod = 'hilbert';    % Buzsaki lab suggests it is more conservative
    
    for i = 1:length(datahigh)
        if isempty(datahigh{i})==1
            continue
        end

        % first concatenate signals, then remove repeats of timestamps
        tempHigh = []; tempLow = [];
        tempHigh = datahigh{i};
        tempLow  = datalow{i};

        % convert to double
        tempHigh = double(horzcat(tempHigh{:}));
        tempLow  = double(horzcat(tempLow{:}));  

        % get unique timestamps
        [~,idx] = unique(tempHigh(4,:)); % only keep unique timestamps
        tempHigh = tempHigh(:,idx); % index out your dataset
        [~,idx] = unique(tempLow(4,:)); % only keep unique timestamps
        tempLow = tempLow(:,idx); % index out your dataset

        % get LFP
        lfpHighPFC = []; lfpLowPFC = []; 
        lfpHighHPC = []; lfpLowHPC = [];
        lfpHighVMT = []; lfpLowVMT = [];

        lfpHighPFC = tempHigh(1,:);
        lfpHighHPC = tempHigh(2,:);
        lfpHighVMT = tempHigh(3,:);

        lfpLowPFC = tempLow(1,:);
        lfpLowHPC = tempLow(2,:);
        lfpLowVMT = tempLow(3,:);

        % get spike matrix
        spikeTimeHighData = []; spikeTimeLowData = [];
        spikeTimeHighData = tempHigh(5:end,:);
        spikeTimeLowData  = tempLow(5:end,:);

        % remove units if <50spks
        remData = []; frTempHigh = []; frTempLow = [];
        for uniti = 1:size(spikeTimeHighData,1)
            spkCountH = find(spikeTimeHighData(uniti,:));
            spkCountL = find(spikeTimeLowData(uniti,:));
            if numel(spkCountH)<50 || numel(spkCountL)<50
                remData(uniti)=1;
            end
            % calculate firing rate
            frTempHigh{uniti} = numel(spkCountH)/((size(spikeTimeHighData(uniti,:),2))/2000);
            frTempLow{uniti}  = numel(spkCountL)/((size(spikeTimeLowData(uniti,:),2))/2000);            
        end
        remData = logical(remData);
        spikeTimeHighData(remData,:)=[];
        spikeTimeLowData(remData,:)=[];
        frTempHigh(remData)=[];
        frTempLow(remData)=[];
        
        % store fr
        frHigh{i} = frTempHigh;
        frLow{i}  = frTempLow;

        % entrainment and SFC
        for uniti = 1:size(spikeTimeHighData,1)

            % get spikes
            spksHigh = []; spksHigh = spikeTimeHighData(uniti,:);
            spksLow  = []; spksLow  = spikeTimeLowData(uniti,:);

            % spike index
            spkIdxHigh = find(spksHigh);
            spkIdxLow  = find(spksLow);

            % -- calculate entrainment -- %
            
            % vmt high
            [spkPhase_vmtH{i}{uniti},spkRadian_vmtH{i}{uniti},...
                rayleighsP_vmtH{i}{uniti},rayleighsZ_vmtH{i}{uniti},...
                bsMrl_vmtH{i}{uniti},n_vmtH{i}{uniti},xout_vmtH{i}{uniti}] = ...
                unitEntrainment(spkIdxHigh,lfpHighVMT,lowpass,highpass,srate,phaseMethod,filterThetaDelta);              

            % hpc high
            [spkPhase_hpcH{i}{uniti},spkRadian_hpcH{i}{uniti},...
                rayleighsP_hpcH{i}{uniti},rayleighsZ_hpcH{i}{uniti},...
                bsMrl_hpcH{i}{uniti},n_hpcH{i}{uniti},xout_hpcH{i}{uniti}] = ...
                unitEntrainment(spkIdxHigh,lfpHighHPC,lowpass,highpass,srate,phaseMethod,filterThetaDelta);              
            
            % vmt low
            [spkPhase_vmtL{i}{uniti},spkRadian_vmtL{i}{uniti},...
                rayleighsP_vmtL{i}{uniti},rayleighsZ_vmtL{i}{uniti},...
                bsMrl_vmtL{i}{uniti},n_vmtL{i}{uniti},xout_vmtL{i}{uniti}] = ...
                unitEntrainment(spkIdxLow,lfpLowVMT,lowpass,highpass,srate,phaseMethod,filterThetaDelta);              

            % hpc low
            [spkPhase_hpcL{i}{uniti},spkRadian_hpcL{i}{uniti},...
                rayleighsP_hpcL{i}{uniti},rayleighsZ_hpcL{i}{uniti},...
                bsMrl_hpcL{i}{uniti},n_hpcL{i}{uniti},xout_hpcL{i}{uniti}] = ...
                unitEntrainment(spkIdxLow,lfpLowHPC,lowpass,highpass,srate,phaseMethod,filterThetaDelta);           
                        
        end
        disp(['Completed with session ',num2str(i)])
    end
    clear dataSpkLFP datahigh datalow lfpHighHPC lfpLowHPC lfpHighPFC lfpLowPFC ...
        lfpHighVTM lfpLowVMT spksHigh spksLow tempHigh tempLow uniti ...
        spkIdxHigh spkIdxLow spkCountH spkCountL spikeTimeHighData spikeTimeLowData ...
        remData idx frTempHigh frTempLow
    disp('Saving results...')
    date = todaysDate();
    save(['data_ent_',date])   
else
    % this is the cohen method. I tried Welch's, but the results were not
    % reliable
    load('data_ent_21_Jun_2023'); % load for theta
    %load('data_ent_22_Jun_2023'); % load for beta
end

% SFC
if rerunSFC == 1
    freq = [1:.5:20]; srate = 2000; nCycles = 6;
    for i = 1:length(datahigh)
        if isempty(datahigh{i})==1
            continue
        end

        % first concatenate signals, then remove repeats of timestamps
        tempHigh = []; tempLow = [];
        tempHigh = datahigh{i};
        tempLow  = datalow{i};

        % convert to double
        tempHigh = double(horzcat(tempHigh{:}));
        tempLow  = double(horzcat(tempLow{:}));  

        % get unique timestamps
        [~,idx] = unique(tempHigh(4,:)); % only keep unique timestamps
        tempHigh = tempHigh(:,idx); % index out your dataset
        [~,idx] = unique(tempLow(4,:)); % only keep unique timestamps
        tempLow = tempLow(:,idx); % index out your dataset

        % get LFP
        lfpHighPFC = []; lfpLowPFC = []; 
        lfpHighHPC = []; lfpLowHPC = [];
        lfpHighVMT = []; lfpLowVMT = [];

        lfpHighPFC = tempHigh(1,:);
        lfpHighHPC = tempHigh(2,:);
        lfpHighVMT = tempHigh(3,:);

        lfpLowPFC = tempLow(1,:);
        lfpLowHPC = tempLow(2,:);
        lfpLowVMT = tempLow(3,:);

        % get spike matrix
        spikeTimeHighData = []; spikeTimeLowData = [];
        spikeTimeHighData = tempHigh(5:end,:);
        spikeTimeLowData  = tempLow(5:end,:);

        % remove units if <50spks
        remData = [];
        for uniti = 1:size(spikeTimeHighData,1)
            spkCountH = find(spikeTimeHighData(uniti,:));
            spkCountL = find(spikeTimeLowData(uniti,:));
            if numel(spkCountH)<50 || numel(spkCountL)<50
                remData(uniti)=1;
            end
        end
        remData = logical(remData);
        spikeTimeHighData(remData,:)=[];
        spikeTimeLowData(remData,:)=[];

        % get sfc using welch's method
        for uniti = 1:size(spikeTimeHighData,1)
            % high coherence states
            [sfcHighPFC{i}(uniti,:),freq] = getSpikeFieldCoherence(lfpHighPFC,spikeTimeHighData(uniti,:),freq,nCycles,srate,'phase');
            [sfcHighVMT{i}(uniti,:),freq] = getSpikeFieldCoherence(lfpHighVMT,spikeTimeHighData(uniti,:),freq,nCycles,srate,'phase');
            [sfcHighHPC{i}(uniti,:),freq] = getSpikeFieldCoherence(lfpHighHPC,spikeTimeHighData(uniti,:),freq,nCycles,srate,'phase');
            % low coherence states
            [sfcLowPFC{i}(uniti,:),freq] = getSpikeFieldCoherence(lfpLowPFC,spikeTimeLowData(uniti,:),freq,nCycles,srate,'phase');
            [sfcLowVMT{i}(uniti,:),freq] = getSpikeFieldCoherence(lfpLowVMT,spikeTimeLowData(uniti,:),freq,nCycles,srate,'phase');
            [sfcLowHPC{i}(uniti,:),freq] = getSpikeFieldCoherence(lfpLowHPC,spikeTimeLowData(uniti,:),freq,nCycles,srate,'phase');            
        end
        disp(['Completed with session #',num2str(i)])
    end
    date = todaysDate();
    save(['data_sfc_',date],'sfcHighPFC','sfcLowPFC','sfcHighVMT','sfcLowVMT','sfcHighHPC','sfcLowHPC','freq')    
else
    % this is the cohen method. I tried Welch's, but the results were not
    % reliable
    load('data_sfc_21_Jun_2023');
end
load('data_spkCounts');

%% reformatting and plotting spike-phase results

% rayleighs p
rayleighsP_hpcH = emptyCellErase(rayleighsP_hpcH);
rayleighsP_hpcL = emptyCellErase(rayleighsP_hpcL);
rayleighsP_vmtH = emptyCellErase(rayleighsP_vmtH);
rayleighsP_vmtL = emptyCellErase(rayleighsP_vmtL);

% bootstrapped mrl
bsMrl_hpcH = emptyCellErase(bsMrl_hpcH);
bsMrl_hpcL = emptyCellErase(bsMrl_hpcL);
bsMrl_vmtH = emptyCellErase(bsMrl_vmtH);
bsMrl_vmtL = emptyCellErase(bsMrl_vmtL);

% Z
rayleighsZ_hpcH = emptyCellErase(rayleighsZ_hpcH);
rayleighsZ_hpcL = emptyCellErase(rayleighsZ_hpcL);
rayleighsZ_vmtH = emptyCellErase(rayleighsZ_vmtH);
rayleighsZ_vmtL = emptyCellErase(rayleighsZ_vmtL);

% spk radian information
spkRadian_hpcH = emptyCellErase(spkRadian_hpcH);
spkRadian_hpcL = emptyCellErase(spkRadian_hpcL);
spkRadian_vmtH = emptyCellErase(spkRadian_vmtH);
spkRadian_vmtL = emptyCellErase(spkRadian_vmtL);

% phase histogram info
xout_hpcH = emptyCellErase(xout_hpcH);
xout_hpcL = emptyCellErase(xout_hpcL);
xout_vmtH = emptyCellErase(xout_vmtH);
xout_vmtL = emptyCellErase(xout_vmtL);
n_hpcH    = emptyCellErase(n_hpcH);
n_hpcL    = emptyCellErase(n_hpcL);
n_vmtH    = emptyCellErase(n_vmtH);
n_vmtL    = emptyCellErase(n_vmtL);

% same for sfc
sfcHighHPC = emptyCellErase(sfcHighHPC);
sfcHighVMT = emptyCellErase(sfcHighVMT);
sfcLowHPC  = emptyCellErase(sfcLowHPC);
sfcLowVMT  = emptyCellErase(sfcLowVMT);

% concatenate
sfcHighVMT = vertcat(sfcHighVMT{:});
sfcHighHPC = vertcat(sfcHighHPC{:});
sfcLowVMT  = vertcat(sfcLowVMT{:});
sfcLowHPC  = vertcat(sfcLowHPC{:});

% reformat
rayleighsP_hpcH = horzcat(rayleighsP_hpcH{:});
rayleighsP_hpcL = horzcat(rayleighsP_hpcL{:});
rayleighsP_vmtH = horzcat(rayleighsP_vmtH{:});
rayleighsP_vmtL = horzcat(rayleighsP_vmtL{:});
bsMrl_hpcH      = horzcat(bsMrl_hpcH{:});
bsMrl_hpcL      = horzcat(bsMrl_hpcL{:});
bsMrl_vmtH      = horzcat(bsMrl_vmtH{:});
bsMrl_vmtL      = horzcat(bsMrl_vmtL{:});    
rayleighsZ_hpcH = horzcat(rayleighsZ_hpcH{:});
rayleighsZ_hpcL = horzcat(rayleighsZ_hpcL{:});
rayleighsZ_vmtH = horzcat(rayleighsZ_vmtH{:});
rayleighsZ_vmtL = horzcat(rayleighsZ_vmtL{:});    
spkRadian_hpcH  = horzcat(spkRadian_hpcH{:});
spkRadian_hpcL  = horzcat(spkRadian_hpcL{:});
spkRadian_vmtH  = horzcat(spkRadian_vmtH{:});
spkRadian_vmtL  = horzcat(spkRadian_vmtL{:});
xout_hpcH       = horzcat(xout_hpcH{:});
xout_hpcL       = horzcat(xout_hpcL{:});
xout_vmtH       = horzcat(xout_vmtH{:});
xout_vmtL       = horzcat(xout_vmtL{:});
n_hpcH          = horzcat(n_hpcH{:});
n_hpcL          = horzcat(n_hpcL{:});
n_vmtH          = horzcat(n_vmtH{:});
n_vmtL          = horzcat(n_vmtL{:});

% reformat
rayleighsP_hpcH = empty2nan(rayleighsP_hpcH);
rayleighsP_hpcL = empty2nan(rayleighsP_hpcL);
rayleighsP_vmtH = empty2nan(rayleighsP_vmtH);
rayleighsP_vmtL = empty2nan(rayleighsP_vmtL);
bsMrl_hpcH      = empty2nan(bsMrl_hpcH);
bsMrl_hpcL      = empty2nan(bsMrl_hpcL);
bsMrl_vmtH      = empty2nan(bsMrl_vmtH);
bsMrl_vmtL      = empty2nan(bsMrl_vmtL);    
rayleighsZ_hpcH = empty2nan(rayleighsZ_hpcH);
rayleighsZ_hpcL = empty2nan(rayleighsZ_hpcL);
rayleighsZ_vmtH = empty2nan(rayleighsZ_vmtH);
rayleighsZ_vmtL = empty2nan(rayleighsZ_vmtL);    
spkRadian_hpcH  = empty2nan(spkRadian_hpcH);
spkRadian_hpcL  = empty2nan(spkRadian_hpcL);
spkRadian_vmtH  = empty2nan(spkRadian_vmtH);
spkRadian_vmtL  = empty2nan(spkRadian_vmtL);
xout_hpcH       = empty2nan(xout_hpcH);
xout_hpcL       = empty2nan(xout_hpcL);
xout_vmtH       = empty2nan(xout_vmtH);
xout_vmtL       = empty2nan(xout_vmtL);
n_hpcH          = empty2nan(n_hpcH);
n_hpcL          = empty2nan(n_hpcL);
n_vmtH          = empty2nan(n_vmtH);
n_vmtL          = empty2nan(n_vmtL);

% reformat again
rayleighsP_hpcH = horzcat(rayleighsP_hpcH{:});
rayleighsP_hpcL = horzcat(rayleighsP_hpcL{:});
rayleighsP_vmtH = horzcat(rayleighsP_vmtH{:});
rayleighsP_vmtL = horzcat(rayleighsP_vmtL{:});
bsMrl_hpcH      = horzcat(bsMrl_hpcH{:});
bsMrl_hpcL      = horzcat(bsMrl_hpcL{:});
bsMrl_vmtH      = horzcat(bsMrl_vmtH{:});
bsMrl_vmtL      = horzcat(bsMrl_vmtL{:});    
rayleighsZ_hpcH = horzcat(rayleighsZ_hpcH{:});
rayleighsZ_hpcL = horzcat(rayleighsZ_hpcL{:});
rayleighsZ_vmtH = horzcat(rayleighsZ_vmtH{:});
rayleighsZ_vmtL = horzcat(rayleighsZ_vmtL{:}); 

% percent mod
rpHPCh = rayleighsP_hpcH(~isnan(rayleighsP_hpcH));
rpHPCl = rayleighsP_hpcL(~isnan(rayleighsP_hpcL));
rpVMTh = rayleighsP_vmtH(~isnan(rayleighsP_vmtH));
rpVMTl = rayleighsP_vmtL(~isnan(rayleighsP_vmtL));
perc_hpcH = (numel(find(rpHPCh<0.05))/numel(rpHPCh))*100;
perc_vmtH = (numel(find(rpVMTh<0.05))/numel(rpVMTh))*100;
perc_hpcL = (numel(find(rpHPCl<0.05))/numel(rpHPCl))*100;
perc_vmtL = (numel(find(rpVMTl<0.05))/numel(rpVMTl))*100;
totalHPC  = (numel(find(rpHPCh<0.05 | rpHPCl<0.05))/numel(rpHPCl))*100;

figure('color','w');
multiBarPlot(horzcat(perc_vmtH,perc_vmtL,perc_hpcH,perc_hpcL),[{'VMT high'} {'VMT low'} {'HPC high'} {'HPC low'}],'% mod.');

% bootstrapped mrl
diffMRL_hpc = (bsMrl_hpcH-bsMrl_hpcL)./(bsMrl_hpcH+bsMrl_hpcL);
diffMRL_vmt = (bsMrl_vmtH-bsMrl_vmtL)./(bsMrl_vmtH+bsMrl_vmtL);
data2plot = []; data2plot{1} = diffMRL_hpc; data2plot{2} = diffMRL_vmt;
figure('color','w');
multiBarPlot(data2plot,[{'HPC'} {'VMT'}],'Bootstrapped MRL');

diffZ_hpc = (rayleighsZ_hpcH-rayleighsZ_hpcL)./(rayleighsZ_hpcH+rayleighsZ_hpcL);
diffZ_vmt = (rayleighsZ_vmtH-rayleighsZ_vmtL)./(rayleighsZ_vmtH+rayleighsZ_vmtL);
data2plot = []; data2plot{1} = diffZ_hpc; data2plot{2} = diffZ_vmt;
figure('color','w');
multiBarPlot(data2plot,[{'HPC'} {'VMT'}],'Rayleighs Z');

uniti = 22;    
figure('color','w');
subplot 221;
    circ_plot(spkRadian_hpcH{uniti},'hist',[],18,false,true,'lineWidth',4,'color','b');
    title('High')
subplot 222;
    circ_plot(spkRadian_hpcL{uniti},'hist',[],18,false,true,'lineWidth',4,'color','r');
    title('Low')
disp(['High Raleighs Z = ',num2str(rayleighsZ_hpcH(uniti)),' p = ',num2str(rayleighsP_hpcH(uniti))]);
disp(['High Raleighs Z = ',num2str(rayleighsZ_hpcL(uniti)),' p = ',num2str(rayleighsP_hpcL(uniti))]);

subplot(223)
    bar(xout_hpcH{uniti},n_hpcH{uniti},'FaceColor','b')
    xlim ([0 360])
    xlabel ('Phase')
    ylabel ('Spike Count') 
    box off
subplot(224)
    bar(xout_hpcL{uniti},n_hpcL{uniti},'FaceColor','r')
    xlim ([0 360])
    xlabel ('Phase')
    ylabel ('Spike Count') 
    box off

% -- sfc -- %
diff_VMT = (sfcHighVMT-sfcLowVMT)./(sfcHighVMT+sfcLowVMT);
diff_HPC = (sfcHighHPC-sfcLowHPC)./(sfcHighHPC+sfcLowHPC);

figure('color','w'); hold on;
    shadedErrorBar(freq,mean(diff_VMT,1),stderr(diff_VMT,1),'g',0);
    shadedErrorBar(freq,mean(diff_HPC,1),stderr(diff_HPC,1),'b',0);
    axis tight;
    xlabel('Frequency (Hz)')
    ylabel('Spike field coherence (diff)')
    ylimits = ylim; xlimits = xlim;

    p = []; statVM = [];
    for i = 1:size(diff_VMT,2)
        [h,p(i),ci,stat]=ttest(diff_VMT(:,i));
        statVM(i,:)=stat.tstat;
    end 
    [h, crit_p, adj_ci_cvrg, padj]=fdr_bh(p);
    pLine = padj;
    pLine(pLine>0.05)=NaN;
    pLine(pLine<0.05)=ylimits(2);
    line(freq,pLine,'color','g','LineWidth',2) 
    
    p = []; statHC = [];
    for i = 1:size(diff_HPC,2)
        [h,p(i),ci,stat]=ttest(diff_HPC(:,i));
        statHC(i,:)=stat.tstat;
    end 
    [h, crit_p, adj_ci_cvrg, padj]=fdr_bh(p',0.05,'pdep','yes');
    pLine = padj;
    pLine(pLine>0.05)=NaN;
    pLine(pLine<0.05)=ylimits(2);
    line(freq,pLine,'color','b','LineWidth',2) 
     
% a unit that entrainment analysis discovered - unit 22
figure('color','w'); plot(freq,sfcHighHPC(22,:),'b','LineWidth',2)
hold on; plot(freq,sfcLowHPC(22,:),'r','LineWidth',2)
box off

% get mod units and examine sfc
hpcModH = find(rayleighsP_hpcH<0.05);
hpcModL = find(rayleighsP_hpcL<0.05);
vmtModH = find(rayleighsP_vmtH<0.05);
vmtModL = find(rayleighsP_vmtL<0.05);

% get sfc
diff_HPC_modH = sfcHighHPC(hpcModH,:);
diff_HPC_modL = sfcLowHPC(hpcModL,:);
diff_VMT_modH = sfcHighVMT(vmtModH,:);
diff_VMT_modL = sfcLowVMT(vmtModL,:);

figure('color','w'); hold on;
    plot(freq,mean(sfcHighHPC,1),'b','LineWidth',2)
    plot(freq,mean(sfcHighVMT,1),'m','LineWidth',2)

plot(freq,mean(sfcLowHPC(hpcModL,:),1),'r','LineWidth',2)

figure('color','w'); 
subplot 211; hold on;
    plot(freq,mean(sfcHighHPC,1),'b','LineWidth',2)
    plot(freq,mean(sfcHighVMT,1),'m','LineWidth',2)
subplot 212; hold on;
    plot(freq,mean(sfcLowHPC,1),'b','LineWidth',2)
    plot(freq,mean(sfcLowVMT,1),'m','LineWidth',2)
    for i = 1:size(sfcHighHPC,2)
        [h,p(i)]=ttest(sfcHighHPC(:,i),sfcHighVMT(:,i));
    end
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(p);

% fishiris has 3 species of 50 data points on x-axis, and dimensions of the flower on y
dataK = vertcat(diff_VMT,diff_HPC);
    
% number of clusters
rng('default')
clust = [];
clust = zeros(size(dataK,1),10);
for i=1:10
    clust(:,i) = kmeans(dataK,i);      
end
va = evalclusters(dataK,clust,'CalinskiHarabasz');
k=va.OptimalK;
c=kmeans(dataK,k);

% separate data
clustIdxVMT    = c(1:size(diff_VMT),:);
c(1:size(diff_VMT),:)=[];
clustIdxHPC    = c(1:size(diff_HPC),:);
c(1:size(diff_HPC),:)=[];

% separate clusters
diff_VMT_clust{1} = diff_VMT(clustIdxVMT==1,:);
diff_VMT_clust{2} = diff_VMT(clustIdxVMT==2,:);
diff_HPC_clust{1} = diff_HPC(clustIdxHPC==1,:);
diff_HPC_clust{2} = diff_HPC(clustIdxHPC==2,:);

figure('color','w');        
    subplot 211; hold on;
        shadedErrorBar(freq,mean(diff_VMT_clust{1},1),stderr(diff_VMT_clust{1},1),'k',0);
        shadedErrorBar(freq,mean(diff_VMT_clust{2},1),stderr(diff_VMT_clust{2},1),'m',0);
        axis tight;
        ylim([-0.5 0.5])  
        ylimits = ylim;
        
           % ttest for cluster 1
            p = []; statVM1 = [];
            for i = 1:size(diff_VMT_clust{1},2)
                [h,p(i),ci,stat]=ttest(diff_VMT_clust{1}(:,i));
                statVM1(i,:)=stat.tstat;
            end 
            [h, crit_p, adj_ci_cvrg, padj]=fdr_bh(p);
            pLine = padj;
            pLine(pLine>0.05)=NaN;
            pLine(pLine<0.05)=ylimits(2);
            line(freq,pLine,'color','k','LineWidth',2) 
            tableDataVMT_clust1 = []; frequency = freq'; pval = p'; padjust = padj';
            tableDataVMT_clust1 = table(frequency,statVM1,pval,padjust);
            
            % ttest for cluster 2
            p = []; statVM2 = [];
            for i = 1:size(diff_VMT_clust{1},2)
                [h,p(i),ci,stat]=ttest(diff_VMT_clust{2}(:,i));
                statVM2(i,:)=stat.tstat;
            end 
            [h, crit_p, adj_ci_cvrg, padj]=fdr_bh(p);
            pLine = padj;
            pLine(pLine>0.05)=NaN;
            pLine(pLine<0.05)=ylimits(2);
            line(freq,pLine,'color','m','LineWidth',2) 
            tableDataVMT_clust2 = []; frequency = freq'; pval = p'; padjust = padj';
            tableDataVMT_clust2 = table(frequency,statVM2,pval,padjust);
        
    subplot 212; hold on;
        shadedErrorBar(freq,mean(diff_HPC_clust{1},1),stderr(diff_HPC_clust{1},1),'k',0);
        shadedErrorBar(freq,mean(diff_HPC_clust{2},1),stderr(diff_HPC_clust{2},1),'m',0);
        axis tight;
        ylim([-0.5 0.5])  
        ylimits = ylim;
        
            % ttest for cluster 1
            p = []; statHC1 = [];
            for i = 1:size(diff_HPC_clust{1},2)
                [h,p(i),ci,stat]=ttest(diff_HPC_clust{1}(:,i));
                statHC1(i,:)=stat.tstat;
            end 
            [h, crit_p, adj_ci_cvrg, padj]=fdr_bh(p);
            pLine = padj;
            pLine(pLine>0.05)=NaN;
            pLine(pLine<0.05)=ylimits(2);
            line(freq,pLine,'color','k','LineWidth',2) 
            tableDataHPC_clust1 = []; frequency = freq'; pval = p'; padjust = padj';
            tableDataHPC_clust1 = table(frequency,statHC1,pval,padjust);
            
            % ttest for cluster 2
            p = []; statHC2 = [];
            for i = 1:size(diff_HPC_clust{1},2)
                [h,p(i),ci,stat]=ttest(diff_HPC_clust{2}(:,i));
                statHC2(i,:)=stat.tstat;
            end 
            [h, crit_p, adj_ci_cvrg, padj]=fdr_bh(p);
            pLine = padj;
            pLine(pLine>0.05)=NaN;
            pLine(pLine<0.05)=ylimits(2);
            line(freq,pLine,'color','m','LineWidth',2) 
            tableDataHPC_clust2 = []; frequency = freq'; pval = p'; padjust = padj';
            tableDataHPC_clust2 = table(frequency,statHC2,pval,padjust);

% separate mrl data
diffMrlVMT = (bsMrl_vmtH-bsMrl_vmtL)./(bsMrl_vmtH+bsMrl_vmtL);
diffMrlHPC = (bsMrl_hpcH-bsMrl_hpcL)./(bsMrl_hpcH+bsMrl_hpcL);

diffMRL_VMT_clust{1} = diffMrlVMT(clustIdxVMT==1);
diffMRL_VMT_clust{2} = diffMrlVMT(clustIdxVMT==2);
diffMRL_HPC_clust{1} = diffMrlHPC(clustIdxHPC==1);
diffMRL_HPC_clust{2} = diffMrlHPC(clustIdxHPC==2);

figure('color','w'); 
subplot 211; hold on;
    multiBarPlot(diffMRL_VMT_clust,[{'Clust1'} {'Clust2'}],'BS MRL')
subplot 212; hold on;
    multiBarPlot(diffMRL_HPC_clust,[{'Clust1'} {'Clust2'}],'BS MRL')

%% plotting entrainment and spike field coherence

load('data_coh_entrainment');

% plot an example unit with LFP
sessi    = 12; % has unit 22
temphigh = horzcat(datahigh{sessi}{:});
templow  = horzcat(datalow{sessi}{:});

% get unique timestamps
[~,idx] = unique(temphigh(4,:)); % only keep unique timestamps
temphigh = temphigh(:,idx); % index out your dataset
[~,idx] = unique(templow(4,:)); % only keep unique timestamps
templow = templow(:,idx); % index out your dataset

figure('color','w'); 
disp('Note that these data are not filtered like described in the paper')
disp('To see those data, you would have to hack the code above')
    %plot(C); axis tight;
    lfpIdx = [1:3]; unitIdx = [5]; srate = 2000;
    % the coherence analysis above worked through 1.25s windows with 0.25s
    % overlap, therefore account for missing the last
    lfpRaster(temphigh(:,181082:181082+2000),lfpIdx,unitIdx,srate)
    
%% How is PFC modulated by VMT stim?

% -- 21-45 -- %
% this rat had a probe in PFC layers, virus along rostro-caudal extent of
% RE. Referenced to ground, then rereferenced by taking the common avg and
% subtracting
clearvars -except sourceRoot sourceFolder sourceData sourceCode sourceRawCode
load('data_probeLFP_2145_groundRef');
stimRange = [5 9]; % stim at 7hz
sessionName = char(fieldnames(data.rat2145));

% set to 1 if you want to subtract a common avg (could be helpful for
% ground referencing)
commAvg = 1;
detrendData = 0; % if common avg rereferencing, dont worry about detrending

% get blue on and blue off for each shank
eventStrings = data.rat2145.(sessionName).events.strings;
eventTimes   = data.rat2145.(sessionName).events.times;
idxRedON  = find(contains(eventStrings,'RedON'));
idxBlueON = find(contains(eventStrings,'BlueON'));
timesBlueON = eventTimes(idxBlueON);
timesRedON  = eventTimes(idxRedON);

% get lfp times for blue on and red on
lfpTimes = data.rat2145.(sessionName).LFP.times;
lfpIdxBON = dsearchn(lfpTimes',timesBlueON');
lfpIdxRON = dsearchn(lfpTimes',timesRedON');

% get lfp data
lfpData = data.rat2145.(sessionName).LFP.lfp;

% common avg
if commAvg == 1
    lfpDataRef = nan2empty(lfpData);
    % avg within shank, then across
    lfpDataShank = cellcat(lfpDataRef,'vertcat','col');
    % avg
    lfpDataShankM = cellfun2(lfpDataShank,'mean',{'1'});
    % avg across shanks
    lfpDataShank2 = vertcat(lfpDataShankM{:});
    % define common avg
    lfpComAvg = mean(lfpDataShank2,1);
    % remove common avg from signals
    for rowi = 1:size(lfpData,1)
        for coli = 1:size(lfpData,2)
            if isnan(lfpData{rowi,coli})==0
                lfpData{rowi,coli} = lfpData{rowi,coli}-lfpComAvg; 
            end
        end
    end
end

% get srate
srate = data.rat2145.(sessionName).LFP.srate;

% work with each shank separately
lfpBON = []; lfpRON = [];
for shanki = 1:size(lfpData,1)
    for ei = 1:size(lfpData,2)
        for boni = 1:length(lfpIdxBON)
            % get 1s before and 4s after
            idx = []; % temp var
            idx = lfpIdxBON(boni)-srate(shanki,ei):lfpIdxBON(boni)+(srate(shanki,ei)*4);

            % get data
            try
                if detrendData == 1
                    lfpBON{shanki,ei}(boni,:) = detrend(lfpData{shanki,ei}(idx),3);
                else
                    lfpBON{shanki,ei}(boni,:) = lfpData{shanki,ei}(idx);
                end
            end
        end
        for roni = 1:length(lfpIdxRON)
            % get 1s before and 4s after
            idx = []; % temp var
            idx = lfpIdxRON(roni)-srate(shanki,ei):lfpIdxRON(roni)+(srate(shanki,ei)*4);

            % get data
            try
                if detrendData == 1
                    lfpRON{shanki,ei}(roni,:) = detrend(lfpData{shanki,ei}(idx),3);
                else
                    lfpRON{shanki,ei}(roni,:) = lfpData{shanki,ei}(idx);
                end                    
            end
        end        
    end
end

% visualize
for shanki = 1:size(lfpData,1)
    for ei = 1:size(lfpData,2)
        try mlfpBON{shanki,ei} = mean(lfpBON{shanki,ei},1); end
        try mlfpRON{shanki,ei} = mean(lfpRON{shanki,ei},1); end
    end
end
     
%{
% example from shank 8 
srate = 1000;
shank = 8; electrode = 4;
timerVar = linspace(-1,4,((srate*1+srate*4)+1)); 
figure('color','w'); 
subplot 211;
    lfpTheta = skaggs_filter_var(lfpBON{shank, electrode}(2,:),5,9,1000);
    plot(timerVar,lfpBON{shank, electrode}(2,:),'k');
    hold on; plot(timerVar,lfpTheta,'m','LineWidth',1)
    axis tight;
    box off;
    ylimits = ylim;
    xlimits = xlim;
    line([0 0],[ylimits(1) ylimits(2)],'Color','b','LineStyle','--','LineWidth',1)
    xlim([-1 2])
    xlabel('Time around stim')
    title(['Shank ',num2str(shank),' electrode',num2str(electrode)])
subplot 212;
    lfpTheta = skaggs_filter_var(lfpRON{shank, electrode}(2,:),5,9,1000);
    plot(timerVar,lfpRON{shank, electrode}(2,:),'k');
    hold on; plot(timerVar,lfpTheta,'m','LineWidth',1)
    axis tight;
    box off;
    ylimits = ylim;
    xlimits = xlim;
    line([0 0],[ylimits(1) ylimits(2)],'Color','r','LineStyle','--','LineWidth',1)
    xlim([-1 2])
    xlabel('Time around stim')
    title(['Shank ',num2str(shank),' electrode',num2str(electrode)])

% plot data
figure('color','w')
looper = 0; 
numShanks = size(lfpBON,1); 
numElectrodes = size(lfpBON,2);
for shanki = 1:numShanks
    for ei = 1:numElectrodes
        looper = looper+1;        
        subplot(numShanks,numElectrodes,looper)
        try
            plot(timerVar,mlfpBON{shanki,ei})
        catch
        end
        title(['Shank',num2str(shanki),' electrode',num2str(ei)])
        axis tight;
        %ylim([-6000 6000])
        % keep track of the number of loops
    end
end
%}

% take shank average
slfpBON = cellcat(mlfpBON,'vertcat','col');
slfpRON = cellcat(mlfpRON,'vertcat','col');
mslfpBON = cellfun2(slfpBON,'mean',{'1'});
mslfpRON = cellfun2(slfpRON,'mean',{'1'});

figure('color','w')
srate = 1000;
looper = 0; 
numShanks = size(lfpBON,1); 
numElectrodes = size(lfpBON,2);
timerVar = linspace(-1,4,((srate*1+srate*4)+1)); 
idxPlacement = [1:2:16 2:2:16];
dataDown = horzcat(mslfpBON, mslfpRON);
colors = vertcat(repmat('b',[1 8])',repmat('r',[1 8])');
for i = 1:length(idxPlacement)
    subplot(numShanks,2,idxPlacement(i))
    thetaD = []; thetaD = skaggs_filter_var(dataDown{i},5,9,1000);
    plot(timerVar,dataDown{i},'k'); hold on;
    plot(timerVar,thetaD,'m','LineWidth',1)
    axis tight;
    xlim([-1 2])
    ylimits = ylim;
    xlimits = xlim;
    box off;
    line([0 0],[ylimits(1) ylimits(2)],'Color',colors(i),'LineStyle','--','LineWidth',1)
end

% get power during 1s post stim
params = getCustomParams;
params.Fs = 1000;
params.fpass = [0 20];
params.tapers = [2 3];
params.trialave = 0; % work with each epoch separately
Sb = []; f = []; Sbl = []; Srl = []; SblM = []; SblE = []; SrlM = []; SrlE = [];
for shanki = 1:size(lfpBON,1)
    for ei = 1:size(lfpBON,2)
        try
            for epochi = 1:size(lfpBON{shanki,ei},1)
                lfpBtemp = [];
                lfpBtemp = lfpBON{shanki,ei}(epochi,:)';
                lfpBtemp = lfpBtemp(1000:3000,:); % first 2s post stim
                [Sb{shanki,ei}(epochi,:),f] = mtspectrumc(lfpBtemp,params);
                % log transform
                Sbl{shanki,ei}(epochi,:) = log10(Sb{shanki,ei}(epochi,:));
            end
            % get avg
            SblM{shanki,ei} = mean(Sbl{shanki,ei},1);
            SblE{shanki,ei} = stderr(Sbl{shanki,ei},1);
        end
    end
end
for shanki = 1:size(lfpData,1)
    for ei = 1:size(lfpData,2)
        try
            for epochi = 1:size(lfpRON{shanki,ei},1)
                lfpRtemp = [];
                lfpRtemp = lfpRON{shanki,ei}(epochi,:)';
                lfpRtemp = lfpRtemp(1000:3000,:); % first 2s post stim
                [Sr{shanki,ei}(epochi,:),f] = mtspectrumc(lfpRtemp,params);
                % log transform
                Srl{shanki,ei}(epochi,:) = log10(Sr{shanki,ei}(epochi,:));
            end
            % get avg
            SrlM{shanki,ei} = mean(Srl{shanki,ei},1);
            SrlE{shanki,ei} = stderr(Srl{shanki,ei},1);            
        end
    end
end

figure('color','w')
looper = 0; 
numShanks = size(lfpBON,1); 
numElectrodes = size(lfpBON,2);
for shanki = 1:numShanks
    for ei = 1:numElectrodes
        looper = looper+1;        
        subplot(numShanks,numElectrodes,looper)
        try
            shadedErrorBar(f,SblM{shanki,ei},SblE{shanki,ei},'b',0);
            hold on;
            shadedErrorBar(f,SrlM{shanki,ei},SrlE{shanki,ei},'r',0);
            ylim([2.5 5.5])
        catch
        end
        %title(['Shank',num2str(shanki),' electrode',num2str(ei)])
        axis tight;
        axis off
        %ylim([-6000 6000])
        % keep track of the number of loops
    end
end
savefig('fig_SEB_laserOnPowerAllElectrodes')

figure('color','w'); hold on;
shank=4; electrode=8;
shadedErrorBar(f,SblM{shank,electrode},SblE{shank,electrode},'b',0);
shadedErrorBar(f,SrlM{shank,electrode},SrlE{shank,electrode},'r',0);
ylabel('Log Transformed Power')
xlabel('Frequency (Hz)')

%{
% get avg over electrodes
sbe = cellcat(Sbl,'vertcat','col');
sre = cellcat(Srl,'vertcat','col');

sbe = cellfun2(sbe,'mean',{'1'});
sre = cellfun2(sre,'mean',{'1'});

% plot
figure('color','w')
for i = 1:length(sbe)
    subplot(4,2,i); hold on;
    plot(f,sbe{i},'b','LineWidth',2)
    plot(f,sre{i},'r','LineWidth',2)
    axis tight
    xlim([0 20]);
    %axis tight;
    title(['Electrode',num2str(i)])
   % ylim([1 6])
end
savefig('fig_SEB_laserOnPowerPerShank')

% get theta power
fTheta = find(f > stimRange(1) & f < stimRange(2));

for rowi = 1:size(Sbl,1)
    for coli = 1:size(Sbl,2)
        try
            SblTheta{rowi,coli} = mean(Sbl{rowi,coli}(:,fTheta),2);
            SrlTheta{rowi,coli} = mean(Srl{rowi,coli}(:,fTheta),2);
        end
    end
end

% avg over shanks
shankThetaB = []; shankThetaR = []; shankThetaBm = []; shankThetaRm = [];
shankThetaB = cellcat(SblTheta,'horzcat','col');
shankThetaR = cellcat(SrlTheta,'horzcat','col');
for i = 1:length(shankThetaB)
    shankThetaBm(:,i) = mean(shankThetaB{i},2);
    shankThetaRm(:,i) = mean(shankThetaR{i},2);
end

% fig
data2plot = shankThetaBm;
multiBarPlot(data2plot,[1:8],[num2str(stimRange(1)),'-',num2str(stimRange(2)),' power (blue laser)'])
ylim([2.5 4])

data2plot = shankThetaRm;
multiBarPlot(data2plot,[1:8],[num2str(stimRange(1)),'-',num2str(stimRange(2)),' power (blue laser)'])
ylim([2.5 4])

data2plot = [];
for i = 1:8
    data2plot{i} = padcat(shankThetaRm(:,i),shankThetaBm(:,i));
end
data2plot = horzcat(data2plot{:});
multiBarPlot(data2plot,[{'redShank1'} {'blueShank1'} {'redShank2'} {'blueShank2'} {'redShank3'} {'blueShank3'} ...
     {'redShank4'} {'blueShank4'}  {'redShank5'} {'blueShank5'}  {'redShank6'} {'blueShank6'} ...
      {'redShank7'} {'blueShank7'}  {'redShank8'} {'blueShank8'} ],[num2str(stimRange(1)),'-',num2str(stimRange(2)),' power'])
ylim([3 4.5])
cd(datafolder);
savefig('fig_laserOnPow')
save('data_laserOnPow','data2plot')

% difference scores
diffPlot = normDiffScore(data2plot);
figure;
multiBarPlot(diffPlot,[{'Shank1'} {'Shank2'} {'Shank3'} {'Shank4'} {'Shank5'} {'Shank6'} {'Shank7'} {'Shank8'}],'Theta power');
ylim([-0.05 0.15])
anova1(diffPlot(1:83,:))

% ranksum tests with multiple corrections
looper = 1:2:size(data2plot,2);
for i = 1:length(looper)
    [p(i),h]=ranksum(data2plot(:,looper(i)),data2plot(:,looper(i)+1));
end
p=p.*length(p);
 
%}

%% How is PFC-HPC interactions modulated by VMT stim?
% -- 21-43 and 21-42 -- %
clear;
ratID='rat2142';
if contains(ratID,'42')
    load('data_2142_stim8Hz');
elseif contains(ratID,'43')
    load('data_2143_stim7Hz')
end

params = getCustomParams;
params.Fs = 2000; srate = 2000;
params.tapers = [2 3];

disp('Please note that there was considerable variable over trials.')
disp('I looked across a bunch of trials to determine which window of time to use')
i = 15; % i = 10 for 21-43; i = 15 for 21-42
figure('color','w');
    xData = linspace(-2,2,size(pfcBon,1));
    subplot 311
        plot(xData,hpcBon(:,i),'b'); hold on;
        plot(xData,pfcBon(:,i),'r'); axis tight;
        xlim([-0.5 2]); box off;
    subplot 312;
        hpc = skaggs_filter_var(hpcBon(:,i),4,12,2000);
        pfc = skaggs_filter_var(pfcBon(:,i),4,12,2000);
        plot(xData,hpc,'b'); hold on; plot(xData,pfc,'r');
        axis tight; box off;
        xlim([-0.5 2])
    subplot 313;
        params.fpass = [6 9];
        [C,phi,S12,S1,S2,t] = cohgramc(hpcBon(:,i),pfcBon(:,i),[0.5, 0.15],params);
        xData = linspace(-2,2,numel(t));
        plot(xData,mean(C,2));
        xlim([-0.5 2])
        box off

plotTrials = 0;
if plotTrials == 1
    for i = 1:size(hpcBon,2)
        figure('color','w')
            subplot 211
            plot(hpcBon(:,i),'b'); hold on;
            plot(pfcBon(:,i),'r'); axis tight;
            subplot 212;
            hpc = skaggs_filter_var(hpcBon(:,i),4,12,2000);
            pfc = skaggs_filter_var(pfcBon(:,i),4,12,2000);
            plot(hpc,'b'); hold on; plot(pfc,'r');
            axis tight;
        pause;
        close;
    end
end
      
% another way to look at the data. I don't care for the averaging of the
% LFP too much, but it does reveal some interesting things about
% hippocampal theta
figure('color','w');
    xData = linspace(-2,2,size(pfcBon,1));
    subplot 311
        plot(xData,mean(hpcBon,2),'b'); hold on;
        plot(xData,mean(pfcBon,2),'r'); axis tight;
        xlim([-2 2]); box off;
    subplot 312
        hpc = skaggs_filter_var(mean(hpcBon,2),4,12,2000);
        pfc = skaggs_filter_var(mean(pfcBon,2),4,12,2000);    
        plot(xData,hpc,'b'); hold on; plot(xData,pfc,'r');
        axis tight; box off;
        xlim([-2 2]); box off;
    subplot 313;
        params.trialave = 1;
        params.fpass = [9 10];
        [C,phi,S12,S1,S2,t] = cohgramc(hpcBon,pfcBon,[0.5, 0.15],params);
        xData = linspace(-2,2,numel(t));
        plot(xData,mean(C,2));
        xlim([-2 2])
        box off
        
% return
params.fpass = [0 20];
params.trialave = 0;
disp('Visual observation revealed that initially, Re stim screws up phase locking, but then it becomes highly consistent')
% 5000-7000
% multitapers
timeAround = [2.5 3.5]; % 2.5 to 3.5 = 0.5 to 1.5s; 2.0 to 3.5 = entire
%timeAround = [2 4];
SpfB = []; ShcB = [];
for i = 1:size(hpcBon,2)
    [SpfB(i,:),f] = mtspectrumc(pfcBon(timeAround(1)*srate:srate*timeAround(2),i),params);
    [ShcB(i,:),fpb] = mtspectrumc(hpcBon(timeAround(1)*srate:srate*timeAround(2),i),params);
    [Cb(i,:),phib{i},S12b{i},S1,S2,f] = coherencyc(hpcBon(timeAround(1)*srate:srate*timeAround(2),i),pfcBon(timeAround(1)*srate:srate*timeAround(2),i),params);
    %
    SpfB(i,:) = log10(SpfB(i,:));
    ShcB(i,:) = log10(ShcB(i,:));
end
SpfR = []; ShcR = [];
for i = 1:size(hpcRon,2)
    [SpfR(i,:),f] = mtspectrumc(pfcRon(timeAround(1)*srate:srate*timeAround(2),i),params);
    [ShcR(i,:),fpr] = mtspectrumc(hpcRon(timeAround(1)*srate:srate*timeAround(2),i),params);
    [Cr(i,:),phir{i},S12r{i},S1,S2,f] = coherencyc(hpcRon(timeAround(1)*srate:srate*timeAround(2),i),pfcRon(timeAround(1)*srate:srate*timeAround(2),i),params);
    
    %
    SpfR(i,:) = log10(SpfR(i,:));
    ShcR(i,:) = log10(ShcR(i,:));    
end  

% set to 1 if 21-42
kmeanit = 1;
rng('default');
if kmeanit == 1
    if contains(ratID,'42')
        disp('for this rat (minimal virus), sometimes stim produced pfc rhythms, sometimes it didnt. ')
        disp('Since re stim should produce those rhythms, extract times when it actually worked')

        % 21-42 - sometimes it worked but it didnt always work
        fTheta = find(f>6 & f<9);

        % power
        pfThetaB = mean(SpfB(:,fTheta),2);
        pfThetaR = mean(SpfR(:,fTheta),2);
        [C,idx] = kmeans(pfThetaB,2);

        % filter data
        CbClust{1} = Cb(C==1,:);
        CbClust{2} = Cb(C==2,:);

        figure; 
            subplot 211;
                plot(f,mean(CbClust{1},1),'k'); hold on;
                plot(f,mean(CbClust{2},1),'m');  
                ylabel('Coherence');
                xlabel('Frequency');
                legend('Clust1','Clust2');
            subplot 212;
                k_pfB{1} = SpfB(C==1,:);
                k_pfB{2} = SpfB(C==2,:);
                plot(f,mean(k_pfB{1},1),'k'); hold on;
                plot(f,mean(k_pfB{2},1),'m');                  
                ylabel('Power');
                xlabel('Frequency');
                legend('Clust1','Clust2');            

        if mean(pfThetaB(C==1)) > mean(pfThetaB(C==2))
            Cb   = Cb(C==1,:);
            SpfB = SpfB(C==1,:);
            ShcB = ShcB(C==1,:);
        else
            Cb   = Cb(C==2,:);
            SpfB = SpfB(C==2,:);
            ShcB = ShcB(C==2,:);
        end

    end
end

thetaAn = [6 11];
figure('color','w');
subplot 311; hold on;
    fTheta = find(f>4 & f<12);
    shadedErrorBar(f(fTheta),mean(SpfB(:,fTheta),1),stderr(SpfB(:,fTheta),1),'b',0)
    shadedErrorBar(f(fTheta),mean(SpfR(:,fTheta),1),stderr(SpfR(:,fTheta),1),'r',0)
    title('PFC')
    ylabel('Log10 power')
    xlimits = xlim;
    ylimits = ylim;    
    p = [];
    for i = 1:length(fTheta)
        [h,p(i)]=ttest2(SpfB(:,fTheta(i)),SpfR(:,fTheta(i)))
    end 
    fT = f(fTheta);
    fTrange = fT(fT > thetaAn(1) & fT < thetaAn(2));
    pT = p(fT > thetaAn(1) & fT < thetaAn(2));
    fxP = horzcat(fTrange',pT');
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pT);
    pLine = NaN([size(p)]);
    pLine(fT > thetaAn(1) & fT < thetaAn(2))=adj_p;  
    pLine(pLine>0.05)=NaN;
    pLine(pLine<0.05)=ylimits(2);
    line(f(fTheta),pLine,'color','m','LineWidth',2)
       
subplot 312; hold on;
    shadedErrorBar(f(fTheta),mean(ShcB(:,fTheta),1),stderr(ShcB(:,fTheta),1),'b',0)
    shadedErrorBar(f(fTheta),mean(ShcR(:,fTheta),1),stderr(ShcR(:,fTheta),1),'r',0)
    title('HPC')
    ylabel('Log10 power')
    xlimits = xlim;
    ylimits = ylim;    
    p = [];
    for i = 1:length(fTheta)
        [h,p(i)]=ttest2(ShcB(:,fTheta(i)),ShcR(:,fTheta(i)))
    end 
    pT = p(f(fTheta) > thetaAn(1) & f(fTheta) < thetaAn(2));
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pT);
    pLine = NaN([size(p)]);
    pLine(f(fTheta) > thetaAn(1) & f(fTheta)<thetaAn(2))=adj_p;  
    pLine(pLine>0.05)=NaN;
    pLine(pLine<0.05)=ylimits(2);
    line(f(fTheta),pLine,'color','m','LineWidth',2)
subplot 313; hold on;
    shadedErrorBar(f(fTheta),mean(Cb(:,fTheta),1),stderr(Cb(:,fTheta),1),'b',0)
    shadedErrorBar(f(fTheta),mean(Cr(:,fTheta),1),stderr(Cr(:,fTheta),1),'r',0)
    ylabel('Coherence')
    xlimits = xlim;
    ylimits = ylim;    
    p = [];
    for i = 1:length(fTheta)
        [h,p(i)]=ttest2(Cb(:,fTheta(i)),Cr(:,fTheta(i)))
    end 
    pT = p(f(fTheta) > thetaAn(1) & f(fTheta) < thetaAn(2));
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pT);
    pLine = NaN([size(p)]);
    pLine(f(fTheta) > thetaAn(1) & f(fTheta)<thetaAn(2))=adj_p;  
    pLine(pLine>0.05)=NaN;
    pLine(pLine<0.05)=ylimits(2);
    line(f(fTheta),pLine,'color','m','LineWidth',2)
    title([ratID])
