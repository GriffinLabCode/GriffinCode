%% This script calculates coherence during the interval of interest
% note that to change this interval, you will need to manually go into the
% function 'coherence_firingrates.m' and 'rat_location.m' to change this.
% Future updates will target changing this from the inputs function
%
% Int_lfp is only corrected for stem entry-tjunction exit
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

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');

[input]=get_coh_inputs();

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

    % define and load some variables 
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
    
    % get coherence and firing-rates
    [sample_cohData{nn-2},sample_cohMean{nn-2},sample_fr{nn-2},...
        sample_frMean{nn-2},frex_sample{nn-2}] = coherence_firingrates(datafolder,input,Int_sample);
    [choice_cohData{nn-2},choice_cohMean{nn-2},choice_fr{nn-2},...
        choice_frMean{nn-2},frex_choice{nn-2}] = coherence_firingrates(datafolder,input,Int_choice);
    
    % get location data
    [sample_X{nn-2},sample_Y{nn-2},ExtractedX_all{nn-2},ExtractedY_all{nn-2}] = rat_location(datafolder,Int_sample);
    [choice_X{nn-2},choice_Y{nn-2},~,~] = rat_location(datafolder,Int_choice);    

    clearvars -except sample_cohData sample_cohMean sample_fr ...
        sample_frMean choice_cohData choice_cohMean choice_fr ...
        choice_frMean input Datafolders folder_names Coh_sam Coh_cho ...
        CohS_mean CohCh_mean nn frex_sample frex_choice sample_X sample_Y...
        choice_X choice_Y ExtractedX_all ExtractedY_all num_types num_orig ...
        turn_nam correct_trajectory
    
    X = ['finished with session ',num2str(nn-2)];
    disp(X)    

end

%% new figures - 5/29/19
% reformat - removing empty cells
choice_ref1 = choice_cohData(~cellfun('isempty',choice_cohData));
sample_ref1 = sample_cohData(~cellfun('isempty',sample_cohData));

frex_cho_ref = frex_choice(~cellfun('isempty',frex_choice));
frex_sam_ref = frex_sample(~cellfun('isempty',frex_sample));

% reformat again by concatenating trials
i = [];
for i = 1:length(choice_ref1)
    choice_cat{i} = horzcat(choice_ref1{i}{:});
    sample_cat{i} = horzcat(sample_ref1{i}{:});
    
    frex_cho_cat{i} = vertcat((frex_cho_ref{i}{:}));
    frex_sam_cat{i} = vertcat((frex_sam_ref{i}{:}));
end

% average trials
i = [];
for i = 1:length(choice_cat)
    choice_trialAvg{i} = mean(choice_cat{i},2);
    sample_trialAvg{i} = mean(sample_cat{i},2);
    
    frex_cho_TrAvg{i} = mean(frex_cho_cat{i});
    frex_sam_TrAvg{i} = mean(frex_sam_cat{i});
end

% average across sessions
data_choice = horzcat(choice_trialAvg{:});
data_sample = horzcat(sample_trialAvg{:});

mean_choice = mean(data_choice,2);
mean_sample = mean(data_sample,2);

% get frequency stuff
data_frex_choice = vertcat(frex_cho_TrAvg{:});
data_frex_sample = vertcat(frex_sam_TrAvg{:});

mean_frex_choice = mean(data_frex_choice);
mean_frex_sample = mean(data_frex_sample);
mean_frex = mean(vertcat(mean_frex_choice,mean_frex_sample));

% get sems
sem_choice = std(data_choice')/sqrt(length(data_choice));
sem_sample = std(data_sample')/sqrt(length(data_sample));

% generate figure
figure('color',[1 1 1]);
shadedErrorBar(mean_frex(1:round(length(mean_sample)/2)),mean_sample(1:round(length(mean_sample)/2)),sem_sample(1:round(length(mean_sample)/2)),'-r',1);
hold on;
shadedErrorBar(mean_frex(1:round(length(mean_sample)/2)),mean_choice(1:round(length(mean_sample)/2)),sem_choice(1:round(length(mean_sample)/2)),'-b',1);
box off

figure('color',[1 1 1]);
shadedErrorBar(mean_frex,mean_sample,sem_sample,'-r',1);
hold on;
shadedErrorBar(mean_frex,mean_choice,sem_choice,'-b',1);
box off

% test theta frex for significance
theta_band = find(mean_frex > 4 & mean_frex < 12);
theta_sample = mean_sample(theta_band);
theta_choice = mean_choice(theta_band);
diffscore_theta = (theta_choice-theta_sample)./(theta_choice+theta_sample);
[~,norm_theta]=swtest(diffscore_theta);
if norm_theta > 0.05
    [h_theta,p_theta,ci_theta,stat_theta]=ttest(diffscore_theta);
else
    [h_theta,p_theta,stat_theta]=signrank(diffscore_theta);
end

delta_band = find(mean_frex > 1 & mean_frex < 4);
delta_sample = mean_sample(delta_band);
delta_choice = mean_choice(delta_band);
diffscore_delta = (delta_choice-delta_sample)./(delta_choice+delta_sample);
[~,norm_delta]=swtest(diffscore_delta);
if norm_delta > 0.05
    [h_delta,p_delta,ci_delta,stat_delta]=ttest(diffscore_delta);
else
    [h_delta,p_delta,stat_delta]=signrank(diffscore_delta);
end

noise = find(mean_frex > 56 & mean_frex < 62);
noise_sample = mean_sample(noise);
noise_choice = mean_choice(noise);

beta_band = find(mean_frex > 15 & mean_frex < 30);
beta_sample = mean_sample(beta_band);
beta_choice = mean_choice(beta_band);
diffscore_beta = (beta_choice-beta_sample)./(beta_choice+beta_sample);
[~,norm_beta]=swtest(diffscore_beta);
if norm_beta > 0.05
    [h_beta,p_beta,ci_beta,stat_beta]=ttest(diffscore_beta);
else
    [p_beta,h_beta,stat_beta]=signrank(diffscore_beta);
end

sGam_band = find(mean_frex > 25 & mean_frex < 50);
sGam_sample = mean_sample(sGam_band);
sGam_choice = mean_choice(sGam_band);
diffscore_sGam = (sGam_choice-sGam_sample)./(sGam_choice+sGam_sample);
[~,norm_sGam]=swtest(diffscore_sGam);
if norm_sGam > 0.05
    [h_sGam,p_sGam,ci_sGam,stat_sGam]=ttest(diffscore_sGam);
else
    [p_sGam,h_sGam,stat_sGam]=signrank(diffscore_sGam);
end

fGam_band = find(mean_frex > 65 & mean_frex < 100);
fGam_sample = mean_sample(fGam_band);
fGam_choice = mean_choice(fGam_band);
diffscore_fGam = (fGam_choice-fGam_sample)./(fGam_choice+fGam_sample);
[~,norm_fGam]=swtest(diffscore_fGam);
if norm_fGam > 0.05
    [h_fGam,p_fGam,ci_fGam,stat_fGam]=ttest(diffscore_fGam);
else
    [p_fGam,h_fGam,stat_fGam]=signrank(diffscore_fGam);
end


figure('color',[1 1 1]);
shadedErrorBar(mean_frex(fGam_band),mean_sample(fGam_band),sem_sample(fGam_band),'-r',1);
hold on;
shadedErrorBar(mean_frex(fGam_band),mean_choice(fGam_band),sem_choice(fGam_band),'-b',1);
box off

% test for normality
%[h,p,stat] = swtest(theta_sample)
%[h,p,stat] = swtest(theta_choice)

%[h,p] = signrank(theta_sample,theta_choice)

%% coherence analysis where session in the N
mean_frex_choice = mean(data_frex_choice);
mean_frex_sample = mean(data_frex_sample);
mean_frex = mean(vertcat(mean_frex_choice,mean_frex_sample));

data_choice = data_choice';
data_sample = data_sample';

sessionN_delta_sample = mean(data_sample(:,delta_band),2);
sessionN_delta_choice = mean(data_choice(:,delta_band),2);
diffscore_session_delta = (sessionN_delta_choice-sessionN_delta_sample)./...
    (sessionN_delta_choice+sessionN_delta_sample);
diffscore_session_delta(isnan(diffscore_session_delta))=[];
[~,p_norm]=swtest(diffscore_session_delta);
if p_norm > 0.05
    [h,p_delta,ci_delta,stat_delta]=ttest(diffscore_session_delta);
elseif p_norm < 0.05
    [p_delta]=signrank(diffscore_session_delta);
end

sessionN_theta_sample = mean(data_sample(:,theta_band),2);
sessionN_theta_choice = mean(data_choice(:,theta_band),2);
diffscore_session_theta = (sessionN_theta_choice-sessionN_theta_sample)./...
    (sessionN_theta_choice+sessionN_theta_sample);
diffscore_session_theta(isnan(diffscore_session_theta))=[];
[~,p_norm]=swtest(diffscore_session_theta);
if p_norm > 0.05
    [h,p_theta,ci_theta,stat_theta]=ttest(diffscore_session_theta);
elseif p_norm < 0.05
    [p_theta]=signrank(diffscore_session_theta);
end

sessionN_beta_sample = mean(data_sample(:,beta_band),2);
sessionN_beta_choice = mean(data_choice(:,beta_band),2);
diffscore_session_beta = (sessionN_beta_choice-sessionN_beta_sample)./...
    (sessionN_beta_choice+sessionN_beta_sample);
diffscore_session_beta(isnan(diffscore_session_beta))=[];
[~,p_norm]=swtest(diffscore_session_beta);
if p_norm > 0.05
    [h,p_beta,ci_beta,stat_beta]=ttest(diffscore_session_beta);
elseif p_norm < 0.05
    [p_beta]=signrank(diffscore_session_beta);
end

sessionN_sGam_sample = mean(data_sample(:,sGam_band),2);
sessionN_sGam_choice = mean(data_choice(:,sGam_band),2);
diffscore_session_sGam = (sessionN_sGam_choice-sessionN_sGam_sample)./...
    (sessionN_sGam_choice+sessionN_sGam_sample);
diffscore_session_sGam(isnan(diffscore_session_sGam))=[];
[~,p_norm]=swtest(diffscore_session_sGam);
if p_norm > 0.05
    [h,p_sGam,ci_sGam,stat_sGam]=ttest(diffscore_session_sGam);
elseif p_norm < 0.05
    [p_sGam]=signrank(diffscore_session_sGam);
end

sessionN_fGam_sample = mean(data_sample(:,fGam_band),2);
sessionN_fGam_choice = mean(data_choice(:,fGam_band),2);
diffscore_session_fGam = (sessionN_fGam_choice-sessionN_fGam_sample)./...
    (sessionN_fGam_choice+sessionN_fGam_sample);
diffscore_session_fGam(isnan(diffscore_session_fGam))=[];
[~,p_norm]=swtest(diffscore_session_fGam);
if p_norm > 0.05
    [h,p_fGam,ci_fGam,stat_fGam]=ttest(diffscore_session_fGam);
elseif p_norm < 0.05
    [p_fGam]=signrank(diffscore_session_fGam);
end

%% plot position data
sample_Xog = sample_X;
sample_Yog = sample_Y;
choice_Xog = choice_X;
choice_Yog = choice_Y;

sample_X = sample_Xog;
sample_Y = sample_Yog;
choice_X = choice_Xog;
choice_Y = choice_Yog;

% remove empty cells (sessions with poor lfp, or no lfp, that were excluded)
sample_X = sample_X(~cellfun('isempty',sample_X));
sample_Y = sample_Y(~cellfun('isempty',sample_Y));
choice_X = choice_X(~cellfun('isempty',choice_X));
choice_Y = choice_Y(~cellfun('isempty',choice_Y));

% if theres a sampling error on the video tracking, subsample to make it
% the same size as the rest of the trials
for i = 1:length(sample_X)
    % create a variable that can be used to identify inconsistencies
    for ii = 1:length(sample_X{i})
        size_pos_sample{i}(ii) = length(sample_X{i}{ii}); 
        size_pos_choice{i}(ii) = length(choice_X{i}{ii});         
    end
    
    % find most common position data size
    mode_values_sam{i} = mode(size_pos_sample{i});
    mode_values_cho{i} = mode(size_pos_sample{i}); 
    
    % find minimum
    %min_values_sam{i} = min(size_pos_sample{i});
    %min_values_cho{i} = min(size_pos_sample{i});
    
    % find inconsistencies
    error_sample{i} = find(size_pos_sample{i}~=mode_values_sam{i});
    error_choice{i} = find(size_pos_choice{i}~=mode_values_cho{i});
    
    % use the error_sample as an index to subsample
    if isempty(error_sample{i}) == 0
        % if there is an inconsistency, then find a random value and
        % eliminate it. Also note that elim_idx accounts for cases where
        % there could be more than 1 inconsistency by |mode-number errors|
        for k = 1:length(error_sample{i})
            elim_idx = []; 
            elim_idx = randsample(1:length(sample_X{i}{error_sample{i}(k)}),...
                abs(mode_values_sam{i}-length(sample_X{i}{error_sample{i}(k)})));
            sample_X{i}{error_sample{i}(k)}(elim_idx)=[];
            sample_Y{i}{error_sample{i}(k)}(elim_idx)=[];  
        end
    else
        X = ['no inconsistencies in sample phase VT count for session ', ...
            num2str(i)];
        disp(X);   
    end
    
    % use the error_sample as an index to subsample
    if isempty(error_choice{i}) == 0
        % if there is an inconsistency, then find a random value and
        % eliminate it. Also note that elim_idx accounts for cases where
        % there could be more than 1 inconsistency by |mode-number errors|
        for k = 1:length(error_choice{i})
            elim_idx = []; 
            elim_idx = randsample(1:length(choice_X{i}{error_choice{i}(k)}),...
                abs(mode_values_cho{i}-length(choice_X{i}{error_choice{i}(k)})));
            choice_X{i}{error_choice{i}(k)}(elim_idx)=[];
            choice_Y{i}{error_choice{i}(k)}(elim_idx)=[];  
        end
    else
        X = ['no inconsistencies in choice phase VT count for session ', ...
            num2str(i)];
        disp(X);   
    end    
end

%% NEEDS FIXING
% if there are cases where the above lines didn't work, it's probably
% because a lower number can't be subsampled to a larger one, thus the
% lines below account for those times
    % find minimum
    min_values_sam{i} = min(size_pos_sample{i});
    min_values_cho{i} = min(size_pos_sample{i});
    
    % find inconsistencies
    error_sample_min{i} = find(size_pos_sample{i}~=min_values_sam{i});
    error_choice_min{i} = find(size_pos_choice{i}~=min_values_cho{i});
    
    % use the error_sample as an index to subsample
    if isempty(error_sample{i}) == 0
        % if there is an inconsistency, then find a random value and
        % eliminate it. Also note that elim_idx accounts for cases where
        % there could be more than 1 inconsistency by |mode-number errors|
        for k = 1:length(error_sample_min{i})
            elim_idx = []; 
            elim_idx = randsample(1:length(sample_X{i}{error_sample_min{i}(k)}),...
                abs(min_values_sam{i}-length(sample_X{i}{error_sample_min{i}(k)})));
            sample_X{i}{error_sample{i}(k)}(elim_idx)=[];
            sample_Y{i}{error_sample{i}(k)}(elim_idx)=[];  
        end
    else
        X = ['no inconsistencies in sample phase VT count for session ', ...
            num2str(i)];
        disp(X);   
    end
    
    % use the error_sample as an index to subsample
    if isempty(error_choice{i}) == 0
        % if there is an inconsistency, then find a random value and
        % eliminate it. Also note that elim_idx accounts for cases where
        % there could be more than 1 inconsistency by |mode-number errors|
        for k = 1:length(error_choice{i})
            elim_idx = []; 
            elim_idx = randsample(1:length(choice_X{i}{error_choice_min{i}(k)}),...
                abs(min_values_cho{i}-length(choice_X{i}{error_choice_min{i}(k)})));
            choice_X{i}{error_choice_min{i}(k)}(elim_idx)=[];
            choice_Y{i}{error_choice_min{i}(k)}(elim_idx)=[];  
        end
    else
        X = ['no inconsistencies in choice phase VT count for session ', ...
            num2str(i)];
        disp(X);   
    end    

    for i = 1:length(sample_X)
        trialavg_samX{i} = mean(vertcat(sample_X{i}{:}));
        trialavg_samY{i} = mean(vertcat(sample_Y{i}{:}));
        trialavg_choX{i} = mean(vertcat(choice_X{i}{:}));
        trialavg_choY{i} = mean(vertcat(choice_Y{i}{:}));
    end
    
    
% collapse across sessions
session_samX = vertcat(trialavg_samX{:});
session_samY = vertcat(trialavg_samY{:});
session_choX = vertcat(trialavg_choX{:});
session_choY = vertcat(trialavg_choY{:});

% figure
figure('color',[1 1 1]);
    % choice
    i = [];
    % plot session averages
    for i = 1:size(session_choX,1)
        hold on
        subplot 212
        %plot(session_choX(i,:),session_choY(i,:), 'color',[0.6,0.6,0.6])
        plot(session_choX(i,:),session_choY(i,:), 'color',[0 0.4 1])
    end
    % plot average
    hold on
    plot(mean(session_choX),mean(session_choY),'k','LineWidth',3)  
    xlim([160 180])
    %ylim([140 200])
    box off
    hold on
    
    % sample
    i = [];
    % plot session averages
    for i = 1:size(session_samX,1)
        hold on
        subplot 211
        %plot(session_samX(i,:),session_samY(i,:), 'color',[0.6,0.6,0.6])
        plot(session_samX(i,:),session_samY(i,:), 'color',[1 0 0.1])
    end
    % plot average
    hold on
    plot(mean(session_samX),mean(session_samY),'k','LineWidth',3)
    xlim([160 180]) 
    %ylim([140 200])
    box off    

%% old figures

% reformat rates
rates_sample = (horzcat(sample_frMean{:}))';
rates_choice = (horzcat(choice_frMean{:}))';
diffscore_rates = (rates_choice-rates_sample)./(rates_choice+rates_sample);
nans = find(isnan(diffscore_rates));
diffscore_rates(nans)=[];

[~,norm_rates]=swtest(diffscore_rates);
if norm_rates > 0.05
    [h_rates,p_rates,ci_rates,stat_rates]=ttest(diffscore_rates);
else
    [p_rates,h_rates,stat_rates]=signrank(diffscore_rates);
end

%{
% average the coherence means
for m = 1:length(sample_cohMean)
    cohMean_sample(m) = mean(cell2mat(sample_cohMean{m}));
    cohMean_choice(m) = mean(cell2mat(choice_cohMean{m}));    
end

% remove empty matrices (NaNs)
cohMean_sample(isnan(cohMean_sample))=[];
cohMean_choice(isnan(cohMean_choice))=[];

rateMean_sample = sample_frMean(~cellfun('isempty',sample_frMean));
rateMean_choice = choice_frMean(~cellfun('isempty',choice_frMean));

% find a way to assign neurons that fall into the same cell array as the
% coherence value, the same coherence values. Making the neuron struct
% array didnt work here.

    % find how many cells each session had
    for iii = 1:length(rateMean_sample)
        howmany_cells(iii) = size(rateMean_sample{iii},2);
    end
    
    % duplicate the coherence value depending on the number of cells it
    % belongs to
    for n = 1:length(rateMean_sample)
        repnum = [];
        repnum = size(rateMean_sample{n},2);
        repeats_cohSample{n} = repmat(cohMean_sample(n),1,repnum);
        repeats_cohChoice{n} = repmat(cohMean_choice(n),1,repnum);        
    end
    
    % reformat
    cohrep_sample = (horzcat(repeats_cohSample{:}))';
    cohrep_choice = (horzcat(repeats_cohChoice{:}))';
%{  
% correlation plot
diffscore_coherence = (cohrep_choice-cohrep_sample)./(cohrep_choice+cohrep_sample);
diffscore_rates = (rates_choice-rates_sample)./(rates_choice+rates_sample);

nans = find(isnan(diffscore_rates));
%diffscore_coherence(nans)=[];
%diffscore_rates(nans)=[];

var1 = []; var2 = [];
var1 = mean(horzcat(cohrep_choice,cohrep_sample),2);
var2 = (abs(diffscore_rates));
var1(nans)=[];
var2(nans)=[];
% remove sparse neurons
sparse_cell = find(var2 == 1);
var1(sparse_cell)=[];
var2(sparse_cell)=[];
%{
figure('color',[1 1 1]);
scatterhist(var1,var2,'Kernel','on','Location','SouthWest','Direction',...
    'out','Color','kbr','LineStyle',{'-','-.',':'},'Marker','od','MarkerSize',[4,5,6])

figure('color',[1 1 1]);
scatter(var1,var2)
    [R,P] = corrcoef(var1,var2);
        coeffs = polyfit(var1, var2, 1);
        % Get fitted values
        fittedX = linspace(min(var1), max(var1), 200);
        fittedY = polyval(coeffs, fittedX);
        % Plot the fitted line
        hold on;
        plot(fittedX, fittedY, 'r', 'LineWidth', 2); 
        box off
%}

    
diffscore_coherence = (cohMean_sample-cohMean_choice)./...
    (cohMean_sample+cohMean_choice);
[h_norm,p_norm]=swtest(diffscore_coherence);
if p_norm > 0.05
    [h,p]=ttest(diffscore_coherence)
else
    [h,p]=signrank(diffscore_coherence)
end
%}
%}