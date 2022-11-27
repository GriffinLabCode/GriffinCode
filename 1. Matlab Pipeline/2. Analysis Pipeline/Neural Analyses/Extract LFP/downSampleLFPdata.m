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
    
	% butterworth filter (kind of rounds things too much for my liking)
	%dataOut = skaggs_filter_var(lfp_data, lowPass, highPass, srate);    
    
	% Adam said his guys use 32-tap Bartlett windowing FIR
	%lfp_ds = fir1(taps,highPass,bartlett())	
	%blo = fir1(34,0.48,chebwin(35,30));
	%outlo = filter(blo,1,y);
    %figure; subplot 211; plot(linspace(0,10,numel(lfp_data(1:srate*100))),lfp_data(1:srate*100)); axis tight;
    %subplot 212; plot(linspace(0,10,numel(lfp_ds(1:2035*100))),lfp_ds(1:2035*100)); axis tight;

	
    % get the downsampling rate divisor
    [divisor,srate] = find_downsample_rate(srate,target_rate);
    
    % downsample
    lfp_ds = downsample(lfp_data,divisor);
    times_ds = downsample(lfp_times,divisor);
    
    %{
    % loop over data N times. When you trim every other point, then
    % repeatedly do that, the relationship between the starting point and
    % ending point is logirithmic
    lfp_ds = []; times_ds = [];
    lfp_ds = lfp_data; times_ds = lfp_times;
    
    for i = 1:sqrt(divisor) % sqrt bc log relationship between cutting the data in half at progressively diff time scales and takes divisor times to get from og srate to new srate through linear division
        % forward and backward
        evenOdd = mod(i,2);
        if evenOdd == 1 % if odd loops
            lfp_ds   = lfp_ds(1:2:end);
            times_ds = times_ds(1:2:end);            
        elseif evenOdd == 0 % on odd loop i
            % flip variables 180degrees
            lfp_ds = flipud(lfp_ds')';
            times_ds = flipud(times_ds')';
            % remove 1:2:end (which is really end:-2:1 or something
            lfp_ds   = lfp_ds(1:2:end);
            times_ds = times_ds(1:2:end);   
            % flip back to normal
            lfp_ds = flipud(lfp_ds')';
            times_ds = flipud(times_ds')';
        end
    end
    %}
    % check it! Get in some data sampled at ~32kh. then extract 120s of
    % data. Run the code below
    %lfp_danumel(lfp_ds)/numel(lfp_ds(1:16:end))
    % lfp_data has 120s
    % my final dataset should be 2000*120
    % 2035*120 = 240k points
    
    % yet it only takes 4 loops, cutting out every other data point, to
    % downsample from 32kh to 2hz?
    
    %{
    % you do not want to downsample your data like this. Downsample 1:2:end
    N number of times. Below skews the output so that the relationship
    between downsampled and true signal is wrong progressively worse as
    time goes on
    
    % downsample data	
    lfp_ds = []; times_ds = [];
    lfp_ds   = dataOut(1:divisor:end);
    times_ds = lfp_times(1:divisor:end);
    new_srate = target_rate;
    %lfp_ds = round(lfp_ds,100); disp('Rounding signal');
    %}
else
    disp('Sampling rate matches the target rate, therefore data was not down-sampled')
end

end