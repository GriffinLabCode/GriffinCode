%% get_entrainment_inputs
%
% this function is used to both consolidate space in other functions/
% scripts and to store all classifier input parameters
%
% OUTPUT: input - a struct array containing parameters for classification
%
% written by John Stout

function [input]=get_power_inputs() 
    
    % region
    input.mPFC_good = 1;
    input.mPFC_poor = 0;
    input.OFC       = 0;
 
    % sub-region
    input.Prelimbic         = 0;    
    input.AnteriorCingulate = 0;
    input.MedialOrbital     = 0;
    input.VentralOrbital    = 0;
    
    % specgram or freq plot?
    input.specgram = 1;
    input.freqplot = 0;
    
    % simultaneous recordings?
    input.simultaneous = 0;
    
    %
    input.Tjunction = 0;
    input.Tentry_longepoch = 1; % this tells get_power_data which int file to choose, you need to manually change power_fun time
    % VERY important - you can only have two of these set to one at a
    % single time.
    input.pow_pfc = 0;
    input.pow_hpc = 1;
    % if you select 1 here, select all_sites = 1 below. No Re recordings
    % occured without HPC or mPFC recordings.
    input.pow_re  = 0; 
    input.pow_hpc_HpcPfc_sessions = 1; % set this to 1 with pow_hpc to get sessions that pfc-hpc coherence were analyzed from
    
    % only analyze sessions with all three sites? 1 for yes, 0 for no
    % if analyzing Re, make sure you select this
    input.all_sites =0;
    
    % phase bandpass
    input.phase_bandpass = [0 100];
    
    % plot after every iteration? Highly not recommended
    input.plot = 0;

end