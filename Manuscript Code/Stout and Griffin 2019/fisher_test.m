%% fisher_test
%
% this script runs a fishers exact test to test the null hypothesis that
% there are no nonrandom associates between two categorial variables (good
% vs poor) in x, against the alternative that there is a nonrandom
% association. Uses built in fisher_test function
%
% INPUTS: sample1 and sample2: both are Nx1 vectors containing testing data
%         as 1s or 0s
%
% OUTPUTS: fisher_p: p-value from fishertest
%          table_var: a table showing the data being compared
%
% written by John Stout


function [fisher_p,table_var] = fisher_test(sample1,sample2)

% first sample
sample1_hit = size(find(sample1 == 1),1);
sample1_miss = size(find(sample1 == 0),1);

% second sample
sample2_hit = size(find(sample2 == 1),1);
sample2_miss = size(find(sample2 == 0),1);

% make x
table_var = table([sample1_hit;sample1_miss],[sample2_hit;sample2_miss],...
    'VariableNames',{'good','poor'},'RowNames',{'hit','miss'});

% fisher test
[h,fisher_p] = fishertest(table_var);

end

