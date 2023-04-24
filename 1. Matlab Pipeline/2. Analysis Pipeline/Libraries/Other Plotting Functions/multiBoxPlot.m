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
% orient: orientation of boxplot. Empty if vertical, 'horizontal' if
%           horizontal. 'vertcal' will also make it vertical
% outliers: 'y' if you want to display outliers. anything else if otherwise
% new_fig: optional. provides a way to create subplots. new_fig = 'y'
%           generates a new figure in this script. If you do not define, it
%           automatically generates a new figure in the script. If you set
%           new_fig = 'n', then you create the figure outside of this
%           script. For example:
%                   figure; subplot 211; multiBoxPlot(data,x,y,'vertical','n','n')                    
% -- OUTPUTS -- %
% b: box plot figure
%
% written by John Stout

function [b] = multiBoxPlot(data,xLabels,yLabel,orient,outliers,new_fig)
    % check that data is a cell array, if not, convert it. This happens if
    % you input a vector or matrix
    if iscell(data) == 0
        data_og = data; data = [];
        %data{1} = data_og;
        for i = 1:size(data_og,2)
            data{i} = data_og(:,i);
        end
        warning('Independent Variables MUST be on the column dimension!')
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
    if exist('new_fig')==0
        new_fig = 'y';
    end
    if contains(new_fig,'n')
    else
        figure('color','w')
    end        
    x = []; y = [];
    for i = 1:length(data)
        xTemp = [];
        xTemp = i*ones(size(data{i}));
        x = [x;xTemp];
        
        yTemp = [];
        yTemp = data{i};
        y = [y;yTemp];
    end
    
    % handle symbols
    if contains(outliers,'y')

        % default is vertical
        if exist('orient') == 0 | isempty('orient')
            b = boxplot(y,x,'orientation','vertical');
        elseif exist('orient')
            try
                b = boxplot(y,x,'orientation',orient);
            catch
                disp('error in orient naming, defaulted to vertical')
                b = boxplot(y,x,'orientation','vertical');
            end
        end     
        
    else
        if exist('orient') == 0 | isempty('orient')
            b = boxplot(y,x,'orientation','vertical');
        elseif exist('orient')
            try
                b = boxplot(y,x,'orientation',orient,'symbol','');
            catch
                disp('error in orient naming, defaulted to vertical')
                b = boxplot(y,x,'orientation','vertical','symbol','');
            end
        end
    end
    %axis tight
    box off
    ax = gca;
    ax.XTickLabel = xLabels;
    ax.XTickLabelRotation = 45;
    ylabel(yLabel);
    set(gcf,'Position',[300 250 350 300])
    

    