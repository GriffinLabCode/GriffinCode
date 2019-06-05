%% CreateNeuron
% this script creates a variable called neuron. 
%
% neuron is a structure array containing cluster ID, as well as various
% metrics of interest.
%
% written by John Stout

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');
input = get_inputs;

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
    
% initialize struct variables
neuron = [];
neuron_temp = [];

%% calculate firing rate for all sessions
for nn = 3:length(folder_names)

        Datafolders = Datafolders;
        cd(Datafolders);
        folder_names = dir;
        temp_folder = folder_names(nn).name;
        cd(temp_folder);
        datafolder = pwd;
        cd(datafolder);    

        % define and load some variables 
        load (strcat(datafolder,'\Int_file.mat')); 
        load(strcat(datafolder, '\VT1.mat'));
        cd(Datafolders);
        folder_names = dir;
        cd(datafolder);
        clusters   = dir('TT*.txt');
        TimeStamps = TimeStamps_VT;

        % Create index of sample and choice trials
        sample_trials = (1:2:size(Int,1));
        choice_trials = (2:2:size(Int,1));     

    %% Create firing rate arrays
        for ci=1:length(clusters)
            cd(datafolder);
            spikeTimes = textread(clusters(ci).name);
            cluster    = clusters(ci).name(1:end-4);
            neuron_temp(1,ci).name = clusters(ci).name(1:end-4);
          %{  
            % ITI    
            for i = 1:length(sample_trials)-1
                iti_rate(i,:) = (length(find(spikeTimes>Int(choice_trials(i),8) &...
                    spikeTimes<Int(choice_trials(i)+1,1))))/((Int(choice_trials(i)...
                    +1,1)-Int(choice_trials(i),8))/1e6);
            end  
            iti_rates(:,ci) = iti_rate;
            
            % delay
            for i = 2:size(sample_trials,2)
                delay_rate(i,:) = (length(find(spikeTimes>Int(sample_trials(i),8) &...
                    spikeTimes<Int(choice_trials(i),1))))/((Int(choice_trials(i),1)-...
                    Int(sample_trials(i),8))/1e6);
            end
            % first row is zero
            delay_rate(1,:) = [];            
            % combine data across cells for each session
            delay_rates(:,ci) = delay_rate;
            
           % ITI early and late    
            for i = 2:length(sample_trials)
                %% last 10 seconds
                spk_temp_last10 = find(spikeTimes>Int(sample_trials(i),1)-(10*1e6) & spikeTimes<Int(sample_trials(i),1));
                numspikes_last10 = length(spk_temp_last10);
                time_temp_last10 = (Int(sample_trials(i),1))-(Int(sample_trials(i),1)-(10*1e6));
                time_temp_last10 = time_temp_last10/1e6;
                fr_last10(i,:) = numspikes_last10/time_temp_last10;

                %% First 10 seconds
                spk_temp_first10 = find(spikeTimes>Int(sample_trials(i)-1,8) & spikeTimes<Int(sample_trials(i)-1,8)+(10*1e6));
                numspikes_first10 = length(spk_temp_first10);
                time_temp_first10 = (Int(sample_trials(i)-1,8)+(10*1e6)) - Int(sample_trials(i)-1,8);
                time_temp_first10 = time_temp_first10/1e6;
                fr_first10(i,:) = numspikes_first10/time_temp_first10;
            end
            fr_first10(1,:) = [];
            fr_last10(1,:)  = [];
            svm_temp_ITI_last10 = fr_last10;
            svm_temp_ITI_first10 = fr_first10;                        
            
            clear spk_temp_first10 numspikes_first10 ...
                time_temp_first10 time_temp_first10 fr_first10 ...
                spk_temp_last10 numspikes_last10 time_temp_last10 ...
                time_temp_last10 fr_last10            
            
            for i = 2:length(choice_trials)
                %% Last 10 seconds delay
                spk_temp_last10 = find(spikeTimes>Int(choice_trials(i),1)-(10*1e6) & spikeTimes<Int(choice_trials(i),1));
                numspikes_last10 = length(spk_temp_last10);
                time_temp_last10 = (Int(choice_trials(i),1))-(Int(choice_trials(i),1)-(10*1e6));
                time_temp_last10 = time_temp_last10/1e6;
                fr_last10(i,:) = numspikes_last10/time_temp_last10;

                %% First 10 seconds delay
                spk_temp_first10 = find(spikeTimes>Int(sample_trials(i),8)...
                    & spikeTimes<Int(sample_trials(i),8)+(10*1e6)); 
                numspikes_first10 = length(spk_temp_first10);
                time_temp_first10 = Int(sample_trials(i),8)+(10*1e6) - ...
                    Int(sample_trials(i),8);
                time_temp_first10 = time_temp_first10/1e6;
                fr_first10(i,:) = numspikes_first10/time_temp_first10;
            
            end
            fr_first10(1,:) = [];
            fr_last10(1,:)  = [];
            svm_temp_Delay_first10 = fr_first10;
            svm_temp_Delay_last10  = fr_last10;

           %}
            clear spk_temp_first10 numspikes_first10 ...
                time_temp_first10 time_temp_first10 fr_first10 ...
                spk_temp_last10 numspikes_last10 time_temp_last10 ...
                time_temp_last10 fr_last10                        
  
            for i = 1:size(sample_trials,2)
            % sample stem                 
                % sample
                stem_sample(i)  = (length(find(spikeTimes>Int(sample_trials(i),1) &...
                    spikeTimes<Int(sample_trials(i),5))))/((Int(sample_trials(i)...
                    ,5)-Int(sample_trials(i),1))/1e6);
                   
                % choice
                stem_choice(i) = (length(find(spikeTimes>Int(choice_trials(i),1) &...
                    spikeTimes<Int(choice_trials(i),5))))/((Int(choice_trials(i)...
                    ,5)-Int(choice_trials(i),1))/1e6); 
                           
            % tjunction
                % sample
                t_sample(i) = (length(find(spikeTimes>Int(sample_trials(i),5) &...
                    spikeTimes<Int(sample_trials(i),6))))/((Int(sample_trials(i)...
                    ,6)-Int(sample_trials(i),5))/1e6);
                                                  
                % choice
                t_choice(i) = (length(find(spikeTimes>Int(choice_trials(i),5) &...
                    spikeTimes<Int(choice_trials(i),6))))/((Int(choice_trials(i)...
                    ,6)-Int(choice_trials(i),5))/1e6);    
                                
                
            % goal arms
                % sample
                GA_sample(i) = (length(find(spikeTimes>Int(sample_trials(i),6) &...
                    spikeTimes<Int(sample_trials(i),2))))/((Int(sample_trials(i)...
                    ,2)-Int(sample_trials(i),6))/1e6);
                                 
                
                % choice
                GA_choice(i) = (length(find(spikeTimes>Int(choice_trials(i),6) &...
                    spikeTimes<Int(choice_trials(i),2))))/((Int(choice_trials(i)...
                    ,2)-Int(choice_trials(i),6))/1e6); 
                                 
            % goal zone
                % sample
                GZ_sample(i) = (length(find(spikeTimes>Int(sample_trials(i),2) &...
                    spikeTimes<Int(sample_trials(i),7))))/((Int(sample_trials(i)...
                    ,7)-Int(sample_trials(i),2))/1e6);
                                   
                % choice
                GZ_choice(i) = (length(find(spikeTimes>Int(choice_trials(i),2) &...
                    spikeTimes<Int(choice_trials(i),7))))/((Int(choice_trials(i)...
                    ,7)-Int(choice_trials(i),2))/1e6);  
                              
            % return arm
                % sample
                RA_sample(i) = (length(find(spikeTimes>Int(sample_trials(i),7) &...
                    spikeTimes<Int(sample_trials(i),8))))/((Int(sample_trials(i)...
                    ,8)-Int(sample_trials(i),7))/1e6);
                               
                % choice
                RA_choice(i) = (length(find(spikeTimes>Int(choice_trials(i),7) &...
                    spikeTimes<Int(choice_trials(i),8))))/((Int(choice_trials(i)...
                    ,8)-Int(choice_trials(i),7))/1e6); 
                                
            end
            % store task phase data
            %neuron_temp(1,ci).early_delay_rates = svm_temp_Delay_first10';
            %neuron_temp(1,ci).early_iti_rates   = svm_temp_ITI_first10';   
            %neuron_temp(1,ci).late_delay_rates  = svm_temp_Delay_last10';
            %neuron_temp(1,ci).late_iti_rates    = svm_temp_ITI_last10';
            neuron_temp(1,ci).stem_sample_rates = stem_sample';
            neuron_temp(1,ci).stem_choice_rates = stem_choice';
            neuron_temp(1,ci).t_sample_rates    = t_sample';
            neuron_temp(1,ci).t_choice_rates    = t_choice';
            neuron_temp(1,ci).GA_sample_rates   = GA_sample';
            neuron_temp(1,ci).GA_choice_rates   = GA_choice';
            neuron_temp(1,ci).GZ_sample_rates   = GZ_sample';
            neuron_temp(1,ci).GZ_choice_rates   = GZ_choice';
            neuron_temp(1,ci).RA_sample_rates   = RA_sample';
            neuron_temp(1,ci).RA_choice_rates   = RA_choice';  

            % save correct and incorrect index 
            neuron_temp(1,ci).behavior = Int(:,4);    
            
            % save correct trials rates and DI
            corr_idx  = find(Int(1:2:size(Int(:,4),1),4) == 0);
            diffT_corr = ((mean(t_choice(corr_idx)))-(mean(t_sample(corr_idx))))./...
                ((mean(t_choice(corr_idx)))+(mean(t_sample(corr_idx))));
            diffSt_corr = ((mean(stem_choice(corr_idx)))-(mean(stem_sample(corr_idx))))./...
                ((mean(stem_choice(corr_idx)))+(mean(stem_sample(corr_idx))));
            diffGA_corr = ((mean(GA_choice(corr_idx)))-(mean(GA_sample(corr_idx))))./...
                ((mean(GA_choice(corr_idx)))+(mean(GA_sample(corr_idx))));   
            diffGZ_corr = ((mean(GZ_choice(corr_idx)))-(mean(GZ_sample(corr_idx))))./...
                ((mean(GZ_choice(corr_idx)))+(mean(GZ_sample(corr_idx))));            
            diffRA_corr = ((mean(RA_choice(corr_idx)))-(mean(RA_sample(corr_idx))))./...
                ((mean(RA_choice(corr_idx)))+(mean(RA_sample(corr_idx))));
            
            % save incorrect trials rates and DI
             incor_idx  = find(Int(1:2:size(Int(:,4),1),4) == 1);
                if isempty(incor_idx)==0
                    diffT_incorr = ((mean(t_choice(incor_idx)))-(mean(t_sample(incor_idx))))./...
                        ((mean(t_choice(incor_idx)))+(mean(t_sample(incor_idx))));
                    diffSt_incorr = ((mean(stem_choice(incor_idx)))-(mean(stem_sample(incor_idx))))./...
                        ((mean(stem_choice(incor_idx)))+(mean(stem_sample(incor_idx))));   
                    diffGA_incorr = ((mean(GA_choice(incor_idx)))-(mean(GA_sample(incor_idx))))./...
                        ((mean(GA_choice(incor_idx)))+(mean(GA_sample(incor_idx))));   
                    diffGZ_incorr = ((mean(GZ_choice(incor_idx)))-(mean(GZ_sample(incor_idx))))./...
                        ((mean(GZ_choice(incor_idx)))+(mean(GZ_sample(incor_idx))));            
                    diffRA_incorr = ((mean(RA_choice(incor_idx)))-(mean(RA_sample(incor_idx))))./...
                        ((mean(RA_choice(incor_idx)))+(mean(RA_sample(incor_idx))));   

                    diffT_incorr(isnan(diffT_incorr))=0;                
                    diffSt_incorr(isnan(diffSt_incorr))=0;
                    diffGA_incorr(isnan(diffGA_incorr))=0;
                    diffGZ_incorr(isnan(diffGZ_incorr))=0;
                    diffRA_incorr(isnan(diffRA_incorr))=0;
                elseif isempty(incor_idx)==1  
                    incor_idx     = NaN;
                    diffT_incorr  = NaN;
                    diffSt_incorr = NaN; 
                    diffGA_incorr = NaN; 
                    diffGZ_incorr = NaN;          
                    diffRA_incorr = NaN;
                end

            % replace nans with zero
            diffT_corr(isnan(diffT_corr))=0;  
            diffSt_corr(isnan(diffSt_corr))=0;
            diffGA_corr(isnan(diffGA_corr))=0;
            diffGZ_corr(isnan(diffGZ_corr))=0;
            diffRA_corr(isnan(diffRA_corr))=0;

            % store neuron
            neuron_temp(1,ci).diffSt_corr = diffSt_corr;
            neuron_temp(1,ci).diffT_corr  = diffT_corr;
            neuron_temp(1,ci).diffGA_corr = diffGA_corr;
            neuron_temp(1,ci).diffGZ_corr = diffGZ_corr;
            neuron_temp(1,ci).diffRA_corr = diffRA_corr;
            
            neuron_temp(1,ci).diffSt_incorr = diffSt_incorr;
            neuron_temp(1,ci).diffT_incorr  = diffT_incorr;
            neuron_temp(1,ci).diffGA_incorr = diffGA_incorr;
            neuron_temp(1,ci).diffGZ_incorr = diffGZ_incorr;
            neuron_temp(1,ci).diffRA_incorr = diffRA_incorr;            
            
            % house-keeping
            clear delay_rate iti_rate stem_sample stem_choice t_sample...
                t_choice GA_sample GA_choice GZ_sample GZ_choice...
                RA_sample RA_choice svm_temp_Delay_first10 ...
                svm_temp_ITI_first10 svm_temp_Delay_last10 ...
                svm_temp_ITI_last10 corr_idx diffT_corr diffSt_corr ...
                diffGA_corr diffGZ_corr diffRA_corr incor_idx diffT_incorr...
                diffSt_incorr diffGA_incorr diffGZ_incorr diffRA_incorr                 
        end
        
        % house-keeping
        clear delay_rates iti_rates stem_sample_rates stem_choice_rates...
            t_sample_rates t_choice_rates GA_sample_rates ...
            GA_choice_rates GZ_sample_rates GZ_choice_rates ...
            RA_sample_rates RA_choice_rates corr_incorr_idx   

X = ['finished with session ',num2str(nn-2)];
disp(X)

neuron = horzcat(neuron,neuron_temp);
neuron_temp = [];

end   

    
    