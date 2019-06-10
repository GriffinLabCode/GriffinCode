%% Using coherence to extract entrainment
%
% This function utilizes coherence to pinpoint when to extract spiking data
% and phase data.
% 
% ----- INPUTS ----- 
% datafolder: string variable that tells which session to pull from
% input:      struct array - see 'get_instLFP_inputs.mat'
% Int:        matrix containing timestamps data for maze locations
%
% ----- OUTPUTS ----- 
% Coh_data: cell array containing coherence data
% Coh_mean: cell array containing mean coherence data
%
% written by John Stout

function [Coh_data,Coh_mean,fr,fr_mean,frex] = coherence_firingrates(datafolder,input,Int)
    
    try
        % check if pfc data exists
        if input.Prelimbic == 1
            region = '\PrL_locdetrend.mat';
        elseif input.AnteriorCingulate == 1
            region = '\ACC.mat';
        elseif input.mPFC_good == 1
            region = '\mPFC.mat';
        end

        % Henry mentioned he detrended data for all LFP analyses. THis data
        % is preemtively detrended via locdetrend. Each trial is cleaned
        % via rmlinesmovingwin
        load(strcat(datafolder,region)); 
            EEG_pfc = Samples(:)';

        load(strcat(datafolder,'\HPC_locdetrend.mat'));   
            EEG_hpc = Samples(:)';

        %% set parameters
        params.fpass           = input.phase_bandpass; 
        params.tapers           = [3 5];    %[2 3]
        params.trialave         = 0;
        params.err              = [2 .05];
        params.pad              = 0;
        %params.fpass            = [0 100]; % [1 100]
        params.Fs               = SampleFrequencies(1,1); 

        movingwin_yn            = 0; % 1 for yes, 0 for no

        %% reformat timestamps
        % linspace(Timestamps(1,1),Timestamps(1,end),length(EEG_pfc));  % old way
        %cd ('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
        [Timestamps_new, ~] = interp_TS_to_CSC_length_non_linspaced(Timestamps, Samples); % figure; subplot 121; plot(Timestamps); subplot 122; plot(Timestamps_new)

        Timestamps_og = Timestamps;
        Timestamps = [];
        Timestamps = Timestamps_new;

        %% load VT data
        load(strcat(datafolder,'\VT1.mat'));
        load(strcat(datafolder,'\Events.mat'));

        %%  Extract location data
        for triali=1:size(Int,1) % trial

            % vector of start and stop times

            % note: you can't use delay iti here yet since int file is gonna rely
            % on Int being defined as sample or choice Int 
            time = [];
            %time = [(Int(triali,5)-(1*1e6)) (Int(triali,5)+(1*1e6))];
            %time = [(Int(triali,6)-(2*1e6)) (Int(triali,6))];
            %time = [(Int(triali,1)) (Int(triali,1)+(2*1e6))]; 
            %time = [(Int(triali,6)-(1*1e6)) (Int(triali,6))];
            %time = [(Int(triali,5)-(1*1e6)) (Int(triali,5))];
            %time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5)+(0.5*1e6))];
            time = [(Int(triali,1)) (Int(triali,1)+(1.5*1e6))];  
            %time = [(Int(triali,1)) (Int(triali,1)+(1*1e6))];
            %time = [(Int(triali,1)+(0.5*1e6)) (Int(triali,1)+(1.5*1e6))];
            %time = [(Int(triali,1)) (Int(triali,6))];
            %time = [(Int(triali,1)+0.5*1e6) (Int(triali,6)-(0.5*1e6))];

            data1{triali} = EEG_pfc(Timestamps > time(1,1) & Timestamps < time(1,2));
            data2{triali} = EEG_hpc(Timestamps > time(1,1) & Timestamps < time(1,2));

            %x_label = linspace(0,(size(data1{triali},2)/params.Fs),size(data1{triali},2));
            %figure(); plot(x_label,data1{triali},'r'); hold on; plot(x_label,data2{triali},'b');
            %xlabel('time (sec)'); ylabel('voltage');
            %legend('pfc','hpc','Location','southeast'); box off
            
            %% clean lfp
            % do this after you extract because it can change the length of
            % the lfp by a small amount
            data1_clean{triali} = rmlinesmovingwinc(data1{triali},[1 0.05],10,params,'n');
            data2_clean{triali} = rmlinesmovingwinc(data2{triali},[1 0.05],10,params,'n');

            %% calculate coherence
            % loop across the bins
            [Coh_data{triali},phi,S12,S1,S2,frex{triali},confC,phistd,Cerr] = ...
                coherencyc(data1_clean{triali}',data2_clean{triali}',params); 

            Coh_mean{triali} = mean(Coh_data{triali});
            clear C phi S12 S1 S2 f confC phistd Cerr

            % x_label = linspace(0.5,(length(win_bin)-1)/2,length(win_bin)-1);
            % figure(); stem(x_label,Coh_mean{triali},'m'); ylabel('coherence'); xlabel('time (sec) from stem entry to goal-arm entry')
            % hold on; plot(xlim,[.7 .7],'LineWidth',1,'Color','k','linestyle','--')
            % hold on; plot(xlim,[.4 .4],'LineWidth',1,'Color','b','linestyle','--')

            %% get spike data
            cd(datafolder);
            clusters = [];
            clusters = dir('TT*.txt');

            % calculate firing rate
            for ci = 1:size(clusters,1)
                spk = [];
                spk = textread(clusters(ci).name);
                fr{ci}{triali} = (length(find(spk > time(1,1) & ...
                    spk < time(1,2))))/((time(1,2)-time(1,1))/1e6); 
            end          
        end
        
        % average trial-rates
        for m = 1:length(fr)
            fr_mean(m) = mean(cell2mat(fr{m}));
        end
        
    catch
        disp('missing lfp')
    end
end

