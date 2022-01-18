%% rasterPrep
% this function provides an easy way to use to int file and begin creating
% a raster plot of neuronal activity. The sequence of code should be as
% following:
% 1) Run rasterPrep
% 2) Run getRelativeSpikeTimes
% 3) Run rasterPlot
%
% written by JS

function [spk_sec,anchorTimes,clusters] = rasterPrep(datafolder,tt_name,Int,IntLoc,timeAround)

% some old stuff
%IntLoc = [5];
%timeAround = [2 2];

% change directories
cd(datafolder);

% get spike data
[spikeTimes,clusters] = getSpikeData(datafolder,tt_name);

% define number of trials
numTrials = size(Int,1);

% get data for each neuron
spk_sec = [];
for triali = 1:numTrials
    for ci = 1:length(clusters)
        % get spiketimes converted to seconds
        spk_sec{ci,triali} = (spikeTimes{ci}( spikeTimes{ci} >= ( Int(triali,IntLoc)- (timeAround(1)*1e6) ) & spikeTimes{ci} <= ( Int(triali,IntLoc)+ (timeAround(2)*1e6) ) ) )./1e6;  
    end
    % anchor - this is the point to subtract all data from.
    anchorTimes(triali) = Int(triali,IntLoc)./1e6;
end

