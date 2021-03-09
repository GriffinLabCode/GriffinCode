%% cohens d
% calculates effect size using cohens D
%d = (M2 - M1) ? ?((SD1^2 + SD2^2)/ 2)
%
% written by John Stout using https://www.socscistatistics.com/effectsize/default3.aspx

function [d] = cohensD(x,y)

    d = (nanmean(y) - nanmean(x)) / sqrt(((nanstd(x)^2) + (nanstd(y)^2))/2);

end