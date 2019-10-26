%% phase amplitude coupling
%
% this code utilizes Henrys old code
%
% written by John Stout

% clear out
clear; clc

% addpaths
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Henry Code')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');

[input]=get_pac_inputs();

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

    try
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
            % EEG1 is pfc EEG2 is hpc.
            if input.hpc_phase == 1 && input.pfc_amp == 1
                EEG_phase     = EEG2; % hpc phase
                EEG_amplitude = EEG1; % pfc amplitude
            elseif input.pfc_phase == 1 && input.hpc_amp == 1
                EEG_phase     = EEG1; % pfc phase
                EEG_amplitude = EEG2; % hpc amplitude
            end
        elseif input.pfc == 1 && input.re == 1
            % EEG1 is pfc EEG3 is re. 
            if input.re_phase == 1 && input.pfc_amp == 1
                EEG_phase     = EEG3;
                EEG_amplitude = EEG1;
            elseif input.pfc_phase == 1 && input.re_amp == 1
                EEG_phase     = EEG1;
                EEG_amplitude = EEG3;
            end
        elseif input.hpc == 1 && input.re == 1
            % EEG2 is hpc EEG3 is re
            if input.hpc_phase == 1 && input.re_amp == 1
                EEG_phase     = EEG2;
                EEG_amplitude = EEG3;
            elseif input.re_phase == 1 && input.hpc_amp == 1
                EEG_phase     = EEG3;
                EEG_amplitude = EEG2;
            end
        elseif input.pfc == 1 && input.hpc == 0 && input.re == 0
            EEG_phase     = EEG1;
            EEG_amplitude = EEG1;
        elseif input.pfc == 0 && input.hpc == 1 && input.re == 0
            EEG_phase     = EEG2;
            EEG_amplitude = EEG2;
        elseif input.pfc == 0 && input.hpc == 0 && input.re == 1
            EEG_phase     = EEG3;
            EEG_amplitude = EEG3;
        end  
    catch
        continue % if no data, reset loop
    end
    
    %% set parameters
    params.tapers           = [3 5];
    params.trialave         = 0;
    params.err              = [2 .05];
    params.pad              = 0;
    params.fpass            = [1 100]; 
    params.Fs               = SampleFrequencies(1,1);  
    
    %% reformat timestamps
    [Timestamps_new, ~] = interp_TS_to_CSC_length_non_linspaced(Timestamps, EEG_phase); % figure; subplot 121; plot(Timestamps); subplot 122; plot(Timestamps_new)
    Timestamps_og = Timestamps;
    Timestamps = [];
    Timestamps = Timestamps_new;

    %% load VT data
    load(strcat(datafolder,'\VT1.mat'));
    load(strcat(datafolder,'\Events.mat'));
    
    %% get lfp data
    % get lfp data of interest, detrend, clean, concatenate
    for triali = 1:size(Int,1)
        % define where you want to perform the analysis
        time = [];
        %time = [(Int(triali,1)) (Int(triali,5))]; 
        %time = [(Int(triali,5)) (Int(triali,6))]; 
        
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
        
        % get timestamps
        signal_ts{triali} = Timestamps(Timestamps>time(1,1) & Timestamps<time(1,2));        
        
        % get data
        signalx_raw{triali} = EEG_phase(Timestamps>time(1,1) & Timestamps<time(1,2));
        signaly_raw{triali} = EEG_amplitude(Timestamps>time(1,1) & Timestamps<time(1,2));  


        % detrend the down-sampled data
        signalx_det{triali} = locdetrend(signalx_raw{triali});
        signaly_det{triali} = locdetrend(signaly_raw{triali});
  
        % clean
        signalx_cle{triali} = rmlinesc(signalx_det{triali},params,[],'n');
        signaly_cle{triali} = rmlinesc(signaly_det{triali},params,[],'n');
        
        
    end
    
    % loop across both task phases
    for i = 1:2
        if i == 1 % sample phase
            signalx  = signalx_cle(1:2:length(signalx_cle));
            signaly  = signaly_cle(1:2:length(signaly_cle));
            signalts = signal_ts(1:2:length(signal_ts));
        elseif i == 2 % choice phase
            signalx  = signalx_cle(2:2:length(signalx_cle));
            signaly  = signaly_cle(2:2:length(signaly_cle));
            signalts = signal_ts(2:2:length(signal_ts));
        end
        
        % concatenate across trials for both signals
        eeg1     = vertcat(signalx{:})';
        eeg2     = vertcat(signaly{:})';
        eegTimes = (horzcat(signalts{:}));

        %% format and run mod index for phase amplitude coupling
        % format variable signal_data variable
        signal_data.timestamps         = eegTimes;
        signal_data.phase_EEG          = eeg1; % signal x data which derives from EEG_phase variable
        signal_data.amplitude_EEG      = eeg2; % eeg2 comes from signaly which is derived from EEG_amplitude variable
        signal_data.phase_bandpass     = input.phase_bandpass;
        signal_data.amplitude_bandpass = input.amplitude_bandpass;
        signal_data.srate              = SampleFrequencies(1);
        signal_data.phase_extraction   = 1; % 0 is hilbert transform 1 is interpolation - henry used interp

        if input.modindex == 1
            % make data file for phase amplitude coupling
            [data] = makedatafile(signal_data);

            % run modindex - 18 is the default, henry also used 18
            [M] = modindex(data,'n',18);  

            % store sample and choice data
            if i == 1
                data_phase_sample{nn-2}     = M.phase;
                data_MI_sample{nn-2}        = M.MI;
                data_normAmp_sample{nn-2}   = M.NormAmp;
                data_phaseAxis_sample{nn-2} = M.PhaseAxis;
            elseif i == 2
                data_phase_choice{nn-2}     = M.phase;
                data_MI_choice{nn-2}        = M.MI;
                data_normAmp_choice{nn-2}   = M.NormAmp;
                data_phaseAxis_choice{nn-2} = M.PhaseAxis;                
            end

            clearvars -except Datafolders folder_names nn input ...
                       correct_trajectory frequencies data_MI_sample ...
                       data_phase_sample data_MI_choice data_phase_choice i ...
                       signalx signaly signalts signalx_cle signaly_cle ...
                       signal_ts eeg1 eeg2 eegTimes SampleFrequencies params ...
                       data_normAmp_choice data_normAmp_sample data_phaseAxis_choice ...
                       data_phaseAxis_sample
        elseif input.comodgram == 1
            signal_data.phase_extraction = 2; % morlet wavelet
            % use same num as henry
            phase_bins = 18;
            % 1 bin
            amplitude_freq_bins = 1;%signal_data.amplitude_bandpass(2)-signal_data.amplitude_bandpass(1);
            phase_freq_bins = 1;%signal_data.phase_bandpass(2)-signal_data.phase_bandpass(1);
            % don't plot
            plot = 1; % don't plot
            % store data
            if i == 1
                phase_map_sample{nn-2} = phase_comodgram(signal_data, phase_bins, amplitude_freq_bins, phase_freq_bins, plot);
            elseif i == 2
                phase_map_choice{nn-2} = phase_comodgram(signal_data, phase_bins, amplitude_freq_bins, phase_freq_bins, plot);
            end 
                
            clearvars -except Datafolders folder_names nn input ...
               correct_trajectory frequencies data_MI_sample ...
               data_phase_sample data_MI_choice data_phase_choice i ...
               signalx signaly signalts signalx_cle signaly_cle ...
               signal_ts eeg1 eeg2 eegTimes SampleFrequencies params ...
               phase_map_sample phase_map_choice phase_bins ...
               amplitude_freq_bins phase_freq_bins plot data_normAmp_choice ...
               data_normAmp_sample data_phaseAxis_sample data_phaseAxis_choice
        end
    end
   
    % display progress
    X = ['finished with session ', num2str(nn-2)];
    disp(X)
     
    % house-keeping
        clearvars -except Datafolders folder_names nn input ...
                   correct_trajectory frequencies data_MI_sample ...
                   data_phase_sample data_MI_choice data_phase_choice ...
                   phase_map_sample phase_map_choice
end
cd('X:\07. Manuscripts\In preparation\Stout - JNeuro\Data\lfp around tjunction')
%save('PAC_all.mat');

% make variables for saving - this is the region
if input.modindex == 1
    X_det = 'ModIndex';
elseif input.comodgram == 1
    X_det = 'CoModGram';
end

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
elseif input.T_entry == 1
    X_save_loc = 'entryT';
end

% save data
X_save = ['PAC_',X_det,'_',X_regs,'_',X_save_loc];
save(X_save);

% plot and stats
if input.modindex == 1
    % difference scores
    MI_sample = cell2mat(data_MI_sample);
    MI_choice = cell2mat(data_MI_choice);
    diffscore_MI = (MI_choice-MI_sample)./(MI_choice+MI_sample);

    [h,p_norm]=swtest(diffscore_MI);
    if p_norm < 0.05
        [p_sign_MI,h,stat_MI]=signrank(diffscore_MI);
    else
        [h,p_ttest_MI,ci_MI_MI,stat]=ttest(diffscore_MI);
    end

    phase_sample = cell2mat(data_phase_sample);
    phase_choice = cell2mat(data_phase_choice);
    diffscore_phase = (phase_choice-phase_sample)./(phase_choice+phase_sample);

    [h,p_norm]=swtest(diffscore_phase);
    if p_norm < 0.05
        [p_sign_phase,h,stat_phase]=signrank(diffscore_phase);
    else
        [h,p_ttest_phase,ci_phase,stat_phase]=ttest(diffscore_phase);
    end
    
    % bar graphs
    figure(); 
    bar(sort(diffscore_phase),'k'); 
    box off
    hold on;
    %line([mean(diffscore_phase) mean(diffscore_phase)],xlim,'Color',[1 0 0],'linestyle','--')
    %plot(ylim,[mean(diffscore_phase) mean(diffscore_phase)],'LineWidth',1,'Color','r','linestyle','--')
    
    figure(); 
    bar(phase_sample,'r')
    hold on
    plot(phase_sample,'r')
    hold on;
    bar(phase_choice,'b')
    hold on;
    plot(phase_choice,'b');
    box off

    figure();
    plot((phase_sample))
    hold on
    plot((phase_choice))
    box off
    
    [h,p]=kstest2(phase_choice,phase_sample)
    
elseif input.comodgram == 1
    phase_map_choice_var = phase_map_choice(~cellfun('isempty',phase_map_choice));
    phase_map_sample_var = phase_map_sample(~cellfun('isempty',phase_map_sample));

    % make into 3D matrix
    for i = 1:length(phase_map_choice_var)
        phase_sample_matrix(:,:,i) = phase_map_sample_var{i};
        phase_choice_matrix(:,:,i) = phase_map_choice_var{i};
    end
    
    phase_sample = mean(phase_sample_matrix,3);
    phase_choice = mean(phase_choice_matrix,3);
    
    % redefine these
    phase_bins = 18;
    amplitude_freq_bins = 1;%signal_data.amplitude_bandpass(2)-signal_data.amplitude_bandpass(1);
    phase_freq_bins = 1;%signal_data.phase_bandpass(2)-signal_data.phase_bandpass(1);
    signal_data.phase_bandpass     = [4 12];
    signal_data.amplitude_bandpass = [30 100];    
    amplitude_highpass = ((signal_data.amplitude_bandpass(:,1))+amplitude_freq_bins:amplitude_freq_bins:signal_data.amplitude_bandpass(:,2));
    
    x_label_temp = linspace(input.phase_bandpass(1),input.phase_bandpass(2),size(phase_sample,2));
    y_label_temp = linspace(amplitude_highpass(1),amplitude_highpass(end),size(phase_sample,1));
    
    figure('color',[1 1 1])
    pcolor(x_label_temp,y_label_temp,phase_sample); % x pos was M.PhaseAxis
    set(gca,'fontsize', 13);
    colormap(jet)
    colorbar   
    caxis([0.0548 0.0563])    
    shading 'interp'
    ylabel('Frequency (Hz)')
    xlabel('Theta Phase')
    
    figure('color',[1 1 1])
    pcolor(M.PhaseAxis,amplitude_highpass,phase_choice)
    set(gca,'fontsize', 13);    
    colormap(jet)
    colorbar
    %caxis([0.0552 0.0561])
    caxis([0.0548 0.0563])        
    shading 'interp'
    ylabel('Frequency (Hz)')
    xlabel('Theta Phase')    
    
    figure('color',[1 1 1])
    pcolor(M.PhaseAxis,amplitude_highpass,squeeze(mean(cat(3,phase_sample,phase_choice),3)))
    set(gca,'fontsize', 13);    
    colormap(jet)
    colorbar
    %caxis([0.0552 0.0561])
    shading 'interp'
    ylabel('Frequency (Hz)')
    xlabel('Theta Phase')     
    
end
