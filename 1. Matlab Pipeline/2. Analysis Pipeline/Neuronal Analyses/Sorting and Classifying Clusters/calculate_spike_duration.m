%% calculate_spike_duration
% this function calculates spike duration (aka spike width) for a given
% cell. 
%
% INPUTS: Samples: 32(sample rate)x4(wires)xN(spikes) dataset extracted 
%                   using Nlx2MatSpike function. 
%         Header: a 49x1 cell array containing various information about
%                  the recorded spike data including the adbit conversion
%
% OUTPUTS: spike_duration in milliseconds
%
% written by John Stout

function [spike_duration] = calculate_spike_duration(Samples,Header)
%% Calculate spike width

% extract unique ADbitVolt value and multiply by Samples
ad_bit_string = cell2mat(Header(16));
ad_bit = strsplit(ad_bit_string);
ad_bit = ad_bit(end);
ad_bit = cell2mat(ad_bit);
ad_bit = str2num(ad_bit);

% Average all data points for each wire, pick highest peak, convert to V
spike_avg = (mean(Samples,3))*ad_bit;

% find max peak
max_spike_avg = max(spike_avg);
max_peak      = max(max_spike_avg);
% this tells you which wire picked up on the highest voltage spike
max_peak_ind  = find(max_peak == max_spike_avg);

% generate rough approximation of time values based on sampling rate (32)
x = linspace(0,1,32);

% extract wire with highest voltage
y = spike_avg(:,max_peak_ind);

% find peak and trough
peak   = max(y);
trough = min(y);

% find their corresponding times
peak_ind    = find(y == peak);
peak_time   = x(peak_ind);

trough_ind  = find(y == trough);
trough_time = x(trough_ind);

% Calculate spike width (accounting for the fact that sometimes spikes are
% inverted)
if trough_time > peak_time  
    spike_duration = trough_time - peak_time;
elseif peak_time > trough_time
    spike_duration = peak_time - trough_time;
end

end