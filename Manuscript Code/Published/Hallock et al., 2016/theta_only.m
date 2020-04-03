function [high_amp_theta] = theta_only(Samples, srate)
%%

%   This function calculates delay period phase coherence and theta-gamma coupling only
%   during epochs of high theta amplitude in the hippocampal LFP

%   Outputs:
%       performance:        Percentage correct choices
%       MI:                 Modulation index for theta-gamma coupling
%       coherence:          Theta phase coherence

%   Inputs:
%       Samples:            1 x n data points array of continuously sampled data 
%       srate:              Sampling rate (Hz)

%%

Samples = Samples(:)';

% Filter out theta and delta oscillations
filtered_theta = skaggs_filter_var(Samples, 5, 11, srate);
filtered_delta = skaggs_filter_var(Samples, 1, 4, srate);

% Use the Hilbert transform to extract the instantaneous amplitude of each
% filtered signal
hilbert_theta = hilbert(filtered_theta);    
hilbert_delta = hilbert(filtered_delta);
theta_env = abs(hilbert_theta);                 
delta_env = abs(hilbert_delta);

% Calculate a theta/delta ratio
theta_delta = theta_env./delta_env;             

% Find sample periods where the theta/delta ratio >= 4
ratio_ind = find(theta_delta >= 4);            
    
high_amp_theta = Samples(ratio_ind);  

end

