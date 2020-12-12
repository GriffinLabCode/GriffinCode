%% get_thetaCycleTimes
%
% This function was designed to extract timestamps within each theta cycle.
% It does so by first defining a theta cycle as being peak to peak, then
% ensuring there is a trough identified between peaks, then extracting
% timestamps and lfp.
%
% Code that precedes this: Use get_thetaPhase
%
% -- INPUTS -- %
% peak: theta phase peaks (180)
% trough: theta phase troughs (0)
%
% -- OUTPUTS -- %
% cycleTimes: a cell array where each cell element is timestamps within a
%               theta cycle
%
% written by John Stout

function [cycleTimes,cycleLFP] = get_thetaCycleTimes(lfp_times,lfp,peak,trough)

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
        
        % get times - cell array
        cycleTimes{i} = lfp_times(peak(i):peak(i+1));
        cycleLFP{i}   = lfp(peak(i):peak(i+1));
        
    end
end