% clear workspace and command window
clear; clc; 

% addpath to folder
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate')

% get inputs
[input]=get_inputs();

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
                sample_trials = 1:2:size(Int,1);
                choice_trials = 2:2:size(Int,1);
                
                % make sure the cell fires on both task-phases
                    for i = 1:length(sample_trials)
                        spk_sam{i} = spk(find(spk>Int(sample_trials(i),1)...
                            & spk<Int(sample_trials(i),8)));
                        spk_cho{i} = spk(find(spk>Int(choice_trials(i),1)...
                            & spk<Int(choice_trials(i),8)));
                    end
                        spk_s = vertcat(spk_sam{:});
                        spk_c = vertcat(spk_cho{:});
                        
                        if isempty(spk_s) == 0 && isempty(spk_c) == 0
                            % get spatial coverage
                            %{
                            [coverage_sample,coverage_choice,peak_rate_sample,...
                                peak_rate_choice] = spatial_coverage_score_taskphase2(datafolder,...
                                Int,ExtractedX,ExtractedY,TimeStamps,spk,clusters);
                            %}
                            
                            % run spatial coverage on whole maze without SB
                            [spatial_coverage,peak_rate,filtered_map] = spatial_coverage_score_noSB(datafolder,Int,ExtractedX,ExtractedY,TimeStamps,maze_times,spk,clusters);   
                            % use peak rate from whole maze
                            [coverage_sample,coverage_choice] = spatial_coverage_score_taskphase4(datafolder,Int,ExtractedX,ExtractedY,TimeStamps,spk,clusters,peak_rate);                                    
                            
                            % get mean firing-rates
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
                            mean_sample = mean(fr_sample);
                            mean_choice = mean(fr_choice);
                            
                            % store
                            neuron_temp(1,ci).diffscore = diffscore;
                            neuron_temp(1,ci).mean_sample = mean_sample;
                            neuron_temp(1,ci).mean_choice = mean_choice;
                        
                        else
                            coverage_sample  = NaN;
                            coverage_choice  = NaN;
                            peak_rate = NaN;
                            peak_rate = NaN;
                            diffscore        = NaN;
                        end
                        
                % store
                neuron_temp(1,ci).coverage_sample  = coverage_sample;
                neuron_temp(1,ci).coverage_choice  = coverage_choice;
                %neuron_temp(1,ci).peak_threshold   = threshold;
                %neuron_temp(1,ci).diffscore_peaks  = (meanpeak_choice-meanpeak_sample)/...
                   % (meanpeak_choice+meanpeak_sample);
                neuron_temp(1,ci).peak_rate_sample = peak_rate;
                neuron_temp(1,ci).peak_rate_choice = peak_rate;

            else
                disp('cell exlusion based on less than 100 spikes')
            end
                clear coverage_sample coverage_choice ...
                    peak_rate_sample peak_rate_choice ...
                    spk_s spk_c spk_sam spk_cho sample_trials ...
                    choice_trials fr_sample fr_choice diffscore
        end
        
        % store data
        neuron = horzcat(neuron,neuron_temp);
        neuron_temp = [];
        
        clearvars -except datafolder nn folder_names Datafolders ...
            input neuron neuron_temp rate
        
    end

clearvars -except neuron

coverage_sample = extractfield(neuron,'coverage_sample');
coverage_choice = extractfield(neuron,'coverage_choice');

peak_rates_sample = extractfield(neuron,'peak_rate_sample');
peak_rates_choice = extractfield(neuron,'peak_rate_choice');

less_than1 = find(peak_rates_sample<3);
less_than2 = find(peak_rates_choice<3);
less_than = [less_than1,less_than2];
less_than = unique(less_than);

nanidx = find(isnan(coverage_choice)==1);
coverage_choice(nanidx)=[];
coverage_sample(nanidx)=[];
nanidx = find(isnan(coverage_sample)==1);
coverage_choice(nanidx)=[];
coverage_sample(nanidx)=[];

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Cool Plots')
mat = horzcat(coverage_sample',coverage_choice');
%mat = coverage_choice-coverage_sample;

plot_bar = 1;
plot_box = 0;
jitter = 0;
connect_jitter = 0;
PlotLine = 0;
BarPlotsJitteredData(mat,plot_bar,plot_box,jitter,connect_jitter,PlotLine)






%% old
diffscore_coverage = (coverage_choice-coverage_sample)./...
    (coverage_choice+coverage_sample);
diffscore_peakRates = (peak_rates_choice-peak_rates_sample)./...
    (peak_rates_choice+peak_rates_sample);
diffscore_mean = extractfield(neuron,'diffscore');

var1 = ((diffscore_peakRates));
var2 = ((diffscore_coverage));
var1(less_than)=[];
var2(less_than)=[];

% remove units with peak-rate under 3Hz
diffscore_mean(less_than)=[];
diffscore_coverage(less_than)=[];

% distribution
% if using mpfc, you'll notice less neurons. At first, you'll also notice a
% baseline count of 186 instead of 187, that's because of the way the
% script was formatted. If you look into the task-phase spatialcoverage
% score, there is no mean rates for a neuron because it couldn't estimate
% spatial-coverage. Was a quick way to pass over neurons that weren't
% playing a role

figure('color',[1 1 1])
hist(var1,10)
line([median(var1) median(var1)],ylim,'Color',[1 0 0],'linestyle','--')
box off

figure('color',[1 1 1])
hist(var2,10)
line([median(var2) median(var2)],ylim,'Color',[1 0 0],'linestyle','--')
box off

% test for normality
[h,p_swtest_meandiffscore]=swtest(diffscore_mean);
[h,p_swtest_covdiffscore]=swtest(diffscore_coverage);


%% old stuff

coverage_choice(less_than)=[];
coverage_sample(less_than)=[];

peak_rates_choice(less_than)=[];
peak_rates_sample(less_than)=[];

diffscore_mean(less_than)=[];

% remove nans
nan1 = find(isnan(var1)==1);
nan2 = find(isnan(var2)==1);
nan_rem = [nan1,nan2];

var1(nan_rem)=[];
var2(nan_rem)=[];

coverage_choice(nan_rem)=[];
coverage_sample(nan_rem)=[];

peak_rates_choice(nan_rem)=[];
peak_rates_sample(nan_rem)=[];

figure('color',[1 1 1]);
scatter(abs(var1),var2,'k')
[R,P] = corrcoef(abs(var1),var2);
    coeffs = polyfit(abs(var1), var2, 1);
    % Get fitted values
    fittedX = linspace(min(abs(var1)), max(abs(var1)), size(neuron,2));
    fittedY = polyval(coeffs, fittedX);
    % Plot the fitted line
    hold on;
    plot(fittedX, fittedY, 'r', 'LineWidth', 2);   
    axis tight
    
%% fig - plots sample by choice coverage, with a colors indicating differential preference in the peak rate for task-phase
diffscore_peakRates(less_than)=[];
diffscore_peakRates(nan_rem)=[];
diffscore_coverage(less_than)=[];
diffscore_coverage(nan_rem)=[];

figure('color',[1 1 1]);
scatter(coverage_sample,coverage_choice,50,diffscore_mean,'Filled')
hcbar=colorbar;
caxis([min(diffscore_mean) max(diffscore_mean)])
h = colorbar;
ylabel(h, 'choice - sample')
colormap(jet)
    [R,P] = corrcoef(coverage_sample,coverage_choice);
   coeffs = polyfit(coverage_sample,coverage_choice, 1);
    % Get fitted values
    fittedX = linspace(min(coverage_sample), max(coverage_sample), 200);
    fittedY = polyval(coeffs, fittedX);
    % Plot the fitted line
    hold on;
    %plot(fittedX, fittedY, 'r', 'LineWidth', 2);   
ylabel('spatial coverage choice')
xlabel('spatial coverage sample')
hold on;
x = linspace(min(coverage_sample), max(coverage_sample), length(coverage_sample));
y = linspace(min(coverage_choice), max(coverage_choice), length(coverage_choice));
plot(x,y,'--k','LineWidth',2)


choice_peaks = find(diffscore_peakRates>0);
sample_peaks = find(diffscore_peakRates<0);
ratio_taskphase_peaks = length(sample_peaks)/length(choice_peaks)
peaks_var = [length(choice_peaks)/(length(choice_peaks)+length(sample_peaks)),...
    length(sample_peaks)/(length(choice_peaks)+length(sample_peaks))];

figure('color' ,[1 1 1]);
pie(peaks_var)

choice_coverage = find(diffscore_coverage>0);
sample_coverage = find(diffscore_coverage<0);
ratio_taskphase_coverage = length(sample_coverage)/length(choice_coverage)
coverage_var = [length(choice_coverage)/(length(choice_coverage)+length(sample_coverage)),...
    length(sample_coverage)/(length(choice_coverage)+length(sample_coverage))];
figure('color' ,[1 1 1]);
pie(coverage_var)

diffscore_mean = extractfield(neuron,'diffscore');
diffscore_mean(less_than)=[];
diffscore_mean(nan_rem)=[];

var1 = (diffscore_coverage);
var2 = (diffscore_mean);

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

[h,p]=ranksum(sample_peaks,choice_peaks)

%% scatter hist
var1 = []; var2 = [];
var1 = (diffscore_mean);
var2 = (diffscore_coverage);
figure('color',[1 1 1]);
scatterhist(var1,var2,'Kernel','on','Location','SouthWest','Direction',...
    'out','Color','kbr','LineStyle',{'-','-.',':'},'Marker','od','MarkerSize',[4,5,6])

    [R,P] = corrcoef(var1,var2);
        coeffs = polyfit(var1, var2, 1);
        % Get fitted values
        fittedX = linspace(min(var1), max(var1), 200);
        fittedY = polyval(coeffs, fittedX);
        % Plot the fitted line
        hold on;
        plot(fittedX, fittedY, 'r', 'LineWidth', 2); 
        box off
        

        
%box off
%{
figure('color',[1 1 1]);
hist(spatial_coverage,10)
line([median(spatial_coverage) median(spatial_coverage)],ylim,'Color',[1 0 0],'linestyle','--')
box off
%}
var1 = spatial_coverage;
var2 = abs(diffscore_mean); var2(less_than)=[];
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


%% create a bootstrapped distribution
var1 = diffscore_peakRates;
var2 = diffscore_coverage;

% subsample
for i = 1:100000
    var1_subbed{i} = randsample(var1,55,'true');
    var2_subbed{i} = randsample(var2,55,'true');
    %[R,P] = corrcoef(var1_subbed{i},var2_subbed{i});
    [p_prates(i),h_prates(i),stat_prates{i}] = signrank(var1_subbed{i});
    [p_cov(i),h_cov(i),stat_cov{i}] = signrank(var2_subbed{i});
   % p(i) = P(2);
   % r(i) = R(2);
   % clear R P
end

figure('color',[1 1 1]);
hist(p_prates,20);
box off
figure('color',[1 1 1]);
var_pie = [length(find(p_prates<0.05)) length(find(p_prates>0.05))];
pie(var_pie);

figure('color',[1 1 1]);
hist(p_cov,20);
box off

figure('color',[1 1 1]);
var_pie = [length(find(p_cov<0.05)) length(find(p_cov>0.05))];
pie(var_pie);

%line(0.05 0.05],ylim,'Color',[1 0 0],'linestyle','--')
%}
