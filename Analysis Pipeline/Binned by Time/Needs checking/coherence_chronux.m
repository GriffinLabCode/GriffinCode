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

function [C,f] = coherence_chronux(datafolder,input,Int,params)
    
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
                elseif input.T_entry_minus2 == 1;
                    time = [(Int(triali,5)-(2*1e6)) (Int(triali,5))];                        
                end
            elseif input.Tentry_longepoch == 1;
                time = [(Int(triali,5)-(2*1e6)) (Int(triali,5)+(1*1e6))];
            elseif input.T_DataDriven == 1
                time = [(Int(triali,5)-(0.8*1e6)) (Int(triali,5)+(0.2*1e6))];    
            elseif input.T_beforeEffect == 1
                time = [(Int(triali,5)-(2*1e6)) (Int(triali,5)-(1*1e6))];
            elseif input.goal_entry == 1
                time = [(Int(triali,1)-(1*1e6)) (Int(triali,1)+(1*1e6))];                
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
            if input.Tjunction == 1 || input.time_freq == 1 || input.T_entry_minus2 == 1 || input.T_DataDriven == 1 || input.T_beforeEffect == 1
                data1_clean{triali} = rmlinesmovingwinc(data1_cleantemp{triali},[0.5 0.01],10,params,'n');
                data2_clean{triali} = rmlinesmovingwinc(data2_cleantemp{triali},[0.5 0.01],10,params,'n');
            else
                data1_clean{triali} = rmlinesc(data1_cleantemp{triali},params,[],'n');
                data2_clean{triali} = rmlinesc(data2_cleantemp{triali},params,[],'n');
            end   

        end
        
        %% coherence
            % concatenate data in the format samples x trials
            data1_all = horzcat(data1_clean{:});
            data2_all = horzcat(data2_clean{:});
            
            if input.time_freq == 1
                 [C,phi,S12,S1,S2,t,f,confC,phistd,Cerr]=cohgramc(data1_all,data2_all,params.movingwin,params);
            else % coherency across broad-band spectrum
                % coherency
                [C,phi,S12,S1,S2,f,confC,phistd,Cerr]=coherencyc(data1_all,data2_all,params);
            end
    catch
        disp('missing lfp')
        C = NaN;
        f = NaN;
    end
end

