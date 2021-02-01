%% 
% this function takes a variable, normalizes it between 0 and 1, then sorts
% it based on a separate input. The output is a graph that is a heatplot,
% but sorted so that the max rate of each neuron is organized based on the
% column, or x-axis
%
% INPUTS
% x: a matrix that you want sorted. Should be formated with rows being cell
% number and columns being observation
% y: a matrix that you want to sort by. Same formatting as above
% plot_fig: set 1 if plot, 0 if no plot
% jetOn: set to 1 for jet color
%
% OUTPUTS:
% figure
% xsort: sorted x variable
%
% writen by John Stout

function [x_sort,idxsort] = SortedRateMap(x,y,smoothFactor,normData,plot_fig,jetOn)

% smooth the sorted variable
if isempty(smoothFactor) == 0
    for i = 1:size(x,1)
        x_smooth(i,:) = smoothdata(x(i,:),'gauss',smoothFactor);
        y_smooth(i,:) = smoothdata(y(i,:),'gauss',smoothFactor);   
    end
else
    x_smooth = x;
    y_smooth = y;
end

% normalize each row between 0 and 1
numcells = size(x,1);
numbins  = size(x,2);

if contains(normData,'y')
    for celli = 1:numcells
        x_norm(celli,:) = normalize(x_smooth(celli,:),'range');
        y_norm(celli,:) = normalize(y_smooth(celli,:),'range');
       
        %{
        for bini = 1:numbins
            x_norm(celli,bini) = (x(celli,bini)-min(x(celli,:)))/...
                (max(x(celli,:))-min(x(celli,:)));   
            y_norm(celli,bini) = (y(celli,bini)-min(y(celli,:)))/...
                (max(y(celli,:))-min(y(celli,:)));           
        end
        %}
    end
    
else
    x_norm = x_smooth;
    y_norm = y_smooth;
end

% get indices to sort by
[maxval, idxmax]  = max(y_norm');
[matsort,idxsort] = sort(idxmax);

% use idxsort to sort the x_norm variable
x_sort = x_norm(idxsort,:);

% remove nan
%idxRem = find(isnan(x_sort(:,1))==1);
%x_sort(idxRem,:)=[];

% make figure
%figure('color','w');
if plot_fig == 1
    imagesc(x_sort);
    colormap default
    colorbar
    ylabel('Neuron ID')
    xlabel('Bin Number')
    %set(gca,'FontSize',13);
    if jetOn == 1
        colormap('jet')
    end
end

end