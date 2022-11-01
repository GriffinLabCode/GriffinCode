%% get spike time index
%
% code designed to extract LFP for each spike. It should be noted that you
% do not need to put your entire LFP trace into this code. However, you do
% need to make sure that your LFP and spike timestamps trace are consistent
% with the time boundaries. For example, if you have spike timestamps from
% time point 0-10s, but lfp from 1-10s, its going to force your spike
% timestamp data from range 0-1s into lfp data at 1s.
%
% If you are interested in delay period spike times, get spike times during
% the delay, get LFP during the delay, then input that code. It will save
% you a lot of processing time.
%
% -- INPUTS -- %
% lfpTimes: vector of lfp timestamps
% spikeTimes: spike timestamps that you want to get LFP values for
%
% -- OUTPUTS -- %
% spikeLFPidx: an index of spike-LFP values. Use this to get LFP values
% spikeLFPval: LFP per each spike
%
% written by John Stout

function [spikeLFPidx,spikeLFPval] = getSpikeLFPidx(lfpTimes,spikeTimes)

% do some reorienting
lfpTimes = change_row_to_column(lfpTimes);
spikeTimes = change_row_to_column(spikeTimes)';

% get index of LFP
spikeLFPidx = [];
spikeLFPidx = dsearchn(lfpTimes,spikeTimes);

% Get lfp
spikeLFPval = lfpTimes(spikeTimes);



