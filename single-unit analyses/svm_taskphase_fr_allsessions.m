%% svm_taskphase_fr_allsessions
%
% INPUT: input: a struct array that sets parameters for the function to
% follow
%
% OUTPUTS: svm: a struct array containing firing rates for all maze bins
%          behavior_accuracy - a variable containing correct and incorrect
%          trials. Note that if size(behavior_accuracy,1)=36, and Int file
%          was made from DNMP task, then 1 is first trial sample, 2 is
%          first trial choice etc...
%
% written by John Stout

function [svm,behavior_accuracy,timeSpent_sample,timeSpent_choice]=svm_taskphase_fr_allsessions(input)
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
    
% initialize some variables
delay_pop       = cell([1 size(input.rat,2)]);
iti_pop         = cell([1 size(input.rat,2)]);
stem_sample_pop = cell([1 size(input.rat,2)]);
stem_choice_pop = cell([1 size(input.rat,2)]);
t_sample_pop    = cell([1 size(input.rat,2)]);
t_choice_pop    = cell([1 size(input.rat,2)]);
GA_sample_pop   = cell([1 size(input.rat,2)]);
GA_choice_pop   = cell([1 size(input.rat,2)]);
GZ_sample_pop   = cell([1 size(input.rat,2)]);
GZ_choice_pop   = cell([1 size(input.rat,2)]);
RA_sample_pop   = cell([1 size(input.rat,2)]);
RA_choice_pop   = cell([1 size(input.rat,2)]);
delay_early     = cell([1 size(input.rat,2)]);
iti_early       = cell([1 size(input.rat,2)]);
delay_late      = cell([1 size(input.rat,2)]);
iti_late        = cell([1 size(input.rat,2)]);
behavior_accuracy   = cell([1 size(input.rat,2)]);
timeSpent_sample = cell([1 size(input.rat,2)]);
timeSpent_choice = cell([1 size(input.rat,2)]);

%% calculate firing rate for all sessions
for iii = 1:size(input.rat,2)
    kendog = input.rat{iii}
    
    for nn = kendog %[15:23 32:39] %kendog %[3:14 24:31]%kendog

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
        if input.noradrenergic == 1
            clusters = dir('no*.txt');
        else
            clusters   = dir('TT*.txt');
        end
        
        if isempty(clusters)==1
            continue
        end
        
        if input.correct == 1
            Int = Int(find(Int(:,4)==0),:);
        elseif input.incorrect == 1
            Int = Int(find(Int(:,4)==1),:);
            if isempty(Int) == 1
                continue
            end
        else
            Int = Int;
        end
            
        TimeStamps = TimeStamps_VT;

        % Create index of sample and choice trials
        sample_trials = (1:2:size(Int,1));
        choice_trials = (2:2:size(Int,1));     

    %% Create firing rate arrays
        for ci=1:length(clusters)
            cd(datafolder);
            spikeTimes = textread(clusters(ci).name);
            cluster    = clusters(ci).name(1:end-4);

            % ITI    
            for i = 1:length(sample_trials)-1
                iti_rate(i,:) = (length(find(spikeTimes>Int(choice_trials(i),8) &...
                    spikeTimes<Int(choice_trials(i)+1,1))))/((Int(choice_trials(i)...
                    +1,1)-Int(choice_trials(i),8))/1e6);
            end  
            iti_rates(:,ci) = iti_rate;
            
           % ITI    
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
            svm_temp_ITI_last10(:,ci) = fr_last10;
            svm_temp_ITI_first10(:,ci) = fr_first10;                        
            
            clear spk_temp_first10 numspikes_first10 ...
                time_temp_first10 time_temp_first10 fr_first10 ...
                spk_temp_last10 numspikes_last10 time_temp_last10 ...
                time_temp_last10 fr_last10            
            
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
            svm_temp_Delay_first10(:,ci) = fr_first10;
            svm_temp_Delay_last10(:,ci)  = fr_last10;


            clear spk_temp_first10 numspikes_first10 ...
                time_temp_first10 time_temp_first10 fr_first10 ...
                spk_temp_last10 numspikes_last10 time_temp_last10 ...
                time_temp_last10 fr_last10            
            
            for i = 1:size(sample_trials,2)
            % sample stem                 
                % sample
                stem_sample(i) = (length(find(spikeTimes>Int(sample_trials(i),1) &...
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
            % store data
            stem_sample_rates(:,ci) = stem_sample;
            stem_choice_rates(:,ci) = stem_choice;
            t_sample_rates(:,ci)    = t_sample;
            t_choice_rates(:,ci)    = t_choice;
            GA_sample_rates(:,ci)   = GA_sample;
            GA_choice_rates(:,ci)   = GA_choice;
            GZ_sample_rates(:,ci)   = GZ_sample;
            GZ_choice_rates(:,ci)   = GZ_choice;
            RA_sample_rates(:,ci)   = RA_sample;
            RA_choice_rates(:,ci)   = RA_choice;
                   
            % house-keeping
            clear delay_rate iti_rate stem_sample stem_choice t_sample...
                t_choice GA_sample GA_choice GZ_sample GZ_choice...
                RA_sample RA_choice  spk_temp_first10 numspikes_first10 ...
                time_temp_first10 time_temp_first10 fr_first10 ...
                spk_temp_last10 numspikes_last10 time_temp_last10 ...
                time_temp_last10 fr_last10

            % save correct and incorrect index 
            corr_incorr_idx(:,ci) = Int(:,4);
            
            % store timespent at cp
            time_spent_sample(:,ci) = ((Int(sample_trials,6)-...
                Int(sample_trials,5)))/1e6;
            time_spent_choice(:,ci) = ((Int(choice_trials,6)-...
                Int(choice_trials,5)))/1e6;
            
        end
        % combine cells across sessions within input.rat variable
        delay_pop{iii}       = horzcat(delay_rates,delay_pop{iii});
        iti_pop{iii}         = horzcat(iti_rates,iti_pop{iii});
        stem_sample_pop{iii} = horzcat(stem_sample_rates,...
                                stem_sample_pop{iii});
        stem_choice_pop{iii} = horzcat(stem_choice_rates,...
                                stem_choice_pop{iii});
        t_sample_pop{iii}    = horzcat(t_sample_rates,t_sample_pop{iii});
        t_choice_pop{iii}    = horzcat(t_choice_rates,t_choice_pop{iii});
        GA_sample_pop{iii}   = horzcat(GA_sample_rates,GA_sample_pop{iii});
        GA_choice_pop{iii}   = horzcat(GA_choice_rates,GA_choice_pop{iii});
        GZ_sample_pop{iii}   = horzcat(GZ_sample_rates,GZ_sample_pop{iii});
        GZ_choice_pop{iii}   = horzcat(GZ_choice_rates,GZ_choice_pop{iii});
        RA_sample_pop{iii}   = horzcat(RA_sample_rates,RA_sample_pop{iii});
        RA_choice_pop{iii}   = horzcat(RA_choice_rates,RA_choice_pop{iii});
        
        delay_early{iii}     = horzcat(svm_temp_Delay_first10,delay_early{iii});
        iti_early{iii}       = horzcat(svm_temp_ITI_first10,iti_early{iii});
        delay_late{iii}      = horzcat(svm_temp_Delay_last10,delay_late{iii});
        iti_late{iii}        = horzcat(svm_temp_ITI_last10,iti_late{iii});
        
        behavior_accuracy{iii} = horzcat(corr_incorr_idx,...
            behavior_accuracy{iii});
        
        timeSpent_sample{iii} = horzcat(time_spent_sample,...
            timeSpent_sample{iii});
        
        timeSpent_choice{iii} = horzcat(time_spent_choice,...
            timeSpent_choice{iii});        
        
        % house-keeping
        clear delay_rates iti_rates stem_sample_rates stem_choice_rates...
            t_sample_rates t_choice_rates GA_sample_rates ...
            GA_choice_rates GZ_sample_rates GZ_choice_rates ...
            RA_sample_rates RA_choice_rates corr_incorr_idx ...
            svm_temp_Delay_first10 svm_temp_Delay_last10 ...
            svm_temp_ITI_first10 svm_temp_ITI_last10 time_spent_sample ...
            time_spent_choice
    end
end   

% combine delay and iti variables
% for svm_var, 1:17 is delay, 18:34 is iti
for gee = 1:size(input.rat,2);
    svm.sb{gee} = vertcat(delay_pop{gee},iti_pop{gee});
end
% combine sample and choice
for gee = 1:size(input.rat,2)
    svm.stem{gee}     = vertcat(stem_sample_pop{gee},stem_choice_pop{gee});
    svm.t_junct{gee}  = vertcat(t_sample_pop{gee},t_choice_pop{gee});
    svm.goalArm{gee}  = vertcat(GA_sample_pop{gee},GA_choice_pop{gee});
    svm.goalZone{gee} = vertcat(GZ_sample_pop{gee},GZ_choice_pop{gee});
    svm.retArm{gee}   = vertcat(RA_sample_pop{gee},RA_choice_pop{gee});    
    svm.early{gee}    = vertcat(delay_early{gee},iti_early{gee});
    svm.late{gee}     = vertcat(delay_late{gee},iti_late{gee});
end

end % end function