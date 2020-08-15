% only include if data is > 50 spikes surrounding a ripple
clear; clc; close all

%Run Matlab Pipeline startup file for necessary functions
%addpath 'X:\03. Lab Procedures and Protocols\MATLABToolbox\1. Matlab Pipeline'
%run 'Startup.m'

%% load and isolate data
% John's Rats
     %BabyGroot   
        %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-12-18';
    % Meusli
        datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Meusli 6-14-18';
    % Groot 
        %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Groot 3-3-18';
    % Thanos 
        %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Thanos 12-8-18';

% Henry's Rats 
    % Ratticus Baseline 1
        %datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Sessions Collapsed\Baseline Recordings\Ratticus Baseline 1';
    
    % Eric2 Baseline + Saline 
        %datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Sessions Collapsed\Baseline Recordings\Eric2 Baseline 1';
        %datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Eric2\Saline\Saline';
        
    % Ratdle Baseline 1
        %datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Sessions Collapsed\Baseline Recordings\Ratdle Baseline 1';
        
    % 14-22 Baseline 3
        %datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Sessions Collapsed\Baseline Recordings\14-22 Baseline 3';
        
% SWR .WAV file    
    %datafolder = 'X:\01.Experiments\John n Andrew\SWR confirmation\Testing SWRs';

%{
datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-11-18';
%datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Sessions Collapsed\Baseline Recordings\Ratticus Baseline 1';
%datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Eric2\Saline\Saline';
%datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-11-18';
%datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Meusli 6-14-18';
cd(datafolder);
%datafolder = 'X:\01.Experiments\John n Andrew\SWR confirmation\Testing SWRs';
%}
    
    
% get lfp data
cd(datafolder);
%load('CSC3'); % ratticus
%load('CSC8'); % use with Eric2
%load('Re');
load('HPC');
%load('mPFC');
%load('SWRtest'); 

% sometimes data can be named differently
if exist("CSC_Timestamp")
    Times_unf = CSC_Timestamp;
else
    Times_unf = Timestamps;
    clear Timestamps
end
    
if exist("CSC_Samples")
    Samples_unf = CSC_Samples;
else
    Samples_unf = Samples;
    clear Samples
end

[Timestamps, lfp] = interp_TS_to_CSC_length_non_linspaced(Times_unf, Samples_unf);     

% get behavior
load('Events.mat') 
load('VT1.mat')                 
[ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);             
load('Int');  % load int file

if exist("TimeStamps")
    TimeStamps_VT = TimeStamps;
    clear TimeStamps
end

% get LFP data from reward well
numTrials = size(Int,1); % define number of trials
%numTrials = 13;
clear X Y TS
for triali = 1:numTrials
    LFPtimes{triali} = Timestamps(Timestamps > Int(triali,2) & Timestamps < Int(triali,7));
    LFP{triali}      = lfp(Timestamps > Int(triali,2) & Timestamps < Int(triali,7));
    X{triali}        = ExtractedX(TimeStamps_VT > Int(triali,2) & TimeStamps_VT < Int(triali,7));
    Y{triali}        = ExtractedY(TimeStamps_VT > Int(triali,2) & TimeStamps_VT < Int(triali,7));
    TS{triali}       = TimeStamps_VT(TimeStamps_VT > Int(triali,2) & TimeStamps_VT < Int(triali,7));
end

%% extract swrs
% calculate and define the sampling rate
totalTime  = (Times_unf(2)-Times_unf(1))/1e6; % this is the time between valid samples
numValSam  = size(Samples_unf,1);     % this is the number of valid samples (512)
srate      = round(numValSam/totalTime); % this is the sampling rate

% phase bandpass
phase_bandpass = [150 250];

% define how many standard deviations from mean for inclusion
std_above_mean = 3;

% define gauss
gauss = 0;

% plot?
plotFig = 1;

% inter ripple interval
InterRippleInterval = 0; % this is the time required between ripples. if ripple occurs within this time range (in sec),

% extract swr function
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\SWR')
mazeLoc = [2 7];
%tic
% took about 4 sec rounded

% this function considers trials
[SWRcount,SWRdurations,SWRtimes,SWRtimeIdx] = extract_SWR_3(lfp,mazeLoc,Int,Timestamps,srate,phase_bandpass,std_above_mean,gauss,InterRippleInterval,plotFig);
%toc

% this function looks across session
%[SWRcount,SWRdurations,SWRtimes,SWRtimeIdx] = extract_session_SWRs(lfp,Timestamps,srate,phase_bandpass,std_above_mean,gauss,InterRippleInterval);

%% extract times when running speed > 4cm/sec - ignore until we have measurements

%time frame around ripple
timeFrame    = 0.5; % seconds
VTsrate      = 30; % sampling rate of video tracking data
sampleWindow = timeFrame*VTsrate; % in samples

conv_auto = 0;
if conv_auto == 1
    disp('Calculating a conversion factor for X and Y pos. data - if you prefer manual, stop and define')
    % convert to cm - if right room (henry data) realDim_X = 178; realDim_Y = 163;
    realDim_X = 178
    realDim_Y = 163
    [convFact,convX,convY] = Pixels2Measurement(ExtractedX,ExtractedY,realDim_X,realDim_Y,[],[],[],[]);
else
    % manual
    convX = ExtractedX./2.09;
    convY = ExtractedY./2.04;
end

% exclude ripples if rat was running > 4cm/sec during the entirety of the
% ripple event
clear runIdx runTime runX runY times speed vel pos tDiff
for i = 1:SWRcount
        
    % initialize vector
    runIdx{i} = zeros([1 2]);
    times{i}  = zeros([1 2]);
    
    % use dsearchn to find the nearest timestamp for swr onset. Have to use
    % dsearchn because we're using video tracking timestamps NOT lfp
    % timestamps
    %runIdx{i}(2)  = dsearchn(TimeStamps_VT',SWRtimes{i}(1));   
    runIdx{i}(1) = dsearchn(TimeStamps_VT',SWRtimes{i}(1));
    runIdx{i}(2) = dsearchn(TimeStamps_VT',SWRtimes{i}(end));
    
    % note that we need to use lfp timestamps for calculating velocity
    % because the resolution is finer. Otherwise, we'll get some nans
    times{i}(1)  = Timestamps((Timestamps == SWRtimes{i}(1)));
    times{i}(2)  = Timestamps((Timestamps == SWRtimes{i}(end)));
    
    % get data one point before and one after
    %runIdx{i}(1) = runIdx{i}(2)-sampleWindow;
    %runIdx{i}(3) = runIdx{i}(2)+sampleWindow;
    
    % get position data
    %runTime{i} = TimeStamps_VT(runIdx{i});
    runX{i}    = convX(runIdx{i});
    runY{i}    = convY(runIdx{i});    
    % calculate speed per trajetory
    [speed{i},vel{i},pos{i},tDiff{i}] = instant_speed(runX{i},runY{i},times{i}/1e6);
end
% take the average of the instantaneous speed surrounding ripple onsets
speedMean = cellfun(@mean,speed);
% find instances where speed is > than 4cm/sec
speedRem = find(speedMean > 4);
% remove those from the data
SWRcount = SWRcount - (length(speedRem));
SWRdurations(speedRem)=[];
SWRtimes(speedRem)=[];
SWRtimeIdx(speedRem)=[];

%% remove clipping events

time_around = [0.5 0.5];
lfpAroundRipple = [];
lfpDuringRipple = [];
% grab lfp 2 sec around ripple.
for swri = 1:length(SWRtimes)
    
    % lfp around ripple
    lfpAroundRipple{swri} = lfp(Timestamps>(SWRtimes{swri}(1)-(time_around(1)*1e6))&Timestamps<(SWRtimes{swri}(1)+(time_around(2)*1e6)));

    % lfp during ripple
    lfpDuringRipple{swri} = lfp(find(Timestamps == SWRtimes{swri}(1)):find(Timestamps == SWRtimes{swri}(end)));

    % find number of clippings - only put the ripple data
    [~,~,numClippings(swri)] = detect_clipping(lfpDuringRipple{swri});
    
end

% remove clipping events
idxRem = find(numClippings > 0);
SWRcount = SWRcount - (length(idxRem));
SWRdurations(idxRem)=[];
SWRtimes(idxRem)=[];
SWRtimeIdx(idxRem)=[];
lfpAroundRipple(idxRem)=[];
lfpDuringRipple(idxRem)=[];

%% consider theta-delta ratio
% get theta delta ratio for entire session
[TDratio,TDratioZ] = Theta_Delta_Ratio(lfp,[6 12],[1 4],srate);

% get theta delta ratio data during the ripple event
TDratioArRip = []; TDratioAroundRip = [];
for swri = 1:length(SWRtimes)
    
    % extract theta delta ratio around ripples
    TDratioDuringRip{swri} = TDratioZ(find(Timestamps ==(SWRtimes{swri}(1))):find(Timestamps ==(SWRtimes{swri}(end))));
   
    % around ripple
    TDratioAroundRip{swri} = TDratioZ(find(Timestamps>(SWRtimes{swri}(1)-(time_around(1)*1e6))&Timestamps<(SWRtimes{swri}(1)+(time_around(2)*1e6))));
    
end

% remove events > 1 sd (theta:delta ratio - indicates theta is high)

swrNum = 1;

figure('color','w');
subplot 211
    x_label = linspace(0,length(TDratioDuringRip{swrNum})/(srate/1000),length(TDratioDuringRip{swrNum}));
    plot(x_label,TDratioDuringRip{swrNum},'b','LineWidth',2)
    xlimits = xlim;
    ylimits = ylim;
    line([xlimits(1) xlimits(2)],[1 1],'Color','r','LineStyle','--')
    ylim([ylimits(1) 1.5])
    xlabel('Time During Ripple (ms)')
    ylabel('Theta:Delta ratio')

subplot 212
    x_label = linspace(-1*(time_around(1)),time_around(2),length(TDratioAroundRip{swrNum}));
    plot(x_label,TDratioAroundRip{swrNum},'b','LineWidth',2)
    xlimits = xlim;
    ylimits = ylim;
    line([xlimits(1) xlimits(2)],[1 1],'Color','r','LineStyle','--')
    ylim([ylimits(1) 1.5])
    xlabel('Time Around Ripple (Sec)')
    ylabel('Theta:Delta ratio')


% find instances where theta delta ratio is above 1sd within the ripple
% events
idxThetaDelta = [];
for i = 1:length(TDratioAroundRip)
    idxThetaDelta{i} = find(TDratioAroundRip{i} > 1);
end

% find instances where theta delta > 1 and remove them from ripple events
thetaPow2High = find(cellfun('isempty',idxThetaDelta)==0);

% remove instances where theta power exceeded delta power
SWRcount = SWRcount - (length(thetaPow2High));
SWRdurations(thetaPow2High)=[];
SWRtimes(thetaPow2High)=[];
SWRtimeIdx(thetaPow2High)=[];
lfpAroundRipple(thetaPow2High)=[];
lfpDuringRipple(thetaPow2High)=[];

%% find ripples in other regions and remove them from HPC, consider them noise
%{
clear Times_unf Samples_unf
load('Re.mat');

if exist("CSC_Timestamp")
    Times_unf = CSC_Timestamp;
else
    Times_unf = Timestamps;
    clear Timestamps
end
    
if exist("CSC_Samples")
    Samples_unf = CSC_Samples;
else
    Samples_unf = Samples;
    clear Samples
end

[Timestamps, lfp2] = interp_TS_to_CSC_length_non_linspaced(Times_unf, Samples_unf);     

[SWRcount2,SWRdurations2,SWRtimes2,SWRtimeIdx2,~] = extract_SWR_2(lfp2,mazeLoc,Int,Timestamps,srate,phase_bandpass,std_above_mean,gauss,InterRippleInterval,plotFig);
%}

%% visualize single trial power
            % on 07-08-2020 I found that Re exhibits the same 130-160hz ripple, while
            % pfc does not. This makes me question if 130-160 is actually a ripple or
            % an artifact of theta.

% average across
% plot heat map https://www.pnas.org/content/pnas/112/46/E6379.full.pdf -
% fig 2c
params.tapers    = [2 3];
params.trialave  = 0;
params.err       = [2 .05];
params.pad       = 0;
params.fpass     = [0 300]; % [1 100]
params.movingwin = [0.05 0.01]; % was [0.25 0.01] %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
params.Fs        = srate;

clear pow_trials time_trials freq_trials
for z = 1:length(lfpAroundRipple)
    [pow_trials{z},time_trials,freq_trials]=mtspecgramc(lfpAroundRipple{z},params.movingwin,params);
end

    swrNum = 1;
    % plot 1 trial
    figure('color','w')
    subplot 121
        x_label = linspace(-0.5, 0.5, length(time_trials));
        timeIdx = find(x_label > -0.4 & x_label < 0.4);
        pcolor(x_label(timeIdx),freq_trials,log10(pow_trials{swrNum}(timeIdx,:)'))
        colormap(jet)
        c = colorbar;   
        %caxis([0.0548 0.0563])    
        shading 'interp'
        ylabel('frequency')
        xlabel('time') 
        title(['swr number ',num2str(swrNum)])
        set(gca,'FontSize',10)
    subplot 122
        freq_get = find(freq_trials > 100 & freq_trials < 300);
        pcolor(x_label(timeIdx),freq_trials(freq_get),log10(pow_trials{swrNum}(timeIdx,freq_get)'))
        colormap(jet)
        c = colorbar;   
        %caxis([0.0548 0.0563])    
        shading 'interp'
        ylabel('frequency')
        xlabel('time') 
        title(['swr number ',num2str(swrNum)])
        set(gca,'FontSize',10)

%% Four way SWR analysis plot (LFP, RippleBand, Avg Norm.Power, Avg Freq Norm. for time, Avg time Norm. for freq  
%normalize across time
norm_pow = normalize(pow_trials{swrNum},'range'); % normalized across time

x_label_pow = linspace(-time_around(1),time_around(2),length(time_trials));
x_label_lfp = linspace(-time_around(1),time_around(2),length(lfpAroundRipple{swrNum}));

%Raw LFP
figure('color','w')
subplot 421
plot(x_label_lfp,lfpAroundRipple{swrNum},'m')
box off
ylabel('Voltage')
title(['SWR Number ',num2str(swrNum)])

%Filtered ripple-band and plot hilbert transformation
filt_Ripple = skaggs_filter_var(lfpAroundRipple{swrNum}, phase_bandpass(1),...
    phase_bandpass(2), srate); % why do we filter again here?   
subplot 423
plot(x_label_lfp,zscore(filt_Ripple),'r')
box off
ylabel('Voltage')

% Session Avg power plot Normalized by time
subplot 223
freq_band = [0 300];
freq_idx = find(freq_trials >= freq_band(1) & freq_trials <= freq_band(2)); 
pcolor(x_label_pow,freq_trials(freq_idx),norm_pow(:,freq_idx)')
colormap(jet)
shading 'interp'
ylabel('frequency')
xlabel('Time around SWR onset') 
set(gca,'FontSize',10)
title('Power norm. by time')

% now do averages across frequencies of swr band (see the time resolution)
swr_band = [150 250];
freq_idx = find(freq_trials >= swr_band(1) & freq_trials <= swr_band(2));
freq_new = freq_trials(freq_idx); % get freqs
swr_pow  = norm_pow(:,freq_idx);
swr_pow_avg = mean(swr_pow,2); % average across frequencies, not time
subplot 222
plot(x_label_pow,swr_pow_avg,'b','LineWidth',2)
box off
xlabel('Time around SWR onset')
ylabel('Norm. Power of SWR freqs')
title(['Frequencies: ',num2str(swr_band(1)),'-',num2str(swr_band(2))])

% average across time (see the frequency resolution)
subplot 224
x_label = linspace(-0.5, 0.5, length(time_trials));
timeIdx = find(x_label > -0.1 & x_label < 0.1);
freq_idx = find(freq_trials >= swr_band(1) & freq_trials <= swr_band(2));
swr_pow_avg2 = mean(norm_pow(timeIdx,:),1); % averaged across time
plot(swr_pow_avg2(freq_idx),freq_trials(freq_idx),'k','LineWidth',2)
box off
ylabel('Frequency')
xlabel('Norm. Power')

%% ~~ power plotting both power gram and fre x pow ~~ %
% 3d matrix
clear pow_3d pow_mean
pow_3d   = cat(3,pow_trials{:});
pow_mean = mean(pow_3d,3);

figure('color','w');
subplot 311
    x_label_pow = linspace(-time_around(1),time_around(2),length(time_trials));
    pcolor(x_label_pow,freq_trials,log10(pow_mean'))
    colormap(jet)
    %c = colorbar;   
    %caxis([0.0548 0.0563])    
    shading 'interp'
    ylabel('frequency')
    xlabel('time') 
    ylabel('SWR event avg. power (db)')
    set(gca,'FontSize',10)
    title('SWR averaged')
subplot 312
    x_label_pow = linspace(-time_around(1),time_around(2),length(time_trials));
    pcolor(x_label_pow,freq_trials,(normalize(log10(pow_mean),'range'))')
    colormap(jet)
    %c = colorbar;   
    %caxis([0.0548 0.0563])    
    shading 'interp'
    ylabel('frequency')
    xlabel('time') 
    ylabel('SWR event avg. power (db)')
    set(gca,'FontSize',10)
    title('Normalize SWR power')
    
% look at freq x power
clear freqXpower freq_freqXpow
params.fpass = [0 250];
for z = 1:length(lfpAroundRipple)
    [freqXpower{z},freq_freqXpow]=mtspectrumc(lfpAroundRipple{z},params);
end
% average
freqXpow_cat  = log10(horzcat(freqXpower{:}));
freqXpow_mean = mean(freqXpow_cat,2);
freqXpow_std  = stderr(freqXpow_cat');

subplot 313
shadedErrorBar(freq_freqXpow,freqXpow_mean,freqXpow_std,'k',1)
ylabel('Power (log10)')
xlabel('Frequency')
box off

%% plot histogram of ripples
figure('color','w')
histogram(SWRdurations)
box off
ylabel('SWR count')
xlabel('SWR duration (ms)')
ylimits = ylim;
l1 = line([mean(SWRdurations) mean(SWRdurations)],[ylimits(1) ylimits(2)]);
l1.LineStyle = '--';
l1.LineWidth = 2;
l1.Color     = 'k';

%% PSTH

% define times around
timesAround = [0.5*1e6 0.5*1e6];

% load spikeTimes
cd(datafolder);
clusters = dir('TT*.txt');
ci = 6; % cluster 1
spikeTimes = textread(clusters(ci).name); % spike times

% plot fig?
plotFig = 1;

% psth
[FR,n,exclude] = PETH_SWR(spikeTimes,SWRtimes,timesAround,plotFig)



