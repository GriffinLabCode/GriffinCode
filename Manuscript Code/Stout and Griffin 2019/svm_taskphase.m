%% svm_taskphase
%
% this function uses svm to predict whether the animal is on sample or
% choice phase during specific parameters dictated by the Int file, and if
% the animal is in a delay or ITI
%
% INPUT: input - struct array containing classification parameters
%
% OUTPUTS: svm_perf - a double containing classification accuracies
%          svm_sem  - a double containing the sem of classification
%          svm_categories - a Char variable containing the title for each
%          classification done
%          trial_accuracy - a cell array containing classification 
%          accuracy for each trial
%          svm_iterat - a cell array 1xN(iterations) containing trial
%          accuracy data; primarily used if doing many iterations
%          subsampling
%
% written by John Stout

function [svm_perf,svm_sem,svm_categories,trial_accuracy,svm_iterat,...
    svm_data,svm_perf_it,svm_sem_it,svm_rand_perf_it,svm_rand_sem_it,...
    svm_perf_rand,svm_sem_rand,trial_accuracy_rand,svm_rand_iterat,roc] = svm_taskphase(input,hz_filter)

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Linear Classifier');

% get formatted firing rate data
svm = svm_taskphase_fr_allsessions(input);

% get rid of NaNs
for NoNans = 1:size(input.rat,2)
   svm.sb{NoNans}(isnan((svm.sb{NoNans})))=0; 
   svm.stem{NoNans}(isnan((svm.stem{NoNans})))=0; 
   svm.t_junct{NoNans}(isnan((svm.t_junct{NoNans})))=0; 
   svm.goalArm{NoNans}(isnan((svm.goalArm{NoNans})))=0;
   svm.goalZone{NoNans}(isnan((svm.goalZone{NoNans})))=0; 
   svm.retArm{NoNans}(isnan((svm.retArm{NoNans})))=0; 
   svm.early{NoNans}(isnan((svm.early{NoNans})))=0; 
   svm.late{NoNans}(isnan((svm.late{NoNans})))=0;        
   disp('NaNs replaced with zero')
end
    
%% create svm_var
svm_var = vertcat(svm.early,svm.late,svm.stem,svm.t_junct,svm.goalArm,svm.goalZone,...
    svm.retArm);
svm_categories = char({'sb early','sb late','stem','t-junction','goal-arm',...
    'goal-zone','return-arm'});

%% zscore
    
if input.standardize_across_vars == 1
    % defined for ease - will need to change if maze locations change
    %trials = [1,34;35,70;71,106;107,142;143,178;179,214];
    %trials = [1,35;36,71;72,107;108,143;144,179;180,215;216,251];
    trials = [1,34;35,68;69,104;105,140;141,176;177,212;213,248];
    
    % run function
    [svm_var_new] = get_standardized_svmData(input,svm_var,trials);

    % save under svm_data common name
    svm_data = svm_var_new;    
    
    disp('data standardized across maze locations and task-phases')
elseif input.standardize_within_var == 1

    for col = 1:size(svm_var,2)
        for row = 1:size(svm_var,1)
            svm_z{row,col}  = zscore(svm_var{row,col});
        end
    end
    svm_data = svm_z;

else
    svm_data = svm_var;
end

%% subsample
% store original data
svm_data_og = svm_data;

% iterations can be used to create sub-sampled distributions and compare
% accuracies between two variables
for iterations = 1:input.n_iterations;
    % this can be used to compare two outcomes that have different sample
    % sizes
    if input.subsample == 1
        [subsampled_svmData,sub_idx] = svm_subsample(svm_data_og,input);
        svm_data = [];
        svm_data = subsampled_svmData;

        % display
        X = [];
        X = ['data subsampled down to ',num2str(input.n_samples),' cells'];
        disp(X);
    end

    %% svm   
        % add libsvm toolbox to directory.
        addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\libsvm-3.20\matlab');

        % run svm function
        % on script that works - svm_temp is a NxN double, labels_temp is 35x1
        % double, testing_data is 1xN double, and model is 1x1 struct
        for row = 1:size(svm_data,1)
            for col = 1:size(svm_data,2)
                    % create labels for classifier parameters
                    labels = vertcat(ones(size(svm_var{row,col},1)/2,1),...
                        -ones(size(svm_var{row,col},1)/2,1));
                    % svm classifier
                    for i = 1:size(labels,1)
                        svm_temp = svm_data{row,col};
                        labels_temp = labels;
                        testing_data = svm_data{row,col}(i,:);
                        testing_label = labels(i,:);
                        svm_temp(i,:) = [];
                        labels_temp(i,:) = [];
                        model = svmtrain(labels_temp, svm_temp, '-c 1 -t 0');
                        [predict_label, accuracy, dec_value] = ...
                            svmpredict(testing_label, testing_data, model);
                        if accuracy(1,:) == 100
                            total_accuracy(i,:) = 1;
                        else
                            total_accuracy(i,:) = 0;
                        end
                        dec_values(i,:) = dec_value;
                    end

                % store accuracy values in variable
                trial_accuracy{row,col} = total_accuracy;

                % convert to percentage
                svm_perf(row,col) = (length(find(total_accuracy == 1))...
                    /length(labels))*100;
                svm_sem(row,col)  = (std(total_accuracy)/...
                    sqrt(length(total_accuracy)))*100;

                % use dec_values to determine how accurate classifier is
                [roc.X{row,col},roc.Y{row,col},roc.T{row,col},roc.AUC{row,col}]...
                = perfcurve(labels,dec_values,1);

                clear svm_temp labels_temp testing_label testing_data...
                    model predict_label accuracy dec_values labels ...
                    total_accuracy
            end
        end

% now for shuffled labels
        for row = 1:size(svm_data,1)
            for col = 1:size(svm_data,2)
                    ones_var = ones(size(svm_var{row,col},1)/2,1)';
                    neg_ones = (-ones(size(svm_var{row,col},1)/2,1))';
                    var = [ones_var;neg_ones];  
                    labels = var(:);
                    % svm classifier
                    for i = 1:size(labels,1)
                        svm_temp = svm_data{row,col};
                        labels_temp = labels;
                        testing_data = svm_data{row,col}(i,:);
                        testing_label = labels(i,:);
                        svm_temp(i,:) = [];
                        labels_temp(i,:) = [];
                        model = svmtrain(labels_temp, svm_temp, '-c 1 -t 0');
                        [predict_label, accuracy, dec_value] = ...
                            svmpredict(testing_label, testing_data, model);
                        if accuracy(1,:) == 100
                            total_accuracy(i,:) = 1;
                        else
                            total_accuracy(i,:) = 0;
                        end
                        dec_values_rand(i,:) = dec_value;
                    end

                % store accuracy values in variable
                trial_accuracy_rand{row,col} = total_accuracy;

                % convert to percentage
                svm_perf_rand(row,col) = (length(find(total_accuracy == 1))...
                    /length(labels))*100;
                svm_sem_rand(row,col)  = (std(total_accuracy)/...
                    sqrt(length(total_accuracy)))*100;

                % use dec_values to determine how accurate classifier is
                [roc.X_rand{row,col},roc.Y_rand{row,col},roc.T_rand{row,col},roc.AUC_rand{row,col}]...
                = perfcurve(labels,dec_values_rand,1);

                clear svm_temp labels_temp testing_label testing_data...
                    model predict_label accuracy dec_values labels ...
                    total_accuracy
            end
        end
        
        % store trial accuracy classifier data across iterations
        if input.n_iterations > 1
           svm_iterat{:,iterations} = trial_accuracy;
           svm_perf_it{iterations} = svm_perf;
           svm_sem_it{iterations} = svm_sem;
           
           svm_rand_iterat{:,iterations} = trial_accuracy_rand;
           svm_rand_perf_it{iterations} = svm_perf_rand;
           svm_rand_sem_it{iterations} = svm_sem_rand;
           svm_perf = []; svm_sem = []; trial_accuracy = [];
           X = [];
           X = ['iteration ',num2str(iterations)];
           disp(X);
        else
            svm_iterat       = NaN;
            svm_perf_it      = NaN;
            svm_sem_it       = NaN;
            svm_rand_iterat  = NaN;
            svm_rand_perf_it = NaN;
            svm_rand_sem_it  = NaN;
        end

end

if input.plot == 1 && input.pseudosimultaneous == 1
    figure();
    plot(roc.X{6},roc.Y{6},'k')
    hold on; 
    plot(roc.X_rand{6},roc.Y_rand{6},'r') % 'r'
    axis tight
    %legend('mPFC early','mPFC late','location','southeast') % 
    %legend('AUC Choice-Point','AUC 20s Delay','location','east') % 
    xlabel('False Positive Rate')
    ylabel('True Positive Rate')
    box off
end

if input.n_iterations > 1
    cd('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Linear Classifier')
    save('svm_iterat.mat','svm_iterat');
end
end




