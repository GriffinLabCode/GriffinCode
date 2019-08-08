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
    input.mPFC_good = 1;
    input.mPFC_poor = 0;
    input.OFC       = 0;
 
    % sub-region
    input.Prelimbic         = 0;    
    input.AnteriorCingulate = 0;
    input.MedialOrbital     = 0;
    input.VentralOrbital    = 0;
    
    % do you want to analyze 1 second surrounding tjunction entry?
    input.Tjunction = 1;
    
        % if you've selected input.Tjunction = 1, select which epoch
        input.T_entry  = 0; % 1 sec surrounding t entry
        input.T_before = 0; % 1 sec before t entry 
        input.T_after  = 1; % 1 sec after t entry    
    
    % do you want a time-frequency plot or a broad-band spectrum?
    input.time_freq = 0; % 1 is a time-frequency plot for heatmap creation
    
    % VERY important - you can only have two of these set to one at a
    % single time.
    input.coh_pfc = 0;
    input.coh_hpc = 1;
    % if you select 1 here, select all_sites = 1 below. No Re recordings
    % occured without HPC or mPFC recordings.
    input.coh_re  = 1; 
    
    % only analyze sessions with all three sites? 1 for yes, 0 for no
    % if analyzing Re, make sure you select this
    input.all_sites = 0; % keep this at 0 if examining tjunction
    
    % phase bandpass
    input.phase_bandpass = [0 100];
    
    % plot after every iteration? Highly not recommended
    input.plot = 0;

end