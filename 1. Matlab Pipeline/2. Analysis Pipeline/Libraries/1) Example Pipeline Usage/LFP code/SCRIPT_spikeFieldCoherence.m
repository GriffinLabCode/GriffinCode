%% tester
%
% this code is a proof of concept for my (JS) use of spike field coherence.
% I used this as it has a known input and known output. I generated the
% figure 23.7 in mike cohens matlab for brain and cognitive scientists
% book. I then used this code on griffin lab data to perform spike field
% coherence.
%
% last edit was on 6-10-2022 by John Stout

clear; clc;
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


