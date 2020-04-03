%% Power analysis
% this function estimate spectral power
% 
% ----- INPUTS ----- 
% datafolder: string variable that tells which session to pull from
% input:      struct array - see 'get_instLFP_inputs.mat'
% Int:        matrix containing timestamps data for maze locations
%
% ----- OUTPUTS ----- 
% pow_data: cell array containing coherence data
% pow_mean: cell array containing mean coherence data
% time_mean: averaged time spent in location of interest
%
% written by John Stout

function [power,frex] = power_fun(datafolder,input,Int,params)
    
    % try - incase the variables don't exist
    try
        if input.pow_pfc == 1
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
            load(strcat(datafolder,region),'Samples','Timestamps','SampleFrequencies'); 
                %EEG_pfc = Samples(:)';
                EEG1 = Samples(:)';
        end
        
        if input.pow_hpc == 1
            load(strcat(datafolder,'\HPC.mat'),'Samples','Timestamps','SampleFrequencies');   
                %EEG_hpc = Samples(:)';
                 EEG1 = Samples(:)';
        end
        
        if input.pow_re == 1
            load(strcat(datafolder,'\Re.mat'),'Samples','Timestamps','SampleFrequencies')
                EEG1 = Samples(:)';
        end
      
        % define the sampling rate parameter
        params.Fs = SampleFrequencies(1,1);   

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
            
      % stem to T-exit
      time = [(Int(triali,5)-(2*1e6)) (Int(triali,5)+(1*1e6))];
      
      % effect window
      %time = [(Int(triali,5)-(0.8*1e6)) (Int(triali,5)+(0.2*1e6))];
         
      % before effect window
      %time = [(Int(triali,5)-(2*1e6)) (Int(triali,5)-(1*1e6))];
      
      
      %time = [(Int(triali,6)-(2*1e6)) (Int(triali,6))];
            %time = [(Int(triali,1)) (Int(triali,1)+(2*1e6))]; 
      %time = [(Int(triali,6)-(1.5*1e6)) Int(triali,6)];  
            %time = [(Int(triali,5)-(1*1e6)) (Int(triali,5))];
            %time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5)+(0.5*1e6))];
       %time = [(Int(triali,1)) (Int(triali,1)+(1.5*1e6))];  
            %time = [(Int(triali,1)) (Int(triali,1)+(1*1e6))];
            %time = [(Int(triali,1)+(0.5*1e6)) (Int(triali,1)+(1.5*1e6))];
            %time = [(Int(triali,1)) (Int(triali,6))];
            %time = [(Int(triali,1)+0.5*1e6) (Int(triali,6)-(0.5*1e6))];
       %time = [(Int(triali,5)) (Int(triali,6))];
       %time = [(Int(triali,1)) (Int(triali,5))];
        
            data1{triali} = EEG1(Timestamps > time(1,1) & Timestamps < time(1,2));
            %data2{triali} = EEG_2(Timestamps > time(1,1) & Timestamps < time(1,2));

            %x_label = linspace(0,(size(data1{triali},2)/params.Fs),size(data1{triali},2));
            %figure(); plot(x_label,data1{triali},'r'); hold on; plot(x_label,data2{triali},'b');
            %xlabel('time (sec)'); ylabel('voltage');
            %legend('pfc','hpc','Location','southeast'); box off
            
            %% clean lfp
            % do this after you extract because it can change the length of
            % the lfp by a small amount - also saves so much time
            % first detrend
            data1_cleantemp{triali} = locdetrend(data1{triali});
            %data2_cleantemp{triali} = locdetrend(data2{triali});
            % next clean
            data1_clean{triali} = rmlinesmovingwinc(data1_cleantemp{triali},[0.5 0.01],10,params,'n');
            %data2_clean{triali} = rmlinesmovingwinc(data2_cleantemp{triali},[1 0.05],10,params,'n');
            %data1_clean{triali} = rmlinesc(data1_cleantemp{triali},params,[],'n');
            %data2_clean{triali} = rmlinesc(data2_cleantemp{triali},params,[],'n');
        end
        if params.trialave == 0
            % concatenate data
            signal = vertcat(data1_clean{:});
        elseif params.trialave == 1
            signal = horzcat(data1_clean{:});
        end
        
            %% estimate spectral power
            % loop across the bins
            % next calculate power
            if input.freqplot == 1 % powerXfreq
                [power,frex,power_err]  = mtspectrumc(signal,params);
            elseif input.specgram == 1 % freqXtimeXpower
                [power,t,frex,power_err]=mtspecgramc(signal,params.movingwin,params);
            end
            % x_label = linspace(0.5,(length(win_bin)-1)/2,length(win_bin)-1);
            % figure(); stem(x_label,pow_mean{triali},'m'); ylabel('coherence'); xlabel('time (sec) from stem entry to goal-arm entry')
            % hold on; plot(xlim,[.7 .7],'LineWidth',1,'Color','k','linestyle','--')
            % hold on; plot(xlim,[.4 .4],'LineWidth',1,'Color','b','linestyle','--')

        
    catch
        disp('missing lfp')
    end
end