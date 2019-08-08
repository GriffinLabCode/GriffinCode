%% taskphase classifier
clear; clc

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Linear Classifier')
input = get_classifier_inputs();

% get classifier data
[stem] = svm_stem_taskphase_binned(input,input.numbins);
%[tjunct] = svm_tjunction(input);
%[goalarm] = svm_goalarm_taskphase(input,input.numbins);
%[goalzone] = svm_goalzone(input);
%[returnarm] = svm_retarm_taskphase(input,input.numbins);

%{
% format data
for i = 1:size(tjunct,2)
    tjun{i} = horzcat(tjunct{i}{:});
end
tjun = horzcat(tjunct{i}{:});
stm = stem{1};

% concatenate data
binned_stem = horzcat(stm,tjun');
%}

binned_stem = stem{1};
if input.standardize_across_vars == 1

    % reseparate
    trials = [1,36;37,72;73,108;109,144;145,180;181,216;217,252;253,288;...
        289,324;325,360;361,396;397,432;433,468;469,504];  

    [svm_data] = get_standardized_svmData(input,binned_stem',trials);

    % invert for consistency sake
    svm_data = svm_data';
elseif input.standardize_within_var == 1
    for col = 1:size(binned_stem,2)
        for row = 1:size(binned_stem,1)
            svm_z{row,col}  = zscore(binned_stem{row,col});
        end
    end
    svm_data = svm_z;
else
    svm_data = binned_stem;
end
%% svm
    % Switch to directory containing libsvm toolbox.
    cd('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\libsvm-3.20\matlab');

    % run svm function
    % on script that works - svm_temp is a NxN double, labels_temp is 35x1
    % double, testing_data is 1xN double, and model is 1x1 struct  
    
    % for each rat
        for row = 1:size(svm_data,1)
            for col = 1:size(svm_data,2)
                    % create labels for classifier parameters
                    labels = vertcat(ones(size(svm_data{row,col},1)/2,1),...
                        -ones(size(svm_data{row,col},1)/2,1));
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
                %[roc.X{bruh},roc.Y{bruh},roc.T{bruh},roc.AUC{bruh}]...
                %= perfcurve(labels,dec_values,1);

                clear svm_temp labels_temp testing_label testing_data...
                    model predict_label accuracy dec_values labels ...
                    total_accuracy
            end
        end
  
 
% run shuffled data
 % for each rat
        for row = 1:size(svm_data,1)
            for col = 1:size(svm_data,2)
                %{
                    ones_var = ones(size(svm_data{row,col},1)/2,1)';
                    neg_ones = (-ones(size(svm_data{row,col},1)/2,1))';
                    var = [ones_var;neg_ones];  
                    labels = var(:)
                %}    
                    labels = [-1;-1;1;1;1;-1;-1;1;1;-1;-1;1;1;-1;1;-1;-1;1;1;-1;-1;-1;-1;1;-1;-1;1;1;1;1;-1;-1;1;1;-1;1];
                    
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
                trial_accuracy_rand{row,col} = total_accuracy;

                % convert to percentage
                svm_perf_rand(row,col) = (length(find(total_accuracy == 1))...
                    /length(labels))*100;
                svm_sem_rand(row,col)  = (std(total_accuracy)/...
                    sqrt(length(total_accuracy)))*100;

                % use dec_values to determine how accurate classifier is
                %[roc.X{bruh},roc.Y{bruh},roc.T{bruh},roc.AUC{bruh}]...
                %= perfcurve(labels,dec_values,1);

                clear svm_temp labels_temp testing_label testing_data...
                    model predict_label accuracy dec_values labels ...
                    total_accuracy
            end
        end
        
% normal labels
mean_perf1 = svm_perf; mean_perf2 = svm_perf_rand;
sem_perf1 = svm_sem; sem_perf2 = svm_sem_rand;

% figure - run script separately twice while changing inputs to generate
x_label = (1:size(mean_perf1,2));

figure('color',[1 1 1]);
shadedErrorBar(x_label,mean_perf1,sem_perf1,'-k',1);
hold on;
shadedErrorBar(x_label,mean_perf2,sem_perf2,'-r',1);
set(gca, 'XTick',[1,2,3,4,5,6,7])
set(gca, 'xticklabel',{'stem','stem','stem','stem','stem','t-junction'})
ax = gca;
ax.XTickLabelRotation = 45;    
box off
ylabel('Classifier Accuracy (%)')
axis tight
ylim([20 100])
hold on;
xlim=get(gca,'xlim');
hold on
%plot(xlim,[50 50],'LineWidth',1,'Color','r','linestyle','--')
box off
set(gca,'FontSize',14)

figure();
e = errorbar(x_label,mean_perf1,sem_perf1,'g');
e.LineWidth = 2;
hold on;
ee = errorbar(x_label,mean_perf2,sem_perf2,'r');
ee.LineWidth = 2;
eee = errorbar(x_label,mean_perf3,sem_perf3,'k');
eee.LineWidth = 2;
set(gca, 'XTick',[1,2,3,4,5,6,7])
set(gca, 'xticklabel',{'stem entry','stem','stem','stem','stem','stem','t-junction'})
ax = gca;
ax.XTickLabelRotation = 45;    
box off
ylabel('Classifier Accuracy')
axis tight
ylim([0 100])
hold on;
xlim=get(gca,'xlim');
hold on
plot(xlim,[50 50],'LineWidth',1,'Color','r','linestyle','--')

% stats
%[h,p,ci,stats]=ttest2(svm_perf(:,end),svm_perf_rand(:,end))
[h,p,kstat]=kstest2(svm_perf,svm_perf_rand)

if input.pseudosimultaneous == 1
    for i = 1:size(trial_accuracy,2)
        [fisher_p{i},~] = fisher_test(trial_accuracy{i},trial_accuracy_rand{i});
    end
end