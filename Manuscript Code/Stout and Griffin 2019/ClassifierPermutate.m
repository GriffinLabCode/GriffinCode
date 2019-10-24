%% kmeans on classifier
clear; clc

load('data_classifier_mazeLocations.mat');
load('KmeansIdx.mat');
clearvars -except idx C svm_cell svm_data low_accuracy high_accuracy

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\libsvm-3.20\matlab');

permute_data   = 0; % train on 75% of data test on 25% (randomly selected 1000x)
permute_labels = 1; % shuffle and train/test classifier 1000x
leave1out      = 1; % leave 1 out approach

% reformat
if iscell(svm_cell) == 1
    svm_cell = svm_data;
else
    svm_cell = struct2cell(svm_cell);
end

%% classifier on all data
for ii = 1:length(svm_cell)
    if permute_data == 1
        if leave1out == 0
            for ii = 1:length(svm_cell)
                data = [];
                data = svm_cell{ii};
                for i = 1:1000
                    % train on 14, test on 4, 1000x. ztest
                    % randperm
                    perm_sample = randperm(18);
                    perm_choice = randperm(18); % only need up to 18 then split up labels
                    % get labels
                    labels_sample = ones(size(svm_data.stem,1)/2,1);
                    labels_choice = -ones(size(svm_data.stem,1)/2,1); 
                    % training and testing labels
                    train_sample = perm_sample(1:14);
                    train_choice = perm_choice(1:14); % take the first 14 (they're random anyway)
                    test_sample  = perm_sample(15:end);
                    test_choice  = perm_choice(15:end); % take the last few (they're random)
                    % data
                    data_sample  = data(1:18,:);
                    data_choice  = data(19:end,:);
                    % training data
                    data_training(1:14,:) = data_sample(train_sample,:);
                    data_training(size(data_training,1)+1:28,:) = data_choice(train_choice,:);
                    % testing data
                    data_testing(1:4,:) = data_sample(test_sample,:);
                    data_testing(5:8,:) = data_choice(test_choice,:);
                    % labels
                    labels_training = vertcat(repmat(1,14,1),repmat(-1,14,1));
                    labels_testing  = vertcat(repmat(1,4,1),repmat(-1,4,1));
                    % svm training
                    model = svmtrain(labels_training, data_training, '-c 1 -t 0');
                    [predict_label, accuracy, dec_value] = svmpredict(labels_testing, data_testing, model);
                    % store accuracy
                    Accuracy_iteration(i) = accuracy(1);
                    % clear data
                    clear labels_training labels_testing data_testing data_training data_sample ...
                        data_choice train_sample test_sample train_choice test_choice perm_sample ...
                        perm_choice labels_sample labels_choice model predict_label accuracy dec_value
                end
                figure('color',[1 1 1]);
                histogram(Accuracy_iteration,6)
                line([50 50],[0 max(ylim)],'Color','r','linestyle','--','LineWidth',2)
                box off
                set(gca,'FontSize',14)
            end
        end
    elseif permute_labels == 1

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
        
        clearvars -except svm_perf svm_perf_rand svm_cell permute_data ...
            permute_labels leave1out ii n p svm_sem shuff_mean svm_perf_rand
    end

%{
    % figure
    figure('color',[1 1 1]);
    histogram(svm_perf_rand{ii})
    line([svm_perf(ii) svm_perf(ii)],[0 max(ylim)],'Color','k','linestyle','--','LineWidth',2)
    box off
    set(gca,'FontSize',14)
%}
    
    % ztest to determine if the mean observed of the real data differs from
    % the mean and std of the shuffled distribution
    [h,p(ii)] = ztest(svm_perf(ii),mean(svm_perf_rand{ii}),std(svm_perf_rand{ii}));
    
    % store shuffled average
    shuff_mean(ii) = mean(svm_perf_rand{ii});
end

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
x_label = linspace(-4,4,length(shuff_mean));

% figure
figure('color',[1 1 1]); hold on
shadedErrorBar(x_label,svm_perf,svm_sem,'k',0);
plot(x_label,shuff_mean,'--r','LineWidth',2)
line([0 0],[40 100],'Color','k','linestyle','-','LineWidth',2)
set(gca,'FontSize',14)

high_low_rate = 0;
%% classifier on high and low rate neurons
if high_low_rate == 1
    extract = 2; % 1 for low, 2 for high

    % analyze high rate or low rate data
    svm_og = svm_cell;
    for i = 1:length(svm_cell)
        svm_temp{i}=svm_cell{i}(:,find(idx==extract));
    end
    clear svm_cell
    svm_cell=svm_temp;

    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\libsvm-3.20\matlab');

    permute_data   = 0; % train on 75% of data test on 25% (randomly selected 1000x)
    permute_labels = 1; % shuffle and train/test classifier 1000x
    leave1out      = 1; % leave 1 out approach

    %% classifier
    for ii = 1:length(svm_cell)
        if permute_data == 1
            if leave1out == 0
                for ii = 1:length(svm_cell)
                    data = [];
                    data = svm_cell{ii};
                    for i = 1:1000
                        % train on 14, test on 4, 1000x. ztest
                        % randperm
                        perm_sample = randperm(18);
                        perm_choice = randperm(18); % only need up to 18 then split up labels
                        % get labels
                        labels_sample = ones(size(svm_data.stem,1)/2,1);
                        labels_choice = -ones(size(svm_data.stem,1)/2,1); 
                        % training and testing labels
                        train_sample = perm_sample(1:14);
                        train_choice = perm_choice(1:14); % take the first 14 (they're random anyway)
                        test_sample  = perm_sample(15:end);
                        test_choice  = perm_choice(15:end); % take the last few (they're random)
                        % data
                        data_sample  = data(1:18,:);
                        data_choice  = data(19:end,:);
                        % training data
                        data_training(1:14,:) = data_sample(train_sample,:);
                        data_training(size(data_training,1)+1:28,:) = data_choice(train_choice,:);
                        % testing data
                        data_testing(1:4,:) = data_sample(test_sample,:);
                        data_testing(5:8,:) = data_choice(test_choice,:);
                        % labels
                        labels_training = vertcat(repmat(1,14,1),repmat(-1,14,1));
                        labels_testing  = vertcat(repmat(1,4,1),repmat(-1,4,1));
                        % svm training
                        model = svmtrain(labels_training, data_training, '-c 1 -t 0');
                        [predict_label, accuracy, dec_value] = svmpredict(labels_testing, data_testing, model);
                        % store accuracy
                        Accuracy_iteration(i) = accuracy(1);
                        % clear data
                        clear labels_training labels_testing data_testing data_training data_sample ...
                            data_choice train_sample test_sample train_choice test_choice perm_sample ...
                            perm_choice labels_sample labels_choice model predict_label accuracy dec_value
                    end
                    figure('color',[1 1 1]);
                    histogram(Accuracy_iteration,6)
                    line([50 50],[0 max(ylim)],'Color','r','linestyle','--','LineWidth',2)
                    box off
                    set(gca,'FontSize',14)
                end
            end
        elseif permute_labels == 1

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

            clearvars -except svm_perf svm_perf_rand svm_cell permute_data ...
                permute_labels leave1out ii n p svm_sem shuff_mean svm_perf_rand
        end

        % figure
        figure('color',[1 1 1]);
        histogram(svm_perf_rand{ii})
        line([svm_perf(ii) svm_perf(ii)],[0 max(ylim)],'Color','k','linestyle','--','LineWidth',2)
        box off
        set(gca,'FontSize',14)

        % ztest to determine if the mean observed of the real data differs from
        % the mean and std of the shuffled distribution
        [h,p(ii)] = ztest(svm_perf(ii),mean(svm_perf_rand{ii}),std(svm_perf_rand{ii}));

        % store shuffled average
        shuff_mean(ii) = mean(svm_perf_rand{ii});
    end

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
    ylim([low_pnt-2*min_sem,100])
end




