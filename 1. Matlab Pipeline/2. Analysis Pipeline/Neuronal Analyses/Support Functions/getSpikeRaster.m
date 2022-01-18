%% population raster plotting
% this code will create raster plots for all of your neurons
%
% this code will also plot neuronal activity at the trial resolution
% denoted by different colors?
%
% You can find a run through here:
% 1. Matlab Pipeline\2. Analysis Pipeline\Libraries\1) Example Pipeline Usage\Spike Code
%
% -- INPUTS -- %
% relativeSpikeTrials: spike data with each cell containing spike times
%                       that are relative to some point of interest. This
%                       MUST be in the format of rows(neuronID) X
%                       columns(trials) with each cell array container
%                       containing relative spike times.
% timeAround: time (seconds) around the data of interest. This should match
%               your input to "rasterPrep"

function [] = getSpikeRaster(relativeSpikeTimes,timeAround)

    % define the number of trials
    nTrials = size(relativeSpikeTimes,2);
    nUnits  = size(relativeSpikeTimes,1);

    % some preparations
    ylimits  = [0 nTrials+1];
    xmin     = -timeAround(1);
    xmax     = timeAround(2);
    tickSize = 0.4;

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
        end
        ylim(ylimits)
        title(['Cell # ',num2str(celli)])
    end 
    ylabel('Trial #')
    xlabel('Time from ...')

    % trial resolution - plot populations on a trial-to-trial basis
    ylimits  = [0 nUnits+1];
    figure('color','w');
    cmap = hsv(nUnits);
    for triali = 1:nTrials
        for celli = 1:nUnits
            subplot(1,nTrials,triali); hold on;
            if length(relativeSpikeTimes{celli,triali}) == 2 % patch for weird error if num spikes is 2
                for ii = 1:length(relativeSpikeTimes{celli,triali})
                    line([relativeSpikeTimes{celli,triali}(ii) relativeSpikeTimes{celli,triali}(ii)],[celli-tickSize celli+tickSize],'Color',cmap(celli,:))            
                end
            else
                line([relativeSpikeTimes{celli,triali} relativeSpikeTimes{celli,triali}],[celli-tickSize celli+tickSize],'Color',cmap(celli,:))            
            end            
        end
        title(['Trial ',num2str(triali)])
        ylim(ylimits)
        if triali == 1
            ylabel('Neuron')
        end
    end
 
end
