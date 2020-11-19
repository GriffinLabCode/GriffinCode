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

    % check that data is a cell array, if not, convert it. This happens if
    % you input a vector or matrix
    if iscell(data) == 0
        data_og = data; data = [];
        data{1} = data_og;
    end

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
        errorbar(i,mean(data{i}),stderr(data{i},1));
        x_axes               = ones(size(data{i})).*(1+((rand(size(data{i}))-0.5)/10));               
        scat                 = scatter(x_axes,data{i});  
        scat.MarkerEdgeColor = 'k';
        scat.MarkerFaceColor = [.5 .5 .5];            
    end
    box off
    ax = gca;
    ax.XTick = [1:length(data)];
    ax.XTickLabel = xLabels;
    ax.XTickLabelRotation = 45;
    ylabel(yLabel);
    
    