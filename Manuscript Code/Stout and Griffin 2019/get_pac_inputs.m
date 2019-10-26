%% get_pac_inputs
%
% this function is used to both consolidate space in other functions/
% scripts and to store all classifier input parameters
%
% OUTPUT: input - a struct array containing parameters for classification
%
% written by John Stout

function [input]=get_pac_inputs() 
    
    % region
    input.mPFC_good = 1;
    input.mPFC_poor = 0;
    input.OFC       = 0;
 
    % sub-region
    input.Prelimbic         = 0;    
    input.AnteriorCingulate = 0;
    input.MedialOrbital     = 0;
    input.VentralOrbital    = 0;
    
    % VERY important - you can only have two of these set to one at a
    % single time.
    input.pfc = 0;
    input.hpc = 1;
    % if you select 1 here, select all_sites = 1 below. No Re recordings
    % occured without HPC or mPFC recordings.
    input.re  = 1; 
    
    % only analyze sessions with all three sites? 1 for yes, 0 for no
    % if analyzing Re, make sure you select this
    input.all_sites = 0;
    
    % define which signals phase you're interested in
    input.hpc_phase = 0;
    input.pfc_phase = 0;
    input.re_phase  = 1;
    % define which signals amplitude you're interested in
    input.hpc_amp = 0;
    input.pfc_amp = 1;
    input.re_amp  = 0;
    
    % define bandpass for amplitude and phase
    input.phase_bandpass     = [7 9];
    input.amplitude_bandpass = [30 50];

    % modulation index or comodulogram?
    input.modindex  = 1;
    input.comodgram = 0;
    
    % maze time index
    input.T_entry  = 1;
    input.T_before = 0;
    input.T_after  = 0;
    
end