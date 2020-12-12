%% theta-delta ratio in epochs
%
% -- INPUTS -- %
% LFP: lfp vector
% signalTimes: times vector
% timeRes: the time, in seconds, for the epoch length to consider. try 1
% srate: sampling rate
%
% -- OUTPUTS -- %
% TDratio: output on the second scale
% timeIdx: timing for which td ratio was calculated. can use this to remove
%           lfp
%
% written by john stout

function [TDratio,] = TDratioEpochs(LFP,signalTimes,timeRes,srate)

% This input does not matter. Its the threshold on an element-by-element
% basis. This code handles the variability present by telling you which
% epochs having high or low td ratio
TDthresh = 4;

% epoch version - 1 sec resolution 
timeIdx = 1:srate*timeRes:length(signalTimes);
for i = 1:length(timeIdx)
    % get times, lfp and td ratio
    times = signalTimes(signalTimes(timeIdx(i)):signalTimes(timeIdx(i+1)));
    lfp   = LFP(signalTimes(timeIdx(i)):signalTimes(timeIdx(i+1)));
    TDratio(i) = Theta_Delta_Ratio(lfp,times,TDthresh,[5 9],[1 4],srate);
end

