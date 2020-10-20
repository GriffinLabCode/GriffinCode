%% Freedman-Dianconis
%
% This function utilizes a statistical estimate for the number of bins to
% use for calculations of entropy
%
% -- INPUTS -- %
% data: data in vector format
% bin_method: 'freedman diaconis' or 'sturges'
%
% -- OUTPUTS -- %
% nbins: freedman diaconis or sturges bin count. FD should be used if you
%       are concerned with a ton of bins (like using lfp data)
%
% Written by John Stout
% edit on 12/11/18, 10/15/2020

function [nbins] = estimate_nBins(data,bin_method)

    if contains(bin_method,'Freedman-Diaconis')

        % Freedman-Diaconis rule to statistically estimate number of bins
        nbins = ceil((max(data)-min(data))/(2*(iqr(data))*(length(data)^(-1/3))));

    elseif contains(bin_method,'Sturges')
        
        if size(data,1) == 1 & size(data,2) == 1
            nbins = ceil(1+log2(data));
        else
            nbins = ceil(1+log2(length(data)));
        end
    end
