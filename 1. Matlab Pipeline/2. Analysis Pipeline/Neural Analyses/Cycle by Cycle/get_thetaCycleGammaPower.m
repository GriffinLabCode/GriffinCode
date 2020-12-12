%% LG:HG ratio
% index of high gamma to low gamma. values above .5 indicate that high
% gamma is higher than low gamma

% -- OUTPUTS -- %
% hgXsg_idx: each element indicates a high:low gamma index per theta cycle

function [hgXsg_idx,slowGamma,fastGamma] = get_thetaCycleGammaPower(lfp,timesLFP,lfp_srate)

% get peaks and troughs of theta
[~, ~, peak, trough] = get_thetaPhase(lfp,timesLFP,lfp_srate);

% get cycle times
[cycleTimes,cycleLFP] = get_thetaCycleTimes(timesLFP,lfp,peak,trough);

% within each cycle, get fast gamma and slow gamma
slowGammaFreq = [30 55]; % input
fastGammaFreq = [60 90]; % input

% get fast and slow gamma per each theta cycle
instPow_sg = []; instPow_hg = [];
for cyclei = 1:length(cycleLFP)
    
    % get slow gamma power
    sg_filt = [];
    sg_filt = skaggs_filter_var(cycleLFP{cyclei}, slowGammaFreq(1), slowGammaFreq(2), lfp_srate);
    instPow_sg{cyclei} = abs(hilbert(sg_filt));
    
    % get fast gamma power
    hg_filt = [];
    hg_filt = skaggs_filter_var(cycleLFP{cyclei}, fastGammaFreq(1), fastGammaFreq(2), lfp_srate);
    instPow_hg{cyclei} = abs(hilbert(hg_filt));  
    
    % ratio of high gamma to low gamma
    hgXsg_idx(cyclei) = mean(instPow_hg{cyclei})/(mean(instPow_sg{cyclei}) + mean(instPow_hg{cyclei}));
    
end

% get high and low gamma power at the peak and troughs of theta
instPow_sg = []; sg_filt = [];
sg_filt = skaggs_filter_var(lfp, slowGammaFreq(1), slowGammaFreq(2), lfp_srate);
instPow_sg = abs(hilbert(sg_filt)); 

instPow_hg = []; hg_filt = [];
hg_filt = skaggs_filter_var(lfp, fastGammaFreq(1), fastGammaFreq(2), lfp_srate);
instPow_hg = abs(hilbert(hg_filt)); 

% high gamma peaks
slowGamma.thetaPeak   = instPow_sg(peak);
slowGamma.thetaTrough = instPow_sg(trough);
fastGamma.thetaPeak   = instPow_hg(peak);
fastGamma.thetaTrough = instPow_hg(trough);
