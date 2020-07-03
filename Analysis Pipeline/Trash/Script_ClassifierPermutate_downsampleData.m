%% classifier, can handle kmeans, individual cell classification
% if you want to take this into excel, look for svm_perf, svm_sem and
% shuff_mean, and sem_rand
%
%
% ~~~ INPUTS ~~~
%{
permute_data   = 0; % train on 75% of data test on 25% (randomly selected 1000x)
permute_labels = 1; % shuffle and train/test classifier 1000x
leave1out      = 1; % leave 1 out approach
pseudosimult   = 1; % pseudosimultaneous method
individual     = 0; % train on all individual cells against a theoretical 50% chance level
%}
% svm_cell: must be formatted in a cell array. In each cell, the first half
% of rows indicate label 1 and second half label 2. Each cell can be used
% as bins of your choosing. Depends on how you extract your data

% add libraries
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\1. Matlab Pipeline\2. Analysis Pipeline\Binned by Time\Support Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\libsvm-3.20\matlab');

%% classifier on all data
 

    % figure
    num_vars = 1:length(svm_perf);

    figure('color',[1 1 1]); hold on;
    for i = 1:length(svm_perf)
        b                    = bar(num_vars(i),svm_perf(i));               
        er                   = errorbar(num_vars(i),svm_perf(i),svm_sem(i));    
        er.Color             = [0 0 0];                            
        er.LineStyle         = 'none';  
    end
    set(gca,'FontSize',14)
    % add shuffled mean
    for i = 1:length(shuff_mean)
        y = shuff_mean(i);
        line([i-0.4,i+0.4],[y,y],'Color','r','LineWidth',2)
    end
    % get low and high points on graph
    low_pnt = min(shuff_mean)-10;
    % tighten axes
    ylim([low_pnt-2,100])

    % mean and sem of distribution of shuffled labels
    for i = 1:length(svm_perf_rand)
        mean_rand(i) = mean(svm_perf_rand{i});
        sem_rand(i)  = (std(svm_perf_rand{i}))./(sqrt(length(svm_perf_rand{i})));
    end

    % shaded error bar
    x_label = linspace(1,4,length(shuff_mean));

    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Cool Plots');
    
    % figure
    figure('color',[1 1 1]); hold on
    shadedErrorBar(x_label,svm_perf,svm_sem,'k',0);
    plot(x_label,shuff_mean,'--r','LineWidth',2)
    line([0 0],[40 100],'Color','k','linestyle','-','LineWidth',2)
    set(gca,'FontSize',14)

    % line graph
    x_label = 1:length(svm_perf);
    figure('color',[1 1 1]); hold on;
    er                   = errorbar(x_label,svm_perf,svm_sem);    
    er.Color             = 'k';                            
    er.LineWidth         = 2;
    set(gca,'FontSize',14)

    % add shuffled mean
    for i = 1:length(shuff_mean)
        y = shuff_mean(i);
        line([i-0.4,i+0.4],[y,y],'Color','r','LineWidth',2)
    end      

    % plot a line where significance is met
    x_label = 1:length(shuff_mean);
    line_data = NaN([1 length(shuff_mean)]);
    Yminmax = get(gca,'Ylim');
    line_data(find(p<0.05))=Yminmax(2);
    for i = 1:length(shuff_mean)
        y = line_data(i);
        line([i-0.4,i+0.4],[y,y],'Color','m','LineWidth',2)
    end     
end

if individual == 1
    % define a dynamic variable
    data = [];
    data = svm_cell{ii};

    % create labels for classifier parameters
    labels = vertcat(ones(size(svm_cell{1},1)/2,1),...
        -ones(size(svm_cell{1},1)/2,1));

    total_accuracy = [];
    % svm classifier
    for i = 1:size(labels,1)
        svm_temp = data;
        labels_temp = labels;
        testing_data = data(i,:);
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

    % convert to percentage
    svm_perf(ii) = (length(find(total_accuracy == 1))...
    /length(labels))*100;
    svm_sem(ii)  = (std(total_accuracy)/...
    sqrt(length(total_accuracy)))*100;
    svm_std(ii)  = std(total_accuracy);

    % permutate for shuffled labels
    % create labels for classifier parameters
    ones_var = ones(size(svm_cell{1},1)/2,1)';
    neg_ones = (-ones(size(svm_cell{1},1)/2,1))';
    var = [ones_var;neg_ones];  
    labels_interleave = var(:);

    % shuffle labels and make distribution to test against
    for n = 1:1000
       % get half labels for consistency
       half = labels_interleave(1:length(labels)/2);
       % shuffle
       perm_idx1 = randperm(18);
       perm_idx2 = randperm(18);       
       % get labels
       labels_1     = labels_interleave(perm_idx1);
       labels_2     = labels_interleave(perm_idx2);
       labels_shuff = vertcat(labels_1,labels_2);
       % svm
        total_accuracy = [];
        % svm classifier
        for i = 1:size(labels_shuff,1)
            svm_temp = data;
            labels_temp = labels_shuff;
            testing_data = data(i,:);
            testing_label = labels_shuff(i,:);
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

        % convert to percentage
        svm_perf_rand{ii}(n) = (length(find(total_accuracy == 1))...
        /length(labels_shuff))*100;
        svm_sem_rand{ii}(n)  = (std(total_accuracy)/...
        sqrt(length(total_accuracy)))*100;
    end
    
    
end
