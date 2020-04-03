function [LFP_triggered_plot, LFP_triggered_sem] = LFP_triggered_avg(trigger_samples, triggered_samples, lowpass, highpass, srate, edges, phase, plot)
%%

%   This function calculates trough or peak-triggered LFP averages.
%   LFP-triggered averages can be calculated either within one LFP, or
%   between two simultaneously recorded LFPs

%   Inputs:
%       trigger_samples:            1 x n samples array of continuously
%                                   sampled LFP data. These data will be used to identify troughs or
%                                   peaks (a.k.a., these data are the
%                                   "trigger")
%       triggered_samples:          1 x n samples array of continuously
%                                   sampled LFP data. These data will be averaged according to peaks or
%                                   troughs in trigger_samples (a.k.a., these data are what is being
%                                   "triggered")
%       lowpass:                    Frequency lowpass for trigger
%                                   oscillation (Hz)
%       highpass:                   Frequency highpass for trigger
%                                   oscillation (Hz)
%       srate:                      Sampling rate (Hz)
%       edges:                      ([lower upper]) - Lower and upper boundaries for
%                                   triggered average plot (seconds). Lower boundary
%                                   value must be negative, upper boundary value must
%                                   be positive
%       phase:                      Either a 0 or 1
%                                   If 0: Calculates peak-triggered
%                                   averages
%                                   If 1: Calculates trough-triggered
%                                   averages
%       plot:                       0 if plot, 1 if no plot

%   Outputs:
%       LFP_triggered_plot:         LFP-triggered average LFP values
%       LFP_triggered_sem =         Standard error of the mean for LFP-triggered
%                                   LFP values

%%

% Filter LFP samples to be used for trigger events
filtered_samples = skaggs_filter_var(trigger_samples, lowpass, highpass, srate);

MPD = 1/highpass*srate;

% Grab filtered peaks or troughs
if phase == 0
    [~, peaks] = findpeaks(filtered_samples, 'MINPEAKDISTANCE', round(MPD));
elseif phase == 1
    [~, troughs] = findpeaks(filtered_samples.*-1, 'MINPEAKDISTANCE', round(MPD));
end

% Grab LFP surrounding peaks or troughs according to defined edges
% If peak or trough occurs sooner than lower edge boundary or later than
% upper edge boundary, return NaN
if phase == 0
    for i = 1:length(peaks)
        if peaks(i) > (srate*edges(1,2)) && peaks(i) < (length(triggered_samples)-(srate*edges(1,2)))
            triggered_avg(i,:) = triggered_samples(1,peaks(i)+(srate*edges(1,1)):peaks(i)+(srate*edges(1,2)));
        else
            triggered_avg(i,1:(abs(srate*edges(1,1))+(srate*edges(1,2)))+1) = NaN;
        end
    end
end

if phase == 1
    for i = 1:length(troughs)
        if troughs(i) > (srate*edges(1,2)) && troughs(i) < (length(triggered_samples)-(srate*edges(1,2)))
            triggered_avg(i,:) = triggered_samples(1,troughs(i)+(srate*edges(1,1)):troughs(i)+(srate*edges(1,2)));
        else
            triggered_avg(i,1:(abs(srate*edges(1,1))+(srate*edges(1,2)))+1) = NaN;
        end
    end
end

% Clear NaN from matrix
triggered_avg(~any(~isnan(triggered_avg), 2),:) = [];

% Create triggered-averages
LFP_triggered_plot = mean(triggered_avg,1);
LFP_triggered_std = std(triggered_avg,0,1);
LFP_triggered_sem = LFP_triggered_std/sqrt(size(triggered_avg,1));

times = linspace(edges(1,1),edges(1,2),size(LFP_triggered_plot,2));

% Plot LFP-triggered average and standard error
if plot == 0
varargout=shadedErrorBar(times,LFP_triggered_plot,LFP_triggered_sem,'b',1);
box off
set(gca,'TickDir','out')
xlabel('Time (Seconds)')
end


end

