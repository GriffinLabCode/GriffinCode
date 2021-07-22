%% plotCurves
% this function will plot normal distribution curves using vectorized data
% stored in a cell array 
% 
% -- INPUTS -- %
% data: cell array of vectors
% xRange: vector of ranges for example: [-4:.1:4]
% colors: cell array of colors
% dataLabels: labels for data in cell array format
% distType: normal is default, but can take on any of the following 
%               https://www.mathworks.com/help/stats/fitdist.html#btu538h-distname
%
% written by John Stout using MATLABs website

function [] = plotCurves(data,xRange,colors,dataLabels,distType)

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

% make fig
figure('Color','w'); hold on;
for i = 1:length(data)
    line(xRange,y{i},'Color',colors{i},'LineWidth',2);
end
legend(dataLabels);




