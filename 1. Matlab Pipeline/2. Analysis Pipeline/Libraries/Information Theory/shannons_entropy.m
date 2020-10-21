%% Shannons entropy
% Information is the amount of 'surprise' that a variable contains. The
% measurement is in bits.
%
% Variable formatting: 'binned_data' is a vector containing the data of
%                       interest
%                   
% written by John Stout
% edit 12/16/18, edit 10/15/2020, final edit 10/21/2020

function [entropy] = shannons_entropy(binned_data,nbins)

    % make sure data is a vector
    checkSize = size(binned_data);
    
    if isempty(find(checkSize == 1)) == 1
        error('Data must be a vector')
    end
    
    % generally, whats the probability of observing your variable?
    if exist('nbins')
        [counts] = hist(binned_data,nbins); % nbins can be defined by using estimate_nBins
    else
        [counts] = hist(binned_data);
    end
    
    % compute probability per bin
    prob = counts./sum(counts); 

    % take the log2 for bits. add eps to prevent taking log2 of zero
    log_var = log2(prob+eps);

    % multiply the log-prob by the prob
    log_prob = prob.*log_var;

    % sum the log-probability values
    entropy = -sum(log_prob);

    % get rid of cells that have NaNs (didn't fire)
    entropy(isnan(entropy))=0;

end