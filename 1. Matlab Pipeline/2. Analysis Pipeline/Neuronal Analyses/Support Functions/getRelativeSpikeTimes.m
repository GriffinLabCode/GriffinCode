%% getRelativeSpikes
% this function transforms your spike timestamp data into spikes that are
% in seconds, and relative to whatever time point you are interested in.
% To elaborate, first you will need a cell array containing spike time
% stamp data that is raw (uncoverted to seconds). That spike time stamps
% data will be spikes around some point of interest. For example, spike
% times around the entry point of startbox for each trial (denoted in each
% cell array container), or spike timestamps around the entry of choice
% point - whatever you want. When you have that data, it will be in
% Cheetahs uncoverted time. However, you might want that data in seconds
% around the choice point entry. For example, maybe all spikes occur in 0.5
% seconds from choice point entry. Therefore, this code transforms your
% spike times into ACTUAL seconds around some relative point of interest.
%
% This is a good first step before attempting to make a raster plot
%
% -- INPUTS -- %
% spkEvents: this is a cell array containing the spikes per each trial or
%               epoch. If you want to examine a simultaneously recorded
%               population, then your data must be organized as following:
%                   -> cell array of size N(neuron) x M(trial) with each
%                   cell containing spike data from a specific epoch of
%                   interest (for example time around choice point entry).
%
% anchorTimes: this is a vector containing your anchor time points, for example
%           if you are interested in time around choice point entry, then 
%           you will have a vector of N trials containing time stamps of
%           choice point entry for each trial. This should be the same size
%           as spkEvents
%
% written by John Stout

function [relativeSpikeTimes] = getRelativeSpikeTimes(spkEvents,anchorTimes)

    % first, make sure you are only examining cell arrays with actual
    % data
    %[spkEventsCorrected,array2rem] = emptyCellErase(spkEvents);

    % it was actually better to just assign the empty arrays as nan to
    % retain cell array sizes
    spkEventsCorrected = empty2nan(spkEvents);

    % remove anchorTimes
    %anchorTimes(array2rem)=[];

    % converting spikes to relative seconds requires that you subtract
    % each spike timestamp from some relative time point, called the
    % anchor time
    for celli = 1:size(spkEventsCorrected,1)
        for triali = 1:size(spkEventsCorrected,2)
            relativeSpikeTimes{celli,triali} = spkEventsCorrected{celli,triali}-anchorTimes(triali);
        end
    end

end







