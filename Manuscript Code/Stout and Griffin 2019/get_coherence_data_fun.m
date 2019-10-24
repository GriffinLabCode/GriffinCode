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

function [] = get_coherence_data_fun(input)

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
    
% loop across folders
for nn = 3:length(folder_names)%28:35%[3:27,36:length(folder_names)] %3:length(folder_names)
    
    Datafolders = Datafolders;
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
    datafolder = pwd;
    cd(datafolder); 

    % only analyze sessions with Re, hpc, and prl recordings
    % this needs to be fixed - not function as of 8/8/19
    input.all_sites = 0; % hard coded to 0 until fixed
    if input.all_sites == 1
        Files=dir(fullfile(datafolder,'*detrend.mat'));
        if size(Files,1) < 3 
            continue
        end
    end
    
    % define and load some variables 
    if input.Tjunction == 1
        if input.coh_pfc == 1
            try
                load (strcat(datafolder,'\Int_lfp_T.mat')); 
                % display
                C = [];
                C = strsplit(datafolder,'\');
                X = [];
                X = ['successfully loaded Int_lfp_T.mat from ', C{end}];
                disp(X);               
            catch
                % display
                C = [];
                C = strsplit(datafolder,'\');
                X = [];
                X = [C{end}, ' had no Int_lfp_T.mat file'];
                disp(X);              
                continue
            end 
        elseif input.coh_hpc == 1 && input.coh_re == 1
            try
                load (strcat(datafolder,'\Int_HPCRE_T.mat')); 
                % display
                C = [];
                C = strsplit(datafolder,'\');
                X = [];
                X = ['successfully loaded Int_HPCRE_T.mat from ', C{end}];
                disp(X);               
            catch
                % display
                C = [];
                C = strsplit(datafolder,'\');
                X = [];
                X = [C{end}, ' had no Int_HPCRE_T.mat file'];
                disp(X);              
                continue
            end 
        end
    elseif input.Tjunction == 0 && input.coh_hpc == 1 && input.coh_re == 1  
        try
            load (strcat(datafolder,'\Int_HPCRE_StemTCol10.mat')); 
            % display
            C = [];
            C = strsplit(datafolder,'\');
            X = [];
            X = ['successfully loaded Int_HPCRE_StemTCol10.mat from ', C{end}];
            disp(X);               
        catch
            % display
            C = [];
            C = strsplit(datafolder,'\');
            X = [];
            X = [C{end}, ' had no Int_HPCRE_StemTCol10.mat file'];
            disp(X);              
            continue
        end
    elseif input.coh_pfc == 1 && (input.coh_re == 1 || input.coh_hpc == 1)
        try
            load (strcat(datafolder,'\Int_lfp_StemT_Col10.mat')); 
            % display
            C = [];
            C = strsplit(datafolder,'\');
            X = [];
            X = ['successfully loaded Int_lfp_StemT_Col10.mat from ', C{end}];
            disp(X);               
        catch
            % display
            C = [];
            C = strsplit(datafolder,'\');
            X = [];
            X = [C{end}, ' had no Int_lfp_StemT_Col10.mat file'];
            disp(X);              
            continue
        end
    end
    cd(Datafolders);
    folder_names = dir;
    cd(datafolder);

    % get correct trials  
    Int(find(Int(:,4)==1),:)=[];
    
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
        return
    end
   
    % split into sample and choice trials
    Int_sample = Int(1:2:size(Int,1),:);
    Int_choice = Int(2:2:size(Int,1),:);
   
    % check that Int file is formatted correctly again
    if isempty(find(Int_sample(:,10)==1))==0 || isempty(find(Int_choice(:,10)==0))==0
        disp('Int file not formatted correctly')
        return
    end   
    
    % set parameters
    params.fpass = input.phase_bandpass; 
    if input.Tjunction == 1
        params.tapers = [2 3]; % good for short time windows Price et al., 2016
    else
        params.tapers = [3 5];
    end
    params.trialave         = 1;
    params.err              = [2 .05];
    params.pad              = 0;
    %params.fpass           = [0 100]; % [1 100]
    % define movingwin for rmlines moving window version and cogram
    params.movingwin        = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
    
    try
        % this is if you want time around tjunction
        if input.Tjunction == 1
            [Coh_sample{nn-2},frex_sample{nn-2}] = coherence_chronux(datafolder,input,Int_sample,params);     
            [Coh_choice{nn-2},frex_choice{nn-2}] = coherence_chronux(datafolder,input,Int_choice,params);     

            clearvars -except input Datafolders folder_names nn Coh_sample ...
                Coh_choice frex_sample frex_choice correct_trajectory
        else        
            % get coherence and firing-rates
            [sample_cohData{nn-2},sample_cohMean{nn-2},sample_fr{nn-2},...
                sample_frMean{nn-2},frex_sample{nn-2},ts_sample{nn-2}] = coherence_firingrates(datafolder,input,Int_sample,params);
            [choice_cohData{nn-2},choice_cohMean{nn-2},choice_fr{nn-2},...
                choice_frMean{nn-2},frex_choice{nn-2},ts_choice{nn-2}] = coherence_firingrates(datafolder,input,Int_choice,params);

            % get location data
            %[sample_X{nn-2},sample_Y{nn-2},ExtractedX_all{nn-2},ExtractedY_all{nn-2}] = rat_location(datafolder,Int_sample);
            %[choice_X{nn-2},choice_Y{nn-2},~,~] = rat_location(datafolder,Int_choice);    

            clearvars -except sample_cohData sample_cohMean sample_fr ...
                sample_frMean choice_cohData choice_cohMean choice_fr ...
                choice_frMean input Datafolders folder_names Coh_sam Coh_cho ...
                CohS_mean CohCh_mean nn frex_sample frex_choice sample_X sample_Y...
                choice_X choice_Y ExtractedX_all ExtractedY_all num_types num_orig ...
                turn_nam correct_trajectory ts_sample ts_choice
        end
        X = ['finished with session ',num2str(nn-2)];
        disp(X)    
    catch
        X = ['error on session ',num2str(nn-2)];
        disp(X)            
    end
    
end

cd('X:\07. Manuscripts\In preparation\Stout - JNeuro\Data')

% make variables for saving - this is the region
if input.coh_pfc == 1 && input.coh_hpc == 1
    X_regs = 'PfcHpc';
elseif input.coh_pfc == 1 && input.coh_re == 1
    X_regs = 'PfcRe';
elseif input.coh_hpc == 1 && input.coh_re == 1
    X_regs = 'HpcRe';
end

if input.stem_bin == 1
    X_save_loc = 'StemBin';
elseif input.tjunction_bin == 1
    X_save_loc = 'TjuncBin';
end

% save data
X_save = ['Coherence_',X_regs,'_',X_save_loc];
save(X_save);

end
