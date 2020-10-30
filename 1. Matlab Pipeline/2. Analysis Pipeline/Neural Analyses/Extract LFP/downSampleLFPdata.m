%% downSampleLFPdata
%
% this function downsamples lfp vector. This could be useful for
% downsampling your converted lfp vector to a lower frequency. For example,
% if you want to estimate theta entrainment, it could be useful to
% downsample from 2000hz to 125hz. This would accomplish that task
%
% -- INPUTS -- %
% lfp_data: vector of lfp data sampled at the current rate
% lfp_times: vector of lfp timestamps sampled at the current rate
% srate: current sampling rate
% target_rate: target sampling rate (ie try 125hz)
%
% -- OUTPUTS -- %
% lfp_ds: downsampled vector of lfp data
% times_ds: downsampled vector of times
%
% written by John Stout

function [lfp_ds, times_ds] = downSampleLFPdata(lfp_data,lfp_times,srate,target_rate)

if srate ~= target_rate
    disp('Sampling rate does not match the target rate, therefore data will be down-sampled...')
    % get the downsampling rate divisor
    %target_rate = 2000;
    [divisor] = find_downsample_rate(srate,target_rate);

    % downsample data
    lfp_ds = []; times_ds = [];
    lfp_ds   = lfp_data(1:divisor:end);
    times_ds = lfp_times(1:divisor:end);
    
else
    disp('Sampling rate matches the target rate, therefore data was not down-sampled')
end

end