%% Shannons entropy
% prob for bin 1 = (bin count/sum of all bin count)
% log_val for bin 1 = prob*logbase2
% probability-log-probability for bin 1 = prob*log_val
% sum the probability-log-probability values and *-1
%
% Variable formatting: 'binned_data' is a vector containing the data of
%                       interest
%
%                      'clusters' is a Nx1 struct containing the names of
%                      all clusters in the session                     
%
% written by John Stout
% edit 12/16/18, edit 10/15/2020

function [entropy] = shannons_entropy(binned_data)

    % make sure data is a vector
    checkSize = size(binned_data);
    
    if isempty(find(checkSize == 1)) == 1
        error('Data must be a vector')
    end
    
    % convert your data to probability values
    prob = binned_data./sum(binned_data);   

    % take the log2 for bits. add eps to prevent taking log2 of zero
    log_var = log2(prob+eps);

    % multiply the log-prob by the prob
    log_prob = prob.*log_var;

    % sum the log-probability values
    entropy = (sum(log_prob))*-1;

    % get rid of cells that have NaNs (didn't fire)
    entropy(isnan(entropy))=0;

end