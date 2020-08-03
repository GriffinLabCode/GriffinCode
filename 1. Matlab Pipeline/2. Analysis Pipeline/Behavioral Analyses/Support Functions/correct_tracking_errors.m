%% Correct for tracking-errors
% this function corrects for non-missing tracking error data - the tracking
% error will not be zero valued
%
% in some cases, the output may have exaggerated lines deriving from the
% bowl. Since we don't analyze position data while in the sleep bowl, it
% wasn't a problem for me. Future iterations should address this.
%
% NOTE - This function should be used after interp_missing_VT_data
%
% INPUTS: ExtractedX and ExtractedY data thats already been 
%
%
% Written by John Stout (mostly)
%
% thanks to this guy -> https://www.mathworks.com/matlabcentral/answers/
%                       375459-can-the-fillmissing-function-be-used-
%                       earlier-than-2016b-if-not-how-can-i-use-spline-
%                       interpolatio

function [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder)

% load video tracking data
cd(datafolder);
VT_data = load('VT1.mat');

% correct for tracking errors that result in zeroes
[ExtractedX, ExtractedY] = interp_missing_VT_data(VT_data);

% calculate distance
for i = 1:numel(ExtractedX)-1
    dist(i) = sqrt(((ExtractedX(i+1)-ExtractedX(i))^2)+...
        ((ExtractedY(i+1)-ExtractedY(i))^2));
end

% find zscore
z_dist = zscore(dist);

% find periods when distance is larger than normal - set equal to NaN
dist(z_dist >= 3) = NaN;

% map the NaNs onto X and Y data
X = ExtractedX; Y = ExtractedY;
dist = horzcat(dist,0); % zero pad
X(find(isnan(dist)))=NaN;
Y(find(isnan(dist)))=NaN;

% find NaNs, fill in data immediately surrounding the NaNs with NaNs
for i = find(isnan(X))
    if i == 1
        % find first non nan value
        first_nonnan = find(~isnan(X),1);
        X(i) = X(first_nonnan);
    else
        X(i+1)=NaN;
        X(i-1)=NaN;
    end
end

for ii = find(isnan(Y))
    if ii == 1
        % find first non nan value
        first_nonnan = find(~isnan(Y),1);
        Y(ii) = Y(first_nonnan);
    else
        Y(ii+1)=NaN;
        Y(ii-1)=NaN;
    end
end

% grab integer indices of Y to input to spline - find where NaNs are
y  = 1:length(Y);
x  = 1:length(X);
m  = isnan(Y);
m2 = isnan(X);

% query the spline interpolator
s  = spline(y(~m),Y(~m),y(m));
s2 = spline(x(~m2),X(~m2),x(m2));

% replace NaN values with interpolated values; plot to see results
Y(m)  = round(s);
X(m2) = round(s2);

% in keeping with how variables are typically defined
ExtractedX = []; ExtractedY = [];
ExtractedY = Y;
ExtractedX = X;  

end