%% SCRIPT
% This practice script shows how a user might take their spike timestamps
% data obtained after cluster cutting analysis and estimate spike-LFP
% estimates, like spike-field coherence or entrainment
%
% JS - 6/7/2023

% here is an example dataset with LFP and spike timestamps as you would
% collect from the neuralynx system
load('dataSpikeTimesLFP');

% lfp = lfp data, lfpTimes = timestamps for each lfp datapoint.
% spikeTimes = timestamps for each spike from a representative PFC unit

% you want to find lfp timestamps that align with each spike. This function
% spits out a boolean spike train that is of same size and shape as your
% LFP data. It also provides the spike LFP index (index of LFP data
% corresponding to each spike timestamp) and spikeLFPval=spikeLFP values
[spikeLFPbool,spikeLFPidx,spikeLFPval] = ...
    getSpikeLFPidx(lfpTimes,spikeTimes);

% now you can do spike-LFP analysis - here is spike-field coherence
nCycles = 6;
[sfcP,freqP] = getSpikeFieldCoherence(lfp,spikeLFPbool,freq,nCycles,srate,'phase');

figure('color','w');
    plot(freqP,sfcP);
    title('Cohen sfc')
    xlabel('Frequency')
    ylabel('Spike Field Coherence')
    box off

% entrainment
spikeIdx = find(spikeLFPbool); % could also just use spikeLFPidx
lowpass = 4; highpass = 12;
[spkPhase,spkRadian,rayleighsP,rayleighsZ,bsMrl,n,xout] = ...
    unitEntrainment(spikeIdx,lfp,lowpass,highpass,srate,'hilbert','n','n');

figure('color','w')
subplot(121)
    circ_plot(spkRadian,'hist',[],18,false,true,'lineWidth',4,'color','r')
subplot(122)
    bar(xout,n)
    xlim ([0 360])
    xlabel ('Phase')
    ylabel ('Spike Count')  
