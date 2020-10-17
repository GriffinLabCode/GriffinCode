%% Benjamini-Hochberg alpha level correction using False Discovery Rate
% -- INPUTS -- %
% p: must be a vector** - a vector of p-values NOT ordered
% Q: false discovery percentage (decimal value): 
%       - Optional. Pre-set to 0.05
%
% -- OUTPUTS -- %
% new_alpha: updated alpha level that where each element corresponds to
%               your input elements from variable "p".
% survive_alpha: boolean logical variable that denotes which p-values
%                   survived bh correction
%
% written by John Stout using statisticshowto website

function [new_alpha,survive_alpha] = BenjaminiHochberg(p,Q)
% https://www.statisticshowto.com/benjamini-hochberg-procedure/

% 1) Put the individual p-values in ascending order
[sorted_p,idx_sort] = sort(p);

% 2) assign ranks to p-values. For example, the smallest p-value has a rank
% of 1, the second smallest has a rank of 2
rank_vals = 1:length(sorted_p);

% 3) Calculate each p-values critical value using: (i/m)Q where:
%   i = individual p-values rank
%   m = total number of tests
%   Q = false discovery rate (chosen by you)
if exist("Q") == 0 
    Q   = 0.05; % false discovery rate set to 0.05
end
i         = rank_vals; % ranked p-values
m         = length(p); % total number of observations
new_alpha = (i./m).*Q; % this is benjamini hochberg

% 4) Compare your original p-values to the critical B-H from step 3, find
% the largest p-value that is smaller than the critical value
survive_alpha = sorted_p < new_alpha; % boolean

% re-sort the data
[~,reSort] = sort(idx_sort);

% p-values that survived alpha are boolean
survive_alpha = survive_alpha(reSort);
new_alpha     = new_alpha(reSort); % this is the alpha that each p-value is compared to

end


