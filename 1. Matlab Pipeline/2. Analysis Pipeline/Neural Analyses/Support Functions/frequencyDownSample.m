%% down sample frequency and spectral data to plot out a freq x spec plot
%
% code was designed to provide an index output so that the user can
% downsample their spectral data using a different frequency range
%
% -- INPUTS -- %
% f: frequency array to downsample
% f2use: frequency array to match
% -- OUTPUTS -- %
% fKeep: index of frequencies to keep - use to downsample your spectral
% estimates
%
% written by John Stout

function [fKeep] = frequencyDownSample(f,f2use)

% get a size to down sample frequencies to
downSize = length(f2use);

% down sample S variable (spectral analysis input)
fKeep = dsearchn(f',f2use');

end
