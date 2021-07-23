%% plotCurves
% this function will plot normal distribution curves using vectorized data
% stored in a cell array. THis is an alternative to the bulky bar
% histograms
% 
% -- INPUTS -- %
% data: cell array of vectors
% xRange: vector of ranges for example: [-4:.1:4]
% colors: cell array of colors
% dataLabels: labels for data in cell array format
% distType: normal is default, but can take on any of the following 
%               https://www.mathworks.com/help/stats/fitdist.html#btu538h-distname
%
% -- OUTPUTS -- %
% l: simple line histogram. Output is a cell array where each array
%       corresponds to your data inputs. You can further modify your graph
%       through accessing it like so: l{1}.FaceColor or etc...
% a: same for line, but for the area figure
%
% written by John Stout using MATLABs website

function [l,a] = plotCurves(data,xRange,colors,dataLabels,distType)

pd = [];
for i = 1:length(data)
    % make sure orientation is correct
    data{i} = change_row_to_column(data{i});
    % fit distributions
    if exist('distType')==0
        pd{i} = fitdist(data{i},'Normal');
    else
        pd{i} = fitdist(data{i},distType);
    end
    % find minima and maxima for all variables
    minimums(i) = min(data{i});
    maximums(i) = max(data{i});
end
% haven't figured out how to automate this
%x_pdf = [min(minimums):.1:max(maximums)];

y = [];
for i = 1:length(data)
    y{i} = pdf(pd{i},xRange);
end

% make figs
figure('Color','w'); hold on;
for i = 1:length(data)
    l{i} = line(xRange,y{i},'Color',colors{i},'LineWidth',2);
end
legend(dataLabels);

figure('color','w'); hold on;
for i = 1:length(data)
    a{i} = area(xRange,y{i});
    a{i}.FaceColor = colors{i};
    a{i}.EdgeColor = 'k';
    a{i}.LineWidth = 0.1;
    a{i}.FaceAlpha = 0.5;
end
legend(dataLabels);

    


