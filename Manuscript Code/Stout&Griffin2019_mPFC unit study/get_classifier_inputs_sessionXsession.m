%% get_classifier_inputs
%
% this function is used to both consolidate space in other functions/
% scripts and to store all classifier input parameters
%
% OUTPUT: input - a struct array containing parameters for classification
%
% written by John Stout

function [input]=get_classifier_inputs_sessionXsession() 

    % define which folder
    input.mPFC_good         = 1;
    input.mPFC_poor         = 0;
    input.OFC               = 0;
    input.Prelimbic         = 0;
    input.AnteriorCingulate = 0;
    input.MedialOrbital     = 0;
    input.VentralOrbital    = 0;
    
    % can either z-score across all locations (standardize against preferred
    % location or taskphase) or across each individual location of interest
    input.zscore_peakRate = 0;
    input.zscore_eachbin  = 1; 
   
end