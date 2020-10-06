%% preSWRfun - designed to prepare for swr code
%
% this code filters (using 3rd degree butterworth filter) for the
% phase_bandpass of interest, then using the hilbert transform, the
% instantaneous power of the filtered data is obtained. Next, a gaussian is
% convolved with the filtered data to smooth it. It is smoothed with a
% gaussian that has the width of 32ms with 4ms std based on Loren Frank and
% Shantanu Jadhav papers. Finally, the data is
% zscored. Note that this should be applied to the entire LFP vector from a
% given session so that the mean is very adequately estimated.
%
% -- INPUTS -- %
% lfp: vector of csc data
% phase_bandpass: filtering window (phase_bandpass = [150 250]
% srate: sampling rate of the data
% gauss: should be 1 or 0. 1 indicates smoothing.
%
% -- OUTPUTS -- %
% zPreSWRlfp: lfp that is filtered, transformed, (smoothed), and zscored
% preSWRlfp: lfp that is filtered, transformed, (and smoothed)
% lfp_filtered: filtered lfp - useful for plotting and stuff
%
% written by John Stout

function [zPreSWRlfp,preSWRlfp,lfp_filtered] = preSWRfun(lfp,phase_bandpass,srate,gauss)

% get filtered and transformed data across entire session for purposes of
% defining an average
lfp_filtered = skaggs_filter_var(lfp,phase_bandpass(1),phase_bandpass(2),srate);
lfp_hilbert  = abs(hilbert(lfp_filtered));    

% smooth with gaussian
if gauss == 1

    % generate gaussian - 32ms width and 4ms std (Frank and jadhav papers)
    samplesPerMS  = (srate/1000); % number of samples (N) per ms (N/ms)
    gauss_width   = floor(samplesPerMS*32); % 32ms * N samples/ms = 32*N samples = M samples
    target_std_ms = 4; % target std in ms
    target_std_pt = floor(target_std_ms*samplesPerMS); % target std in samples -> std (in ms) * (N samples / ms) 
    alpha         = (gauss_width-1)/(2*target_std_pt); % use https://www.mathworks.com/help/signal/ref/gausswin.html values to check
        
    % automatically get 4ms standard deviation   
    w = gausswin(gauss_width,alpha);   
    
    %{
    % gaussian plot - check what it looks like
    gauss_time = linspace(0,32,gauss_width);
    figure(); plot(gauss_time,w); xlabel('ms'); 
    %}
    
    % smooth for all
    lfp_smooth = conv(lfp_hilbert,w,'same');
    
    % define variable to use regardless of inputs
    preSWRlfp = lfp_smooth;

elseif gauss == 0
    
   preSWRlfp = lfp_hilbert;
   
end

% zscore data
zPreSWRlfp = zscore(preSWRlfp);

end