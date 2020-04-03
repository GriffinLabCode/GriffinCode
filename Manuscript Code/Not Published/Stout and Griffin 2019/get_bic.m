%% get_bic
%
% this function uses armorf.mat function from the bsmart toolbox to
% estimate bayesian information criterion for granger analysis. I got this
% code from chapter28 of MxC Analyzing neural time series data code. 
%
% INPUTS:
% data: 2xN (N observations)
% nr: number of realizations (number of trials)
% nl: length of those realizations (timepoints)
% maxorder: scalar indicating the maximum order to go up to

function [bic]=get_bic(data,nr,nl,maxorder)

    % Estimate BIC
    for bici=1:maxorder
        % run model
        [Axy,E] = armorf(data,nr,nl,bici);
        % compute Bayes Information Criteria
        bic(bici) = log(det(E)) + (log(length(data))*bici*2^2)/length(data);
    end
    
end
