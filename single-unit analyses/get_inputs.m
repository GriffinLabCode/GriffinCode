%% get_classifier_inputs
%
% this function is used to both consolidate space in other functions/
% scripts and to store all classifier input parameters
%
% OUTPUT: input - a struct array containing parameters for classification
%
% written by John Stout

function [input]=get_inputs() 

    % psuedosimultaneous or within rat?
    input.withinRat_design   = 0;
    input.pseudosimultaneous = 1;
    
    % select which svm code to run
    input.startbox_taskphase_binned = 0;
    input.control_trajectory        = 0; % delay l vs iti l, delay r vs iti r
    input.startbox_context          = 0;  
    input.taskphase_maze            = 0;
    input.multiclass_maze_segment   = 0;
    
    % region
    input.mPFC_good = 0;
    input.mPFC_poor = 0;
    input.OFC       = 0;
 
    % sub-region
    input.Prelimbic         = 1;    
    input.AnteriorCingulate = 0;
    input.MedialOrbital     = 0;
    input.VentralOrbital    = 0;
    input.noradrenergic     = 0;
        
    % some other stuff
    input.correct           = 0; % not functional for classification
    input.incorrect         = 0; % not functional for classification
    input.notperfectsess    = 0; % only for classifier
    
    % for filtering out sessions with certain accuracies
    input.filter_accuracy = 0; % if 1 you filter for sessions based on accuracy
    input.num_incorrect   = 0; % if 2, you filter for sessions with >= 2 incorrect trials
    
    % zscore
    input.zscore          = 1;
    
    % subsample?
        input.subsample = 0;
        % how many samples?
            input.n_samples = 23; % 19 for poor - 51 for acc
        % how many iterations?
            input.n_iterat  = 1;
     
    % inputs for plotting correlogram
    input.plot_correlogram = 1;
    input.plot_permutated  = 0;
    input.plot_rawdata     = 1;
    
    % Time bins for startbox
    input.delay_bin         = 20; % this is for the binned startbox script
    
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
    
    % define what to plot
        input.plot_matrix      = 0;
        input.plot_correlogram = 1;

    % filter for units who fire less than mean peak (across maze pos) of 1hz?        
        input.hz_filter = 0;
end