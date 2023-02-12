%% code that generates a plot like Jadhav lab
% -- INPUTS -- %
% lfp: lfp data matrix. This matrix includes signals and spike data
%       converted to boolean. Must be row (signals) x column (samples)
% lfpIdx: index of which rows are your lfp data
% unitIdx: index of which rows are your unit data

function [] = lfpRaster(lfp,lfpIdx,unitIdx)
    disp('Please note that this code only supports two signals right now');

    figure('color','w')
    unitLooper = unitIdx;
    unitCount  = length(unitLooper);
    % pfc
    subplot(unitCount+2,1,1)
        plot(lfp(lfpIdx(1),:),'k'); box off; axis tight; %axis off; 
        xlim([1 length(lfp)])        
    % hpc
    subplot(unitCount+2,1,2);
        plot(lfp(lfpIdx(2),:),'b'); box off; axis tight; axis off;
        xlim([1 length(lfp)])
    % colors for unit plotting
    disp('Color code supported by...')
    colors = distinguishable_colors(size(lfp(5:end,:),1));
    for si = 1:length(unitLooper)
        subplot(unitCount+2,1,si+2)
        for i = 1:length(lfp(unitLooper(si),:))
            if lfp(unitLooper(si),i) == 1
                line([i i],[0 1],'color',colors(si,:))
            else
            end
        end 
        xlim([1 length(lfp)])
        axis off;
    end