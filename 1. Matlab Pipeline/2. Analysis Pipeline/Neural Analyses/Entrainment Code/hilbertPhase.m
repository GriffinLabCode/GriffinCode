%% hilbertPhase
% convert filtered signal to phase using hilber
% -- INPUTS -- %
% filtered_signal: signal filtered for frequency range of interest. Try
%                   using skaggs_filter_var(lfp,4,12,srate)
% -- OUTPUTS -- %
% phaseDeg: phase estimates via hilbert transform wrapped to 0-360
% phaseRad: radians of phase estimates
%
% JS

function [phaseDeg,phaseRad] = hilbertPhase(filtered_signal)
    phaseRad = angle(hilbert(filtered_signal));
    phaseDeg = wrapTo360(rad2deg(phaseRad)); 
end