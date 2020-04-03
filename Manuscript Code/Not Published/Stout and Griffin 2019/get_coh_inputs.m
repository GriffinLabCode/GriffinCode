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
    input.Tjunction = 0; % set to zero if say you want the stem
    
        % if you've selected input.Tjunction = 1, select which epoch
        input.T_entry  = 0; % 1 sec surrounding t entry
        input.T_before = 0; % 1 sec before t entry 
        input.T_after  = 0; % 1 sec after t entry   
  
    input.simultaneous     = 1; % triple site simultaneous recordings?       
    input.T_entry_minus2   = 0; % minus two seconds
    input.Tentry_longepoch = 0; % this is -2 to 1 sec after T
    input.T_DataDriven     = 1; % this is -0.8 to 0.2 based on pfc-hpc coherence data
    input.T_beforeEffect   = 0; % this is -2 sec to -1 sec before Tentry

    input.tjunction_bin = 0; % tjunction bin
    input.stem_bin      = 0; % stem bin
     
    % use the coherence_chronux function or coherence_firingrates? 1 for
    % chronux. Use this function for controlling for time
    input.coh_time = 1;
    
    % do you want a time-frequency plot or a broad-band spectrum?
    input.time_freq = 0; % 1 is a time-frequency plot for heatmap creation
    
    % VERY important - you can only have two of these set to one at a
    % single time.
    % For spike field coherence, you can only define one of these at a time
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