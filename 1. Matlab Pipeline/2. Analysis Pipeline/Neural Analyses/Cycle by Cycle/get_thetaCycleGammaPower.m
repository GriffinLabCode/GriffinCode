%% LG:HG ratio

clear;
load('data_HPC_lfpTimes_tjunction_reformatted')
lfp = hpcReformat{1}{1};
timesLFP = timeReformat{1}{1};
lfp_srate = 2034;

% get peaks and troughs of theta
[~, ~, peak, trough] = get_thetaPhase(lfp,timesLFP,lfp_srate);

% get cycle times
[cycleTimes,cycleLFP] = get_thetaCycleTimes(timesLFP,lfp,peak,trough);

% within each cycle, get fast gamma and slow gamma
fastGammaFreq = [60 90]; % input
slowGammaFreq = [30 55]; % input

for cyclei = 1:length(cycleLFP)
    signal_filtered = [];
    signal_filtered = skaggs_filter_var(cycleLFP{cyclei}, slowGammaFreq(1), slowGammaFreq(2), lfp_srate);
    instPow_sg = abs(hilbert(signal_filtered));
end



