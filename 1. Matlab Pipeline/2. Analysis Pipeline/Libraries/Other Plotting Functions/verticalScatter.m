%% Vertical scatter
% This function makes scatter plots like a bar graph. This idea was taken
% from henrys dissertation
%
% -- INPUTS -- %
% data: cell array containing data that you want to plot
% scat_color: cell array same size as data containing colors
% xLabels: cell array containing labels for each dataset. For example, if
%           you have two datasets you want to plot next to each other, then
%           xLabels = [{'data1'},{'data2'}]
% yLabels: String containing y axis label (ie whats your measurement?)
% centTend: define as 'mean' if you want the average, default is median
%
% -- OUTPUTS -- %
% b: box plot figure
%
% written by John Stout

function [b] = verticalScatter(data,scat_color,xLabels,yLabel,centTend,saveName)

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
        %b = bar(i,mean(data{i}),'FaceColor',[0 0.5 1]);
        %errorbar(i,mean(data{i}),stderr(data{i},1),'Color','k');
        x_axes               = ones(size(data{i})).*(i+((rand(size(data{i}))-0.5)/10));               
        scat                 = scatter(x_axes,data{i}); % multiply by i to follow the bar graph x axes 
        scat.MarkerEdgeColor = 'k';
        scat.MarkerFaceColor = scat_color{i}; 
        
        % plot mean or median horizontal lines
        if contains(centTend,'mean')
            l = line([min(x_axes)-.05 max(x_axes)+.05], [nanmean(data{i}) nanmean(data{i})])
            l.LineWidth = 2;
            l.Color = 'k';
        else
            l = line([min(x_axes)-.05 max(x_axes)+.05], [median(data{i}) median(data{i})])
            l.LineWidth = 2;
            l.Color = 'k';          
        end
    end
    xlim([0.5 length(data)+0.5])
    
    %axis tight
    box off
    ax = gca;
    ax.XTickLabel = xLabels;
    ax.XTickLabelRotation = 45;
    ylabel(yLabel);
    set(gcf,'Position',[300 250 350 300])

    if exist('saveName') 
        print('-painters',[saveName,'.eps'],'-depsc','-r0')
    end    
    

    