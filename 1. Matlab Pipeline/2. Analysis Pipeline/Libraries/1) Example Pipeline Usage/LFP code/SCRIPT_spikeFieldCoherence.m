%% tester
%
% this code is a proof of concept for my (JS) use of spike field coherence.
% I used this as it has a known input and known output. I generated the
% figure 23.7 in mike cohens matlab for brain and cognitive scientists
% book. I then used this code on griffin lab data to perform spike field
% coherence.
%
% This code also generates entrainment values via phase interpolation
%
% This code was validated on a hippocampal place cell against hippocampal
% theta rhythms
%
% last edit was on 2-11-2023 by John Stout

clear; clc;
cd(getCurrentPath);
load('spikefieldData')
frequencies = logspace(0,2); % 10^0 to 10^2: 1:100
nCycle = 6; % constants

% chronux
params = getCustomParams;
params.Fs = srate;
params.pad = 2;
params.fpass = [0:20];
params.tapers = [3 5];
[C,phi,S12,S1,S2,f]=coherencycpb(lfp',spikeTimes',params);
figure; plot(f,C); xlim([0 20])

% sfc defined as the cpsd/s1*s2 via welches method
% notice how this gives you the same answer as chronux's method, except we
% have more control over frequency precision (frequency variable) - this is
% a lot faster as well
freq = [1:.5:20];
[sfc,freq] = getSpikeFieldCoherence(lfp,spikeTimes,freq,[],srate);
figure; plot(freq,sfc);

% sfc defined by phase (practically mrl)
nCycles = 6;
[sfcP,freqP] = getSpikeFieldCoherence(lfp,spikeTimes,freq,nCycles,srate,'phase');

figure('color','w');
subplot 211; hold on;
    plot(freq,smoothdata(sfc,'gaussian',10),'k');
    plot(freq,sfc,'b')
    title('Welchs SFC')
    legend('Smoothed','raw')
subplot 212; 
    plot(freqP,sfcP);
    title('Cohen sfc')
    xlabel('Frequency')
    ylabel('Spike Field Coherence')
    box off
    
% welch's method was fine on the hpc unit, but when I do the same on a PFC
% unit and HPC lfp, the results are remarkably different
clear;
load('spikefieldData_pfcUnitHpcLFP')

freq = [1:.5:20];
[sfc,freq] = getSpikeFieldCoherence(lfp,spikeTimes,freq,[],srate);
figure; plot(freq,sfc);

% sfc defined by phase (practically mrl)
nCycles = 6;
[sfcP,freqP] = getSpikeFieldCoherence(lfp,spikeTimes,freq,nCycles,srate,'phase');

figure('color','w');
subplot 211; hold on;
    plot(freq,smoothdata(sfc,'gaussian',10),'k');
    plot(freq,sfc,'b')
    title('Welchs SFC')
    legend('Smoothed','raw')
subplot 212; 
    plot(freqP,sfcP);
    title('Cohen sfc')
    xlabel('Frequency')
    ylabel('Spike Field Coherence')
    box off
    
%% here are some approaches broken down a bit
%tic;
clear;
load('spikefieldData')
lfp1 = lfp;
% unlike our data, these data are organized as a boolean variable where 1 =
% spike, 0 = no spike. We need to use dsearchn to identify sidx as a
% variable that points to LFP for each spike using out data. Here, find
% does the same job.
sidx = find(spikeTimes); 
sidx_og = sidx; % save for later
for wavei = 1:length(frequencies)
    % get complex morlet wavelets for hpc and pfc at frequency
    % wavei
    [asHpc] = getMorletWaveletConv(lfp,frequencies(wavei),nCycle,srate);
    % now perform spike field coherence across the various analytical
    % signals
    anglesHpc = angle(asHpc(sidx)); % phase of lfp at each spike as extracted via morlet wavelet convolution, as 
    sfc(wavei) = abs(mean(exp(1i*anglesHpc))); % Length of the average vector (like power)
end
figure('color','w')
plot(frequencies,sfc);

% built into a function
[sfc,freq] = getSpikeFieldCoherence(lfp,sidx,[],12,srate,'phase');
figure('color','w')
plot(freq,sfc);

% what is below is for constructing the mathematical equation for
% manuscript purposes:
% note that this is just an example phase angle at frequency (F)
theta = anglesHpc; % theta = phase angle (NOT THETA BRAIN WAVE)

% per phase angle k, multiply imaginary number 1i against theta angle, take
% the exponent of these
N = length(theta);
for k = 1:N
    eulersPartLong(k)=exp(sqrt(-1)*theta(k));
end
% get the average from 1:N
avgEP=sum(eulersPartLong)./numel(eulersPartLong);
SFClong=abs(avgEP);

%% link between spike counts and sfc

% does the same job.
sfc = [];
looper = 1:50:1000; % number of spikes per iteration, i
for i = looper
    sidx = find(spikeTimes);
    sidx = randsample(sidx,i);
    for wavei = 1:length(frequencies)
        % get complex morlet wavelets for hpc and pfc at frequency
        % wavei
        [asHpc] = getMorletWaveletConv(lfp,frequencies(wavei),nCycle,srate);
        % now perform spike field coherence across the various analytical
        % signals
        anglesHpc = angle(asHpc(sidx)); % phase of lfp at each spike as extracted via morlet wavelet convolution, as 
        sfc{i}(wavei) = abs(mean(exp(1i*anglesHpc))); % Length of the average vector (like power)
    end
    disp(['Iteration ',num2str(i)])
end
sfc = emptyCellErase(sfc);
sfc = vertcat(sfc{:});
figure('color','w')
plot(frequencies,sfc);

% spike field coherence per iteration
sfc_it = mean(sfc(:,frequencies > 6 & frequencies < 9),2);
xVar = looper;

sfc_it(1)=[]; xVar(1)=[];
figure('color','w')
    scatter(xVar*100,sfc_it)
    lsline
    [r,p]=corrcoef(xVar,sfc_it);
    xlabel('Number of spikes')
    ylabel('Theta SFC')
    ylimits = ylim;
    xlimits = xlim;
    if p<0.05
        text(xlimits(2)-40*100,ylimits(2)-0.005,['R = ',num2str(r(2)),'*'])
    else
        text(xlimits(2)-40*100,ylimits(2)-0.005,['R = ',num2str(r(2))])
    end    

%% comparing hilbert entrainment to phase interpolation
lowpass  = 6; highpass = 9;
hpcFilt  = skaggs_filter_var(double(lfp)',lowpass,highpass,srate);
[phase,phaseRad] = hilbertPhase(hpcFilt);

nonThetaState = 86511:86511+10000;
figure('color','w'); 
    subplot 211; hold on;
        plot(lfp(1:srate*6),'b'); 
        plot(hpcFilt(1:srate*6),'k','LineWidth',2);
        ylabel('HPC signal')
    yyaxis right;
        plot(phase(1:srate*6),'m','LineWidth',2)
        ylabel([[num2str(lowpass),'-',num2str(highpass)], ' Phase'])
    subplot 212; hold on;
        plot(lfp(nonThetaState),'b'); 
        plot(hpcFilt(nonThetaState),'k','LineWidth',2);
        ylabel('HPC signal')
    yyaxis right;
        plot(phase(nonThetaState),'m','LineWidth',2)
        ylabel([[num2str(lowpass),'-',num2str(highpass)], ' Phase'])

% get spike phases
sidx = find(spikeTimes);
spkPhase   = phase(sidx);
spkRadian  = phaseRad(sidx);
[p, z]     = circ_rtest(spkRadian);
mrlHilbert = circ_r(spkRadian)

% plots
[n, xout] = hist(spkPhase,[0:30:360]); 
figure('color','w')
subplot(221)
    circ_plot(spkRadian,'hist',[],18,false,true,'lineWidth',4,'color','r')
    title('hilbert')
subplot(222)
    bar(xout,n)
    xlim ([0 360])
    xlabel ('Phase')
    ylabel ('Spike Count') 
    title('hilbert')

% phase interp
[phase, InstFreq, cycleFreq] = phase_freq_detect(hpcFilt, lowpass, highpass, srate, 0);            
phaseRad = phase*(pi/180); 
sidx       = find(spikeTimes);
spkPhase   = phase(sidx);
spkRadian  = phaseRad(sidx);
spkPhase(isnan(spkPhase))=[];
spkRadian(isnan(spkRadian))=[];
[p, z]     = circ_rtest(spkRadian);
mrlInterp = circ_r(spkRadian)

[n, xout] = hist(spkPhase,[0:30:360]); 
subplot(223)
    circ_plot(spkRadian,'hist',[],18,false,true,'lineWidth',4,'color','r')
    title('phase interp')
subplot(224)
    bar(xout,n)
    xlim ([0 360])
    xlabel ('Phase')
    ylabel ('Spike Count') 
    title('phase interp')
    
%% typical analysis
% bootstrapped mrl
rng('default'); % for replication
permnum = 1000; % number of permutations
mrl_sub_hpc = []; mrl_sub_pfc = [];
for i = 1:permnum 
    % working with same units and same
    % distribution/pattern
    randIdx = randsample(1:numel(sidx),50);
    mrl_sub(i) = circ_r(spkRadian(randIdx));  
end

% entrainment statistics
bsMrl     = mean(mrl_sub);
mrl       = circ_r(spkRadian); 
[p, z]    = circ_rtest(spkRadian(randomData));
[n, xout] = hist(spkPhase,[0:30:360]); 

figure('color','w')
subplot(121)
    circ_plot(spkRadian,'hist',[],18,false,true,'lineWidth',4,'color','r')
subplot(122)
    bar(xout,n)
    xlim ([0 360])
    xlabel ('Phase')
    ylabel ('Spike Count')  
    
%% entrainment is impacted by spike counts

% Rayleighs test is sensitive to sample size
rng('default')
ptemp = []; ztemp = []; p = []; z = [];
looper = 20:10:1000; % go up to 1000 spikes
for i = 1:length(looper)
    % sample data at sample size (i) 1000 times (bootstrapped distribution)
    for n = 1:1000
        % randomly sample spike phases with increasing amounts of data
        randomData = randsample(spkRadian,looper(i));
        [ptemp(n), ztemp(n)]     = circ_rtest(randomData);
    end
    p(i) = mean(ptemp);
    z(i) = mean(ztemp);
    pstd(i) = std(ptemp);
    zstd(i) = std(ztemp);
    disp(['Finished with ',num2str(looper(i)),' spikes'])
end
    
% MRL
rng('default')
mrltemp = []; mrl = [];
looper = 20:10:1000; % go up to 1000 spikes
for i = 1:length(looper)
    % sample data at sample size (i) 1000 times (bootstrapped distribution)
    for n = 1:1000
        % randomly sample spike phases with increasing amounts of data
        mrltemp(n) = circ_r(randsample(spkRadian,looper(i)));
    end
    mrl(i)    = mean(mrltemp);
    mrlStd(i) = std(mrltemp);
    disp(['Finished with ',num2str(looper(i)),' spikes'])
end

figure('color','w')
    subplot 311;
        shadedErrorBar(looper,p,pstd,'k',0);
        box off
        ylabel('Mean Rayleighs p-value (n=1000 iterations)')
        %xlabel('HPC place cell spike count')
        %title('Rayleighs test of non-uniformity vs spike counts')
    subplot 312;
        shadedErrorBar(looper,z,zstd,'k',0);
        box off
        ylabel('Rayleighs Z (n=1000 iterations)')
        %xlabel('HPC place cell spike count')
    subplot 313;
        shadedErrorBar(looper,mrl,mrlStd,'k',0);
        box off
        ylabel('MRL (n=1000 iterations)')
        xlabel('HPC place cell spike count')
        
figure('color','w')
    subplot 311;
        plot(looper,p,'k');
        box off
        ylabel('Mean Rayleighs p-value (n=1000 iterations)')
        %xlabel('HPC place cell spike count')
        %title('Rayleighs test of non-uniformity vs spike counts')
    subplot 312;
        plot(looper,z,'k');
        box off
        ylabel('Rayleighs Z (n=1000 iterations)')
        %xlabel('HPC place cell spike count')
    subplot 313;
        plot(looper,mrl,'k');
        box off
        ylabel('MRL (n=1000 iterations)')
        xlabel('HPC place cell spike count')
        
figure('color','w');
subplot 311
    plot(looper,zstd,'k')
    ylabel('z standard deviation')
    xlabel('HPC place cell spike counts')
subplot 312;
    plot(looper,pstd,'k')
    ylabel('p standard deviation')
    xlabel('HPC place cell spike counts')
subplot 313;
    plot(looper,mrlStd,'k')
    ylabel('MRL standard deviation')
    xlabel('HPC place cell spike counts')
        
% compare a bootstrapped distribution of MRL estimates to randomly sampled
% LFP phase values
rng('default'); % for replication
permnum = 1000; % number of permutations
phaseRadRand = phaseRad(~isnan(phaseRad)); % get phase distribution without nan
mrl_sub = []; mrl_rand = [];
for i = 1:permnum 
    % get mrl from true data and simply from the LFP phase
    mrl_sub(i)  = circ_r(randsample(spkRadian,50));  
    mrl_rand(i) = circ_r(randsample(phaseRadRand,50));
end

% plot distributions
figure('color','w'); 
subplot 211; hold on;
    histogram(mrl_sub,'FaceColor','b')
    histogram(mrl_rand,'FaceColor','r')
    ylimits = ylim; xlimits = xlim;
    line([mean(mrl_sub) mean(mrl_sub)],[ylimits(1) ylimits(2)],'color','k','LineWidth',2);
    [h,p,ci,z] = ztest(mean(mrl_sub),mean(mrl_rand),std(mrl_rand));
    [h,p] = kstest2(mrl_sub,mrl_rand);
    legend('True spikes','Random Phases')
    ylabel('Interation (n=1000)')
    
    % plot cumulative distribution
subplot 212;
    data   = []; data{1}   = mrl_sub; data{2} = mrl_rand;
    colors = []; colors{1} = 'b';   colors{2} = 'r';
    cumulativeDensity(data,colors,'Bootstrapped MRL','HPC',[],[],'n')
    
%% combine entrainment filtering with phase based spike field coherence

% number of cycles for morlet wavelet (closer to 12 = better frequency
% resolution and worse temporal resolution - standard is 5-12 - Cohen)
nCycles = 6;

% calculate phase-based sfc on filtered spike times from entrainment
% analysis above
[sfc,freq] = getSpikeFieldCoherence(lfp,sidx,[],nCycles,srate,'phase');

% use original, but randomly sample equal number of spikes
sidx_rs = randsample(sidx_og,length(sidx));
[sfc_rs,freq] = getSpikeFieldCoherence(lfp,sidx_rs,[],nCycles,srate,'phase');

figure('color','w'); hold on;
    plot(freq,sfc,'k','LineWidth',2);
    plot(freq,sfc_rs,'b','LineWidth',2);
    legend('Filtered spikes','Raw spikes')
    