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
[sorted_p,idx_sort] = sort(p,'ascend');

% 2) assign ranks to p-values. For example, the smallest p-value has a rank
% of 1, the second smallest has a rank of 2
rank_vals = 1:length(sorted_p);

% 3) Calculate each p-values critical value using: (i/m)Q where:
%   i = individual p-values rank
%   m = total number of tests
%   Q = false discovery rate (chosen by you)

if exist("Q") == 0 
    %N = length(rank_vals);
    %Q = (sorted_p*N)/rank_vals;    
    Q   = 0.05; % false discovery rate set to 0.05
end
i         = rank_vals; % ranked p-values
m         = length(p); % total number of observations
new_alpha = (i./m).*Q; % this is benjamini hochberg

% 4) Compare your original p-values to the critical B-H from step 3, find
% the largest p-value that is smaller than the critical value
survive_temp    = find(sorted_p < new_alpha); % boolean
largestPsurvive = max(survive_temp);
new_alpha       = sorted_p(largestPsurvive);

% all values lower than the new alpha, plus the smallest significant is
% significant
survive = sorted_p < new_alpha;
survive(largestPsurvive) = 1;

% re-sort the data
%[~,reSort] = sort(idx_sort);
origOrder = dsearchn(sorted_p',p');

% p-values that survived alpha are boolean
survive_alpha = survive(origOrder);
orig_p        = sorted_p(origOrder); % this is the alpha that each p-value is compared to

%{
% correct p-values using multiplication. This is essentially the way
% Bonferroni method works. Since alpha levels are varying, reSort reflects
% the order (from max to least) in p-values. Multiple the p-values by
% whether they have the greatest or least alpha levels
[p_desc,~] = sort(p,'descend');
revOrder = (dsearchn(p_desc',p'))';

% multiply the least p value by the smallest number, the greatest by the
% greatest number
p_cor = p.*revOrder;
%}

