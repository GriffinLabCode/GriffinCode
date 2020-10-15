%% spatial coverage
% the fraction of area above 25% of the peak firing rate, Peak must be over
% 3Hz

function [spatialCoverage] = spatial_coverage(rateMap)

% find peak rate
peakRate = max(rateMap);

% find threshold
threshold = peakRate*.25;

% get index of observations greater than threshold
aboveThreshIdx = find(rateMap > threshold);

% number of events > threshold
numAboveThresh = length(aboveThreshIdx);

% number of total bins
numBins = length(rateMap);

% calculate spatial coverage
spatialCoverage = numAboveThresh/numBins;

end

