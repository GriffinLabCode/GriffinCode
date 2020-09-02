function [mrl pval z mrl_subsampled] = entrainment(Int, Timestamps, phase_EEG, spk, phase_bandpass, srate, plot)

%   This function calculates the spike-phase distribution between a single
%   unit and simultaneously recorded oscillations (within a defined
%   frequency band) during start-box occupancy. 

% Inputs:
%   Int:                    n trials x 8 matrix of maze timestamp values
%   Timestamps:             1 x n samples array of timestamp values for 
%                           continuously sampled data
%   phase_EEG:              512 x n samples matrix of continuously sampled
%                           data for phase estimation
%   spk:                    n x 1 array of spike timestamps
%   phase_bandpass:         [fmin fmax]
%   srate:                  Sampling rate (Hz)
%   plot:                   0 if plot, 1 if no plot

% Outputs:
%   mrl:                    Length of mean resultant vector (ranges from 0 to 1)
%   pval:                   Rayleigh's p-value (based on Rayleigh's z-statistic)
%   z:                      Rayleigh's z-statistic (relative to uniform
%                           spike-phase distribution)
%   mrl_subsampled:         Length of mean resultant vector calculated from a bootstrapped
%                           sampling distribution of n = 50 spike-phase pairs (partially controls
%                           for differences in spike count between single units)


%%

phase_EEG = phase_EEG(:)';
Timestamps = linspace(Timestamps(1,1),Timestamps(1,end),length(phase_EEG));

numtrials = size(Int,1);

% Get all CSC data from start-box occupancy periods into one cell array
phase_EEG_temp = cell(1,numtrials-1);
for i = 2:numtrials
    phase_EEG_temp{i-1} = phase_EEG(Timestamps>Int(i-1,8) & Timestamps<Int(i,1));
    phase_EEG_temp{i-1} = phase_EEG_temp{i-1}';
end

% Concatenate CSC data into one array
phase_EEG_new = vertcat(phase_EEG_temp{:});

% Same as above for CSC timestamp values
signal_ts = cell(1,numtrials-1);
for i = 2:numtrials 
    signal_ts{i-1} = find(Timestamps>Int(i-1,8) & Timestamps<Int(i,1));
    signal_ts{i-1} = signal_ts{i-1}';
end

signal_ts_new = vertcat(signal_ts{:});

phase_EEG_new = phase_EEG_new';
signal_ts_new = signal_ts_new';
signal_ts_new = Timestamps(signal_ts_new);

% Filter phase signal
[signal_filtered] = skaggs_filter_var(phase_EEG_new,...
    phase_bandpass(:,1),phase_bandpass(:,2),srate);

% Extract phase information from filtered signal
[Phase, InstCycleFrequency, PerCycleFreq, signal_filtered] = ...
    phase_freq_detect(signal_filtered, signal_ts, phase_bandpass(:,1), phase_bandpass(:,2), srate); 
PhaseRadians = Phase*(pi/180); 

% Get all spikes that occur during start-box occupancy
spk = spk';
for i = 2:numtrials; 
    s{i-1} = find(spk>Int(i-1,8) & spk<Int(i,1));
    s{i-1} = s{i-1}';
end 

%spk_new = cat(2,s{:}); 
spk_new = vertcat(s{:});
spk_new = spk(spk_new);

% Assign a phase value to each spike
for j = 1:length(spk_new)
    spk_ind = dsearchn(signal_ts_new',spk_new(j)');
    spk_phase_radians(j,:) = PhaseRadians(spk_ind,:);
    spk_phase_degrees(j,:) = Phase(spk_ind,:);
end

% Get rid of spikes that could not be assigned a phase value due to low
% amplitude oscillations
spk_phase_radians(isnan(spk_phase_radians)) = [];
spk_phase_degrees(isnan(spk_phase_degrees)) = [];

% Create sub-sampled MRL value from bootstrapped spike-phase distribution
permnum = 1000;
for i = 1:permnum  
    random_spikes = randsample(spk_phase_radians,50);
    mrl_sub(i) = circ_r(random_spikes);
end

% Calculate MRL, Rayleigh's z-statistic, and p-value based on null
% hypothesis of uniform spike-phase distribution
mrl_subsampled = mean(mrl_sub,2);
mrl = circ_r(spk_phase_radians); 
[pval, z] = circ_rtest(spk_phase_radians); 
[n xout] = hist(spk_phase_degrees,[0:30:360]); 

% Create Rayleigh's plot and spike-phase histogram
if plot == 0
subplot(121)
circ_plot(spk_phase_radians,'hist',[],18,false,true,'lineWidth',4,'color','r');
subplot(122)
bar(xout,n)
xlim ([0 360])
xlabel ('Phase')
ylabel ('Spike Count')
end

end

