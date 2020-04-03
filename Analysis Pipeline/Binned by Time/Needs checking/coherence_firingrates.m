%% Coherence function that utilizes chronux toolbox
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
% time_mean: averaged time spent in location of interest
%
% written by John Stout

function [Coh_data,Coh_mean,fr,fr_mean,frex,time_mean] = coherence_firingrates(datafolder,input,Int,params)
    
    % try - incase the variables don't exist
    try
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
            load(strcat(datafolder,region),'Samples','Timestamps','SampleFrequencies'); 
                %EEG_pfc = Samples(:)';
                EEG1 = Samples(:)';
        end
        
        if input.coh_hpc == 1
            load(strcat(datafolder,'\HPC.mat'),'Samples','Timestamps','SampleFrequencies');   
                %EEG_hpc = Samples(:)';
                 EEG2 = Samples(:)';
        end
        
        if input.coh_re == 1
            load(strcat(datafolder,'\Re.mat'),'Samples','Timestamps','SampleFrequencies')
                EEG3 = Samples(:)';
        end
        
        % format EEG_* variable so that it's flexible. We want EEG_1 and
        % EEG_2 to remain constant in terms of the variable name, but we
        % want their lfp to change as a function of the region input.
        if input.coh_pfc == 1 && input.coh_hpc == 1
            EEG_1 = EEG1;
            EEG_2 = EEG2;
        elseif input.coh_pfc == 1 && input.coh_re == 1
            EEG_1 = EEG1;
            EEG_2 = EEG3;
        elseif input.coh_hpc == 1 && input.coh_re == 1
            EEG_1 = EEG2;
            EEG_2 = EEG3;
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
                %time = [(Int(triali,5)-(1*1e6)) (Int(triali,5)+(1*1e6))];
                %time = [(Int(triali,6)-(2*1e6)) (Int(triali,6))];
                %time = [(Int(triali,1)) (Int(triali,1)+(2*1e6))]; 
          %time = [(Int(triali,6)-(1.5*1e6)) Int(triali,6)];  
                %time = [(Int(triali,5)-(1*1e6)) (Int(triali,5))];
           %time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5)+(0.5*1e6))];
           %time = [(Int(triali,1)) (Int(triali,1)+(1.5*1e6))];  
                %time = [(Int(triali,1)) (Int(triali,1)+(2*1e6))];
                %time = [(Int(triali,1)+(0.5*1e6)) (Int(triali,1)+(1.5*1e6))];
                %time = [(Int(triali,1)) (Int(triali,6))];
                %time = [(Int(triali,1)+0.5*1e6) (Int(triali,6)-(0.5*1e6))];
           %time = [(Int(triali,5)) (Int(triali,6))];
               if input.stem_bin == 1
                    time = [(Int(triali,1)) (Int(triali,5))];
               elseif input.tjunction_bin == 1
                    time = [(Int(triali,5)) (Int(triali,6))];
               end               

                data1{triali} = EEG_1(Timestamps > time(1,1) & Timestamps < time(1,2));
                data2{triali} = EEG_2(Timestamps > time(1,1) & Timestamps < time(1,2));

                %x_label = linspace(0,(size(data1{triali},2)/params.Fs),size(data1{triali},2));
                %figure(); plot(x_label,data1{triali},'r'); hold on; plot(x_label,data2{triali},'b');
                %xlabel('time (sec)'); ylabel('voltage');
                %legend('pfc','hpc','Location','southeast'); box off

                %% clean lfp
                % do this after you extract because it can change the length of
                % the lfp by a small amount - also saves so much time
                % first detrend

                % detrend            
                data1_cleantemp{triali} = locdetrend(data1{triali});
                data2_cleantemp{triali} = locdetrend(data2{triali});                

                % clean           
                if input.Tjunction == 1
                    data1_clean{triali} = rmlinesmovingwinc(data1_cleantemp{triali},[1 0.05],10,params,'n');
                    data2_clean{triali} = rmlinesmovingwinc(data2_cleantemp{triali},[1 0.05],10,params,'n');
                else
                    data1_clean{triali} = rmlinesc(data1_cleantemp{triali},params,[],'n');
                    data2_clean{triali} = rmlinesc(data2_cleantemp{triali},params,[],'n');
                end   

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

                % get timespent
                timespent(triali) = (time(1,2)-time(1,1))/1e6;
            end

            % average trial-rates
            for m = 1:length(fr)
                fr_mean(m) = mean(cell2mat(fr{m}));
            end

            % average times
            time_mean = mean(timespent);
    catch
    end
end

