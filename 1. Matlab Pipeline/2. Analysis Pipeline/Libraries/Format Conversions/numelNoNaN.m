%% 
% this function generates the counts of some variable while excluded nan
% values
function [L] = numelNoNaN(x)
    L = numel(x(~isnan(x)));
end