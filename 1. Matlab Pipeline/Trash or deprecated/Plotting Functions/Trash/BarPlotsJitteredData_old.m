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
%   PlotLine: do you want to plot a horizontal line? Set this to [] if you
%               don't want to use
%
%   colorCode_jitter: do want your jitter colorcoded? This is a struct
%                       array. colorCode_jitter.color1 and ...color2 are
%                       colors you choose.
%
% OUTPUTS:
%
%   Figure
%
% Written by John Stout

function [fig] = BarPlotsJitteredData(mat,plot_bar,plot_box,jitter,connect_jitter,PlotLine,colorCode_jitter)

num_vars  = 1:size(mat,2);
mean_data = nanmean(mat);

if size(mat,1) == 1 || size(mat,2) == 1
    stderr    = nanstd(mat)./(sqrt(length(mat))); % if mat is a vector
else
    stderr    = nanstd(mat)./sqrt(size(mat,1)); % if mat is a matrix (observations X variables)
end


if plot_bar == 1
    
    % jittered data
    fig = figure('color',[1 1 1]); hold on;

    if jitter == 1
        for i = 1:length(mean_data)
            b                    = bar(num_vars(i),mean_data(i));   
            %b.LineWidth          = 2;
            er                   = errorbar(num_vars(i),mean_data(i),stderr(i));  
            er.Color             = [0 0 0];                            
            er.LineStyle         = 'none'; 
            %er.LineWidth         = 2;
            x_axes(:,i)          = ones(size(mat(:,i),1),1).*((i)+(rand(size(mat(:,i),1),1)-0.5)/10);    
            scat                 = scatter(x_axes(:,i),mat(:,i));  
            scat.MarkerEdgeColor = 'k';
            scat.MarkerFaceColor = [1,1,1];
            %scat.MarkerFaceAlpha = 0.3;
        end

        if connect_jitter == 1
            if exist('colorCode_jitter') == 1 % this will find increasers and make them grey, decreasers black
                for i = 1:size(mat,1)
                    for ii = 1:2:size(mat,2) % skip every other column (col1 vs col2 col3vs col4 col5vscol6 etc...)
                        if mat(i,ii)-mat(i,ii+1) < 0
                            line([x_axes(i,ii) x_axes(i,ii+1)],...
                            [mat(i,ii) mat(i,ii+1)],'Color',colorCode_jitter.color1,'linestyle','-','LineWidth',0.5)
                        elseif mat(i,ii)-mat(i,ii+1) > 0
                            line([x_axes(i,ii) x_axes(i,ii+1)],...
                            [mat(i,ii) mat(i,ii+1)],'Color',colorCode_jitter.color2,'linestyle','-','LineWidth',0.5)
                        end                            
                    end
                end                
            else
                for i = 1:size(mat,1)
                    for ii = 1:2:size(mat,2) % skip every other column (col1 vs col2 col3vs col4 col5vscol6 etc...)
                        line([x_axes(i,ii) x_axes(i,ii+1)],...
                        [mat(i,ii) mat(i,ii+1)],'Color',[0.8 0.8 0.8],'linestyle','-','LineWidth',0.5)
                    end
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
    if isempty('PlotLine') == 1
        line([xlim],...
        [PlotLine PlotLine],'Color',[0 0 0],'linestyle','--','LineWidth',2)
    end   
    
end
% make font larger
set(gca,'FontSize',20);  

if plot_box == 1
    fig = figure('color',[1 1 1]); hold on;
    boxplot(mat,'BoxStyle','outline','Colors','k','MedianStyle','line')
    
    if jitter == 1
        for i = 1:length(mean_data)
            x_axes(:,i)          = ones(size(mat(:,i),1),1).*((i)+(rand(size(mat(:,i),1),1)-0.5)/10);    
            scat                 = scatter(x_axes(:,i),mat(:,i));  
            scat.MarkerEdgeColor = 'k';
            scat.MarkerFaceColor = [1,1,1];
        end
        if connect_jitter == 1
            if exist('colorCode_jitter') == 1 % this will find increasers and make them grey, decreasers black
                for i = 1:size(mat,1)
                    for ii = 1:2:size(mat,2) % skip every other column (col1 vs col2 col3vs col4 col5vscol6 etc...)
                        if mat(i,ii)-mat(i,ii+1) < 0
                            line([x_axes(i,ii) x_axes(i,ii+1)],...
                            [mat(i,ii) mat(i,ii+1)],'Color',colorCode_jitter.color1,'linestyle','-','LineWidth',0.5)
                        elseif mat(i,ii)-mat(i,ii+1) > 0
                            line([x_axes(i,ii) x_axes(i,ii+1)],...
                            [mat(i,ii) mat(i,ii+1)],'Color',colorCode_jitter.color2,'linestyle','-','LineWidth',0.5)
                        end                            
                    end
                end                
            else
                for i = 1:size(mat,1)
                    for ii = 1:2:size(mat,2) % skip every other column (col1 vs col2 col3vs col4 col5vscol6 etc...)
                        line([x_axes(i,ii) x_axes(i,ii+1)],...
                        [mat(i,ii) mat(i,ii+1)],'Color',[0.8 0.8 0.8],'linestyle','-','LineWidth',0.5)
                    end
                end
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