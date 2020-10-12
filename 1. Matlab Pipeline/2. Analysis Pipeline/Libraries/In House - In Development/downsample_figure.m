%% compress and save figure as .eps file
% this code is incomplete - JS


% define figure
fig      = figIn;

% define figure children, get x and y data in cell arrays
Children = cell([1 length(fig.Children)]);
xData    = cell([1 length(fig.Children)]);
yData    = cell([1 length(fig.Children)]);
for i = 1:length(fig.Children)
    % define children
    Children{i} = fig.Children(i).Children;
    % define x and y data
    xData{i} = get(Children{i}, 'XData');
    yData{i} = get(Children{i}, 'YData');
    % sometimes data is stored as double, sometimes as cell
    if iscell(xData{i})
        xData{i} = xData{i}{end};
        yData{i} = yData{i}{end};
    end
end

% when accessing children of a subplot, they are reversed. Therefore flip
% them back
xData = flipud(xData')';
yData = flipud(yData')';

% downsample data (cut in half)
idx2cut    = 3:4;
downFactor = 10; % downsample rate
for i = 1:length(idx2cut)
    idxCut   = 1:downFactor:length(xData{idx2cut}); % index to downsample
    xDataCut{i} = xData(idxCut); % downsampled
    yDataCut{i} = yData(idxCut);
end

figure('color','w')
for i = 1:length(fig.Children)
    subplot([num2str(length(fig.Children)),'1',num2str(i)])
    plot(xDataCut,yDataCut)
end
    
plot(xDataCut,yDataCut)
set(gcf,'Color','w')
print('-painters',[saveName,'.eps'],'-depsc','-r0')

