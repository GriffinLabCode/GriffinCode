function [coherence, freq] = spikefieldcoherence(lfp_data, lfp_times, params, spk, edges, spc_fig)
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
[lfp_ds, times_ds] = downSampleLFPdata(lfp_data,lfp_times,params.Fs,target_rate,lowPass,highPass);

% redefine sampling rate
srate = target_rate;

% spike triggered average
[spk_triggered_plot,spk_triggered_sem,spk_triggered] = spk_triggered_avg(lfp_ds, times_ds, spk, srate, edges, 1);

% get power spectrum of spike triggered avg (300ms of lfp) 
params.Fs = srate;
%params.tapers = [3 5];
[S_stp,f_stp,Serr_stp]=mtspectrumc(spk_triggered_plot,params);

% get avg power spectrum of all lfp signal traces used for triggered avg
% trial avg
params.trialave = 1;
%params.err = [2 0.05]
[S_tap,f_tap,Serr_tap]=mtspectrumc(spk_triggered',params);

% spk field
coherence = S_stp./S_tap;
freq = f_tap;

if spc_fig == 0 
    figure('color','w'); 
    subplot 411;
        times = linspace(edges(1,1),edges(1,2),size(spk_triggered_plot,2));
        varargout=shadedErrorBar(times,spk_triggered_plot,spk_triggered_sem,'b',1);
        box off
        set(gca,'TickDir','out')
        xlabel('Time (Seconds)') 
        title('Spike triggered average')
    subplot 412;
        plot(f_stp,S_stp,'b','LineWidth',2)
        title('power of spk-triggered-avg')
        box off
    subplot 413
        plot(f_tap,S_tap,'b','LineWidth',2)
        title('power of spk-triggered-avg')
        box off
        title('Average power of all spike triggered LFP')    
    subplot 414;
        plot(freq,coherence,'r','LineWidth',2);
        title('Spike Field Coherence')
        box off
else 
end