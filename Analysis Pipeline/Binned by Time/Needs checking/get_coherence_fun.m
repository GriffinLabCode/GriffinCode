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

% make sure you change the get inputs function






%%%%%%%%%%%%%%%%%% YOU NEED TO CHANGE THE COHERENCE CHRONUX FUNCTION
%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%







%{
% future inputs
Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Andrew data';
int_name    = '\Int_new.mat';
%}

function [] = get_coherence_fun(Datafolders,int_name)

% clear clc
clear; clc

% addpaths
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux_2_12\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');

% inputs
[input]=get_coh_inputs();

% flip over all folders    
cd(Datafolders);
folder_names = dir;    
    
% loop across folders (n = 3:35 if you want to exclude thanos)
for nn = 3:length(folder_names)%28:35%[3:27,36:length(folder_names)] %3:length(folder_names)

    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
    datafolder = pwd;
    cd(datafolder); 

    %% get and format int
    
    % int_name will be the int file name
    load(strcat(datafolder,int_name));
        
    cd(Datafolders);
    folder_names = dir;
    cd(datafolder);
    
    % store C variable
    C = [];
    C = strsplit(datafolder,'\');    
    name = C;
    
    % get correct trials
    if input.correct == 1
        Int(find(Int(:,4)==1),:)=[];
    elseif input.incorrect == 1
        Int(find(Int(:,4)==0),:)=[]; 
    else
        Int = Int;
    end
    
    % remove clipped data - if you entered it this way
    if size(Int,2) >= 9
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
    else
        % split into sample and choice trials
        Int_sample = Int(1:2:size(Int,1),:);
        Int_choice = Int(2:2:size(Int,1),:);    
    end

    % report number of trials
    num_trials{nn-2} = size(Int_sample,1);
    
    % set parameters
    params.fpass            = input.phase_bandpass; 
    params.tapers           = [2 3];
    params.trialave         = 1;
    params.err              = [2 .05];
    params.pad              = 0;
    params.movingwin        = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
    
    % this is if you want time around tjunction
    if input.coh_time == 1
        [Coh_sample{nn-2},frex_sample{nn-2}] = coherence_chronux(datafolder,input,Int_sample,params);     
        [Coh_choice{nn-2},frex_choice{nn-2}] = coherence_chronux(datafolder,input,Int_choice,params);     
        
        clearvars -except session_name input Datafolders folder_names nn Coh_sample ...
            Coh_choice frex_sample frex_choice correct_trajectory num_trials session_name name
    else        
        % get coherence and firing-rates
        [sample_cohData{nn-2},sample_cohMean{nn-2},sample_fr{nn-2},...
            sample_frMean{nn-2},frex_sample{nn-2},ts_sample{nn-2}] = coherence_firingrates(datafolder,input,Int_sample,params);
        [choice_cohData{nn-2},choice_cohMean{nn-2},choice_fr{nn-2},...
            choice_frMean{nn-2},frex_choice{nn-2},ts_choice{nn-2}] = coherence_firingrates(datafolder,input,Int_choice,params);

        % get location data
        [sample_X{nn-2},sample_Y{nn-2},ExtractedX_all{nn-2},ExtractedY_all{nn-2}] = rat_location(datafolder,Int_sample);
        [choice_X{nn-2},choice_Y{nn-2},~,~] = rat_location(datafolder,Int_choice);    
    
        clearvars -except session_name sample_cohData sample_cohMean sample_fr ...
            sample_frMean choice_cohData choice_cohMean choice_fr ...
            choice_frMean input Datafolders folder_names Coh_sam Coh_cho ...
            CohS_mean CohCh_mean nn frex_sample frex_choice sample_X sample_Y...
            choice_X choice_Y ExtractedX_all ExtractedY_all num_types num_orig ...
            turn_nam correct_trajectory ts_sample ts_choice
    end
    
    % session_name
    session_name{nn-2} = name{end};    
    
    % display progress
    disp(['Finshed with session ', num2str(nn-2),'/',num2str(size(folder_names,1)-2)]);  

end

prompt   = 'Please enter a unique name for this dataset ';
unique_name = input(prompt,'s');

prompt   = 'Enter the directory to save the data ';
dir_name = input(prompt,'s');

save_var = unique_name;

cd(dir_name);
save(save_var);

end