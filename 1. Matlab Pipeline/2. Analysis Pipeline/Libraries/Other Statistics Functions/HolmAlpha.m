%% Holm alpha level correction
% -- INPUTS -- %
% p: must be a vector** - a vector of p-values NOT ordered
%
% -- OUTPUTS -- %
% h: boolean. Tells you which of your inputs are significant
% holm_alpha: alpha level to compare you p values against
%
% written by John Stout using http://www.pelagicos.net/BIOL4090_6090/lectures/Biol4090_6090_Fa18_Lecture21_revised.pdf

function [h,holm_alpha] = HolmAlpha(p)
% https://www.statisticshowto.com/benjamini-hochberg-procedure/

% 1) Put the individual p-values in ascending order
[sorted_p,idx_sort] = sort(p,'descend');

% 2) divide .05 by number of obs, in order
numPs = numel(p);
for i = 1:numPs
    holm_alpha(i) = .05/i;
end

% 3) check if your p-value is less than holm_alpha
h = sorted_p < holm_alpha;

% 4) could multiply p -- THIS MAY BE WRONG - check it up
for i = 1:numPs
    % i think spss does a multiplication method
    p_cor(i) = p(i)*i;
    
    % reduce to 1 as p cant be greater
    if p_cor(i) > 1
        p_cor(i) = 1;
    end
end


