%% get filtered signal
datafolder = 'X:\01.Experiments\RERh Inactivation Recording\14-22\Baseline\Baseline 2';
cd(datafolder)
load('HPC')

% convert data
Timestamps_unc = Timestamps; Timestamps = [];
[Timestamps, lfp_hpc] = interp_TS_to_CSC_length_non_linspaced(Timestamps_unc, Samples);     

% calculate and define the sampling rate
totalTime  = (Timestamps_unc(2)-Timestamps_unc(1))/1e6; % this is the time between valid samples
numValSam  = size(Samples,1);     % this is the number of valid samples (512)
srate      = round(numValSam/totalTime); % this is the sampling rate

% get example epoch
LFP = lfp_hpc(1:2000);
timesLFP = Timestamps(1:2000);
figure(); plot(timesLFP,LFP)

% filter 4-12 hz
phase_bandpass = [4 12];
[signal_filtered] = skaggs_filter_var(LFP,phase_bandpass(:,1),phase_bandpass(:,2),srate);

% phase freq detect - get phase
[Phase, InstCycleFrequency, PerCycleFreq, signal_filtered] = phase_freq_detect(signal_filtered, timesLFP, 4, 12, srate);

% using phase, use dsearchn to find closest values to 0, to 180 (peak), and
% to 360 (trough)
trough = find(Phase == 0);
peak   = find(Phase == 180);

% subtract trough and peak two different ways. This will give us the length
% of values between trough and peak and peak and trough. This is because
% the values in the variables above are indices. Define the ascending and
% descending variables, which are going to the be the lengths of
% ascneding and descending.


% calculate asymmetry index log((ascending)) -
% log((descending))


