%% get_classifier_inputs
%
% this function is used to both consolidate space in other functions/
% scripts and to store all classifier input parameters
%
% OUTPUT: input - a struct array containing parameters for classification
%
% written by John Stout

function [input]=get_classifier_inputs() 
    
    % region
    input.mPFC_good = 0;
    input.mPFC_poor = 0;
    input.OFC       = 0;
 
    % sub-region
    input.Prelimbic         = 1;    
    input.AnteriorCingulate = 0;
    input.MedialOrbital     = 0;
    input.VentralOrbital    = 0;
    input.noradrenergic     = 0; % set this to 1 with VO if nor
       
    % plot?
    input.plot = 0;
    
    % This is outdated
    input.swap_labels = 0;
    
    % some other stuff
    input.correct           = 0; % not functional for classification
    input.incorrect         = 0; % not functional for classification
    input.notperfectsess    = 0;
    
    % standardize?
    input.zscore = 1;
    
    % subsample?
    input.subsample         = 0; % go into function and change how much to subsample
     input.n_samples        = 60; % samples to subsample to
    % don't change if you only want one iteration
    input.n_iterations      = 1; % set this to 1 for default - change if want more subs.
    
    % filter? not sure if this works 
    input.hz_filter = 0;
    
    % Time bins for startbox
    input.delay_bin         = 10; % this is for the binned startbox script - you can change this
    input.tjunct_bin        = 10; % do not change this
    
    % for maze classification
    input.rec_room = 1;
    input.numbins  = 7;
    
end
