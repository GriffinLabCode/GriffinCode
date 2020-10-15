%% Shannons entropy
% prob for bin 1 = (bin count/sum of all bin count)
% log_val for bin 1 = prob*logbase2
% probability-log-probability for bin 1 = prob*log_val
% sum the probability-log-probability values and *-1
%
% Variable formatting: 'binned_spks' is a cell array containing doubles for
%                           each element. The doubles represent a spk count
%                           across the entire session for a given bin. For
%                           example if there are 7 bins and binned_spks{1}
%                           = [21 1 17 18 9 8 1] then 21 represents 21
%                           total spks across the session for bin 1.
%
%                      'clusters' is a Nx1 struct containing the names of
%                      all clusters in the session                     
%
% written by John Stout
% edit 12/16/18, edit 10/15/2020

function [entropy] = shannons_entropy(binned_spks)

    % convert your data to probability values
    prob = binned_spks./sum(binned_spks);   

    % take the log2 for bits. add eps to prevent taking log2 of zero
    log_var = log2(prob+eps);

    % multiply the log-prob by the prob
    log_prob = prob.*log_var;

    % sum the log-probability values
    entropy = (sum(log_prob))*-1;

    % get rid of cells that have NaNs (didn't fire)
    entropy(isnan(entropy))=0;

end