%% bic_optimalorder
%
% this method was taken from MxC chapter 28 with outputs nearly matching to
% the use of the armorf function for BIC estimation
%
% If you set the order runs to 100, in other words, running the analysis on
% 100 different model orders, this code will begin examining model orders
% after 10 runs, and if the lowest BIC estimate is less than the current
% loop, it ends the loop. In other words, it will not always run 100 runs,
% it will run as many as necessary (up to 100) to get the lowest model 
% order.
%
% -- INPUTS -- %
% signal1: lfp 1 vector
% signal2: lfp 2 vector
% srate:   sampling rate
% orderRuns: number of runs to estimate BIC (try 100)
%
% -- OUTPUTS -- %
% optimal_order: the model order that corresponds to the lowest BIC
%
% written by John Stout

function [optimalorder,bic_val] = bic_optimalorder(signal1,signal2,srate,orderRuns)

if orderRuns < 10
    orderRuns = 10;
    disp('Do not do less than 10 orderRuns - corrected')
end

for orderi = 1:orderRuns
    % run GCspectral to get model errors
    [~, ~, ~, E1, E2] = GCspectral(signal1, signal2, orderi, srate);
    % calculate the covariance of errors from x2y and y2x regressions
    E=cov(E1,E2);  
    % num data points
    nPoints = length(signal1);
    % calculate bic
    bic(orderi) = log(det(E)) + (log(nPoints)*orderi*2^2)/nPoints;
    % disp
    disp(['order ',num2str(orderi)])
    % get temporary average
    [bic_val,optimalorder] = min(mean(bic,1)); 
    % stop loop if optimal order is less than the loop length as long as
    % you've done at least 10
    if orderi > 10
        if optimalorder < orderi
            return
        end
    end
end

