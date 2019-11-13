%% Analyze all data with state-space granger approach
%
% this function is used to loop across folders, calculated granger
% prediction using a state-space approach from Bernett and Seth,2016
%
% Note: there are no outputs because the data is saved

% define if you want to correct trajectories - I don't recommend as it will
% require random sub-sampling and removal of trials when the number of
% trajectories are probably similar in count
clear; clc

cd('X:\03. Lab Procedures and Protocols\MATLABToolbox\mvgc_v2.0')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\mvgc_v2.0\demo')
startup_fun;

% define if you want to correct trajectories - I don't recommend as it will
% require random sub-sampling and removal of trials when the number of
% trajectories are probably similar in count
correct_trajectory = 0;

[input]=get_granger_inputs();

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
for nn = 3:35%:length(folder_names)
    
    Datafolders = Datafolders;
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
    datafolder = pwd;
    cd(datafolder); 
    
    % only analyze sessions with Re, hpc, and prl recordings
    if input.all_sites == 1
        Files=dir(fullfile(datafolder,'*detrend.mat'));
        if size(Files,1) < 3 
            continue
        end
        % save session name
        C = [];
        C = strsplit(datafolder,'\');

    end    

    %% do Int formatting
   % define and load some variables 
   %{
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
   %}
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
    
    % control for differing number of left and right trials during sample
    % and choice. But also make sure theres an equal number of different
    % trial-type combinations (sampleL sampleR choiceL choiceR)
    if correct_trajectory == 1
        [Int_corrected,corrected_trials,num_orig{nn-2},num_types{nn-2},...
            turn_nam{nn-2}]=correct_trajectory_differences(Int);
        Int_og2 = Int;
        Int = [];
        Int = Int_corrected;
    else
        Int = Int;
    end
   
    % split into sample and choice trials
    Int_sample = Int(1:2:size(Int,1),:);
    Int_choice = Int(2:2:size(Int,1),:);
   
    % check that Int file is formatted correctly again
    if isempty(find(Int_sample(:,10)==1))==0 || isempty(find(Int_choice(:,10)==0))==0
        disp('Int file not formatted correctly')
        return
    end        

    try % not all sessions may have all types of LFP files
            % check if pfc data exists
            if input.Prelimbic == 1
                region = '\PrL.mat';
            elseif input.AnteriorCingulate == 1
                region = '\ACC.mat';
            elseif input.mPFC_good == 1
                region = '\mPFC.mat';
            end

            % Henry mentioned he detrended data for all LFP analyses. THis data
            % is preemtively detrended via locdetrend. Each trial is cleaned
            % via rmlinesmovingwin
            load(strcat(datafolder,region),'Samples','Timestamps',...
                'SampleFrequencies'); 
                %EEG_pfc = Samples(:)';
                EEG1 = Samples(:)';
                clear Samples

            load(strcat(datafolder,'\HPC.mat'),'Samples',...
                'Timestamps','SampleFrequencies');   
                %EEG_hpc = Samples(:)';
                 EEG2 = Samples(:)';
                 clear Samples
        
            load(strcat(datafolder,'\Re.mat'),'Samples',...
                'Timestamps','SampleFrequencies');
                EEG3 = Samples(:)';
                clear Samples
    catch
        continue % skip to the next loop
    end
    
        % format EEG_* variable so that it's flexible. We want EEG_1 and
        % EEG_2 to remain constant in terms of the variable name, but we
        % want their lfp to change as a function of the region input.
        EEG_1 = EEG1; % pfc (x)
        EEG_2 = EEG2; % hpc (y)
        EEG_3 = EEG3; % re  (z)

    %% set parameters
    %params.fpass           = input.phase_bandpass; 
    params.tapers           = [2 3];    %[2 3]
    params.trialave         = 0;
    params.err              = [2 .05];
    params.pad              = 0;
    params.fpass            = [0 100]; % [1 100]
    params.Fs               = SampleFrequencies(1,1); 
    
    %% reformat timestamps
    % linspace(Timestamps(1,1),Timestamps(1,end),length(EEG_pfc));  % old way
    %cd ('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
    [Timestamps_new, ~] = interp_TS_to_CSC_length_non_linspaced(Timestamps, EEG_1); % figure; subplot 121; plot(Timestamps); subplot 122; plot(Timestamps_new)

    Timestamps_og = Timestamps;
    Timestamps = [];
    Timestamps = Timestamps_new;

    %% load VT data
    load(strcat(datafolder,'\VT1.mat'));
    load(strcat(datafolder,'\Events.mat'));
    
    %% define data variable
    %data.x_EEG      = EEG_hpc;
    %data.y_EEG      = EEG_pfc;
    data.srate      = SampleFrequencies(1);
    data.Timestamps = Timestamps;
    
    %% get granger estimates
        % loop across trials
        for triali = 1:size(Int,1)
            % define where you want to perform the analysis
            time = [];
            %time = [(Int(triali,1)) (Int(triali,5))]; 
            %time = [(Int(triali,5)) (Int(triali,6))]; 
            %time = [(Int(triali,6)-1*1e6) (Int(triali,6))]; 
            
        % for tjunction stuff     
           %time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5)+(0.5*1e6))];
          % before
          if input.Tjunction == 1
              if input.T_before == 1
                    time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5))];
              elseif input.T_after == 1 
                    time = [(Int(triali,5)) (Int(triali,5)+(0.5*1e6))];
              elseif input.T_entry == 1
                    time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5)+(0.5*1e6))];                
              end
          elseif input.Tjunction_DataDriven == 1;
                    time = [(Int(triali,5)-(0.8*1e6)) (Int(triali,5)+(0.2*1e6))];                
          end
          
          if input.Stem == 1
              if input.T_minus1 == 1
                  time = [(Int(triali,5)-(1*1e6)) (Int(triali,5))];      
              elseif input.T_plus1 == 1
                  time = [(Int(triali,5)) (Int(triali,5)+(1*1e6))]; 
              end
          end
 
            % get data
            signalx_raw{triali} = EEG_1(data.Timestamps>time(1,1) & data.Timestamps<time(1,2));
            signaly_raw{triali} = EEG_2(data.Timestamps>time(1,1) & data.Timestamps<time(1,2));  
            signalz_raw{triali} = EEG_3(data.Timestamps>time(1,1) & data.Timestamps<time(1,2));  
            
            % downsample? using a new sampling rate of 250 would allow us 
            % to utilize a model order of 25 to get 100 ms of data
            if input.Tjunction == 1 || input.Stem == 1 || input.Tjunction_DataDriven == 1;

                    % detrend the down-sampled data
                    signalx_det{triali} = locdetrend(signalx_raw{triali});
                    signaly_det{triali} = locdetrend(signaly_raw{triali});
                    signalz_det{triali} = locdetrend(signalz_raw{triali});

                    % clean
                    signalx_cle{triali} = rmlinesmovingwinc(signalx_det{triali},[0.5 0.01],10,params,'n');
                    signaly_cle{triali} = rmlinesmovingwinc(signaly_det{triali},[0.5 0.01],10,params,'n');  
                    signalz_cle{triali} = rmlinesmovingwinc(signalz_det{triali},[0.5 0.01],10,params,'n');  

                 if input.signal_derivative == 1
                    % take the derivative of the zscored data to make stationary 
                    signalx{triali} = diff(signalx_cle{triali});
                    signaly{triali} = diff(signaly_cle{triali});
                    signalz{triali} = diff(signalz_cle{triali});
                    
                 else
                     signalx=signalx_cle;
                     signaly=signaly_cle;
                     signalz=signalz_cle;
                     
                 end

                if input.target_sample ~= 0     
                    div = find_downsample_rate(params.Fs,input.target_sample);
                    
                    signalx{triali}=signalx{triali}(1:div:end);
                    signaly{triali}=signaly{triali}(1:div:end);
                    signalz{triali}=signalz{triali}(1:div:end);
                    
                    % provide new srate
                    data.srate = length(1:div:params.Fs);
                end
               
            else
                % detrend the down-sampled data
                signalx_det{triali} = locdetrend(signalx_raw{triali});
                signaly_det{triali} = locdetrend(signaly_raw{triali});
                signalz_det{triali} = locdetrend(signalz_raw{triali});

                % clean
                signalx_cle{triali} = rmlinesc(signalx_det{triali},params,[],'n');
                signaly_cle{triali} = rmlinesc(signaly_det{triali},params,[],'n');   
                signalz_cle{triali} = rmlinesc(signalz_det{triali},params,[],'n');   

                % take the derivative of the zscored data to make stationary 
                signalx{triali} = diff(signalx_cle{triali});
                signaly{triali} = diff(signaly_cle{triali});
                signalz{triali} = diff(signalz_cle{triali});


                if input.target_sample ~= 0     
                    div = find_downsample_rate(params.Fs,input.target_sample);
                    
                    signalx{triali}=signalx{triali}(1:div:end);
                    signaly{triali}=signaly{triali}(1:div:end);
                    signalz{triali}=signalz{triali}(1:div:end);
                    
                    % provide new srate
                    data.srate = length(1:div:params.Fs);
                end
            end
            
           % create a variable where rows are number of signals
           signal(1,:,triali) = signalx{triali}'; % signal x
           signal(2,:,triali) = signaly{triali}'; % signal y
           signal(3,:,triali) = signalz{triali}'; % signal z
           
        end
        
           % format
           data.signals = signal;         

           if input.EstimateModelOrder == 1
               % run granger for sample and choice - this is to control model
               % order between task phases
               %[pf{nn-2},ssmo{nn-2}] = EstimateModelOrder_Griffin(data);
               [pf{nn-2},ssmo{nn-2}] = EstimateModelOrder_2(data);
           elseif input.LoadModelOrder == 1
               cd('X:\07. Manuscripts\In preparation\Stout - JNeuro\Data\StateSpaceGranger_BIC_Tentry')               
               load('ModelOrder_PfcReHpc.mat');
           end
               
           % run granger function
           signals_sample = data.signals(:,:,1:2:end); % odd are sample
           signals_choice = data.signals(:,:,2:2:end); % even are choice
           
           for i = 1:2
               if i == 1
                   data.signals          = [];
                   data.signals          = signals_sample;
                   data.num_trials       = size(data.signals,3);
                   data.num_observations = size(data.signals,2);
                   [fx2y.sam{nn-2},fy2x.sam{nn-2},freqs.sam{nn-2},~,fx2z.sam{nn-2},fz2x.sam{nn-2},fy2z.sam{nn-2},fz2y.sam{nn-2}] = StateSpaceGranger(data,ssmo{nn-2},pf{nn-2});                   
                   
                   %[fx2y.sam{nn-2},fy2x.sam{nn-2},freq.sam{nn-2}] = StateSpaceGranger(data,ssmo{nn-2},pf{nn-2});
               elseif i == 2
                   data.signals          = [];
                   data.signals          = signals_choice;
                   data.num_trials       = size(data.signals,3);
                   data.num_observations = size(data.signals,2); 
                   [fx2y.cho{nn-2},fy2x.cho{nn-2},freqs.cho{nn-2},~,fx2z.cho{nn-2},fz2x.cho{nn-2},fy2z.cho{nn-2},fz2y.cho{nn-2}] = StateSpaceGranger(data,ssmo{nn-2},pf{nn-2});                   
                   
                   %[fx2y.cho{nn-2},fy2x.cho{nn-2},freq.cho{nn-2}] = StateSpaceGranger(data,ssmo{nn-2},pf{nn-2});
               end
           end
           
    % display progress
    X = ['finished with session ', num2str(nn-2)];
    disp(X)
     
    % house-keeping
    clearvars -except Datafolders folder_names nn input ...
         correct_trajectory frequencies granger_sample_x2y ...
         granger_choice_x2y granger_sample_y2x granger_choice_y2x error_var ...
         timespent_sample timespent_choice fx2y fy2x freq ssmo pf fx2z fz2x fy2z fz2y freqs
      
end
cd('X:\07. Manuscripts\In preparation\Stout - JNeuro\Data\lfp around tjunction\Long Epoch')

% make variables for saving - this is the region
X_regs = 'PfcHpcRe';

if input.Tjunction == 1
    % info on before or after T
    if input.T_before == 1
        X_save_loc = 'beforeT';
    elseif input.T_after == 1
        X_save_loc = 'afterT';
    elseif input.T_entry == 1
        X_save_loc = 'entryT';
    end
end

if input.Stem == 1
    if input.T_minus1 == 1
        X_save_loc = 'Tentry_minus1';
    elseif input.T_plus1 == 1
        X_save_loc = 'Tentry_plus1';
    end
end

if input.Tjunction_DataDriven == 1
    X_save_loc = 'CoherenceWindow';
end

if input.target_sample == 0
    X_save_loc = 'NoDownSample_CoherenceWindow';
end

% save data
X_save = ['granger_SS_',X_regs,'_',X_save_loc];
save(X_save);

