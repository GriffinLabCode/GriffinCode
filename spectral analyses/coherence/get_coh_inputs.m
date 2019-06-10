%% get_entrainment_inputs
%
% this function is used to both consolidate space in other functions/
% scripts and to store all classifier input parameters
%
% OUTPUT: input - a struct array containing parameters for classification
%
% written by John Stout

function [input]=get_coh_inputs() 
    
    % region
    input.mPFC_good = 0;
    input.mPFC_poor = 0;
    input.OFC       = 0;
 
    % sub-region
    input.Prelimbic         = 1;    
    input.AnteriorCingulate = 0;
    input.MedialOrbital     = 0;
    input.VentralOrbital    = 0;
    
    % phase bandpass
    input.phase_bandpass = [0 100];
    
    % plot after every iteration? Highly not recommended
    input.plot = 0;

end