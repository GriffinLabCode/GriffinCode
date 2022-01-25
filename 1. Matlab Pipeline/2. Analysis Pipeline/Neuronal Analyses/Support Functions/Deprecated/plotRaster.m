%% population raster plotting
% this code will create raster plots for all of your neurons
%
% this code will also plot neuronal activity at the trial resolution
% denoted by different colors?
%
% you should perform the following steps before being here:
% 1) 

% -- INPUTS -- %
% relativeSpikeTrials: spike data with each cell containing spike times
%                       that are relative to some point of interest. This
%                       MUST be in the format of rows(neuronID) X
%                       columns(trials) with each cell array container
%                       containing relative spike times.
% timeAround: time (seconds) around the data of interest. This should match
%               your input to "rasterPrep"
%
% -- OUTPUTS -- %
% spkHist: spike histogram, where spike data is binned into 100ms windows


function [spkHist] = plotRaster(relativeSpikeTimes,timeAround)

    % define the number of trials
    nTrials = size(relativeSpikeTimes,2);
    nUnits  = size(relativeSpikeTimes,1);

    % some preparations
    ylimits  = [0 nTrials+1];
    xmin     = -timeAround(1);
    xmax     = timeAround(2);
    tickSize = 0.4;

    % assign 'edges' a variable that provides a resolution for histogram
    bin   = 0.01; % 0.01 seconds
    edges = (xmin:bin:xmax);

    spkHist = [];
    figure('color','w');
    for celli = 1:nUnits % loop across each cell
        subplot(nUnits,1,celli); hold on; % create a subplot
        for triali = 1:nTrials % loop across trials
            if length(relativeSpikeTimes{celli,triali}) == 2 % patch for weird error if num spikes is 2
                for ii = 1:length(relativeSpikeTimes{celli,triali})
                    line([relativeSpikeTimes{celli,triali}(ii) relativeSpikeTimes{celli,triali}(ii)],[triali-tickSize triali+tickSize],'Color','k')
                end
            else
                line([relativeSpikeTimes{celli,triali} relativeSpikeTimes{celli,triali}],[triali-tickSize triali+tickSize],'Color','k')
            end
            spkHist{celli}(:,triali) = histc(relativeSpikeTimes{celli,triali},edges);
        end
        ylim(ylimits)
    end
    
    
end
