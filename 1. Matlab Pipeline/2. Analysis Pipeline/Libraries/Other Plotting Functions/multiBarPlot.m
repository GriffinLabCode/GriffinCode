%% multiBoxPlot
% this function was designed so that you can plot multiple different sizes
% of data together in a box plot
%
% -- INPUTS -- %
% data: cell array containing data that you want to plot
% xLabels: cell array containing labels for each dataset. For example, if
%           you have two datasets you want to plot next to each other, then
%           xLabels = [{'data1'},{'data2'}]
% yLabels: String containing y axis label (ie whats your measurement?)
%
% -- OUTPUTS -- %
% b: box plot figure
%
% written by John Stout

function [b] = multiBarPlot(data,xLabels,yLabel)

    % make sure data is oriented correctly
    outSize = size(data{1});
    
    % if sizing is incorrect, flip
    if outSize(1) < outSize(2) & outSize(1) == 1
        dataNew = [];
        for i = 1:length(data)
            dataNew{i} = data{i}';
        end
        data = [];
        data = dataNew;
    end

    % make figure
    figure('color','w'); hold on;
    for i = 1:length(data)
        bar(i,mean(data{i}));
        errorbar(i,mean(data{i}),stderr(data{i}));
    end
    ylim([5 7])
    
    
        xTemp = [];
        xTemp = i*ones(size(data{i}));
        x = [x;xTemp];
        
        yTemp = [];
        yTemp = data{i};
        y = [y;yTemp];
    end
    b = boxplot(y,x);
    box off
    ax = gca;
    ax.XTickLabel = xLabels;
    ax.XTickLabelRotation = 45;
    ylabel(yLabel);
    
    