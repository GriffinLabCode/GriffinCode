%% downSampleLFPdata
%
% This function first filters the data using an fir filter, then
% downsamples the data. This avoids aliases.
%
% -- INPUTS -- %
% lfp_data: vector of lfp data sampled at the current rate
% lfp_times: vector of lfp timestamps sampled at the current rate
% srate: current sampling rate
% target_rate: target sampling rate (ie try 125hz)
% lowpass: set to 1
% highPass: set to n/4 where n is the new sampling rate. So if you want
%               2000hz, cut bw 1:500
%
% -- OUTPUTS -- %
% lfp_ds: downsampled vector of lfp data
% times_ds: downsampled vector of times
%
% written by John Stout

function [lfp_ds, times_ds, srate] = downSampleLFPdata(lfp_data,lfp_times,srate,target_rate,lowPass,highPass)

if isempty(lowPass)
    lowPass = 1;
end
if isempty(highPass)
    highPass = target_rate/4;
end

if srate ~= target_rate
    disp('Sampling rate does not match the target rate, therefore data will be down-sampled...')
    
    disp(['Bandpass filter bw ',num2str(lowPass), ' & ' ,num2str(highPass) , 'Hz'])
    
	% arbitrary response filter
    % FIR filter  
    taps     = 32; % subtract 1 from the actual signal		
    bpFilt = designfilt('bandpassfir','FilterOrder',taps-1, ...
             'CutoffFrequency1',lowPass,'CutoffFrequency2',highPass, ...
             'SampleRate',srate);
    dataOut = filter(bpFilt,lfp_data);
	
    % get the downsampling rate divisor
    [divisor,srate] = find_downsample_rate(srate,target_rate);
    
    % downsample
    lfp_ds = downsample(lfp_data,divisor);
    times_ds = downsample(lfp_times,divisor);

else
    disp('Sampling rate matches the target rate, therefore data was not down-sampled')
end

end