%% Freedman-Dianconis
%
% This function utilizes a statistical estimate for the number of bins to
% use for calculations of entropy
%
% -- INPUTS -- %
% position: a double array containing either linear position or binned
%               position data. If you're not using linear position, you
%               should only consider 1 dimension of motion (ie stem
%               running or something). Linear position is better suited for
%               this analysis.
%
% -- OUTPUTS -- %
% nbins: freedman diaconis bin count
%
% Written by John Stout
% edit on 12/11/18, 10/15/2020

function [nbins] = freedman_diaconis(data)
            
    % Freedman-Diaconis rule to statistically estimate number of bins
    nbins = ceil((max(data)-min(data))/(2*(iqr(data))*(length(data)^(-1/3))));
        
end