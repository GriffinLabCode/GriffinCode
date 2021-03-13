%% confidence interval
% this function uses the t-statistic to generate confidence intervals than
% finds those intervals that do not include 0. it returns an index of
% significant events
%
% -- INPUTS -- %
% x: vector of arrays 
% y: vector of arrays or a single value (like comparing against 0 or .5)
% alpha: alpha level - optional
%
% -- OUTPUTS -- %
% sig: a boolean variable - 1 if signficant
%
% written by john stout

function [sig,ci] = confInterval(x,y,alpha)
out = nargin;
if  out < 3
    % ttest
    [~,~,ci] = ttest(x,y);
else
    % ttest
    [~,~,ci] = ttest(x,y,'Alpha',alpha);
end

for i = 1:length(ci)
    % get full range of values
    rangeVal = linspace(ci(1,i),ci(2,i),100);
    % identify if 0 is included
    belowZero = find(rangeVal <= 0);
    aboveZero = find(rangeVal >= 0);
    % if either is empty, the finding is significant at your alpha
    if (isempty(belowZero) | isempty(aboveZero)) & ((isnan(ci(1,i)) | isnan(ci(2,i)))==0)
        sig(i) = 1;
    else
        sig(i) = 0;
    end
    
end