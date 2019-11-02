%% Classify task phase coding in the different maze bins
%
% output svm_cell is a cell array containing all rate data that is zscored
% across trials


clear; clc;
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Linear Classifier')


    % get classifier inputs
    [input]=get_classifier_inputs();  
        
    % svm at T-junction
    %[tjunct] = svm_tjunction(input);
    stem   = svm_stem(input);
    tjunct = svm_tjunction(input);
    goalzo = svm_goalzone(input);
    goalar = svm_goalarm(input);
    retuar = svm_returnarm(input);

    % zscore
    for i = 1:size(tjunct{1, 1},2)
        svm_z.stem{i}    = zscore(stem{1}{i});
        svm_z.tjunct{i}  = zscore(tjunct{1}{i});
        svm_z.goalzo{i}  = zscore(goalzo{1}{i});
        svm_z.goalar{i}  = zscore(goalar{1}{i});
        svm_z.retuar{i}  = zscore(retuar{1}{i});  
    end

    % concatenate
    svm_data.stem   = horzcat(svm_z.stem{:});
    svm_data.tjunct = horzcat(svm_z.tjunct{:});
    svm_data.goalzo = horzcat(svm_z.goalzo{:});
    svm_data.goalar = horzcat(svm_z.goalar{:});
    svm_data.retuar = horzcat(svm_z.retuar{:});    
    
    svm_cell = struct2cell(svm_data);
    
    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\libsvm-3.20\matlab');

    % create labels for classifier parameters
    labels = vertcat(ones(size(svm_data.stem,1)/2,1),...
        -ones(size(svm_data.stem,1)/2,1));
    % clear out total_accuracy variable
    total_accuracy = [];
    for ii = 1:length(svm_cell)
        % svm classifier
        for i = 1:size(labels,1)
            svm_temp = svm_cell{ii};
            labels_temp = labels;
            testing_data = svm_cell{ii}(i,:);
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
            dec_values{ii}(i,:) = dec_value;
        end

    % store accuracy values in variable
    trial_accuracy{ii} = total_accuracy;

    % convert to percentage
    svm_perf{ii} = (length(find(total_accuracy == 1))...
    /length(labels))*100;
    svm_sem{ii}  = (std(total_accuracy)/...
    sqrt(length(total_accuracy)))*100;

    % use dec_values to determine how accurate classifier is
    [roc.X{ii},roc.Y{ii},roc.T{ii},roc.AUC{ii}] = ...
        perfcurve(labels,dec_values{ii},1);
    end
    
svm_perf = cell2mat(svm_perf);
svm_sem  = cell2mat(svm_sem);

roc.X = horzcat(roc.X{:});
roc.Y = horzcat(roc.Y{:});

i=1;
figure('color',[1 1 1]);
plot(roc.X{i},roc.Y{i},'k')
hold on; 
plot(roc.X_rand{i},roc.Y_rand{i},'r') % 'r'
axis tight
%legend('mPFC early','mPFC late','location','southeast') % 
%legend('AUC Choice-Point','AUC 20s Delay','location','east') % 
xlabel('False Positive Rate')
ylabel('True Positive Rate')
box off
set(gca,'FontSize',14)

[h,p,d]=kstest2(roc.Y{i},roc.Y_rand{i})
