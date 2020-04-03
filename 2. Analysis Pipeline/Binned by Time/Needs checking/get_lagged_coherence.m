%% This script calculates coherence during the interval of interest
% note that to change this interval, you will need to manually go into the
% function 'coherence_firingrates.m' and 'rat_location.m' to change this.
% Future updates will target changing this from the inputs function
%
% Int_lfp is only corrected for stem entry-tjunction exit in col9. col10 is
% taskphase 0 sample 1 choice
%
% This script controls for:
% 1) behavior by including only correct trials
% 2) poor lfp - all sessions included from stem entry to t-junction were
%       visually inspected for clipping artifacts
% 3) number of sample and choice trials by subsampling
% 4) trajectory - differing numbers of sampleL sampleR choiceL and 
%       choiceR; there is the same amount of each trial-type
%
% written by John Stout
clear; clc

correct_trajectory = 0;

%addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');

[input]=get_coh_inputs();

% define whether you want lagged coherence or lagged instantaneous phase
inst_coherence = 0;
inst_phase = 1;

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
    
        %% load lfp data
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
        
        % format EEG_* variable so that it's flexible. We want EEG_1 and
        % EEG_2 to remain constant in terms of the variable name, but we
        % want their lfp to change as a function of the region input.
        if input.coh_pfc == 1 && input.coh_hpc == 1
            EEG_1 = EEG1; % pfc (x)
            EEG_2 = EEG2; % hpc (y)
        elseif input.coh_pfc == 1 && input.coh_re == 1
            EEG_1 = EEG1; % pfc (x)
            EEG_2 = EEG3; % re (y)
        elseif input.coh_hpc == 1 && input.coh_re == 1
            EEG_1 = EEG2; % hpc (x)
            EEG_2 = EEG3; % re (y)
        end    

    %% set parameters
    params.fpass           = input.phase_bandpass; 
    params.tapers           = [2 3];    %[2 3]
    params.trialave         = 1;
    params.err              = [2 .05];
    params.pad              = 0;
    %params.fpass            = [0 100]; % [1 100]
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
        
    for triali = 1:size(Int,1)
        % define where you want to perform the analysis
        time = [];
        %time = [(Int(triali,1)) (Int(triali,5))]; 
        %time = [(Int(triali,5)) (Int(triali,6))]; 
        %time = [(Int(triali,6)-1*1e6) (Int(triali,6))]; 

    % for tjunction stuff     
       %time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5)+(0.5*1e6))];
      % before
       %time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5))];
      % after
      % entire t-entry
       %time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5)+(0.5*1e6))];
        time = [(Int(triali,5)-(0.8*1e6)) (Int(triali,5)+(0.2*1e6))];

       % define lag
        lags = linspace(-(data.srate*0.15),data.srate*0.15,75);
        lags = round(lags);  

        % find time start and end around T-junction
        idx_start = dsearchn(data.Timestamps',time(1,1));
        idx_end   = dsearchn(data.Timestamps',time(1,2));

        % extract signal surrounding it
        % signal x is used for lagging
        % should make this a small function like 'lag_my_signal'
        signalx_raw{triali} = EEG_1(1,(idx_start+lags(1)):(idx_end+lags(end)));
        %signaly_raw{triali} = EEG_2(1,(idx_start+lags(1)):(idx_end+lags(end)));
        
        % get normal data. Notice that the result of this will be 1001 pnts
        % if looking at 1/2 of a second, instead of 1000 pnts. It's
        % identical to what the data would look like if I uncommented the
        % one below, or I just extracted without adding a small time lag.
        signaly_raw{triali} = EEG_2(idx_start:idx_end);
        %signaly_raw{triali} = EEG_2(data.Timestamps>(time(1,1)+lags(1)) & data.Timestamps<(time(1,2)+lags(end)));  

        % chronux routines
        if input.Tjunction == 1 || input.T_DataDriven == 1;

                % detrend the down-sampled data
                signalx_det{triali} = locdetrend(signalx_raw{triali});
                signaly_det{triali} = locdetrend(signaly_raw{triali});

                % clean
                signalx_cle{triali} = rmlinesmovingwinc(signalx_det{triali},[0.5 0.01],10,params,'n');
                signaly_cle{triali} = rmlinesmovingwinc(signaly_det{triali},[0.5 0.01],10,params,'n');  

        else
            % detrend the down-sampled data
            signalx_det{triali} = locdetrend(signalx_raw{triali});
            signaly_det{triali} = locdetrend(signaly_raw{triali});

            % clean
            signalx_cle{triali} = rmlinesc(signalx_det{triali},params,[],'n');
            signaly_cle{triali} = rmlinesc(signaly_det{triali},params,[],'n');   
        end
    end
    
    % this is if you want time around tjunction
    if input.Tjunction == 1 || input.T_DataDriven == 1;
            for i = 1:2
                if i == 1 % sample phase
                    signalx_trials = []; signaly_trials = [];
                    signalx_trials = signalx_cle(1:2:length(signalx_cle));
                    signaly_trials = signaly_cle(1:2:length(signaly_cle));
                    % coherence
                    if inst_coherence == 1
                        [C_sample,f,lag]=lagged_coherence(signalx_trials,signaly_trials,params);  
                    elseif inst_phase == 1
                        for triali = 1:size(signalx_trials,2)
                            [r_sam_trials{triali},lag{triali}]=lagged_LFP(signalx,signaly,phase_bandpass,srate);
                        end
                    end
               else % choice phase
                    signalx_trials = []; signaly_trials = [];
                    signalx_trials = signalx_cle(2:2:length(signalx_cle));
                    signaly_trials = signaly_cle(2:2:length(signaly_cle)); 
                    if inst_coherence == 1
                        % coherence
                        [C_choice]=lagged_coherence(signalx_trials,signaly_trials,params);  
                    elseif inst_phase == 1
                        for triali = 1:size(signalx_trials,2)
                            [r_sam_trials{triali},lag{triali}]=lagged_LFP(signalx{triali},signaly{triali},phase_bandpass,srate);
                        end
                    end
                end
            end 
        
        clearvars -except input Datafolders folder_names nn ...
            C_choice C_sample f lag correct_trajectory coh_choice coh_sample
   
    end
    
    %{
    % plotting heatmap
        figure('color',[1 1 1])
            pcolor(lag,f,horzcat(C_sample{:}))
            set(gca,'fontsize', 13);
            colormap(jet)
            colorbar      
            shading 'interp'
            ylabel('frequency')
            xlabel('time')       
    %}
    
    % store data
    coh_choice{nn-2} = C_choice;
    coh_sample{nn-2} = C_sample;
    
    % remove variables
    clear C_choice C_sample
    
    X = ['finished with session ',num2str(nn-2)];
    disp(X)    

end
cd('X:\07. Manuscripts\In preparation\Stout - JNeuro\Data\lfp around tjunction');
save('lagged_coherence_automaticsave.mat');

% average across sessions
coh_choice = coh_choice(~cellfun('isempty',coh_choice));
coh_sample = coh_sample(~cellfun('isempty',coh_sample));

coh_choice_all = vertcat(coh_choice{:});
coh_sample_all = vertcat(coh_sample{:});

%{
% average across sessions
for lagi = 1:length(coh_choice_all)
    coh_choice_avg_cell{lagi} = mean(horzcat(coh_choice_all{:,lagi}),2);
    coh_sample_avg_cell{lagi} = mean(horzcat(coh_sample_all{:,lagi}),2);
end

% concatenate
coh_choice_matrix = horzcat(coh_choice_avg_cell{:});
coh_sample_matrix = horzcat(coh_sample_avg_cell{:});

%{
figure('color',[1 1 1])
    pcolor(lag,f,coh_choice_matrix)
    set(gca,'fontsize', 13);
    colormap(jet)
    colorbar      
    shading 'interp'
    ylabel('frequency')
    xlabel('time') 
    line([0 0],ylim,'Color',[0 0 0],'linestyle','--','LineWidth',1.5)

figure('color',[1 1 1])
    pcolor(lag,f,coh_sample_matrix)
    set(gca,'fontsize', 13);
    colormap(jet)
    colorbar      
    shading 'interp'
    ylabel('frequency')
    xlabel('time') 
    line([0 0],ylim,'Color',[0 0 0],'linestyle','--','LineWidth',1.5)
%}
%}

%% get band of interest
frex = [6 9];
band = find(f>frex(1) & f<frex(2));

% extract session data across lags
for lagi = 1:length(coh_choice_all)
    chotemp1{lagi} = horzcat(coh_choice_all{:,lagi});
    samtemp1{lagi} = horzcat(coh_sample_all{:,lagi});
    % use 'band' to index frequencies of interest
    %coh_band_cho{lagi} = mean(temp1(band,:));
    %coh_band_sam{lagi} = mean(temp2(band,:));
end

for lagi = 1:length(samtemp1)
    coh_band_cho{lagi} = mean(chotemp1{lagi}(band,:),1);
    coh_band_sam{lagi} = mean(samtemp1{lagi}(band,:),1);
end

% get data into a matrix
sam_mat = (vertcat(coh_band_sam{:}))';
cho_mat = (vertcat(coh_band_cho{:}))';

% mean and sem
mean_sam = mean(sam_mat);
mean_cho = mean(cho_mat);

sem_sam  = (std(sam_mat))./(sqrt(size(sam_mat,1)));
sem_cho  = (std(cho_mat))./(sqrt(size(cho_mat,1)));

figure('color',[1 1 1]); hold on;
shadedErrorBar(lag,mean_sam,sem_sam,'-b',1);
shadedErrorBar(lag,mean_cho,sem_cho,'-r',1);
line([0 0],ylim,'Color',[0 0 0],'linestyle','--','LineWidth',1.5)
axis tight

% get peak lag
for i = 1:size(sam_mat,1) % loop across sessions
    [peak_sam(i),pk_time_sam(i)] = max(sam_mat(i,:));
    [peak_cho(i),pk_time_cho(i)] = max(cho_mat(i,:));
end

peak_time_sam = lag(pk_time_sam);
peak_time_cho = lag(pk_time_cho);

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Cool Plots');
mat = horzcat(peak_time_sam',peak_time_cho');
plot_bar = 0;
plot_box = 1;
jitter = 1;
connect_jitter = 0;
PlotLine = 1;
BarPlotsJitteredData(mat,plot_bar,plot_box,jitter,connect_jitter,PlotLine)
set(gca,'FontSize',14)

[h,pcho,stat_cho]=signrank(peak_time_cho,0)
[h,psam,stat_sam]=signrank(peak_time_sam,0)


%{
% average and sem
coh_choice_mean = cellfun(@mean,coh_band_cho);
coh_sample_mean = cellfun(@mean,coh_band_sam);

for lagi=1:length(coh_choice_all)
    coh_choice_sem(lagi) = std(coh_band_cho{lagi})/(sqrt(length(coh_band_cho{lagi})));
    coh_sample_sem(lagi) = std(coh_band_sam{lagi})/(sqrt(length(coh_band_sam{lagi})));
end

%% find peak means
% put data into matrix thats (trial X lag coherence value)
coh_band_cho_all = vertcat(coh_band_cho{:})';
coh_band_sam_all = vertcat(coh_band_sam{:})';

coh_choice_mean = mean(coh_band_cho_all);
coh_sample_mean = mean(coh_band_sam_all);
coh_choice_sem  = std(coh_band_cho_all)/(sqrt(size(coh_band_cho_all,1)));
coh_sample_sem  = std(coh_band_sam_all)/(sqrt(size(coh_band_sam_all,1)));

% get max data for each trial including the location that it happened at.
% The indexed location will be used to extract the lags
for sessi = 1:size(coh_sample_all,1)
    [coh_band_sam_peak(sessi),idx_sam_peak(sessi)] = max(coh_band_sam_all(sessi,:));
    [coh_band_cho_peak(sessi),idx_cho_peak(sessi)] = max(coh_band_cho_all(sessi,:));
end

%{
% find lag where peak mean occured
figure('color',[1 1 1])
for i = 1:size(coh_band_sam_all,1)
    plot(lag,coh_band_cho_all(i,:),'g');
    hold on
    plot(lag(idx_cho_peak(i)),coh_band_cho_all(i,idx_cho_peak(i)),'-p',...
        'MarkerFaceColor','black','MarkerSize',12,'MarkerEdgeColor','k')    
    %plot(lag(idx_cho_peak(i)),coh_band_cho_all(i,idx_cho_peak(i)),'k*')
end
plot(lag,mean(coh_band_cho_all),'r','LineWidth',2);
box off
line([0 0],ylim,'Color',[0 0 0],'linestyle','--','LineWidth',1.5)
%}

%% get peak lags.
for i = 1:size(coh_band_sam_all,1)
    peak_lags_choice(i)=lag(idx_cho_peak(i));
    peak_lags_sample(i)=lag(idx_sam_peak(i));
end

%% stats
[h,p]=signrank(peak_lags_sample)
[h,p]=signrank(peak_lags_choice)

[h,p_norm]=swtest(peak_lags_sample);
if p_norm<0.05
    [p_rank_sam,h,stat_sam]=signrank(peak_lags_sample,0);
else
    [h,p_ttest_sam,ci,stat_sam]=ttest(peak_lags_sample,0);
end

[h,p_norm]=swtest(peak_lags_choice);
if p_norm<0.05
    [p_rank_cho,h,stat_cho]=signrank(peak_lags_choice,0);
else
    [h,p_ttest_cho,ci,stat_cho]=ttest(peak_lags_choice,0);
end

cd('X:\03. Lab Procedures and Protocols\MATLABToolbox\IoSR-Surrey-MatlabToolbox-4bff1bb')
figure('color',[1 1 1]); 
iosr.statistics.boxPlot([peak_lags_sample',peak_lags_choice']);
%ylim([-160 160])
set(gca,'FontSize',12)
ylim([-50 50])

%%

% change lag demonstration to 100 ms
idx_before = dsearchn(lag',-100);
idx_after  = dsearchn(lag',100);


% figure

%{
figure('color',[1 1 1])
shadedErrorBar(lag(idx_before:idx_after),coh_sample_mean(idx_before:idx_after),coh_sample_sem(idx_before:idx_after),'-b',1);
hold on;
box off
    plot(median(peak_lags_sample),max(coh_sample_mean),'-p',...
        'MarkerFaceColor','black','MarkerSize',12,'MarkerEdgeColor','k')    
set(gca,'FontSize',14)
line([0 0],ylim,'Color',[0 0 0],'linestyle','--','LineWidth',1.5)

figure('color',[1 1 1])
shadedErrorBar(lag,coh_choice_mean,coh_choice_sem,'-r',1);
hold on;
line([0 0],ylim,'Color',[0 0 0],'linestyle','--','LineWidth',1.5)
box off
axis tight

figure('color',[1 1 1])
shadedErrorBar(lag(idx_before:idx_after),coh_sample_mean(idx_before:idx_after),coh_sample_sem(idx_before:idx_after),'-b',1);
hold on;
    % plot the median lag
    plot(median(peak_lags_sample),max(coh_sample_mean),'-p',...
        'MarkerFaceColor','black','MarkerSize',12,'MarkerEdgeColor','k')   
shadedErrorBar(lag(idx_before:idx_after),coh_choice_mean(idx_before:idx_after),coh_choice_sem(idx_before:idx_after),'-r',1);
    % plot median lag
    plot(median(peak_lags_choice),max(coh_choice_mean),'-p',...
        'MarkerFaceColor','black','MarkerSize',12,'MarkerEdgeColor','k')   
line([0 0],ylim,'Color',[0 0 0],'linestyle','--','LineWidth',1.5)
set(gca,'FontSize',14)
box off

%}

figure('color',[1 1 1])
shadedErrorBar(lag,coh_sample_mean,coh_sample_sem,'-b',1);
hold on;
    % plot the median lag
    plot(median(peak_lags_sample),max(coh_sample_mean),'-p',...
        'MarkerFaceColor','black','MarkerSize',12,'MarkerEdgeColor','k')   
shadedErrorBar(lag,coh_choice_mean,coh_choice_sem,'-r',1);
    % plot median lag
    plot(median(peak_lags_choice),max(coh_choice_mean),'-p',...
        'MarkerFaceColor','black','MarkerSize',12,'MarkerEdgeColor','k')   
line([0 0],ylim,'Color',[0 0 0],'linestyle','--','LineWidth',1.5)
set(gca,'FontSize',13)
box off

%% figure for frequency X peak-lags

%% get band of interest
frex = [1 100];
band = find(f>frex(1) & f<frex(2));

% extract session data across lags
for lagi = 1:length(coh_choice_all)
    temp1{lagi} = mean(horzcat(coh_choice_all{:,lagi}),2);
    temp2{lagi} = mean(horzcat(coh_sample_all{:,lagi}),2);
end

% average and sem
coh_choice_mean = cellfun(@mean,coh_band_cho);
coh_sample_mean = cellfun(@mean,coh_band_sam);
%}