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
% spikeLFPidx: an index, pointing to LFP values (lfp variable) that
%               correspond to spike timestamps. Run getSpkLFPidx
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
% This code was adopted from MxC: MATLAB for brain and cognitive
% scientists by John Stout and confirmed for accuracy with their data.

function [sfc,freq] = getSpikeFieldCoherence(lfp,spikeLFPidx,freq,nCycle,srate)
% convert data to single
lfp = single(lfp);

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



