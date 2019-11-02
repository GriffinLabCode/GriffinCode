%% Function to plot bar graph with jittered data points
% define mat as your matrix of data - for coherence it matches the excel
% sheet saved

% ***must define mat as a double***

% INPUTS:
%   mat: a matrix containing paired data that will be used to estimate
%   mean and standard error of the mean. Note that even columns will have
%   an odd column pair. So if col 1 has data, then col 2 is its pair. If
%   col 3 has data than col 4 is its pair. Another example: col 1 and col2
%   is theta coherence for sample and choice, while col 3 nd 4 is gamma
%   coherence for sample and choice
%
%   plot_bar: 1 for bar plot with SEM bars
%
%   plot_box: 1 for boxplot
%
%   jitter: 1 for jittered and connected data points
%
%   connect_jitter: do you want to connect jitter?
%
%   PlotLine: do you want to plot a horizontal line?
%
% OUTPUTS:
%
%   Figure
%
% Written by John Stout

function [] = BarPlotsJitteredData(mat,plot_bar,plot_box,jitter,connect_jitter,PlotLine)

num_vars  = 1:size(mat,2);
mean_data = mean(mat);

if size(mat,1) == 1 || size(mat,2) == 1
    stderr = std(mat)./(sqrt(length(mat))); % if mat is a vector
else
    stderr    = std(mat)./sqrt(size(mat,1)); % if mat is a matrix (observations X variables)
end

% jittered data
figure('color',[1 1 1]); hold on;

if plot_bar == 1
    if jitter == 1
        for i = 1:length(mean_data)
            b                    = bar(num_vars(i),mean_data(i));               
            er                   = errorbar(num_vars(i),mean_data(i),stderr(i));    
            er.Color             = [0 0 0];                            
            er.LineStyle         = 'none';  
            x_axes(:,i)          = ones(size(mat(:,i),1),1).*((i)+(rand(size(mat(:,i),1),1)-0.5)/10);    
            scat                 = scatter(x_axes(:,i),mat(:,i));  
            scat.MarkerEdgeColor = 'k';
            scat.MarkerFaceColor = [0.8,0.8,0.8];
        end

        if connect_jitter == 1
            for i = 1:size(mat,1)
                for ii = 1:2:size(mat,2)
                    line([x_axes(i,ii) x_axes(i,ii+1)],...
                    [mat(i,ii) mat(i,ii+1)],'Color',[0.8 0.8 0.8],'linestyle','-','LineWidth',0.5)
                end
            end
        end
    else
        for i = 1:length(mean_data)
            b                    = bar(num_vars(i),mean_data(i));               
            er                   = errorbar(num_vars(i),mean_data(i),stderr(i));    
            er.Color             = [0 0 0];                            
            er.LineStyle         = 'none';  
        end          
    end
    
    % plot line - usually used for testing against some null
    if PlotLine == 1
        line([xlim],...
        [.5 .5],'Color',[0 0 0],'linestyle','--','LineWidth',2)
    end   
    
end
% make font larger
set(gca,'FontSize',20);  

if plot_box == 1
    figure('color',[1 1 1]); hold on;
    boxplot(mat,'BoxStyle','outline','Colors','k','MedianStyle','line')
    
    for i = 1:length(mean_data)
        x_axes(:,i)          = ones(size(mat(:,i),1),1).*((i)+(rand(size(mat(:,i),1),1)-0.5)/10);    
        scat                 = scatter(x_axes(:,i),mat(:,i));  
        scat.MarkerEdgeColor = 'k';
        scat.MarkerFaceColor = [0.8,0.8,0.8];
    end
    if connect_jitter == 1
        for i = 1:size(mat,1)
            for ii = 1:2:size(mat,2)
                line([x_axes(i,ii) x_axes(i,ii+1)],...
                [mat(i,ii) mat(i,ii+1)],'Color',[0.8 0.8 0.8],'linestyle','-','LineWidth',0.5)
            end
        end 
    end
    
    % plot line - usually used for testing against some null
    if PlotLine == 1
        line([xlim],...
        [.5 .5],'Color',[0 0 0],'linestyle','--','LineWidth',2)
    end
        
    box off;
    set(gca,'FontSize',20);
end