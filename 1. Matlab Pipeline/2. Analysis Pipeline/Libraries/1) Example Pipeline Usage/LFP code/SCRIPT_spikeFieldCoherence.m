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

%tic;
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
[sfc,freq] = getSpikeFieldCoherence(lfp,sidx,[],12,srate);
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

%% compare to entrainment
lowpass = 4; highpass = 12;

% filter the signal with 3rd degree butterworth
jonesWilson = 1;
if jonesWilson == 1
    disp('You are now going to exclude phase estimations on non-theta states')
else
end

hpcFilt = skaggs_filter_var(double(lfp)',lowpass,highpass,srate);
[phase, InstFreq, cycleFreq] = phase_freq_detect(hpcFilt, lowpass, highpass, srate, 1);            
phaseRad = phase*(pi/180); 

% get the signals phase
%phaseRad = angle(hilbert(hpcFilt));
%phase    = rad2deg(phaseRad).*2;
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
sidx(isnan(spkPhase))=[];
spkPhase(isnan(spkPhase))=[];
spkRadian(isnan(spkRadian))=[];

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
[p, z]    = circ_rtest(spkRadian);
[n, xout] = hist(spkPhase,[0:30:360]); 

figure('color','w')
subplot(121)
    circ_plot(spkRadian,'hist',[],18,false,true,'lineWidth',4,'color','r')
subplot(122)
    bar(xout,n)
    xlim ([0 360])
    xlabel ('Phase')
    ylabel ('Spike Count')  
    
%% combine entrainment filtering with spike field coherence

% number of cycles for morlet wavelet (closer to 12 = better frequency
% resolution and worse temporal resolution - standard is 5-12 - Cohen)
nCycles = 6;

% calculate phase-based sfc on filtered spike times from entrainment
% analysis above
[sfc,freq] = getSpikeFieldCoherence(lfp,sidx,[],nCycles,srate);

% use original, but randomly sample equal number of spikes
sidx_rs = randsample(sidx_og,length(sidx));
[sfc_rs,freq] = getSpikeFieldCoherence(lfp,sidx_rs,[],nCycles,srate);

figure('color','w'); hold on;
    plot(freq,sfc,'k','LineWidth',2);
    plot(freq,sfc_rs,'b','LineWidth',2);
    legend('Filtered spikes','Raw spikes')
    

