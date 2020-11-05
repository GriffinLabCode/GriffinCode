%% linear position extension
% this code is designed to extend your linear bins to fit lfp timestamps
%
% -- INPUTS -- %
% linearPosition: linear position bins using vt timestamps
% linearBinRange: range of linear bins [1 200] is an example
% numLFPsamples: number of lfp samples or lfp time samples (same thing)
%
% -- OUTPUTS -- %
% linearPosExtended: interpolated position bins using lfp as a backbone
%
% written by John Stout

function [linearPosExtended] = extendLinearPosition(linearPosition,linearBinRange,numLFPsamples)
    % linspace from start of linear bin to end of linear bins, to the size
    % of number of lfp samples
    extendedBins = linspace(linearBinRange(1),linearBinRange(end),numLFPsamples);
    
    % create an x axis data variable
    xData = linspace(linearBinRange(1),linearBinRange(end),length(linearPosition));
    
    % interpolate data
    linearPosExtended = interp1(xData,linearPosition,extendedBins,'spline');
end