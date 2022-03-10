%% multiBarPlot
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
% written by John Stout and Allison George

function [b,c] = multiBarPlot(data,xLabels,yLabel,jitter,c)

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
    figure('color','w'); hold on;     
    for i = 1:length(data)
        %bar(i,nanmean(data{i}),'FaceColor',[0 0.5 1]);
        bar(i,nanmean(data{i}),'FaceColor',[.5 .5 .5],'LineWidth',1);
        disp(data{i})
        errorbar(i,nanmean(data{i}),stderr(data{i},1),'Color','k','LineWidth',1);
        if exist('jitter')
            if jitter == 1 | contains(jitter,'y')
                %{
                c = [1 1 0; 1 0 1; 0 1 1; 1 0 0; 0 1 0; 0 0 1;
                  0.2 1 0.6; 0.2 0.6 1; 1 0.2 0.6; 1 0.6 0.2; 0.6 1 0.2; 0.6 0.2 1;
                  0.5 0.5 0.5; 0.8 0 0.3; 0.9 0.7 0.3; 0.9 0.3 0.1; 0 0.1 0.3]
                %}
                % define the color variable - once defined, it will not be
                % rewritten, so colors match between plots
                if exist('c')==0 
                    numIn = size(data{i});
                    c = rand(3,numIn(1))';
                elseif size(c,1)~=size(data{i},1)
                    numIn = size(data{i});
                    c = rand(3,numIn(1))';                     
                end                    
                x_axes               = ones(size(data{i})).*(i+((rand(size(data{i}))-0.5)/10));               
                scat                 = scatter(x_axes,data{i},[],c,'filled'); % multiply by i to follow the bar graph x axes
                
               % scat.MarkerEdgeColor = 'k';
               % scat.MarkerFaceColor = [.5 .5 0];  
            end
        end
    end
    box off
    ax = gca;
    ax.XTick = [1:length(data)];
    ax.XTickLabel = xLabels;
    ax.XTickLabelRotation = 45;
    ylabel(yLabel);
    
    