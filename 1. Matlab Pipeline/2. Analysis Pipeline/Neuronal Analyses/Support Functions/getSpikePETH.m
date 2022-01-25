%% getSpikePETH
% spike peri-stimulus time histogram. This is very similar to a spike
% raster plot, but we're controlling for the time resolution and
% essentially binning the spike data.
%
% you will need to run "getRelativeSpikeTimes" first. There is a
% run-through SCRIPT in:
% 1. Matlab Pipeline\2. Analysis Pipeline\Libraries\1) Example Pipeline Usage\Spike Code
%
% -- INPUTS -- %
% relativeSpikeTimes: spike timestamps relative to some point of interest.
%                       This has to be in the form of a cell array where
%                       the rows are neurons and the columns are trials.
% timeAround: time (seconds) around the data of interest. This should match
%               your input to "rasterPrep" if you used that function
% timeRes: This is the time resolution in seconds. So if you set 
%           timeRes = 0.01, then you will work with a 100ms time
%           resolution.
%
% -- OUTPUTS -- %
% spkPETH: Spike peri-stimulus time histogram - binned spike data

function [spkPETH] = getSpikePETH(relativeSpikeTimes,timeAround,timeRes)

    % define the number of trials
    nTrials = size(relativeSpikeTimes,2);
    nUnits  = size(relativeSpikeTimes,1);

    % assign 'edges' a variable that provides a resolution for histogram
    %timeRes   = 0.01; % 0.01 seconds
    xmin     = -timeAround(1);
    xmax     = timeAround(2);
    edges    = (xmin:timeRes:xmax);

    spkPETH = [];
    for celli = 1:nUnits % loop across each cell
        subplot(nUnits,1,celli); hold on; % create a subplot
        for triali = 1:nTrials % loop across trials
            % get spike histogram data for later
            spkPETH{celli}(:,triali) = histc(relativeSpikeTimes{celli,triali},edges);
        end
        % Get firing rate by dividing number of spikes in each bin by bin size
        FR{celli}         = spkPETH{celli}./timeRes;
        trialAvgFR{celli} = nanmean(FR{celli},2);
        Std{celli}        = std(FR{celli},0,2); 
        trialSEM{celli} = Std{celli}/sqrt(nTrials-1);
        smoothFR{celli} = smoothdata(trialAvgFR{celli}','gaussian');
    end

end