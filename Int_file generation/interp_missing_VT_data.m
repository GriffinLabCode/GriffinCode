%% Interpolate missing x and y data
% This function takes video tracking data that has video tracking errors
% and interpolates missing data points.
%
% INPUTS: VT_data: a struct array containing all VT1 data
%                   VT_data = load(strcat(datafolder,'\VT1.mat'))
%
% OUTPUTS: ExtractedX - a 1xN vector that is the same size as orig
%          ExtractedY - a 1xN vector that is the same size as orig
%
%
% thanks to this guy -> https://www.mathworks.com/matlabcentral/answers/
%                       375459-can-the-fillmissing-function-be-used-
%                       earlier-than-2016b-if-not-how-can-i-use-spline-
%                       interpolatio
%
% last edit 1/17/18 by John Stout

function [ExtractedX, ExtractedY] = interp_missing_VT_data(VT_data)

% fill in missing data with NaNs
y_data = VT_data.ExtractedY;
y_data(y_data == 0) = NaN;
x_data = VT_data.ExtractedX;
x_data(x_data == 0) = NaN;

% account for times when the very first coordinate point is zero - if the
% time of missing data exceeds 1 second (arbitrary), find same size data
% from the points immediately following the empty data points and assume
% the animal was doing something similar. 30 is sampling rate per sec - so
% half of a second is a pretty g
if isnan(y_data(1:15))
    % find first non nan value
    first_nonnan = find(~isnan(y_data),1);
    % find value preceeding it
    size_nans = first_nonnan-1;
    % extract data of equal size from recorded points
    sample_ydata = y_data(first_nonnan:first_nonnan+size_nans-1);
    % fill in sampled data points
    y_data(1:first_nonnan-1)=0;
    y_data(1:size_nans)=sample_ydata;
end

if isnan(x_data(1:15))
    % find first non nan value
    first_nonnan = find(~isnan(x_data),1);
    % find value preceeding it
    size_nans = first_nonnan-1;
    % extract data of equal size from recorded points
    sample_xdata = x_data(first_nonnan:first_nonnan+size_nans-1);
    % fill in sampled data points
    x_data(1:first_nonnan-1)=0;
    x_data(1:size_nans)=sample_ydata;
end

% grab integer indices of y_data to input to spline - find where NaNs are
y  = 1:length(y_data);
x  = 1:length(x_data);
m  = isnan(y_data);
m2 = isnan(x_data);

% query the spline interpolator
s  = spline(y(~m),y_data(~m),y(m));
s2 = spline(x(~m2),x_data(~m2),x(m2));

% replace NaN values with interpolated values; plot to see results
y_data(m)  = round(s);
x_data(m2) = round(s2);

% in keeping with how variables are typically defined
ExtractedY = y_data;
ExtractedX = x_data;

%figure(); plot(x_data,y_data);
