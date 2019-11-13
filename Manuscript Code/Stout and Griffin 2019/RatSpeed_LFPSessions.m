%% get all rats locations from LFP sessions
% this script gets rat position data from LFP sessions and calculates speed
% define if you want to correct trajectories - I don't recommend as it will
% require random sub-sampling and removal of trials when the number of
% trajectories are probably similar in count

clear; clc
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');

for i = 1:3 % loop across region combos
    %[input]=get_granger_inputs(); % this works for now
    [input]=get_coh_inputs() 
    if i == 1 % hpc-pfc
        input.coh_pfc = 1; input.coh_hpc = 1; input.coh_re = 0;
    elseif i == 2 % hpc-re
        input.coh_pfc = 0; input.coh_hpc = 1; input.coh_re = 1;
    elseif i == 3 % pfc-re
        input.coh_pfc = 1; input.coh_hpc = 0; input.coh_re = 1;
    end

    correct_trajectory = 0;

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
    for nn = 3:length(folder_names)

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
            elseif (input.pow_re == 1 || input.pow_hpc == 1) && input.simultaneous == 0
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
        elseif input.Tjunction == 0 && input.coh_hpc == 1 && input.coh_re == 1 && (input.T_DataDriven == 1 || input.Tentry_longepoch == 1)
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
        elseif input.Tjunction == 0 || input.T_DataDriven == 1
            if input.coh_pfc == 1 && (input.coh_re == 1 || input.coh_hpc == 1)
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
            if input.coh_pfc == 1
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
            end

            if input.coh_hpc == 1
                load(strcat(datafolder,'\HPC.mat'),'Samples',...
                    'Timestamps','SampleFrequencies');   
                    %EEG_hpc = Samples(:)';
                     EEG2 = Samples(:)';
                     clear Samples
            end

            if input.coh_re == 1
                load(strcat(datafolder,'\Re.mat'),'Samples',...
                    'Timestamps','SampleFrequencies');
                    EEG3 = Samples(:)';
                    clear Samples
            end
        catch
            continue % skip to the next loop
        end

            %% interpolate missing data and convert to cm
            load(strcat(datafolder,'\VT1.mat'));
            [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);

            % convert to cm
            ExtractedX = round(ExtractedX./2.09);
            ExtractedY = round(ExtractedY./2.04);

        %% get position data
            % loop across trials
            for triali = 1:size(Int,1)
                % define where you want to perform the analysis
                time = [];

                % for tjunction stuff 
                %{
                  if input.T_before == 1
                        time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5))];
                  elseif input.T_after == 1 
                        time = [(Int(triali,5)) (Int(triali,5)+(0.5*1e6))];
                  elseif input.T_entry == 1
                        time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5)+(0.5*1e6))];                
                  end
                %}
                %time = [(Int(triali,1)) (Int(triali,1)+(3*1e6))];
               %time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5)+(1.5*1e6))];
              time = [(Int(triali,5)-(2*1e6)) (Int(triali,5)+(1*1e6))];
              %time = [(Int(triali,5)-(0.8*1e6)) (Int(triali,5)+(0.2*1e6))];
                
                % get position data
                PosX{triali}       = ExtractedX(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
                PosY{triali}       = ExtractedY(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));  
                TrialTimes{triali} = (TimeStamps_VT(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2))/1e6);  

            end

            % velocity
            % sampling rate for video tracking data
            sfreq = round(29.97);

            % calculate velocity (cm/sec)
            for i = 1:length(PosX)
                for ii = 1:length(PosX{i})-1
                    vel{i}(ii)=sqrt(((PosX{i}(ii+1)-PosX{i}(ii))^2)+((PosY{i}(ii+1)-PosY{i}(ii))^2))/...
                        (TrialTimes{i}(ii+1)-TrialTimes{i}(ii));
                end
            end

            % interpolate to sfreq
            time_diff = (time(2)-time(1))/1e6;
            for jj = 1:length(vel)
                 y = []; x = []; x_new = [];
                 y         = abs(vel{jj});
                 x         = linspace(-0.8,0.2,length(vel{jj}));
                 x_new     = linspace(-0.8,0.2,sfreq*time_diff); % interp to time epoch  
                 speed{jj} = interp1(x,y,x_new);
            end
            
            % get matrix
            speed_mat{nn-2} = vertcat(speed{:});
            speed_avg{nn-2} = mean(speed_mat{nn-2});

        % display progress
        X = ['finished with session ', num2str(nn-2)];
        disp(X)

        % house-keeping
        clearvars -except Datafolders folder_names nn input ...
             correct_trajectory frequencies granger_sample_x2y ...
             granger_choice_x2y granger_sample_y2x granger_choice_y2x error_var ...
             timespent_sample timespent_choice fx2y fy2x freq ssmo speed_mat speed_avg

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

    % info on before or after T
    if input.T_before == 1
        X_save_loc = 'beforeT';
    elseif input.T_after == 1
        X_save_loc = 'afterT';
    elseif input.T_entry == 1
        X_save_loc = 'entryT';
    end
    
    if input.simultaneous == 1
        X_save_loc = 'simultaneous';
    end
    
    if input.T_DataDriven == 1
        X_save_loc = '111019_approach';
    end

    % save data
    X_save = ['Speed_',X_regs,'_',X_save_loc];
    save(X_save);
    
    clear input speed_mat speed_avg
end % end of loop across types of sessions