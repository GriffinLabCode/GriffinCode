%% get_granger_bsmart
%
% This code uses the bsmart toolbox pwcausal function to estimate granger.
% It relies heavily on the MxC analyzing neural time series data book
% chapter 28. 
%
% Note that I formatted data exactly similar to that of Mike Cohen in
% chapter 28. Here, I used the pwcausal function instead, since it provides
% the granger output using Geweke's method.
%
% Written by John Stout

clear; clc

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\GC code\GCtoolbox\bsmart')

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
    % this needs updating - currently not that functional 
    % 8/8/2019
     input.all_sites = 0; % hard code this to 0 until fixed
    if input.all_sites == 1
        Files=dir(fullfile(datafolder,'*detrend.mat'));
        if size(Files,1) < 3 
            continue
        end
        % save session name
        C = [];
        C = strsplit(datafolder,'\');

    end    

   %% Int formatting
    % define and load some variables 
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

            try
            % Henry mentioned he detrended data for all LFP analyses. THis data
            % is preemtively detrended via locdetrend. Each trial is cleaned
            % via rmlinesmovingwin
            load(strcat(datafolder,region),'Samples','Timestamps',...
                'SampleFrequencies'); 
                %EEG_pfc = Samples(:)';
                EEG1 = Samples(:)';
                clear Samples
            catch
                continue
            end
        end
        
        if input.hpc == 1
            try
            load(strcat(datafolder,'\HPC.mat'),'Samples',...
                'Timestamps','SampleFrequencies');   
                %EEG_hpc = Samples(:)';
                 EEG2 = Samples(:)';
                 clear Samples
            catch
                continue
            end
        end
        
        if input.re == 1
            try
                load(strcat(datafolder,'\Re.mat'),'Samples',...
                    'Timestamps','SampleFrequencies');
                    EEG3 = Samples(:)';
                    clear Samples
            catch
                continue
            end
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
    %params.fpass = input.phase_bandpass; 
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
            if input.Tjunction == 1
                if input.T_entry == 1
                    % 1 second surrounding T
                    time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5)+(0.5*1e6))];
                elseif input.T_before == 1
                    % before
                    time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5))];
                elseif input.T_after == 1
                    % after 
                    time = [(Int(triali,5)) (Int(triali,5)+(0.5*1e6))];
                end
            end
            
            % get data
            signalx_raw{triali} = EEG_1(data.Timestamps>time(1,1) & data.Timestamps<time(1,2));
            signaly_raw{triali} = EEG_2(data.Timestamps>time(1,1) & data.Timestamps<time(1,2));  
                        
            % detrend
            signalx_det{triali} = locdetrend(signalx_raw{triali});
            signaly_det{triali} = locdetrend(signaly_raw{triali});

            % clean           
            if input.Tjunction == 1
                signalx_cle{triali} = rmlinesmovingwinc(signalx_det{triali},[0.5 0.01],10,params,'n');
                signaly_cle{triali} = rmlinesmovingwinc(signaly_det{triali},[0.5 0.01],10,params,'n');
            else
                % this is primarily used if timestamps arent equal in
                % length, like if you were to examine stem across trials.
                signalx_cle{triali} = rmlinesc(signalx_det{triali},params,[],'n');
                signaly_cle{triali} = rmlinesc(signaly_det{triali},params,[],'n');
            end                 

           % create a variable where rows are number of signals
           signaltemp{triali} = vertcat(signalx_cle{triali}',signaly_cle{triali}');
        end
        
        % separate sample and choice trials
        signal_sam_temp = signaltemp(1:2:length(signaltemp)); % sample
        signal_cho_temp = signaltemp(2:2:length(signaltemp)); % choice
        
        % concatenate across trials (this is what cohen did, he converted a 2x51x99 3D matrix into a 2x5049 matrix)
        signal_sample = horzcat(signal_sam_temp{:});
        signal_choice = horzcat(signal_cho_temp{:});
      
        %% run granger for both task phases
        % define number of realizations (trials)
        nr = length(signal_sam_temp);
        % define length of realizations (timepoints) - note since I
        % controlled for time, this won't change. However, this also wont
        % work if you don't control for time. Will need to be made dynamic
        nl = length(signal_sam_temp{1});
        % define range of frequencies (this is 4-100 in 1 freq steps)
        freqs = linspace(4,100,100-4);
        % define max order
        maxorder = 50; % 50 to save time. Note that with progressively increasing model order the time takes progressively longer
        % get bic
        bic = get_bic(signal_sample,nr,nl,maxorder);
        % get model order
        [bic_min,modelorder{nn-2}] = min(bic);
        % run pwcausal - note that the nr and nl don't change across task
        % phases
        [~,~,Fx2y_sam{nn-2},Fy2x_sam{nn-2}]=pwcausal(signal_sample,nr,nl,modelorder{nn-2},data.srate,freqs);
        [~,~,Fx2y_cho{nn-2},Fy2x_cho{nn-2}]=pwcausal(signal_choice,nr,nl,modelorder{nn-2},data.srate,freqs);
        
% house keeping
clearvars -except Fx2y_sam Fx2y_cho Fy2x_sam Fy2x_cho nn ...
    folder_names Datafolders input correct_trajectory modelorder

% script progress
    X = ['finished with session ',num2str(nn-2)];
    disp(X) 
end

%% reformat
% concatenate
x2y_sam=vertcat(Fx2y_sam{:});
x2y_cho=vertcat(Fx2y_cho{:});
y2x_sam=vertcat(Fy2x_sam{:});
y2x_cho=vertcat(Fy2x_cho{:});

% averages and sems
mean_x2y_sam = mean(x2y_sam);
mean_x2y_cho = mean(x2y_cho);
mean_y2x_sam = mean(y2x_sam);
mean_y2x_cho = mean(y2x_cho);

sem_x2y_sam = std(x2y_sam)/(sqrt(size(x2y_sam,1)));
sem_x2y_cho = std(x2y_cho)/(sqrt(size(x2y_cho,1)));
sem_y2x_sam = std(y2x_sam)/(sqrt(size(y2x_sam,1)));
sem_y2x_cho = std(y2x_cho)/(sqrt(size(y2x_cho,1)));

% figure
x_label = linspace(4,100,100-4);
    % sample phase
    figure('color',[1 1 1])
    varargout1=shadedErrorBar(x_label,mean_x2y_sam,sem_x2y_sam,'-k',1);
    hold on;
    varargout2=shadedErrorBar(x_label,mean_y2x_sam,sem_y2x_sam,'-m',1);
    box off
        %plot(median(peak_lags_sample),max(coh_sample_mean),'-p',...
            %'MarkerFaceColor','black','MarkerSize',12,'MarkerEdgeColor','k')    
    set(gca,'FontSize',13)
    %line([0 0],ylim,'Color',[0 0 0],'linestyle','--','LineWidth',1.5)
    ylabel('granger coefficient')
    xlabel('frequency (hz)')
    % legend
    if input.pfc==1 && input.hpc==1
        legend([varargout1.mainLine,varargout2.mainLine],'pfc->hpc','hpc->pfc')
    elseif input.re==1 && input.pfc==1
        legend([varargout1.mainLine,varargout2.mainLine],'pfc->re','re->pfc')  
    elseif input.hpc==1 && input.re==1
        legend([varargout1.mainLine,varargout2.mainLine],'hpc->re','re->hpc')          
    end
% choice phase
    figure('color',[1 1 1])
    varargout1=shadedErrorBar(x_label,mean_x2y_cho,sem_x2y_cho,'-k',1);
    hold on;
    varargout2=shadedErrorBar(x_label,mean_y2x_cho,sem_y2x_cho,'-m',1);
    box off
        %plot(median(peak_lags_sample),max(coh_sample_mean),'-p',...
            %'MarkerFaceColor','black','MarkerSize',12,'MarkerEdgeColor','k')    
    set(gca,'FontSize',13)
    %line([0 0],ylim,'Color',[0 0 0],'linestyle','--','LineWidth',1.5)
    ylabel('granger coefficient')
    xlabel('frequency (hz)')
    % legend
    if input.pfc==1 && input.hpc==1
        legend([varargout1.mainLine,varargout2.mainLine],'pfc->hpc','hpc->pfc')
    elseif input.re==1 && input.pfc==1
        legend([varargout1.mainLine,varargout2.mainLine],'pfc->re','re->pfc')  
    elseif input.hpc==1 && input.re==1
        legend([varargout1.mainLine,varargout2.mainLine],'hpc->re','re->hpc')          
    end

%% loop across all frequencies generating LI
frex     = x_label;    % x_label was a recreated version of freqs
bands{1} = find(frex); % in-case you want to add other combinations
clear LI_sam LI_cho

% generate Lead index. Rows are sessions, columns are frequencies.
for i = 1:length(bands{1})
    LI_sam(:,i) = x2y_sam(:,i)./((x2y_sam(:,i))+(y2x_sam(:,i)));
    LI_cho(:,i) = x2y_cho(:,i)./((x2y_cho(:,i))+(y2x_cho(:,i)));
end
LI_mean_sam = mean(LI_sam);
LI_mean_cho = mean(LI_cho);

% significance testing
for i = 1:length(bands{1})
    [~,p_norm]=swtest(LI_sam(:,i));
    if p_norm<0.05
        p_sam(i)=signrank(LI_sam(:,i),0.5);
    else
        [h,p_sam(i)]=ttest(LI_sam(:,i),0.5);
    end
    
    [~,p_norm]=swtest(LI_cho(:,i));
    if p_norm<0.05
        p_cho(i)=signrank(LI_cho(:,i),0.5);
    else
        [h,p_cho(i)]=ttest(LI_cho(:,i),0.5);
    end            
end
  
% sample phase
figure('color',[1 1 1])
    varargout1=shadedErrorBar(frex,mean(LI_sam),(std(LI_sam)/(sqrt(size(LI_sam,1)))),'-b',1);
    box off
    hold on
    axis tight
    plot(xlim,[.5 .5],'LineWidth',1,'Color','k','linestyle','--','LineWidth',1.5)
    set(gca,'FontSize',13)
    % find and plot significant spots
    p_idx=find(p_sam<0.05);
    x_var=varargout1.mainLine.XData(p_idx);
    y_var=varargout1.mainLine.YData(p_idx);
    %y_var=0.7;
    plot(x_var,y_var,'-p','MarkerFaceColor','yellow','MarkerEdgeColor','black','MarkerSize',10)
    
% choice phase
figure('color',[1 1 1])
    varargout2=shadedErrorBar(frex,mean(LI_cho),(std(LI_cho)/(sqrt(size(LI_cho,1)))),'-r',1);
    box off
    hold on
    axis tight
    plot(xlim,[.5 .5],'LineWidth',1,'Color','k','linestyle','--','LineWidth',1.5)
    set(gca,'FontSize',13)  
    % find and plot significant spots
    p_idx=find(p_cho<0.05);
    x_var=varargout2.mainLine.XData(p_idx);
    y_var=varargout2.mainLine.YData(p_idx);
    %y_var=0.7;
    plot(x_var,y_var,'-p','MarkerFaceColor','yellow','MarkerEdgeColor','black','MarkerSize',10)    
       