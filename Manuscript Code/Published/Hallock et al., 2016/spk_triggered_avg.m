function [spk_triggered_plot, spk_triggered_sem] = spk_triggered_avg(Samples, Timestamps, spk, srate, edges, plot)
%%

%   This function plots the spike-triggered LFP average between a spike-LFP
%   pair

%   Inputs:
%       Samples:        512 x n samples matrix of continuously sampled LFP
%                       data
%       Timestamps:     1 x n samples array of CSC timestamp values
%       spk:            n spikes x 1 array of spike timestamp values
%       srate:          Sampling rate (Hz)
%       edges:          ([lower upper]) - Lower and upper boundaries for
%                       triggered average plot (seconds). Lower boundary
%                       value must be negative, upper boundary value must
%                       be positive
%       plot:           0 if plot, 1 if no plot

%   Outputs:
%       spk_triggered_plot = Spike-triggered average LFP values
%       spk_triggered_sem =  Standard error of the mean for spike-triggered
%                            LFP values

%%

%Samples = Samples(:)';
%Timestamps = linspace(Timestamps(1,1),Timestamps(1,end),length(Samples));


%%

% Index spike timestamps with CSC timestamps
% If the spike timestamp occurs earlier than the lower edge boundary, or
% later than the upper edge boundary, populate its spike-triggered average
% array with NaN
for i = 1:length(spk)
    spk_ind = dsearchn(Timestamps',spk(i));
    if spk_ind > (srate*edges(1,2)) && spk_ind < (length(Samples)-(srate*edges(1,2)))
    spk_triggered(i,:) = Samples(1,spk_ind+(srate*edges(1,1)):spk_ind+(srate*edges(1,2)));
    else
    spk_triggered(i,1:(abs(srate*edges(1,1))+(srate*edges(1,2)))+1) = NaN;
    end
end

% Get rid of NaN rows created by spike timestamps that occurred too early
% or too late
spk_triggered(~any(~isnan(spk_triggered), 2),:) = [];

% Means and standard errors
spk_triggered_plot = mean(spk_triggered,1);
spk_triggered_std = std(spk_triggered,0,1);
spk_triggered_sem = spk_triggered_std/sqrt(size(spk_triggered,1));

times = linspace(edges(1,1),edges(1,2),size(spk_triggered_plot,2));

if plot == 0
varargout=shadedErrorBar(times,spk_triggered_plot,spk_triggered_sem,'b',1);
box off
set(gca,'TickDir','out')
xlabel('Time (Seconds)')
end





end

