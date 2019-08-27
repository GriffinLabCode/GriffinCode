% clear workspace and command window
%
%
clear; clc; 

% addpath to folder
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate')

% get inputs
[input]=get_inputs();

% include startbox?
include_startbox = 0;

% this can be used to correct the number of trajectories. However,
% subsampling of trajectory occurs here, which changes your result each
% time.
correct_trajectory = 0;

    % initialize svm_var cell array (combo - includes stem and sb data)
    spatial_coverage_all = [];

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
    
    % initialize variables
    neuron_temp = [];
    neuron = [];
    
%% flip across sessions
    
    for nn = 3:length(folder_names)
    
        Datafolders = Datafolders;
        cd(Datafolders);
        folder_names = dir;
        temp_folder = folder_names(nn).name;
        cd(temp_folder);
        datafolder = pwd;
        cd(datafolder);    

        % define and load some variables
        cd(datafolder);  
        load (strcat(datafolder,'\Int_noBowl.mat')); 
        % only include correct trials
        Int_correct = Int(find(Int(:,4)==0),:);
        Int_og = Int;
        Int = [];
        Int = Int_correct;
        
        % control for trajectory differences
        if correct_trajectory == 1
        Int_og2 = Int;
        Int = [];
        [Int,corrected_trials,turn_var_update]=correct_trajectory_differences(Int_og2);        
        end
        
        load(strcat(datafolder, '\VT1.mat'));
        cd(Datafolders);
        folder_names = dir;    
         
        % load video tracking and trial-tracking data
        addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
        load(strcat(datafolder,'\VT1.mat'));
        TimeStamps = TimeStamps_VT;

        % correct tracking errors
        [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);

        % create a variable containing all clusters
        cd(datafolder);
        clusters = dir('TT*.txt');

        % use this to index spk locations
        maze_times = find(TimeStamps>Int(1,1)&TimeStamps<Int(end,end));
        
        % loop across clusters
        for ci = 1:length(clusters)
            spk = textread(clusters(ci).name);
            neuron_temp(1,ci).name = clusters(ci).name(1:end-4);
            
            if length(spk > 100)
                % get spatial coverage
                if include_startbox == 1
                    [spatial_coverage,peak_rate] = spatial_coverage_score(datafolder,Int,ExtractedX,ExtractedY,TimeStamps,maze_times,spk,clusters);   
                else
                    [spatial_coverage,peak_rate] = spatial_coverage_score_noSB(datafolder,Int,ExtractedX,ExtractedY,TimeStamps,maze_times,spk,clusters);   
                end
                
                % store data
                neuron_temp(1,ci).spatial_coverage = spatial_coverage;
                neuron_temp(1,ci).peak_rate        = peak_rate;
                
                % get DI
                sample_trials = 1:2:size(Int,1);
                choice_trials = 2:2:size(Int,1);
                
                for triali = 1:length(sample_trials)
                   fr_sample(triali) = (length(find(spk>Int(sample_trials(triali),1) & ...
                       spk<Int(sample_trials(triali),8))))/...
                       ((Int(sample_trials(triali),8)-Int(sample_trials(triali),1))/1e6);
                   
                   fr_choice(triali) = (length(find(spk>Int(choice_trials(triali),1) & ...
                       spk<Int(choice_trials(triali),8))))/...
                       ((Int(choice_trials(triali),8)-Int(choice_trials(triali),1))/1e6);
                end
                
                % get diffscore
                diffscore = (mean(fr_choice)-mean(fr_sample))/...
                    (mean(fr_choice)+mean(fr_sample));
                
                % store
                neuron_temp(1,ci).diffscore = diffscore;
                
                % get mean rates
                mean_sample = mean(fr_sample);
                mean_choice = mean(fr_choice);
                
                % store
                neuron_temp(1,ci).mean_sample = mean_sample;
                neuron_temp(1,ci).mean_choice = mean_choice;
    
            else
                disp('cell exlusion based on less than 100 spikes')
            end
                clear spk spatial_coverage peak_rate
        end
        
        % store data
        neuron = horzcat(neuron,neuron_temp);
        neuron_temp = [];
        
        clearvars -except datafolder nn folder_names Datafolders ...
            input neuron neuron_temp rate correct_trajectory include_startbox
        
    end
clearvars -except neuron

spatial_coverage = extractfield(neuron,'spatial_coverage');
peak_rates = extractfield(neuron,'peak_rate');
diffscore = extractfield(neuron,'diffscore');

less_than = find(peak_rates<3);
spatial_coverage(less_than)=[];

figure('color',[1 1 1]);
hist(spatial_coverage,10)
line([median(spatial_coverage) median(spatial_coverage)],ylim,'Color',[1 0 0],'linestyle','--')
box off

figure('color',[1 1 1]);
hist(diffscore,10)
line([median(diffscore) median(diffscore)],ylim,'Color',[1 0 0],'linestyle','--')
box off

var1 = []; var2 = [];
var1 = spatial_coverage;
var2 = abs(diffscore); var2(less_than)=[];
var3 = peak_rates; var3(less_than)=[];
%var2 = diffscore; var2(less_than)=[];

figure('color',[1 1 1]);
scatter(var1,var2,'k')
[R,P] = corrcoef(var1,var2);
    coeffs = polyfit(var1, var2, 1);
    % Get fitted values
    fittedX = linspace(min(var1), max(var1), 200);
    fittedY = polyval(coeffs, fittedX);
    % Plot the fitted line
    hold on;
    plot(fittedX, fittedY, 'r', 'LineWidth', 2);        
%xlabel('p-value')

%{
% subsample
for i = 1:100000
    var1_subbed{i} = randsample(var1,47,'true');
    var2_subbed{i} = randsample(var2,47,'true');
    [R,P] = corrcoef(var1_subbed{i},var2_subbed{i});
    p(i) = P(2);
    r(i) = R(2);
    clear R P
end

figure('color',[1 1 1]);
hist(p,20);
box off

line(0.05 0.05],ylim,'Color',[1 0 0],'linestyle','--')
%}
