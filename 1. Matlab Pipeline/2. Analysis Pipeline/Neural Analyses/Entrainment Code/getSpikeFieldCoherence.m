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
% -- OPTIONAL -- %
% indVar: set to 'phase' for cohen 2019 method. Set to 'sta' for Ito et
%       al., 2019 method. Do not define or set as anything else for welchs.
%       -> highly recommend 'phase' or 'sta'. sta takes longer
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

function [sfc,freq] = getSpikeFieldCoherence(lfp,spikeTimes,freq,nCycle,srate,indVar)
if exist('indVar')==0
    indVar = 'phase'; % default
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
elseif contains(indVar,'sta')
    disp('Computing sfc as defined by the ratio of spike triggered average to spike triggered power - Ito et al., 2019')

    % for every spike, 480ms of LFP was centered on the spike
    % spike-triggered average calculated = mean of all these centered
    % frequency spectrum calculated over STA via multitaper method
    % % calculate frequency spectrum of each lfp trace individually
    % % average over the power to get spike triggered power
    % SFC = fSTA(f)/STP(f) * 100
    % this method was used by ito and described by wang et al., 2015;
    % theta-frequency phase-locking of single anterior...
    
    % convert data to double type
    lfp = double(lfp);
    spikeTimes = double(spikeTimes);
    
    % get index of spike times
    sidx = find(spikeTimes);
    
    % predefined time around spike
    timeAround = 0.25; % 250ms

    % get lfp around data
    disp('Calculating spike triggered average');
    remData = [];
    lfpAround = zeros([size(sidx,2) (round(srate*timeAround)*2)+1]); 
    for i = 1:length(sidx)
        try % try bc our time around may conflict with amount of data acquired for the first spike
            % get spikes around lfp
            lfpAround(i,:) = lfp(sidx(i)-(round(srate*timeAround)):sidx(i)+(round(srate*timeAround)));
        catch
            remData(i)=1;
        end
    end
    if ~isempty(remData)
        lfpAround(logical(remData),:)=[];
    end

    % sta
    params = getCustomParams; params.Fs = srate;
    params.tapers = [2 3]; params.fpass = [0 20];
    sta = mean(lfpAround,1);
    [staf,freq] = mtspectrumc(sta',params);

    % stp, cannot use params.trialave=1 without breaking matlab
    params.trialave = 0; 
    for i = 1:size(lfpAround,1)
        [stp(i,:),freq] = mtspectrumc(lfpAround(i,:),params);
    end
    stpf = mean(stp,1);
    
    % make sure data are oriented appropriately
    staf = change_row_to_column(staf);
    stpf = change_row_to_column(stpf);

    % sfc
    sfc = (staf./stpf).*100;    
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



