%% get_granger_armorf
%
% this code utilizes the MxC ANTS armorf approach to estimate frequency
% domain granger estimates
%

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
for nn = 3:length(folder_names)
    
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
    if input.Tjunction == 1
        if input.pfc == 1
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
        elseif input.hpc == 1 && input.re == 1
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
    else  
        try
            load (strcat(datafolder,'\Int_lfp.mat')); 
            % display
            C = [];
            C = strsplit(datafolder,'\');
            X = [];
            X = ['successfully loaded Int_lfp.mat from ', C{end}];
            disp(X);               
        catch
            % display
            C = [];
            C = strsplit(datafolder,'\');
            X = [];
            X = [C{end}, ' had no Int_lfp.mat file'];
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

        if input.pfc == 1
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
        
        if input.hpc == 1
            load(strcat(datafolder,'\HPC.mat'),'Samples',...
                'Timestamps','SampleFrequencies');   
                %EEG_hpc = Samples(:)';
                 EEG2 = Samples(:)';
                 clear Samples
        end
        
        if input.re == 1
            load(strcat(datafolder,'\Re.mat'),'Samples',...
                'Timestamps','SampleFrequencies');
                EEG3 = Samples(:)';
                clear Samples
        end
        
        % format EEG_* variable so that it's flexible. We want EEG_1 and
        % EEG_2 to remain constant in terms of the variable name, but we
        % want their lfp to change as a function of the region input.
        if input.pfc == 1 && input.hpc == 1
            EEG_1 = EEG1; % pfc (x)
            EEG_2 = EEG2; % hpc (y)
        elseif input.pfc == 1 && input.re == 1
            EEG_1 = EEG1; % pfc (x)
            EEG_2 = EEG3; % re (y)
        elseif input.hpc == 1 && input.re == 1
            EEG_1 = EEG2; % hpc (x)
            EEG_2 = EEG3; % re (y)
        end    

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
           time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5))];
          % after 
           %time = [(Int(triali,5)) (Int(triali,5)+(0.5*1e6))];

            % get data
            signalx_raw{triali} = EEG_1(data.Timestamps>time(1,1) & data.Timestamps<time(1,2));
            signaly_raw{triali} = EEG_2(data.Timestamps>time(1,1) & data.Timestamps<time(1,2));  
            
            
            % downsample? using a new sampling rate of 250 would allow us 
            % to utilize a model order of 25 to get 100 ms of data
            if input.Tjunction == 1

                    % detrend the down-sampled data
                    signalx_det{triali} = locdetrend(signalx_raw{triali});
                    signaly_det{triali} = locdetrend(signaly_raw{triali});

                    % clean
                    signalx_cle{triali} = rmlinesmovingwinc(signalx_det{triali},[0.5 0.01],10,params,'n');
                    signaly_cle{triali} = rmlinesmovingwinc(signaly_det{triali},[0.5 0.01],10,params,'n');  

                 if input.signal_derivative == 1
                    % take the derivative of the zscored data to make stationary 
                    signalx{triali} = diff(signalx_cle{triali});
                    signaly{triali} = diff(signaly_cle{triali});
                 else
                     signalx=signalx_cle;
                     signaly=signaly_cle;
                 end

                if input.target_sample ~= 0     
                    div = find_downsample_rate(params.Fs,input.target_sample);
                    
                    signalx{triali}=signalx{triali}(1:div:end);
                    signaly{triali}=signaly{triali}(1:div:end);
                    
                    % provide new srate
                    data.srate = length(1:div:params.Fs);
                end
               
            else
                % detrend the down-sampled data
                signalx_det{triali} = locdetrend(signalx_raw{triali});
                signaly_det{triali} = locdetrend(signaly_raw{triali});

                % clean
                signalx_cle{triali} = rmlinesc(signalx_det{triali},params,[],'n');
                signaly_cle{triali} = rmlinesc(signaly_det{triali},params,[],'n');   

                % take the derivative of the zscored data to make stationary 
                signalx{triali} = diff(signalx_cle{triali});
                signaly{triali} = diff(signaly_cle{triali});

                if input.target_sample ~= 0     
                    div = find_downsample_rate(params.Fs,input.target_sample);
                    
                    signalx{triali}=signalx{triali}(1:div:end);
                    signaly{triali}=signaly{triali}(1:div:end);
                    
                    % provide new srate
                    data.srate = length(1:div:params.Fs);
                end
            end
            
           % create a variable where rows are number of signals
           signal(1,:,triali) = signalx{triali}'; % signal x
           signal(2,:,triali) = signaly{triali}'; % signal y
           
        end
        
           % format
           data.signals = signal;
           
           % run granger function
           signals_sample = data.signals(:,:,1:2:end); % odd are sample
           signals_choice = data.signals(:,:,2:2:end); % even are choice
           
           % run granger for sample and choice
           for i = 1:2
               if i == 1
                   data.signals          = [];
                   data.signals          = signals_sample;
                   data.num_trials       = size(data.signals,3);
                   data.num_observations = size(data.signals,2);        
                   [fx2y.sam{nn-2},fy2x.sam{nn-2},freq.sam{nn-2},ssmo.sam{nn-2}] = StateSpaceGranger(data);
               elseif i == 2
                   data.signals          = [];
                   data.signals          = signals_choice;
                   data.num_trials       = size(data.signals,3);
                   data.num_observations = size(data.signals,2);                   
                   [fx2y.cho{nn-2},fy2x.cho{nn-2},freq.cho{nn-2},ssmo.cho{nn-2}] = StateSpaceGranger(data);
               end
           end
           
    % display progress
    X = ['finished with session ', num2str(nn-2)];
    disp(X)
     
    % house-keeping
    clearvars -except Datafolders folder_names nn input ...
         correct_trajectory frequencies granger_sample_x2y ...
         granger_choice_x2y granger_sample_y2x granger_choice_y2x error_var ...
         timespent_sample timespent_choice fx2y fy2x freq ssmo
     
end
cd('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses')

% make variables for saving - this is the region
if input.pfc == 1 && input.hpc == 1
    X_regs = 'PfcHpc';
elseif input.pfc == 1 && input.re == 1
    X_regs = 'PfcRe';
elseif input.hpc == 1 && input.re == 1
    X_regs = 'HpcRe';
end

% info on before or after T
if input.T_before == 1
    X_save_loc = 'beforeT';
elseif input.T_after == 1
    X_save_loc = 'afterT';
end

X_save = ['granger_SS_',X_regs,'_',X_save_loc];
save('granger_SS_autosave.mat');

%% plot and test data

% remove empty arrays
fx2y.sam_new = fx2y.sam(~cellfun('isempty',fx2y.sam));
fx2y.cho_new = fx2y.cho(~cellfun('isempty',fx2y.cho));
fy2x.sam_new = fy2x.sam(~cellfun('isempty',fy2x.sam));
fy2x.cho_new = fy2x.cho(~cellfun('isempty',fy2x.cho));

% number of sessions
num_sessions = length(fx2y.sam_new);

% concatenate across trials
fx2y.sam_all = vertcat(fx2y.sam_new{:});
fx2y.cho_all = vertcat(fx2y.cho_new{:});
fy2x.sam_all = vertcat(fy2x.sam_new{:});
fy2x.cho_all = vertcat(fy2x.cho_new{:});

% average across trials
fx2y.sam_avg = mean(fx2y.sam_all);
fx2y.cho_avg = mean(fx2y.cho_all);
fy2x.sam_avg = mean(fy2x.sam_all);
fy2x.cho_avg = mean(fy2x.cho_all);

% sem across trials
fx2y.sam_sem = std(fx2y.sam_all)/(sqrt(size(fx2y.sam_all,1)));
fx2y.cho_sem = std(fx2y.cho_all)/(sqrt(size(fx2y.cho_all,1)));
fy2x.sam_sem = std(fy2x.sam_all)/(sqrt(size(fy2x.sam_all,1)));
fy2x.cho_sem = std(fy2x.cho_all)/(sqrt(size(fy2x.cho_all,1)));

% fig
idx_freq = find(freq.sam{1}>0 & freq.sam{1}<100); % index freqs
x_label  = freq.sam{1}; % x_label is frequency

% notice how the state space model captures the noise peak
figure('color',[1 1 1]);
    fig_fx2y_sam = shadedErrorBar(x_label(idx_freq),fx2y.sam_avg(idx_freq),fx2y.sam_sem(idx_freq),'b',1);
    hold on;
    fig_fx2y_cho = shadedErrorBar(x_label(idx_freq),fx2y.cho_avg(idx_freq),fx2y.cho_sem(idx_freq),'r',1);
    box off
    set(gca,'FontSize',12)
    if input.re == 1 && input.hpc == 1
        ylabel('GC estimate: HPC->Re')
    elseif input.pfc == 1 && input.hpc == 1
        ylabel('GC estimate: PFC->HPC')
    elseif input.re == 1 && input.pfc == 1
        ylabel('GC estimate: PFC->Re')
    end
    xlabel('Frequency');
    lgd = legend([fig_fx2y_sam.mainLine, fig_fx2y_cho.mainLine],...
        'Sample phase','Choice phase','Location','Northeast');
    lgd.Box = 'Off';
    lgd.FontSize = 12;
    
    
figure('color',[1 1 1]);
    fig_fy2x_sam = shadedErrorBar(x_label(idx_freq),fy2x.sam_avg(idx_freq),fy2x.sam_sem(idx_freq),'b',1);
    hold on;
    fig_fy2x_cho = shadedErrorBar(x_label(idx_freq),fy2x.cho_avg(idx_freq),fy2x.cho_sem(idx_freq),'r',1);
    box off
    set(gca,'FontSize',12)
    if input.re == 1 && input.hpc == 1
        ylabel('GC estimate: Re->HPC')
    elseif input.pfc == 1 && input.hpc == 1
        ylabel('GC estimate: HPC->PFC')
    elseif input.re == 1 && input.pfc == 1
        ylabel('GC estimate: Re->PFC')
    end
    xlabel('Frequency');
    lgd = legend([fig_fy2x_sam.mainLine, fig_fy2x_cho.mainLine],...
        'Sample phase','Choice phase','Location','Northeast');
    lgd.Box = 'Off';
    lgd.FontSize = 12;

% lead index
% generate Lead index. Rows are sessions, columns are frequencies.

LI_sam = fx2y.sam_all./(fx2y.sam_all+fy2x.sam_all);
LI_cho = fx2y.cho_all./(fx2y.cho_all+fy2x.cho_all);

LI_mean_sam = mean(LI_sam);
LI_mean_cho = mean(LI_cho);

LI_sem_sam  = std(LI_sam)/(sqrt(size(LI_sam,1)));
LI_sem_cho  = std(LI_cho)/(sqrt(size(LI_cho,1)));

% signrank from .5
for i = 1:length(idx_freq)
    [psam(i)]=signrank(LI_sam(:,i),0.5);
    [pcho(i)]=signrank(LI_cho(:,i),0.5);
end

figure('color',[1 1 1]);
    fig_LI_sam = shadedErrorBar(x_label(idx_freq),LI_mean_sam(idx_freq),LI_sem_sam(idx_freq),'b',1);
    hold on;
    fig_LI_cho = shadedErrorBar(x_label(idx_freq),LI_mean_cho(idx_freq),LI_sem_cho(idx_freq),'r',1);
    box off
    set(gca,'FontSize',12)
    if input.re == 1 && input.hpc == 1
        ylabel('Lead Index')
    elseif input.pfc == 1 && input.hpc == 1
        ylabel('Lead Index')
    elseif input.re == 1 && input.pfc == 1
        ylabel('Lead Index')
    end
    xlabel('Frequency');
    lgd = legend([fig_LI_sam.mainLine, fig_LI_cho.mainLine],...
        'Sample phase','Choice phase','Location','Northeast');
    lgd.Box = 'Off';
    lgd.FontSize = 12;
    hold on
    % plot stats
    p_idx=find(psam<0.05);
    x_var=fig_LI_sam.mainLine.XData(p_idx);
    y_var=fig_LI_sam.mainLine.YData(p_idx);
    %y_var=0.7;
    plot(x_var,y_var,'-p','MarkerFaceColor','green','MarkerEdgeColor','black','MarkerSize',10)
    hold on
    
    % plot stats - choice
    p_idx=find(pcho<0.05);
    x_var=fig_LI_cho.mainLine.XData(p_idx);
    y_var=fig_LI_cho.mainLine.YData(p_idx);
    %y_var=0.7;
    plot(x_var,y_var,'-p','MarkerFaceColor','yellow','MarkerEdgeColor','black','MarkerSize',10)

    hold on;
    plot(xlim,[.5 .5],'LineWidth',1,'Color','k','linestyle','--','LineWidth',1.5)
