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
%                       array. colorCode_jitter.increase should be the
%                       color that you want the line to be connecting two
%                       values that changed positively. Defaults to red.
%                       colorCode_jitter.decrease reflects decreasing
%                       values between conditions. Defaults to black.
%                       colorCode_jitter.noChange reflects no change.
%                       colorCode_jitter.noChange defaults to grey.
%                 % --- to default, just set colorCode_jitter to 1 --- %
%
%   jitterIdx: numerical vector where numbers correspond to group. For
%               example, if mat is 30x2 (30 observations, 2 variables),
%               where there are 6 different grouping variables (say
%               animals) that contribute 5 observations (say trials) each.
%               Then your jitterIdx would have 5 unique numbers that
%               repeat, such that 1:5 (out of 30) is say 1, 6:10 is say 2,
%               and etc... - this is an optional input. Make empty if not
%               using
%
%   colorIdx: Depending on the number of grouping variables, make each
%               element in this cell array, contains numerical color codes.
%               for example, if you have 6 grouping variables (say
%               animals), then colorIdx{1} = [1 1 1]; is a white fill for N
%               number of observations (see jitterIdx above) - only
%               mandatory if jitterIdx is not empty
%
% OUTPUTS:
%
%   Figure
%
% Written by John Stout

function [fig] = BarPlotsJitteredData(mat,plot_bar,plot_box,jitter,connect_jitter,PlotLine,colorCode_jitter,jitterIdx,colorIdx)

num_vars  = 1:size(mat,2);
mean_data = nanmean(mat);

if size(mat,1) == 1 || size(mat,2) == 1
    stderr    = nanstd(mat)./(sqrt(length(mat))); % if mat is a vector
else
    stderr    = nanstd(mat)./sqrt(size(mat,1)); % if mat is a matrix (observations X variables)
end
    
if plot_bar == 1 && jitter == 1

    fig = figure('color',[1 1 1]); hold on;
    
    if exist('jitterIdx') % this is a jitter index, it color codes data according to numerical inputs
        x_axes = []; % make sure this is empty           
        for i = 1:length(mean_data)

            % make bar graph
            b                    = bar(num_vars(i),mean_data(i));   
            %b.LineWidth          = 2;
            er                   = errorbar(num_vars(i),mean_data(i),stderr(i));  
            er.Color             = [0 0 0];                            
            er.LineStyle         = 'none'; 
            %er.LineWidth         = 2;
            jitterElements       = unique(jitterIdx); % different values for grouping data

            % loop across jitter elements and plot the jittered data
            % (based on the index) separately
            for groupi = 1:length(jitterElements)
                % index of ith grouping value
                idx2get = find(jitterIdx == groupi);
                % define x axis variable
                x_axes{i}{groupi}    = ones(size(mat(idx2get,i),1),1).*((i)+(rand(size(mat(idx2get,i),1),1)-0.5)/10);               
                scat                 = scatter(x_axes{i}{groupi},mat(idx2get,i));  
                scat.MarkerEdgeColor = 'k';
                scat.MarkerFaceColor = colorIdx{groupi};
                %scat.MarkerFaceAlpha = 0.3;
            end

        end

    else   

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

    end
    
elseif plot_box == 1 && jitter == 1
    
    fig = figure('color',[1 1 1]); hold on;
    boxplot(mat,'BoxStyle','outline','Colors','k','MedianStyle','line')   
    
    x_axes = [];
    for i = 1:length(mean_data)
        
        %x_axes(:,i)          = ones(size(mat(:,i),1),1).*((i)+(rand(size(mat(:,i),1),1)-0.5)/10);    
        jitterElements       = unique(jitterIdx); % different values for grouping data
        
        % loop across jitter elements and plot the jittered data
        % (based on the index) separately
        for groupi = 1:length(jitterElements)
            % index of ith grouping value
            idx2get = find(jitterIdx == groupi);
            % define x axis variable
            x_axes{i}{groupi}    = ones(size(mat(idx2get,i),1),1).*((i)+(rand(size(mat(idx2get,i),1),1)-0.5)/10);               
            scat                 = scatter(x_axes{i}{groupi},mat(idx2get,i));  
            scat.MarkerEdgeColor = 'k';
            scat.MarkerFaceColor = colorIdx{groupi};
            %scat.MarkerFaceAlpha = 0.3;
        end         
    end    
end
    
if jitter == 1
    % below should not depend on box plot or bar plot
    if connect_jitter == 1

        if exist('colorCode_jitter') && exist('jitterIdx')==0 % this will find increasers and make them grey, decreasers black

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

        elseif exist('colorCode_jitter') && exist('jitterIdx')

            % use the same x-axis data from earlier
            for ii = 1:length(x_axes)
                x_axes_cat(:,ii) = vertcat(x_axes{ii}{:});
            end
            x_axes = [];
            x_axes = x_axes_cat; % rename

            % display info to user
            if isstruct(colorCode_jitter)            
            elseif colorCode_jitter == 1
                disp('Values that did not change between conditions are defaulted to grey lines')
                disp('Values that changed negatively between conditions are defaulted to black lines')
                disp('Values that changed positively between conditions are defaulted to red lines')
            end

            for i = 1:size(mat,1)

                for ii = 1:2:size(mat,2) % skip every other column (col1 vs col2 col3vs col4 col5vscol6 etc...)

                    if mat(i,ii)-mat(i,ii+1) < 0

                        if isstruct(colorCode_jitter) == 0 && colorCode_jitter == 1
                            line([x_axes(i,ii) x_axes(i,ii+1)],...
                            [mat(i,ii) mat(i,ii+1)],'Color','k','linestyle','-','LineWidth',0.5)                                                                     
                        elseif isstruct(colorCode_jitter)
                            try
                                line([x_axes(i,ii) x_axes(i,ii+1)],...
                                [mat(i,ii) mat(i,ii+1)],'Color',colorCode_jitter.decrease,'linestyle','-','LineWidth',0.5)     
                            catch
                                line([x_axes(i,ii) x_axes(i,ii+1)],...
                                [mat(i,ii) mat(i,ii+1)],'Color','r','linestyle','-','LineWidth',0.5)     
                                %disp('Values that changed negatively between conditions are defaulted to black lines')                                    
                            end
                        end                        
                    elseif mat(i,ii)-mat(i,ii+1) > 0

                        if isstruct(colorCode_jitter) == 0 && colorCode_jitter == 1
                            line([x_axes(i,ii) x_axes(i,ii+1)],...
                            [mat(i,ii) mat(i,ii+1)],'Color','r','linestyle','-','LineWidth',0.5)                                                                     
                        elseif isstruct(colorCode_jitter)
                            try
                                line([x_axes(i,ii) x_axes(i,ii+1)],...
                                [mat(i,ii) mat(i,ii+1)],'Color',colorCode_jitter.increase,'linestyle','-','LineWidth',0.5)     
                            catch
                                line([x_axes(i,ii) x_axes(i,ii+1)],...
                                [mat(i,ii) mat(i,ii+1)],'Color','r','linestyle','-','LineWidth',0.5)     
                                %disp('Values that changed positively between conditions are defaulted to red lines')                                    
                            end
                        end

                    elseif mat(i,ii) == mat(i,ii+1) % no change

                        if isstruct(colorCode_jitter) == 0 && colorCode_jitter == 1
                            line([x_axes(i,ii) x_axes(i,ii+1)],...
                            [mat(i,ii) mat(i,ii+1)],'Color',[.8 .8 .8],'linestyle','-','LineWidth',0.5)                                                                     
                        elseif isstruct(colorCode_jitter)
                            try
                                line([x_axes(i,ii) x_axes(i,ii+1)],...
                                [mat(i,ii) mat(i,ii+1)],'Color',colorCode_jitter.noChange,'linestyle','-','LineWidth',0.5)     
                            catch
                                line([x_axes(i,ii) x_axes(i,ii+1)],...
                                [mat(i,ii) mat(i,ii+1)],'Color',[.8 .8 .8],'linestyle','-','LineWidth',0.5)     
                                %disp('Values that did not change between conditions are defaulted to grey lines')                                    
                            end
                        end
                    end                            
                end                    

            end                  

        elseif exist('jitterIdx') && exist('colorCode_jitter')==0 % in the case where you want to control the color using an index (like plotting a specific color per rat)

            % use the same x-axis data from earlier
            for ii = 1:length(x_axes)
                x_axes_cat(:,ii) = vertcat(x_axes{ii}{:});
            end
            x_axes = [];
            x_axes = x_axes_cat; % rename

            for i = 1:size(mat,1)

                % make lines
                for ii = 1:2:size(mat,2) % skip every other column (col1 vs col2 col3vs col4 col5vscol6 etc...)
                    line([x_axes(i,ii) x_axes(i,ii+1)],...
                    [mat(i,ii) mat(i,ii+1)],'Color',[0.8 0.8 0.8],'linestyle','-','LineWidth',0.5)
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
    

    % plot line - usually used for testing against some null
    if isempty('PlotLine') == 1
        line([xlim],...
        [PlotLine PlotLine],'Color',[0 0 0],'linestyle','--','LineWidth',2)
    end   

    % make font larger
    set(gca,'FontSize',20);  
end
