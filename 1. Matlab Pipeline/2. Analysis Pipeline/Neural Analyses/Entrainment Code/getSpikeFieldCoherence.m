%% spike field coherence function
%
% % the output is an alternative to entrainment. Can be interpreted as the
% strength of phase locking at each frequency. It does not have quite the
% precision of the entrainment code which can tell you exact theta phase.
% But has precision in the frequency domain which would take forever to do
% with the entrainment code.
%
% -- INPUTS -- %
% lfp: vector of LFP used for spike indexing
% spikeTimes: boolean vector of spike times that is of the same size and
%               shape as your LFP vector
% freq: range of frequencies
% nCycle: number of cycles for morlet wavelet convolution. Should be
%           between 4 and 12. Higher values = greater frequency precision
%           at the expense of temporal precision. Default = 6.
% srate: sampling rate for your data
%
% -- OUTPUTS -- %
% sfc: spike field coherence across the range of frequencies provided
% freq: frequencies output
%
% WALKTHROUGH GUIDE***
% Please see "SCRIPT_spikeFieldCoherence" found here:
% \Libraries\1) Example Pipeline Usage\LFP code
%
% This code was adopted from MxC: MATLAB for brain and cognitive
% scientists by John Stout and confirmed for accuracy with their data.
%
% try this for welches method - smooth the output for a similar result to
% Mike Cohens method:
%
% freq = [1:.5:20];
% [sfc,freq] = getSpikeFieldCoherence(lfp,spikeTimes,freq,[],srate);
% figure; plot(freq,sfc);
%
% or this for mike cohen method:
%
% nCycles = 6;
% [sfcP,freqP] = getSpikeFieldCoherence(lfp,spikeTimes,freq,nCycles,srate,'phase');
%
% Written by John Stout (Mike Cohen method was adapted but from Cohen, 2014)

function [sfc,freq,phi] = getSpikeFieldCoherence(lfp,spikeTimes,freq,nCycle,srate,indVar)
if exist('indVar')==0
    indVar = 'n';
end
if contains(indVar,'phase')
    disp('Computing phase based spike field coherence as described by Cohen 2019')
    % convert data to single
    lfp = single(lfp);
    spikeLFPidx = find(spikeTimes);

    if exist('freq')==0 
        disp('Did not detect frequency input, default to log space')
        freq = logspace(0,2); % 10^0 to 10^2: 1:100
    elseif isempty(freq)==1
        disp('Did not detect frequency input, default to log space')
        freq = logspace(0,2); % 10^0 to 10^2: 1:100
    end

    if exist('nCycle')==0 
        disp('Did not detect # cycles input, default to 6')
        nCycle = 6; 
    elseif isempty(nCycle)==1
        disp('Did not detect # cycles input, default to 6')
        nCycle = 6;
    end

    for wavei = 1:length(freq)
        % get the analytic signal for morlet wavelet convolution
        as = getMorletWaveletConv(lfp,freq(wavei),nCycle,srate);
        % get the phase angle of each spike
        angles = angle(as(spikeLFPidx)); 
        % spike field coherence is the length of the averaged vector
        sfc(wavei) = abs(mean(exp(1i*angles)));
    end
    %{
    figure('color','w')
    plot(freq,sfc);
    %}
else
    % spike field coherence
    disp('Computing spike field coherence')

    % coherence is the CPSD/S1.*S2
    [pxy] = cpsd(lfp,spikeTimes,[],[],freq,srate);
    [pxx] = pwelch(lfp,[],[],freq,srate);
    [pyy,freq] = pwelch(spikeTimes,[],[],freq,srate);
    %sfc = ((abs(pxy)).^2)./(pxx.*pyy); % same result
    cyx=pxy./sqrt(pxx.*pyy);
    sfc=abs(cyx);
    phi=angle(cyx);
end



