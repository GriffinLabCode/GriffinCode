function [coherence, freq] = spikefieldcoherence(lfp_data, lfp_times, srate, spk, edges, params, spkAvg_fig, spc_fig)
%% Spike Field Coherence
%  Description:
%       This is a function to quantify spike field coherence;
%           [The ratio of the power spectrum of spike-triggered lfp avg 
%           and the avg power spectrum of the lfp traces that
%           were used to construct the spike triggered lfp avg.]
%
%       This can be utilized as a means of temporally comparing 
%       spiking activity based on coherency to diff. frequencies in LFP...
%           [i.e. are mPFC cells more coherent to spiking during theta in the stem or choice point?]
%
%   The function yields a vector of values(* 100) = %'s indicating to what extent a spike 
%   is coherent to a frequency
%
% - Suhaas Adiraju
%
% - Modified by JS 9-1-21
%
% - Last edit - changing to MATLAB spectral analysis functions. they look
% better, have less ambiguity/abitrations, and seem to reflect what I see
% in the data -> 9/7/21 10pm

%% Inputs and Outputs
% Inputs: 
%   (1) - Samples: Vectorized LFP
%   (2) - Timestamps: Vectorized and converted timestamps
%   (3) - srate: sample rate, depending on data set and recording session
%                (found in datafolder)
%   (4) - spk: set of spikes to perform analysis on (sourced from TT-file) 
%   (5) - edges: ([lower upper]) - Lower and upper boundaries for
%                 triggered average plot (seconds). Lower boundary
%                 value must be negative, upper boundary value must
%                 be positive 
%   (6) - def_params: 0 if default, 1 if customizing
%   (7) - spkAvg_fig: 1 = 300ms spike trig. lfp, 0 if plot, 1 if no plot
%   (8) - spc_fig: 1 = coherence x freq plot, 0 if plot, 1 if no plot
%
% Outputs:
%   (1) - coherence: the coherence values in vector format
%   (2) - freq: the corresponding frequencies by which coherencies will
%   be juxtaposed
%%

% filter (1) and downsample data(:4) to 500hz to improve speed
lowPass  = 1;
highPass = 500/4; % 4:1 ratio
target_rate = 500;
[lfp_ds, times_ds] = downSampleLFPdata(lfp_data,lfp_times,srate,target_rate,lowPass,highPass);

% redefine sampling rate
srate = target_rate;

% spike triggered average
[spk_triggered_plot,spk_triggered_sem,spk_triggered] = spk_triggered_avg(lfp_ds, times_ds, spk, srate, edges, spkAvg_fig);

% get power spectrum of spike triggered avg (300ms of lfp) 
params.Fs = srate;
%params.pad = 2;
%[S_stp,f_stp,Serr_stp]=mtspectrumc(spk_triggered_plot,params);
[S_stp,f_stp] = pspectrum(spk_triggered_plot,srate,'FrequencyLimits',params.fpass);

% get avg power spectrum of all lfp signal traces used for triggered avg
% trial avg
params.trialave = 1;
%[S_tap,f_tap,Serr_tap]=mtspectrumc(spk_triggered',params);
[S_all,f_tap] = pspectrum(spk_triggered',srate,'FrequencyLimits',params.fpass);
S_tap = nanmean(S_all,2); % average of the power spectra across spikes
%figure; plot(f_stp,S_tap);

% spk field
coherence = S_stp./S_tap;
freq = f_tap;

if spc_fig == 0 
    figure; plot(freq,coherence);
else 
end