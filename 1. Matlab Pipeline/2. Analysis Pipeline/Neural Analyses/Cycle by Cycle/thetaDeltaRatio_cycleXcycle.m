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
% highAmp_theta:     high amplitude lfp returned based on theta
%
% written by Suhaas. Modified and organized by JS.

function [theta_delta_rat,ThetaDeltaZ,highAmp_theta] = thetaDeltaRatio_cycleXcycle(LFP,timesLFP,lfp_srate)

% filter 1-80Hz like Amemiya et al 2018
signal_filtered = skaggs_filter_var(LFP,1,80,lfp_srate);

% phase freq detect - get phase bw 6-12 Amemiya et al., 2018
Phase = phase_freq_detect(signal_filtered, timesLFP, 6, 12, lfp_srate);

% using phase, use find function to find closest values to 0, to 180 (peak), and
% to 360 (trough)
trough = find(Phase == 0); %should i add a line including 360?
peak   = find(Phase == 180);

% loop across theta cycles, filter data in between, calculate theta:delta
% ratio. Theta cycles are from peak:peak
for i = 1:length(peak)-1
    
    % make sure that a trough was observed between peaks, if not exclude
    trough_idx = find(trough > peak(i) & trough < peak(i+1));
    
    % if no trough exists between peaks, or if there are multiple troughs
    % between a peak, skip the theta cycle (its not really a theta cycle at
    % this point, its multiple. Data got lost somewhere and so it shouldn't
    % be analyzed).
    if isempty(trough_idx) == 1 | length(trough_idx) > 1
        % make cell arrays empty and matrices nan
        cycleTimes{i} = [];
        continue 
    else 
        % get times - this should be in a separate code
        cycleTimes{i} = timesLFP(peak(i):peak(i+1));
        
    end
end

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

% return high amplitude theta - JS 11/15/20
highThetaIdx  = find(theta_delta_rat >= 4); % Hallock et al., 2016; Brandon et al., 2011
highAmp_theta = LFP(highThetaIdx);

end

