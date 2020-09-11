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