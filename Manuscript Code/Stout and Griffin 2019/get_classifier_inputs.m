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
    input.OFC       = 1;
 
    % sub-region
    input.Prelimbic         = 0;    
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
    
    % filter?
    input.hz_filter = 0;
    
    % Time bins for startbox
    input.delay_bin         = 10; % this is for the binned startbox script - you can change this
    input.tjunct_bin        = 10; % do not change this
    
    % for maze classification
    input.rec_room = 1;
    input.numbins  = 7;
    
    %% IGNORE THIS UNLESS YOU ADD ANIMALS 
    % format rat variable - this tells the functions which sessions are from
    % which rats
    if input.mPFC_good == 1
        input.rat{1} = 3:47;
    elseif input.OFC == 1
        input.rat{1} = 3:21;
    elseif input.Prelimbic == 1
        input.rat{1} = 3:38;
    elseif input.AnteriorCingulate == 1
        input.rat{1} = 3:19;
    elseif input.VentralOrbital == 1
        input.rat{1} = 3:19;
    elseif input.mPFC_poor == 1
        input.rat{1} = 3:10;
end
