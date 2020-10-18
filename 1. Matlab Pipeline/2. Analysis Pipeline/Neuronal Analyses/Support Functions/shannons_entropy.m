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
% edit 12/16/18, edit 10/15/2020, INCOMPLETE - Probability issue

function [entropy] = shannons_entropy(binned_data)

    % make sure data is a vector
    checkSize = size(binned_data);
    
    if isempty(find(checkSize == 1)) == 1
        error('Data must be a vector')
    end
    
    % generally, whats the probability of observing a spike?
    prob = binned_data./sum(binned_data); 
    
    % this cant be true - shannon entropy values too high
    % probability of observing 1 spk, given the distribution of spks
    %prob = poisspdf(1,binned_data); % probability of observing a spk per position. If 1 is most common amount to observe, then it should be found here
    
    % assuming a poisson distribution, calculate the average spike across
    % the distribution. Then ask what the probability of observing one
    % spike is
    %prob2 = poisspdf(binned_data2,mean(binned_data2))

    %pd = makedist('Poisson');
    %y  = pdf(pd,binned_data);

    % take the log2 for bits. add eps to prevent taking log2 of zero
    log_var = log2(prob+eps);

    % multiply the log-prob by the prob
    log_prob = prob.*log_var;

    % sum the log-probability values
    entropy = (sum(log_prob))*-1;

    % get rid of cells that have NaNs (didn't fire)
    entropy(isnan(entropy))=0;

end