%% time around t-junction
%
% this script was used to analyze spike data in 1s bins surrounding the
% tjunction. Make sure to set input.tjunct_bin to 10. This script
% unfortunately is not flexible with that yet - future iterations will be.
%
%
%

% clear workspace and command window
clear; clc; 

% addpath to folder
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Linear Classifier')

% get inputs
[input]=get_classifier_inputs();

    % initialize svm_var cell array (combo - includes stem and sb data)
    svm_var       = cell(1,(input.tjunct_bin-1));
    session_cells = cell(1,(input.tjunct_bin-1));
    svm_var_temp  = cell(1,(input.tjunct_bin-1));

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
    
%% flip across sessions
    
    for nn = 3:length(folder_names)%[3:14 24:31]%3:length(folder_names)
    
        Datafolders = Datafolders;
        cd(Datafolders);
        folder_names = dir;
        temp_folder = folder_names(nn).name;
        cd(temp_folder);
        datafolder = pwd;
        cd(datafolder);    

        % define and load some variables
        cd(datafolder);  
        load (strcat(datafolder,'\Int_file.mat')); 
        load(strcat(datafolder, '\VT1.mat'));
        cd(Datafolders);
        folder_names = dir;    

        % load clusters
        cd(datafolder);
        clusters   = dir('TT*.txt');
        
        % define TimeStamps variable
        TimeStamps = TimeStamps_VT;   

        % create index of sample and choice trials
        sample_trials = 1:2:size(Int,1);
        choice_trials = 2:2:size(Int,1);

        % initialize a variable
        firingrate_pop   = cell([1 (input.tjunct_bin-1)]);

        % sample rates
        for ci=1:length(clusters)
                cd(datafolder);
                spikeTimes = textread(clusters(ci).name);
                cluster    = clusters(ci).name(1:end-4);

                    % define a matrix used to store fr data
                    firingrate_array = cell([1 (input.tjunct_bin-1)]);

                % last row of firing_rate is the last trial
                % first row is 1 second from stem entry, 2nd row is 2 seconds and
                % so forth

                for i = 1:length(sample_trials)

                    % create variables that will be used to make bins 
                        % time of cp entry
                        cp_entry = Int(sample_trials(i),5);
                        % half sec before
                        before = cp_entry-(0.5*1e6);
                        % half sec after
                        after  = cp_entry+(0.5*1e6);
                        
                        % find 4sec before 0.5 sec before cp_entry
                        min_before = before-(4*1e6);
                        % find 4sec after 0.5 sec after cp_entry
                        max_after  = after+(4*1e6);
                        
                        % create a vector of timestamps that range from 4s
                        % before 0.5sec before the cp_entry
                        before_vect = linspace(min_before,before,5);
                        % create a vector of timestamps that range from 4s
                        % after 0.5sec after the cp_entry                        
                        after_vect = linspace(after,max_after,5);
                        
                        % append the vectors so youre center bin is 0.5 sec
                        % less than and 0.5 sec greater than cp entry
                        binned_time = horzcat(before_vect,after_vect);

                    % loop across bins finding spike rate
                    for timei = 1:length(binned_time)-1;

                        % isolate spikes from multiple time points     
                        spk_temp{(timei)} = find(spikeTimes>binned_time(timei) ...
                            & spikeTimes<=binned_time(timei+1));

                        % find total number of spikes
                        numspikes{(timei)} = length(spk_temp{(timei)});

                        % find how much time
                        time_temp{(timei)} = (binned_time(timei+1) - ...
                            binned_time(timei))/1e6;

                        % calculate firing rate
                        fr_new{(timei)} = (numspikes{(timei)})/(time_temp{(timei)});

                    end
                    firing_rate(i,:) = fr_new;
                    clear fr_new time_temp numspikes spk_temp
                end 

                % create a temporary firing rate cell array
                for j = 1:size(firing_rate,2)
                     firingrate_array{j} = firing_rate(:,j);
                end

                % create a cell array that contains all cells firing rates at the
                % specific times of interest defined by 'timing'
                for j = 1:size(firing_rate,2)
                     firingrate_pop{j} = horzcat(firingrate_array{j},firingrate_pop{j});             
                end
                clear firing_rate firingrate_array spikeTimes cp_entry ...
                    before after min_before max_after before_vect ...
                    after_vect binned_time

        end

        % store the data   
        sampleRate = firingrate_pop;
        % open this variable for future usage
        firingrate_pop = [];

            % define a variable
            firingrate_pop = cell([1 (input.tjunct_bin-1)]);

        % choice rates
            for ci=1:length(clusters)
                cd(datafolder);
                spikeTimes = textread(clusters(ci).name);
                cluster    = clusters(ci).name(1:end-4);

                    % define a matrix used to store fr data
                    firingrate_array = cell([1 (input.tjunct_bin-1)]);

                % choice
                for i = 1:length(choice_trials)

                    % create variables that will be used to make bins          
                        % time of cp entry
                        cp_entry = Int(choice_trials(i),5);
                        % half sec before
                        before = cp_entry-(0.5*1e6);
                        % half sec after
                        after  = cp_entry+(0.5*1e6);
                        
                        % find 4sec before 0.5 sec before cp_entry
                        min_before = before-(4*1e6);
                        % find 4sec after 0.5 sec after cp_entry
                        max_after  = after+(4*1e6);
                        
                        % create a vector of timestamps that range from 4s
                        % before 0.5sec before the cp_entry
                        before_vect = linspace(min_before,before,5);
                        % create a vector of timestamps that range from 4s
                        % after 0.5sec after the cp_entry                        
                        after_vect = linspace(after,max_after,5);
                        
                        % append the vectors so youre center bin is 0.5 sec
                        % less than and 0.5 sec greater than cp entry
                        binned_time = horzcat(before_vect,after_vect);
                        
                    % bins that contain evenly spaced timing values from delay
                    %binned_time = linspace(start_time,end_time,input.tjunct_bin);

                    for timei = 1:length(binned_time)-1;

                        % isolate spikes from multiple time points     
                        spk_temp{(timei)} = find(spikeTimes>binned_time(timei) ...
                            & spikeTimes<=binned_time(timei+1));

                        % find total number of spikes
                        numspikes{(timei)} = length(spk_temp{(timei)});

                        % find how much time
                        time_temp{(timei)} = (binned_time(timei+1) - ...
                            binned_time(timei))/1e6;

                        % calculate firing rate
                        fr_new{(timei)} = numspikes{(timei)}/time_temp{(timei)};

                    end
                    firing_rate(i,:) = fr_new;
                    clear fr_new time_temp numspikes spk_temp
                end      
                %firing_rate(1,:) = [];

                % create a temporary firing rate cell array
                for j = 1:size(firing_rate,2)
                     firingrate_array{j} = firing_rate(:,j);
                end

                % create a cell array that contains all cells firing rates at the
                % specific times of interest defined by 'timing'
                for j = 1:size(firing_rate,2)
                     firingrate_pop{j} = horzcat(firingrate_array{j},firingrate_pop{j});
                end
                clear firing_rate firingrate_array spikeTimes cp_entry ...
                    before after min_before max_after before_vect ...
                    after_vect binned_time

            end  

        % save data
        choiceRates = firingrate_pop;

        % append choice and sample rates
        for gee = 1:size(choiceRates,2);
            svm_var_temp{gee} = vertcat(choiceRates{gee},sampleRate{gee});
        end

        % append data
        session_cells = vertcat(session_cells,svm_var_temp);

        clear svm_var2 svm_var1 sample_trials choice_trials ...
            firingrate_pop svm_var_temp s cp_entry max_after min_before ...
            before after after_vect before_vect binned_time sampleRate ...
            choiceRates Int
        
    % display progress    
    X = ['finished with session ',num2str(nn-2)];
    disp(X)               
    end
    
%% subsample data to create equal sized cell arrays for classifier
    % clear out first row (all blanks)
    session_cells(1,:) = [];

%% svm
svm_var = session_cells;

    % zscore
    %{
    if input.standardize == 1
        for z = 1:size(svm_var,1)
            for zz = 1:size(svm_var,2)
                svm_z{z,zz}  = zscore(svm_var{z,zz});
            end
        end
        svm_temp = svm_z;
    elseif input.standardize == 0
        for hh = 1:size(svm_var,1)
            for cc = 1:size(svm_var,2)
                svm_var2{hh,cc} = svm_var{hh,cc};
            end
        end
    end
    %}
 
        for hh = 1:size(svm_var,1)
            for cc = 1:size(svm_var,2)
                svm_var2{hh,cc} = svm_var{hh,cc};
            end
        end    
    
    % since this is pseudosimultanous within rats, then classifier accuracy
    % across rats, we need to concatenate binned data. So column 1 = bin 1
    % = -(first time point), each sessions cells need to be concatenated    
    for columns = 1:size(svm_var2,2)
          svm_data{columns} = horzcat(svm_var2{:,columns});
    end
    
    
    % convert to double
    for i = 1:length(svm_data)
        svm_data{i} = cell2mat(svm_data{i});
    end
    svm_og = svm_data;
    
    % zscore
    if input.standardize == 1
        for i = 1:length(svm_data)
            svm_data{i}=zscore(svm_data{i});
        end
    end
    
    % Switch to directory containing libsvm toolbox.
    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\libsvm-3.20\matlab');

    % run svm function
    % on script that works - svm_temp is a NxN double, labels_temp is 35x1
    % double, testing_data is 1xN double, and model is 1x1 struct
    for bruh = 1:size(svm_data,2)
        % create labels for classifier parameters
        labels = vertcat(ones(1,size(svm_data{1},1)/2)',-ones(1,size(svm_data{1},1)/2)');       
        for i = 1:size(labels,1)
            svm_temp = svm_data{bruh};
            labels_temp = labels;
            testing_data = svm_data{bruh}(i,:);
            testing_label = labels(i,:);
            svm_temp(i,:) = [];
            labels_temp(i,:) = [];
            model = svmtrain(labels_temp, svm_temp, '-c 1 -t 0');
            [predict_label, accuracy, dec_value] = svmpredict(testing_label, testing_data, model);
            if accuracy(1,:) == 100
                total_accuracy(i,:) = 1;
            else
                total_accuracy(i,:) = 0;
            end
            dec_values(i,:) = dec_value;
        end
        
        % convert to percentage
        svm_perf(bruh) = (length(find(total_accuracy == 1))/length(labels))*100;
        svm_sem(bruh)  = (std(total_accuracy)/sqrt(length(total_accuracy)))*100;
        
        % use dec_values to determine how accurate classifier is
        [roc.X{bruh},roc.Y{bruh},roc.T{bruh},roc.AUC{bruh}] = perfcurve(labels,dec_values,1);
        
        % store accuracy values in variable
        trial_accuracy{bruh} = total_accuracy;   
        
        % house-cleaning
        clear svm_temp labels_temp testing_label testing_data model ...
            predict_label accuracy dec_values labels total_accuracy    
    end
    
    for bruh = 1:size(svm_data,2)
        %{
        ones_var = ones(size(svm_data{1},1)/2,1)';
        neg_ones = -ones(size(svm_data{1},1)/2,1)';
        var = [ones_var;neg_ones];  
        labels = var(:);
        labels_half1 = labels(1:size(labels,1)/2);
        shuffled_labels1 = randsample(labels_half1,size(labels,1)/2);     
        labels_half2 = labels(1:size(labels,1)/2);
        shuffled_labels2 = randsample(labels_half2,size(labels,1)/2);
        
        shuffled_labels = vertcat(shuffled_labels1,shuffled_labels2);
        %}
        % this is shuffled labels. Done once for the purpose of replication
        labels = [-1;-1;1;1;1;-1;-1;1;1;-1;-1;1;1;-1;1;-1;-1;1;1;-1;-1;-1;-1;1;-1;-1;1;1;1;1;-1;-1;1;1;-1;1];
        for i = 1:size(labels,1)
            svm_temp = svm_data{bruh};
            labels_temp = labels;
            testing_data = svm_data{bruh}(i,:);
            testing_label = labels(i,:);
            svm_temp(i,:) = [];
            labels_temp(i,:) = [];
            model = svmtrain(labels_temp, svm_temp, '-c 1 -t 0');
            [predict_label, accuracy, dec_value] = svmpredict(testing_label, testing_data, model);
            if accuracy(1,:) == 100
                total_accuracy(i,:) = 1;
            else
                total_accuracy(i,:) = 0;
            end
            dec_values(i,:) = dec_value;
        end
        
        % convert to percentage
        svm_perf_rand(bruh) = (length(find(total_accuracy == 1))/length(labels))*100;
        svm_sem_rand(bruh)  = (std(total_accuracy)/sqrt(length(total_accuracy)))*100;
        
        % use dec_values to determine how accurate classifier is
        [roc.X_rand{bruh},roc.Y_rand{bruh},roc.T_rand{bruh},roc.AUC_rand{bruh}] = perfcurve(labels,dec_values,1);
        
        % store trial accuracy data
        trial_accuracy_rand{bruh} = total_accuracy;   
        
        
        clear svm_temp labels_temp testing_label testing_data model ...
            predict_label accuracy dec_values labels total accuracy
    end

%% figure
% x_label
x_label = linspace(1,length(svm_perf),length(svm_perf));

figure('color',[1 1 1]);
shadedErrorBar(x_label,svm_perf,svm_sem,'-k',1);
hold on;
shadedErrorBar(x_label,svm_perf_rand,svm_sem_rand,'-r',1);

    set(gca, 'XTick',[1:length(x_label)])
    X = num2cell(round(linspace(-4,4,length(x_label))));
    set(gca, 'xticklabel',X)
    %ax = gca;
    %ax.XTickLabelRotation = 45;    

box off
ylabel('Classifier Accuracy (%)')
%xlabel('time')
axis tight
hold on;
ylim=get(gca,'ylim');
ylim=([30 100])
%hold on
%plot(xlim,[50 50],'LineWidth',1,'Color','r','linestyle','--')
line([5 5],[20 100],'Color',[1 0 0],'linestyle','--')
%legend('good performance','poor performance','Location','southeast')
%legend('Good Performance','Poor Performance','Location','southeast')
box off
set(gca,'FontSize',14)

for i = 1:size(trial_accuracy,2)
    [fisher_p{i},var_fisher{i}] = fisher_test(trial_accuracy{i},trial_accuracy_rand{i})
end

[h,p]=kstest2(svm_perf,svm_perf_rand)


% filter
for i = 1:length(svm_data)
   mean_rates{i} = mean(svm_data{i}); 
end

for i = 1:length(mean_rates)
    find_cells{i} = find(mean_rates{i}<1);
end

svm_og = svm_data;
for i = 1:length(find_cells)
    svm_data{i}(:,find_cells{i})=[];
end

% compare sample and choice accuracy
for i = 1:length(trial_accuracy)
    sample_accuracy{i}=trial_accuracy{i}(1:length(trial_accuracy{i})/2);
    choice_accuracy{i}=trial_accuracy{i}((length(trial_accuracy{i})/2)+1:end);
end
for i = 1:size(trial_accuracy,2)
    [p_tps{i},fisher_tps{i}] = fisher_test(sample_accuracy{i},choice_accuracy{i})
end

%% figure for roc analysis

figure('color',[1 1 1]);
plot(roc.X{5},roc.Y{5},'k')
hold on; 
plot(roc.X_rand{5},roc.Y_rand{5},'r') % 'r'
axis tight
%legend('mPFC early','mPFC late','location','southeast') % 
%legend('AUC Choice-Point','AUC 20s Delay','location','east') % 
xlabel('False Positive Rate')
ylabel('True Positive Rate')
box off

% determine if normally distributed
[h,p_norm]=swtest(roc.Y{5})
[p,h,stat]=signrank(roc.Y{5},roc.Y_rand{5})


%% rate maps
% choice rates on top, sample on bottom
for i = 1:length(svm_og)
    rates_choice{i} = svm_og{i}(1:18,:);
    rates_sample{i} = svm_og{i}(19:end,:);
end

% get means
for i = 1:length(svm_og)
    mean_rates_choice{i} = mean(rates_choice{i});
    mean_rates_sample{i} = mean(rates_sample{i});
end

% concat
rates_choice_concat = vertcat(mean_rates_choice{:});
rates_sample_concat = vertcat(mean_rates_sample{:});

% zrates
zscore_choice = (zscore(rates_choice_concat))';
zscore_sample = (zscore(rates_sample_concat))';
%zscore_rates = zscore(vertcat(rates_choice_concat,rates_sample_concat));

% invert
%zscore_choice = zscore_rates(1:9,:)';
%zscore_sample = zscore_rates(10:end,:)';

% sort
[~,indx] = sort(zscore_sample);
sortedChoice = zscore_choice(indx);

figure('color',[1 1 1]);
%heatmap(zscore_choice)
imagesc(sortedChoice)
colorbar

figure('color',[1 1 1]);
%heatmap(zscore_choice)
imagesc(sort(zscore_sample))
colorbar

% similarity
for i = 1:size(sortedChoice,2)
   dotprods(i)=dot(sort(zscore_sample(:,i)),sortedChoice(:,i)); 
end
figure('color',[1 1 1]);
bar(dotprods)

% diffscore
diffscore = (rates_choice_concat-rates_sample_concat)./...
    (rates_choice_concat+rates_sample_concat);

figure('color',[1 1 1]);
%heatmap(zscore_choice)
imagesc(sort(diffscore'))
colorbar