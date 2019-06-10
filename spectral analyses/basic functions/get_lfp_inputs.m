%% get_entrainment_inputs
%
% this function is used to both consolidate space in other functions/
% scripts and to store all classifier input parameters
%
% OUTPUT: input - a struct array containing parameters for classification
%
% written by John Stout

function [input]=get_lfp_inputs() 
    
    % region
    input.mPFC_good = 0;
    input.mPFC_poor = 0;
    input.OFC       = 0;
 
    % sub-region
    input.Prelimbic         = 0;    
    input.AnteriorCingulate = 1;
    input.MedialOrbital     = 0;
    input.VentralOrbital    = 0;
    
    % what function do you want to use?
    input.delay = 1;
        % do you want to examine the last few sec before stem entry?
        input.delay_components = 1;
        % define the time bin before stem entry (value will be in seconds)
        input.timing = 5;
    input.iti   = 0;
        input.iti_components = 0;
    input.choice_stem = 0;
    input.sample_stem = 0;
    input.choice_T = 0;
    input.sample_T = 0;
    
    % is behavior relevant?
    input.correct        = 1;
    input.incorrect      = 0;
    input.notperfectsess = 0;
    
    % phase bandpass
    input.phase_bandpass = [0 100];
    
    % plot after every iteration? Highly not recommended
    input.plot = 0;

end