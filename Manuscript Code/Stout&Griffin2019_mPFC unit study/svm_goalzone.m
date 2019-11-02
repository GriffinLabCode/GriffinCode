function [svm_data] = svm_goalzone(input)

%% Function that calculates firing rate across multiple stem points
% Written by John Stout

%% Initializing
disp(' - Initializing stem svm function...')

    % Initialize cell arrays
        sample_trials   = []; 
        choice_trials   = [];
        
    %% Initialize variables to flip over all folders    
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

%% For loop across folders
for iii = 1:size(input.rat,2)
    kendog = input.rat{iii}
    session_cells = cell([1]);
    
for nn = kendog
    
    Datafolders = Datafolders;
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
    datafolder = pwd;
    cd(datafolder);
    
    %% Load, define, and initialize some variables
    
    cd(datafolder)
    
    % load int
    load (strcat(datafolder,'\Int_file.mat')); 

    % load vt data
    load(strcat(datafolder, '\VT1.mat'));
    try load(strcat(datafolder,'\ExtractedYSample.mat'));
        disp('Successfully loaded ExtractedY Sample')
    catch 
         disp('ExtractedY from VT1 will be included');
    end
    TimeStamps = TimeStamps_VT;
    
    % load clusters
    clusters = dir('TT*.txt');    
    
    % sample and choice trials
    sample_trials = 1:2:size(Int,1);
    choice_trials = 2:2:size(Int,1);
    
%% Calculate firing rates and store in svm variable
svm_sample = []; svm_choice = [];

% first for sample left
    for ci=1:length(clusters) 
        cd(datafolder);
        spikeTimes = textread(clusters(ci).name);
        cluster = clusters(ci).name(1:end-4);
        fr = []; time = []; spk_idx = [];
        
        for i = 1:length(sample_trials)
            spk_idx = find(spikeTimes>Int(sample_trials(i),2)...
                & spikeTimes<=Int(sample_trials(i),7)); 
            time    = (Int(sample_trials(i),7)-Int(sample_trials(i),2))/1e6;
            fr(i,:)   = length(spk_idx)/time; % in Hz
        clear spk_idx time
        end
        
    % combine all clusters fr
        svm_sample(:,ci) = fr;     
    end
    
% next for choice 
cd(datafolder);

     for ci=1:length(clusters) 
        cd(datafolder);
        spikeTimes = textread(clusters(ci).name);
        cluster = clusters(ci).name(1:end-4);
        fr = []; time = []; spk_idx = [];

        for i = 1:length(choice_trials)
            spk_idx = find(spikeTimes>Int(choice_trials(i),2)...
                & spikeTimes<=Int(choice_trials(i),7)); 
            time    = (Int(choice_trials(i),7)-Int(choice_trials(i),2))/1e6;
            fr(i,:)   = length(spk_idx)/time; % in Hz
        clear spk_idx time
        end
        
    % combine all clusters fr
        svm_choice(:,ci) = fr;
     end
    
        
    % combine sample_trials and sampleR
    svm_var_temp{1} = vertcat(svm_choice,svm_sample);

    % combine data from all sessions
    session_cells = horzcat(session_cells,svm_var_temp);
    
    choice_trials = []; sample_trials=[]; svm_var_temp=[]; 
     
end
% due to formatting, session_cells first element is empty
session_cells(1)=[];
 
%format new array thats as long as there are bins. Within each bins,
%there should be 
for n = 1:size(session_cells,2)
    svm_var{1,n} = horzcat(session_cells{:,n});
end

% get rid of NaNs
for goawayNaN = 1:size(svm_var,2)
    svm_var{goawayNaN}(isnan((svm_var{goawayNaN})))=0;
end

svm_data{iii} = svm_var;

clearvars -except iii input stem_mean stem_sem svm_data...
    folder_names kendog Datafolders bins roc goalzone_mean goalzone_sem

    % Initialize cell arrays
        svm_sample = []; 
        svm_choice = [];

end
 

end
