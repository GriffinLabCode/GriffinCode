%% linearPosition_binData
%
% this function bins data per each linear position bin. Data will be
% structured in 1xN where N is the number of data points and each element
% corresponds to the data of interest. For example, if you had
% instantaneous spikes, where each element corresponds to spike counts
% across time, then your output variable 'dataBinned' will be number of
% spikes per linear position bin.
%
% -- INPUTS -- %
% data: vector of data
% linearPosition: vector of linear position - this needs to be the same
%                   size as data
% total_dist: total distance traveled (total theoretical distance), so if
%               you set linear bins to 300, and you have 299, enter 300
%
% -- OUTPUTS -- %
% dataBinned: data binned according to linear position. This is
%               additionally spline interpolated to handle any missing bins
%
% written by John Stout

function [dataOut] = linearPosition_binData(data,linearPosition,total_dist)

% get data per bin
dataBinned = cell([1 total_dist]); 
for i = 1:total_dist % loop across the number of bins
    dataBinned{i} = data(linearPosition == i);
end

% take average
speedBinnedAvg = cellfun(@mean,dataBinned);

% do interpolation to handle NaNs
xLabel = linspace(0,total_dist,total_dist);
badElements = isnan(speedBinnedAvg);
newY = speedBinnedAvg(~badElements);
newX = xLabel(~badElements);
xq   = xLabel;
dataInterp = interp1(newX, newY, xq, 'spline');

% organize output
dataOut = dataInterp;



