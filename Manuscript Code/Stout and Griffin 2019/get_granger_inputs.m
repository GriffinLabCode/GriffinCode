%% get_entrainment_inputs
%
% this function is used to both consolidate space in other functions/
% scripts and to store all classifier input parameters
%
% OUTPUT: input - a struct array containing parameters for classification
%
% written by John Stout

function [input]=get_granger_inputs() 
    
    % region
    input.mPFC_good = 1;
    input.mPFC_poor = 0;
    input.OFC       = 0;
 
    % sub-region
    input.Prelimbic         = 0;    
    input.AnteriorCingulate = 0;
    input.MedialOrbital     = 0;
    input.VentralOrbital    = 0;
    
    % define time to examine - make this so you define here
    % time = [(data.Int(triali,1)) (data.Int(triali,1)+(1.5*1e6))];  
    input.Tjunction = 1;
    
        % if you've selected input.Tjunction = 1, select which epoch
        input.T_entry  = 1; % 1 sec surrounding t entry
        input.T_before = 0; % 1 sec before t entry 
        input.T_after  = 0; % 1 sec after t entry
    
    % downsample data? this is extremely useful to circumvent the problem
    % of not having enough time or cycles in your data. If you define the
    % following variable, you must designate your target down-sampled rate
    input.target_sample = 250;
    
    % do you want to take the first derivative of the signal? This helps
    % with data stationarity
    input.signal_derivative = 0;
    
    % phase bandpass
    input.phase_bandpass = [4 12];
    
    % plot after every iteration? Highly not recommended
    input.plot = 0;
    
    % Keep this at 0 - this is an old feature that needs updating
    input.all_sites = 0; % keep this at zero if running granger in times surrounding T
    
    % define regions to examine
    input.pfc = 1;
    input.hpc = 1;
    input.re  = 0;

end