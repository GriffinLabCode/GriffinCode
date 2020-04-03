%% This script calculates coherence during the interval of interest
%
% Note: This is a long code, but only because a lot of different things
% were explored after coherence was calculated.
%
% If you're exploring time around T-junction, you can adjust the interval
% in the get_coh_inputs function. If you want to manually change the
% interval, search for 'time'
%
% If exploring maze locations, manually change the time variable in the
% function 'coherence_firingrates.m' and 'rat_location.m'.
% Future updates will target changing this from the inputs function
%
% This script controls for:
% 1) behavior by including only correct trials
% 2) poor lfp - all sessions included from stem entry to t-junction were
%       visually inspected for clipping artifacts
% 3) number of sample and choice trials by subsampling
%
% written by John Stout

clear; clc

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux_2_12\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');

[input]=get_coh_inputs();

% flip over all folders    
    if input.Prelimbic == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic';
    elseif input.OFC ==1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Orbital Frontal';    
    elseif input.AnteriorCingulate == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Anterior Cingulate';
    elseif input.mPFC_good == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';
    elseif input.mPFC_poor == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Poor Performance\Medial Prefrontal Cortex'; 
    elseif input.VentralOrbital == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Ventral Orbital';
    elseif input.MedialOrbital == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Orbital';
    else
        disp('Warning - Error in loading Datafolders')
    end
    
    cd(Datafolders);
    folder_names = dir;    
    
% loop across folders (n = 3:35 if you want to exclude thanos)
for nn = 3:length(folder_names)%28:35%[3:27,36:length(folder_names)] %3:length(folder_names)
    
    Datafolders = Datafolders;
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
    datafolder = pwd;
    cd(datafolder); 

    %% only analyze sessions with Re, hpc, and prl recordings
    if input.simultaneous == 1 
        
        Files.pfc=dir(fullfile(datafolder,'mPFC.mat'));
        Files.re=dir(fullfile(datafolder,'Re.mat'));
        Files.hpc=dir(fullfile(datafolder,'HPC.mat'));
        
        if input.Tentry_longepoch == 1 || input.T_DataDriven == 1 || input.T_entry_minus2 == 1
            Files.int=dir(fullfile(datafolder,'Int_lfp_StemT_Col10.mat'));
        elseif input.T_entry == 1 || input.T_before == 1 || input.T_after == 1
            Files.int=dir(fullfile(datafolder,'Int_lfp_T.mat'));     
        end
        
        fn = fieldnames(Files);
        
        for fieldi = 1:length(fn)
            if size(Files.(fn{fieldi}),1) == 0
                store_size(fieldi) = 0;
            elseif size(Files.(fn{fieldi}),1) == 1
                store_size(fieldi) = 1;                    
            end
        end
        
        % if any of the data is missing, skip to the next loop
        if isempty(find(store_size == 0)) == 0 % this means one of the store_size values are zero. in other words, this session does not have simultaneous recordings
            continue
        end        
    end
    


    %% get and format int
    
    % define and load some variables 
    if input.Tjunction == 1
        if input.coh_pfc == 1 || input.simultaneous == 1
            try
                load (strcat(datafolder,'\Int_lfp_T.mat')); 
                % display
                Z = [];
                Z = strsplit(datafolder,'\');
                X = [];
                X = ['successfully loaded Int_lfp_T.mat from ', Z{end}];
                disp(X);               
            catch
                % display
                Z = [];
                Z = strsplit(datafolder,'\');
                X = [];
                X = [Z{end}, ' had no Int_lfp_T.mat file'];
                disp(X);              
                continue
            end 
        elseif (input.pow_re == 1 || input.pow_hpc == 1) && input.simultaneous == 0
            try
                load (strcat(datafolder,'\Int_HPCRE_T.mat')); 
                % display
                Z = [];
                Z = strsplit(datafolder,'\');
                X = [];
                X = ['successfully loaded Int_HPCRE_T.mat from ', Z{end}];
                disp(X);               
            catch
                % display
                Z = [];
                Z = strsplit(datafolder,'\');
                X = [];
                X = [Z{end}, ' had no Int_HPCRE_T.mat file'];
                disp(X);              
                continue
            end 
        end
    elseif input.Tjunction == 0 && input.coh_hpc == 1 && input.coh_re == 1  && input.simultaneous == 0 && (input.T_DataDriven == 1 || input.Tentry_longepoch == 1 || input.T_beforeEffect == 1)
        try
            load (strcat(datafolder,'\Int_HPCRE_StemTCol10.mat')); 
            % display
            Z = [];
            Z = strsplit(datafolder,'\');
            X = [];
            X = ['successfully loaded Int_HPCRE_StemTCol10.mat from ', Z{end}];
            disp(X);               
        catch
            % display
            Z = [];
            Z = strsplit(datafolder,'\');
            X = [];
            X = [Z{end}, ' had no Int_HPCRE_StemTCol10.mat file'];
            disp(X);              
            continue
        end
    elseif input.Tjunction == 0 || input.T_DataDriven == 1 || input.T_beforeEffect == 1
        % if you want to examine pfc-re or pfc-hpc interactions, have
        % selected the stem-to-t cleaning OR if you've selected
        % simultaneous pfc-re-hpc recordings and have selected re and hpc
        if input.coh_pfc == 1 && (input.coh_re == 1 || input.coh_hpc == 1) || (input.coh_re == 1 && input.coh_hpc == 1 && input.simultaneous == 1)
            try
                load (strcat(datafolder,'\Int_lfp_StemT_Col10.mat')); 
                % display
                Z = [];
                Z = strsplit(datafolder,'\');
                X = [];
                X = ['successfully loaded Int_lfp_StemT_Col10.mat from ', Z{end}];
                disp(X);               
            catch
                % display
                Z = [];
                Z = strsplit(datafolder,'\');
                X = [];
                X = [Z{end}, ' had no Int_lfp_StemT_Col10.mat file'];
                disp(X);              
                continue
            end
        end
    end
    cd(Datafolders);
    folder_names = dir;
    cd(datafolder);

    % get correct trials
    Int(find(Int(:,4)==1),:)=[];
   
    try
        % remove clipped trials
        Int(Int(:,9)==1,:)=[];

        % control for differing number of sample and choice trials by
        % removing the entire trial. 
        Int_og = Int;
        Int = [];
        Int = correct_taskphase_counts_nonsubsample(Int_og); 

        % end script if either a choice trial is first or sample is last. This
        % would mess up odd even distinction of sample and choice trials
        if Int(1,10) == 1 || Int(end,10) == 0
            disp('Int file not formatted correctly')
            continue
        end

        % split into sample and choice trials
        Int_sample = Int(1:2:size(Int,1),:);
        Int_choice = Int(2:2:size(Int,1),:);

        % check that Int file is formatted correctly again
        if isempty(find(Int_sample(:,10)==1))==0 || isempty(find(Int_choice(:,10)==0))==0
            disp('Int file not formatted correctly')
            continue
        end  
    catch
        continue
    end
    
    % set parameters
    params.fpass = input.phase_bandpass; 
    %{
    if input.Tjunction == 1
        params.tapers = [2 3]; % good for short time windows Price et al., 2016
    else
        params.tapers = [3 5];
    end
    %}
    params.tapers           = [2 3];
    params.trialave         = 1;
    params.err              = [2 .05];
    params.pad              = 0;
    %params.fpass           = [0 100]; % [1 100]
    % define movingwin for rmlines moving window version and cogram
    params.movingwin        = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
    
    % store int file
    Int_sam_og = []; Int_cho_og = [];
    Int_sam_og = Int_sample;
    Int_cho_og = Int_choice;
    
    % create a coherence distribution to compare the incorrect trials
    % against
    % this is if you want time around tjunction
    [Coh_sample{nn-2},frex_sample{nn-2},sam_trials{nn-2}] = coherence_chronux_permutated(datafolder,input,Int_sample,params);     
    [Coh_choice{nn-2},frex_choice{nn-2},cho_trials{nn-2}] = coherence_chronux_permutated(datafolder,input,Int_choice,params);     
    
    % store session
    session_name{nn-2} = Z{end};
    
    % house keeping
    clearvars -except input Datafolders folder_names nn Coh_sample ...
        Coh_choice frex_sample frex_choice correct_trajectory num_trials permi ...
        Int_sam_og Int_cho_og session_name
    
    X = ['finished with session ',num2str(nn-2)];
    disp(X) 
    
    save('coherence_permutated_temp.mat');

end
