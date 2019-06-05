%% get_classifier_inputs
%
% this function is used to both consolidate space in other functions/
% scripts and to store all classifier input parameters
%
% OUTPUT: input - a struct array containing parameters for classification
%
% written by John Stout

function [input]=get_classifier_inputs() 

    % psuedosimultaneous or within rat?
    input.withinRat_design   = 0;
    input.pseudosimultaneous = 1;
   
    % ~~~ IGNORE if not using compare_classifier iteration ~~~ %
        % select which code to run
        input.startbox_taskphase_binned = 1;
        input.control_trajectory        = 0; % delay l vs iti l, delay r vs iti r
        input.startbox_context          = 0;  
        input.taskphase_maze            = 0;
        input.multiclass_maze_segment   = 0;

        % for binned classifiers, do you want to make time bins, comparing
        % delay sec 1 to iti sec 1:2? 
        input.equal_bins_delayITI = 0;
    
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
    input.standardize_across_vars = 0;
    input.standardize_within_var  = 1;
    input.standardize = 1;
    
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
    if input.withinRat_design == 1
        if input.mPFC_good == 1
            input.rat{1} = 3:14;  % baby groot
            input.rat{2} = 15:19; % capn
            input.rat{3} = 20:27; % groot
            input.rat{4} = 28:35; % meusli
            input.rat{5} = 36:47; % thanos
            input.rat_names = char({'baby groot','capn crunch','groot'...
                ,'meusli','thanos'});
        elseif input.OFC == 1
            input.rat{1} = 3:11;  % baby groot
            input.rat{2} = 12:21; % meusli
            input.rat_names = char({'baby groot','meusli'});
        elseif input.Prelimbic == 1
            input.rat{1} = 3:14;  % baby groot
            input.rat{2} = 15:18; % capn
            input.rat{3} = 19:23; % groot
            input.rat{4} = 24:31; % meusli
            input.rat{5} = 32:39; % thanos
            input.rat_names = char({'baby groot','capn crunch','groot',...
                'meusli','thanos'});
        elseif input.AnteriorCingulate == 1
            input.rat{1} = 3:4; % capn
            input.rat{2} = 5:11; % groot
            input.rat{3} = 12:19; % thanos
            input.rat_names = char({'capn crunch','groot','thanos'});
        elseif input.VentralOrbital == 1
            input.rat{1} = 3:9;
            input.rat{2} = 10:19;
        elseif input.mPFC_poor == 1
            input.rat{1} = 3:5; % capn
            input.rat{2} = 6:7; % groot
            input.rat{3} = 8:9; % Meusli
            input.rat{4} = 10;  % thanos
        end
    elseif input.pseudosimultaneous == 1
        if input.mPFC_good == 1
            input.rat{1} = 3:47;
        elseif input.OFC == 1
            input.rat{1} = 3:21;
        elseif input.Prelimbic == 1
            input.rat{1} = 3:39;
        elseif input.AnteriorCingulate == 1
            input.rat{1} = 3:19;
        elseif input.VentralOrbital == 1
            input.rat{1} = 3:19;
        elseif input.mPFC_poor == 1
            input.rat{1} = 3:10;
        end
    end
end