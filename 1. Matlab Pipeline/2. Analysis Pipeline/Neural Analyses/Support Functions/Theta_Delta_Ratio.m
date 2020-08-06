%% Function/Script written to create a Theta-Delta Ratio calculation/figure for SWR identification
% This script is derived from Tang et. al. 2017 
%"Hippocampal-Prefrontal Reactivation during Learning Is Stronger in Awake Compared with Sleep States"

%"Briefly, theta (6–12 Hz) and delta (1–4 Hz) power was bandpass filtered and averaged from all available
%CA1 tetrodes (referenced to GND). A thresh- old (mean 1 SD) of the theta/delta ratio was automatically
%set to separate SWS/NREM and REM sleep states. LFP and position data for each sleep state were also
%visually inspected for accuracy." 

% -- INPUTS -- %
% LFP:            vector of lfp
% theta_bandpass: theta frequencies (ie theta_bandpass = [4 12])
% delta_bandpass: delta frequencies
% srate:          sampling rate
%
% -- OUTPUTS -- %
% Theta_Delta_Ratio: ratio from theta to delta
% ThetaDeltaZ:       stds of theta delta ratio
%
% written by Suhaas. Modified and organized by JS.

function [theta_delta_rat,ThetaDeltaZ] = Theta_Delta_Ratio(LFP,theta_bandpass,delta_bandpass,srate)

% -- FOR THETA -- %

% phase bandpass
phase_bandpass_theta = theta_bandpass; %[6 12];

% bandpass filter (3rd deg butterworth filter)
lfp_filtered_theta = skaggs_filter_var(LFP, phase_bandpass_theta(1),...
    phase_bandpass_theta(2), srate); 
inst_theta_power   = abs(hilbert(lfp_filtered_theta));    

% -- FOR DELTA -- %

% phase bandpass
phase_bandpass_delta = delta_bandpass; %[1 4]

% bandpass filter (3rd deg butterworth filter)
lfp_filtered_delta = skaggs_filter_var(LFP, phase_bandpass_delta(1),...
    phase_bandpass_delta(2), srate);  
inst_delta_power   = abs(hilbert(lfp_filtered_delta));    

% -- calculate ratio -- %
%Theta_Delta_Ratio = lfp_filtered_theta./lfp_filtered_delta;
theta_delta_rat = inst_theta_power./inst_delta_power; % theta / delta - was delta/theta - JS change on 8/6/20

% Z-score data to work in Std. Devs 
ThetaDeltaZ = zscore(theta_delta_rat);

end

