%% thetaDeltaRatio_cycleXcycle
% 
% a theta:delta ratio that is cycle-specific. It gets an average
% theta:delta ratio estimate that reflects a theta cycle score.
%
% -- INPUTS -- %
% LFP:            vector of lfp
% timesLFP:       vector of lfp times
% lfp_srate:      sampling rate of lfp
%
% -- OUTPUTS -- %
% TDratio: theta:delta ratio per theta cycle
%
% written by John Stout. Suhaas Adiraju wrote the original theta:delta
% script

function [TDratio] = thetaDeltaRatio_cycleXcycle(LFP,timesLFP,lfp_srate)

% bandpass filter theta
lfp_filtered_theta = skaggs_filter_var(LFP, 6, 12, lfp_srate); 
inst_theta_power   = abs(hilbert(lfp_filtered_theta));    

% bandpass filter delta
lfp_filtered_delta = skaggs_filter_var(LFP,1, 4, lfp_srate);  
inst_delta_power   = abs(hilbert(lfp_filtered_delta));    

% get theta cycle phase information
[~, ~, peak, trough] = get_thetaPhase(LFP,timesLFP,lfp_srate);

% loop across theta cycles, only move forward if a trough is present,
% calculate theta:delta ratio within each theta cycle
for i = 1:length(peak)-1
    
    % make sure that a trough was observed between peaks, if not exclude
    trough_idx = find(trough > peak(i) & trough < peak(i+1));
    
    % if no trough exists between peaks, or if there are multiple troughs
    % between a peak, skip the theta cycle (its not really a theta cycle at
    % this point, its multiple. Data got lost somewhere and so it shouldn't
    % be analyzed).
    if isempty(trough_idx) == 1 | length(trough_idx) > 1
        
        % make cell arrays empty and matrices nan
        TDratio(i) = NaN;
        
        continue 
    else 
        
        % per each theta cycle, get instantaneous theta and delta power
        theta_temp = []; delta_temp = [];
        theta_temp = inst_theta_power(peak(i):peak(i+1));
        delta_temp = inst_delta_power(peak(i):peak(i+1));
        
        % calculate a theta:delta ratio per cycle
        TDratio(i) = mean(theta_temp./delta_temp);
        
    end
end

end

