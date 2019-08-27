%% CreateNeuron
% this function creates a structure array called 'neuron' that contains
% multiple parameters for each cell in structure array. This is
% advantageous if you want to select out specific neurons
%
% written by John Stout
clear; clc

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
for nn = 3:length(folder_names) %[3:27,36:length(folder_names)]

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
            % get session firing rate
            fr_session = length((find(spikeTimes>Int(1,1) & ...
                spikeTimes<Int(end))))/((Int(end)-Int(1,1))/1e6);
            
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
            neuron_temp(1,ci).fr_session        = fr_session;
            
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
            
            % save t-junction mean-rates
            t_sampleMean = mean(t_sample(corr_idx));
            t_choiceMean = mean(t_choice(corr_idx));
            t_mean = mean(horzcat(t_sample(corr_idx),t_choice(corr_idx)));
            
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
            
            neuron_temp(1,ci).tmean_sample = t_sampleMean;
            neuron_temp(1,ci).tmean_choice = t_choiceMean;
            neuron_temp(1,ci).tmean_bothphases = t_mean;
            % house-keeping
            clear delay_rate iti_rate stem_sample stem_choice t_sample...
                t_choice GA_sample GA_choice GZ_sample GZ_choice...
                RA_sample RA_choice svm_temp_Delay_first10 ...
                svm_temp_ITI_first10 svm_temp_Delay_last10 ...
                svm_temp_ITI_last10 corr_idx diffT_corr diffSt_corr ...
                diffGA_corr diffGZ_corr diffRA_corr incor_idx diffT_incorr...
                diffSt_incorr diffGA_incorr diffGZ_incorr diffRA_incorr ...
                t_sampleMean t_choiceMean t_mean
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

clearvars -except neuron

diff_stem_inc = extractfield(neuron,'diffSt_incorr');
diff_T_inc    = extractfield(neuron,'diffT_incorr');
diff_GA_inc   = extractfield(neuron,'diffGA_incorr');
diff_GZ_inc   = extractfield(neuron,'diffGZ_incorr');
diff_RA_inc   = extractfield(neuron,'diffRA_incorr');

nan_idx = find(isnan(diff_stem_inc));
diff_stem_inc(isnan(diff_stem_inc))=[];
diff_T_inc(isnan(diff_T_inc))=[];
diff_GA_inc(isnan(diff_GA_inc))=[];
diff_GZ_inc(isnan(diff_GZ_inc))=[];
diff_RA_inc(isnan(diff_RA_inc))=[];

diff_stem = extractfield(neuron,'diffSt_corr');
diff_T    = extractfield(neuron,'diffT_corr');
diff_GA   = extractfield(neuron,'diffGA_corr');
diff_GZ   = extractfield(neuron,'diffGZ_corr');
diff_RA   = extractfield(neuron,'diffRA_corr');

% only assess the same sessions that had incorrect trials
nan_idx = find(isnan(diff_stem));
diff_stem(nan_idx)=[];
diff_T(nan_idx)=[];
diff_GA(nan_idx)=[];
diff_GZ(nan_idx)=[];
diff_RA(nan_idx)=[];


%maze_matrix1 = abs(horzcat(diff_stem',diff_T',diff_GA',diff_GZ',diff_RA'));
%maze_matrix2 = abs(horzcat(diff_stem_inc',diff_T_inc',diff_GA_inc',diff_GZ_inc',diff_RA_inc'));

% mean for all locations into one vector
% remove the abs (absolute value) for directionality
maze_matrix1 = (horzcat(diff_stem',diff_T',diff_GA',diff_GZ',diff_RA'));

% standard error of mean
sem_matrix1 = std(maze_matrix1)/(sqrt(size(maze_matrix1,1)));

%% plot and stats

figure('color',[1 1 1])
    bar(mean(maze_matrix1),'k');
    hold on
    e = errorbar(mean(maze_matrix1),sem_matrix1,'.k');
    e.LineWidth = 1.5;
    set(gca,'XTick',[1,2,3,4,5]);
    set(gca,'xticklabel',[{'stem','t-junction','goal-arms','goal-zone',...
        'return-arms'}]);
    ax = gca;
    ax.XTickLabelRotation = 45;
    axis tight     

% if you've only looked at absolute value - compare t-junction to rest
if isempty(find(maze_matrix1<0)) == 1
    for i = 1:size(maze_matrix1,2)
        [h,p_norm{i}]=swtest(maze_matrix1(:,i))
        try
            if p_norm{i} > 0.05
                [h_ttest,p_ttest{i}]=ttest(maze_matrix1(:,2),maze_matrix1(:,i));
            else
                [p_rank{i},h,stat_rank{i}]=signrank(maze_matrix1(:,2),maze_matrix1(:,i));
            end
        catch
        end
    end
    disp('compared t-junction to rest of abs(diffscore)')
else
    for i = 1:size(maze_matrix1,2)
        [h,p_norm{i}]=swtest(maze_matrix1(:,i))
        try
            if p_norm{i} > 0.05
                [h_ttest,p_ttest{i}]=ttest(maze_matrix1(:,i));
            else
                [p_rank{i},h,stat_rank{i}]=signrank(maze_matrix1(:,i));
            end
        catch
        end
    end    
end

%{
% figure
figure('color',[1 1 1]);
subplot 211
    bar(mean(maze_matrix1),'k');
    hold on
    e = errorbar(mean(maze_matrix1),sem_matrix1,'.k');
    e.LineWidth = 1.5;
   % set(gca,'XTick',[1,2,3,4,5]);
    %set(gca,'xticklabel',[{'stem','t-junction','goal-arms','goal-zone',...
       % 'return-arms'}]);
    %ax = gca;
    %ax.XTickLabelRotation = 45;
    %ylabel('averaged difference score (choice - sample)');
    %ylim([-0.16 .1]);
    %ylabel('averaged DI');
    box off    
    ylim([-0.2 .13])

subplot 212
    bar(mean(maze_matrix2),'r');
    hold on
    e = errorbar(mean(maze_matrix2),sem_matrix2,'.r');
    e.LineWidth = 1.5;
    set(gca,'XTick',[1,2,3,4,5]);
    set(gca,'xticklabel',[{'stem','t-junction','goal-arms','goal-zone',...
        'return-arms'}]);
    ax = gca;
    ax.XTickLabelRotation = 45;
    %ylabel('averaged difference score (choice - sample)');
    %ylim([-0.16 .1]);
    %ylabel('averaged DI');
    box off   
    ylim([-0.2 .13])
    
for i = 1:size(maze_matrix1,2)
    [h(i),p(i)]=signrank(maze_matrix1(:,i))
    %[h(i),p(i)]=ranksum(maze_matrix1(:,i),maze_matrix2(:,i))    
end

p = kruskalwallis(maze_matrix1);


figure('color',[1 1 1]);
    bar(mean(maze_matrix1),'k');
    hold on
    e = errorbar(mean(maze_matrix1),sem_matrix1,'.k');
    e.LineWidth = 1.5;
    set(gca,'XTick',[1,2,3,4,5]);
    set(gca,'xticklabel',[{'stem','t-junction','goal-arms','goal-zone',...
        'return-arms'}]);
    ax = gca;
    ax.XTickLabelRotation = 45;
    %ylabel('averaged difference score (choice - sample)');
    %ylim([-0.16 .1]);
    %ylabel('averaged DI');
    box off    
    %ylim([0 .5])

for i = 1:size(maze_matrix1,2)
    [h,p_norm{i}]=swtest(maze_matrix1(:,i))
    try
        if p_norm{i} > 0.05
            [h_ttest,p_ttest{i}]=ttest(maze_matrix1(:,i),maze_matrix1(:,i));
        else
            [p_rank{i}]=signrank(maze_matrix1(:,i),maze_matrix1(:,i));
        end
    catch
    end
end
    
%} 


%% is the difference score change a result of an increase at sample phase
% compare to session averaged firing rate
fr_session = extractfield(neuron,'fr_session');
fr_t_sam_mean = extractfield(neuron,'tmean_sample');
fr_t_cho_mean = extractfield(neuron,'tmean_choice');

diffscore_sam = (fr_session-fr_t_sam_mean)./((fr_t_sam_mean+fr_session));
diffscore_cho = (fr_session-fr_t_cho_mean)./((fr_t_cho_mean+fr_session));

sem_diffsam = std(diffscore_sam)/(sqrt(length(diffscore_sam)));
sem_diffcho = std(diffscore_cho)/(sqrt(length(diffscore_cho)));   

% fig
figure('color',[1 1 1]);
bar(1, mean(diffscore_sam),'EdgeColor','k','LineWidth',1,'FaceColor',[0.8 0 0])
hold on
errorbar(1,mean(diffscore_sam),sem_diffsam,'Color',[0.8 0 0],'LineWidth',1.5)
bar(2, mean(diffscore_cho),'EdgeColor','k','LineWidth',1,'FaceColor',[0 0 0.6])
errorbar(2,mean(diffscore_cho),sem_diffcho,'Color',[0 0 0.6],'LineWidth',1.5)
ylim([-0.4 0.4]);
set(gca,'FontSize',14)
set(gca,'XTick',[1,2]);
set(gca,'xticklabel',[{'sample phase','choice phase'}]);
ax = gca;
ax.XTickLabelRotation = 45;
box off

% stats
[h,p_samdiff]=swtest(diffscore_sam);
[h,p_chodiff]=swtest(diffscore_cho);

[p_sign_sam,h,stat_sam]=signrank(diffscore_sam);
[p_sign_cho,h,stat_cho]=signrank(diffscore_cho);
[p_bw_Phases,h,stat]=signrank(diffscore_sam,diffscore_cho);


%%

% or decrease at choice?
% attempt 4 modified
clearvars -except neuron
t_sam_mean = extractfield(neuron,'tmean_sample');
t_cho_mean = extractfield(neuron,'tmean_choice');
t_mean = extractfield(neuron,'tmean_bothphases');

% take the norm. difference from the mean
t_diff_sam = (t_sam_mean-t_mean)./(t_sam_mean+t_mean);
t_diff_cho = (t_cho_mean-t_mean)./(t_cho_mean+t_mean);
t_diff_sam(isnan(t_diff_sam))=[];
t_diff_cho(isnan(t_diff_cho))=[];

sem_diffsam = std(t_diff_sam)/(sqrt(length(t_diff_sam)));
sem_diffcho = std(t_diff_cho)/(sqrt(length(t_diff_cho)));   

[h,p_samdiff]=swtest(t_diff_sam);
[h,p_chodiff]=swtest(t_diff_cho);

[p_sign_sam,h,stat_sam]=signrank(t_diff_sam);
[p_sign_cho,h,stat_cho]=signrank(t_diff_cho);
[p_ranksum,h,stat]=ranksum(t_diff_sam,t_diff_cho);

figure('color',[1 1 1]);
bar(1, median(t_diff_sam),'EdgeColor','k','LineWidth',1,'FaceColor',[0.8 0 0])
hold on
bar(2, median(t_diff_cho),'EdgeColor','k','LineWidth',1,'FaceColor',[0 0 0.6])
box off
ylim([-0.05 0.05]);
set(gca,'FontSize',14)
set(gca,'XTick',[1,2]);
set(gca,'xticklabel',[{'sample phase','choice phase'}]);
ax = gca;
ax.XTickLabelRotation = 45;  