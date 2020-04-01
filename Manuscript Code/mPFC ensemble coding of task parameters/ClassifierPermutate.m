%% Pseudo-simultaneous and individual classification
% This code uses a classifier found from Henry to classify two classes
% designed by you. This code supports a few different features: 1) You can
% train on 75% and test on 25% iteratively, 2) you can take the leave 1 out
% approach (the recommended approach), 3) you can compare your data against
% a shuffled label distribution that tends to sit around 50% chance level
% accuracy, 4) you can take a down-sampling approach - this is a unique way
% to control for varying aspects of the structure of your data. For
% example, without down-sampling, you need a perfectly sized matrix for
% pseudo-simultaneous classification. However, with down-sampling, you find
% the session with the lowest number of trials per condition (ie there were
% 6 left trials was the lowest number of trials for all sessions and
% left/right conditions), and it will iteratively classify what you want it
% to. Because of the sub-sampling procedure, the down-sampling approach
% also shuffles the structure of your data therefore controlling for a
% chance effect you may have seen. The down-side is if representations are
% structured across time, you lose out on it. This approach allows you to
% look at only correct trials also. 5) Individual classification is a
% classifier trained on units individually - this tends to do pretty
% poorly.
%
% Note: you must format your data like so: a cell array where the first
% layer is cluster, and within each session is a matrix where rows indicate
% trial, columns indicate bin, and element reflects firing rate.
%
% ~~~ INPUTS ~~~
% data1: a cell array where each cell represents a clusters data. Within
%           each cell should be a matrix where row is trial and column is
%           bin. This is your first class.
% data2: sample as data1. This is your second class. The classifier will be
%           trained to distinguish between data1 and data2
% numObs: a scalar that represents the number of observations. Note that if
%           your sessions vary in observations, set downsample_data to 1.
%           IMPORTANT: numObs is the number of observations of trials per
%           condition. So if you have 14 lefts and 15 right trials, use 14.
%
% method_75Training_25Testing = 0; % train on 75% of data test on 25% (randomly selected 1000x)
% permute_labels  = 1; % shuffle and train/test classifier 1000x
% leave1out       = 1; % leave 1 out approach
% pseudosimult    = 1; % pseudosimultaneous method
% individual      = 0; % train on all individual cells against a theoretical 50% chance level
% downsample_data = 1; % iteratively downsample - good for diff trial counts
% numbins         = 22; % define this according to the number of cell elements
%                           in your svm_cell cellarray
%
% Example dataset 
%{
 cd('X:\03. Lab Procedures and Protocols\MATLABToolbox\1. Matlab Pipeline\Sample Data')
 load('data_mPFC_sampleChoice.mat')
%}

 method_75Training_25Testing = 0; 
 permute_labels   = 1; 
 leave1out        = 1; 
 pseudosimult     = 1; 
 individual       = 0; 
 downsample_data  = 1; 
 controlLeftRight = 0; % control for the number of lefts/rights? This is only important if you have DNMP task
 % things to change often
 %data1 = data_raw.FRdata.sample_neiLess;
 %data2 = data_raw.FRdata.choice_neiLess;
 %data1 = FRdata.lefts;
 %data2 = FRdata.rights;
 
 % if taskphase, do 15 trials. If trajectory, do 6 trials.
 numbins = 7; % numbins will be 1 less than when you estimate it
 numObs  = 6; % how many rows you got (ie trials). Use the minimum number. % 15 for sample/choice
 data1   = FRdata.lefts; % to get this, run formatData_Cleaning_...
 data2   = FRdata.rights; 
 
 % backup storage
 if controlLeftRight == 1
     data1og = data1;
     data2og = data2;
     data1be = FRdata.behSam; % these variables must be as long as clusters and for each cluster be the int file for sample/choice
     data2be = FRdata.behCho;
 end
 
% written by John Stout

% add libraries
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\1. Matlab Pipeline\2. Analysis Pipeline\Binned by Time\Support Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\libsvm-3.20\matlab');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Useful Functions')

%% classifier on all data
if pseudosimult == 1
    
    % train on ~75% and test on ~25% of data. This segment requires a
    % symmetrical matrix (ie sample number of trials for both conditions
    % and across all sessions).
    if method_75Training_25Testing == 1 && downsample_data == 0 
        disp('75% training 25% testing approach selected')
        pause(1)
            % reformat - don't have to loop separately. This new
            % format will be an array where each cell element is an
            % observation, and within the first shell is the number
            % of neurons concatenated horizontally
            for m = 1:numbins
                for mm = 1:length(data1)
                    data1form{m}(:,mm) = data1{mm}(:,m);
                    data2form{m}(:,mm) = data2{mm}(:,m);            
                end
            end                

            % concatenate the data vertically so that one class is
            % on top, one class is on bottom                    
            data = [];
            % generalized formatting for classifier
            for bini = 1:numbins % loop across bins
                % concatenate horizontally such that left is top, right is bottom
                data{bini} = vertcat(data1form{bini}, data2form{bini});
            end
            
            % replace any NaNs with 0 - note that NaNs will drive
            % the accuracy of your model to 50%
            for bini = 1:numbins
                data{bini}(find(isnan(data{bini})==1)) = 0;
            end            

            % loop iteratively
            for bini = 1:numbins
                disp(['shuffle ',num2str(n)]);
                for n = 1:1000
                    % train on 14, test on 4, 1000x. ztest
                    % randperm
                    perm_cond1 = randperm(numObs); % use the number of observations per condition to pull randomly from
                    perm_cond2 = randperm(numObs); 
                    % get labels
                    labels = vertcat(ones(numObs,1),-ones(numObs,1)); 
                    % training and testing labels
                    floor_75 = floor(numObs*.75);
                    ceil_end = ceil(numObs*.75);
                    train_cond1 = perm_cond1(1:floor_75);
                    train_cond2 = perm_cond2(1:floor_75); % take 1 through the floor of 75% of the data
                    test_cond1  = perm_cond1(ceil_end:end);
                    test_cond2  = perm_cond2(ceil_end:end); % take ceiling of 75% of data till the end
                    % data
                    data_cond1 = data1{bini}(perm_cond1,:); % get random data
                    data_cond2 = data2{bini}(perm_cond2,:); % get random data
                    % training data
                    data_training(1:floor_75,:) = data_cond1(train_cond1,:); % again randomize what you're pulling from the random data
                    data_training(ceil_end:floor_75*2,:) = data_cond2(train_cond2,:);
                    % testing data
                    data_testing(1:length(ceil_end:numObs),:) = data_cond1(test_cond1,:);
                    data_testing(length(ceil_end:numObs)+1:length(ceil_end:numObs)*2,:) = data_cond2(test_cond2,:);
                    % labels
                    labels_training = vertcat(repmat(1,floor_75,1),repmat(-1,floor_75,1));
                    labels_testing  = vertcat(repmat(1,length(ceil_end:numObs),1),repmat(-1,length(ceil_end:numObs),1));
                    % svm training
                    model = svmtrain(labels_training, data_training, '-c 1 -t 0');
                    [predict_label, accuracy, dec_value] = svmpredict(labels_testing, data_testing, model);
                    % store accuracy
                    Accuracy_iteration{bini}(n) = accuracy(1);
                    % clear data
                    clear labels_training labels_testing data_testing data_training data_sample ...
                        data_choice train_sample test_sample train_choice test_choice perm_sample ...
                        perm_choice labels_sample labels_choice model predict_label accuracy dec_value
                end
            end
            
            % get average per bin
            svm_perf = cellfun(@mean,Accuracy_iteration);
            
            % this figure shows the classifiers accuracy compared to a
            % theoretical 50%
            figure('color',[1 1 1]); hold on;
            for bini = 1:numbins
                subplot(numbins,1,bini)
                histogram(Accuracy_iteration{bini},6)
                line([50 50],[0 max(ylim)],'Color','r','linestyle','--','LineWidth',2)
                box off
                set(gca,'FontSize',9)
                ylabel(['bin ', num2str(bini)])
            end
            xlabel('Classifier Accuracy')
    elseif method_75Training_25Testing == 1 && downsample_data == 1  
        
        disp('training with 75% testing with 25% with iteratively down-sampled data selected')
        pause(1)

            % display
            disp('Controlling for different numbers of trials by permutation')
            pause(1)

            % generate labels
            labels = vertcat(ones(numObs,1),-ones(numObs,1));                

            % shuffle trials
            for n = 1:1000  
                disp(['shuffle trials ', num2str(n)])

                % this randomizes the ordering of trials for each
                % cluster. This, therefore, breaks any temporal
                % component to the population coding
                for clusti = 1:length(data1)

                    % random permutate and draw n observations (trials)
                    randPull1 = randsample(randperm(size(data1{clusti},1)),numObs);
                    randPull2 = randsample(randperm(size(data2{clusti},1)),numObs);

                    % extract data
                    data1new{clusti} = data1{clusti}(randPull1,:);
                    data2new{clusti} = data2{clusti}(randPull2,:);

                end
                
                % reformat - don't have to loop separately. This new
                % format will be an array where each cell element is an
                % observation, and within the first shell is the number
                % of neurons concatenated horizontally
                for m = 1:numbins
                    for mm = 1:length(data1)
                        data1form{m}(:,mm) = data1new{mm}(:,m);
                        data2form{m}(:,mm) = data2new{mm}(:,m);            
                    end
                end

                % concatenate the data vertically so that one class is
                % on top, one class is on bottom                    
                dataPerm = [];
                % generalized formatting for classifier
                for bini = 1:numbins % loop across bins
                    % concatenate horizontally such that left is top, right is bottom
                    dataPerm{bini} = vertcat(data1form{bini}, data2form{bini});
                end

                % replace any NaNs with 0 - note that NaNs will drive
                % the accuracy of your model to 50%
                for bini = 1:numbins
                    dataPerm{bini}(find(isnan(dataPerm{bini})==1)) = 0;
                end

                addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\libsvm-3.20\matlab')           

                % loop iteratively
                for nn = 1:1000
                    disp(['shuffle ratio of training/testing ',num2str(nn)]);
                    for bini = 1:numbins
                        % randperm
                        perm_cond1 = randperm(numObs); % use the number of observations per condition to pull randomly from
                        perm_cond2 = randperm(numObs); 
                        % get labels
                        labels = vertcat(ones(numObs,1),-ones(numObs,1)); 
                        % training and testing labels
                        floor_75 = floor(numObs*.75);
                        ceil_end = ceil(numObs*.75);
                        train_cond1 = perm_cond1(1:floor_75);
                        train_cond2 = perm_cond2(1:floor_75); % take 1 through the floor of 75% of the data
                        test_cond1  = perm_cond1(ceil_end:end);
                        test_cond2  = perm_cond2(ceil_end:end); % take ceiling of 75% of data till the end
                        % data
                        data_cond1 = data1{bini}(perm_cond1,:); % get random data (not really random, but random trials)
                        data_cond2 = data2{bini}(perm_cond2,:);
                        % training data
                        data_training(1:floor_75,:) = data_cond1(train_cond1,:);
                        data_training(ceil_end:floor_75*2,:) = data_cond2(train_cond2,:);
                        % testing data
                        data_testing(1:length(ceil_end:numObs),:) = data_cond1(test_cond1,:);
                        data_testing(length(ceil_end:numObs)+1:length(ceil_end:numObs)*2,:) = data_cond2(test_cond2,:);
                        % labels
                        labels_training = vertcat(repmat(1,floor_75,1),repmat(-1,floor_75,1));
                        labels_testing  = vertcat(repmat(1,length(ceil_end:numObs),1),repmat(-1,length(ceil_end:numObs),1));
                        % svm training
                        model = svmtrain(labels_training, data_training, '-c 1 -t 0');
                        [predict_label, accuracy, dec_value] = svmpredict(labels_testing, data_testing, model);
                        % store accuracy - row is shuffled trials, column
                        % is shuffled ratio of training/testing
                        Accuracy_iteration{bini}(n,nn) = accuracy(1);
                        % clear data
                        clear labels_training labels_testing data_testing data_training data_sample ...
                            data_choice train_sample test_sample train_choice test_choice perm_sample ...
                            perm_choice labels_sample labels_choice model predict_label accuracy dec_value
                    end
                end
            end
            
            % get average per bin
            svm_perf = cellfun(@mean,cellfun(@mean,Accuracy_iteration,'UniformOutput',false));
            
            % this figure shows the classifiers accuracy compared to a
            % theoretical 50%
            figure('color',[1 1 1]); hold on;
            for bini = 1:numbins
                subplot(numbins,1,bini)
                histogram(Accuracy_iteration{bini},6)
                line([50 50],[0 max(ylim)],'Color','r','linestyle','--','LineWidth',2)
                box off
                set(gca,'FontSize',9)
                ylabel(['bin ', num2str(bini)])
            end
            xlabel('Classifier Accuracy')        
        
    end
    
    if leave1out == 1
        disp('Leave 1 out approach selected')
        pause(1)

        % run classifier on untouched data
        if downsample_data == 0

            disp('Leave 1 out approach without down-sampling')
            pause(1)

            % create labels for classifier parameters
            labels = vertcat(ones(numObs,1),-ones(numObs,1));

            % reformat - don't have to loop separately. This new
            % format will be an array where each cell element is an
            % observation, and within the first shell is the number
            % of neurons concatenated horizontally
            for m = 1:numbins
                for mm = 1:length(data1)
                    data1form{m}(:,mm) = data1{mm}(:,m);
                    data2form{m}(:,mm) = data2{mm}(:,m);            
                end
            end                

            % concatenate the data vertically so that one class is
            % on top, one class is on bottom                    
            data = [];
            % generalized formatting for classifier
            for bini = 1:numbins % loop across bins
                % concatenate horizontally such that left is top, right is bottom
                data{bini} = vertcat(data1form{bini}, data2form{bini});
            end

            % replace any NaNs with 0 - note that NaNs will drive
            % the accuracy of your model to 50%
            for bini = 1:numbins
                data{bini}(find(isnan(data{bini})==1)) = 0;
            end                

            for bini = 1:numbins
                total_accuracy = [];
                % svm classifier
                for i = 1:size(labels,1)
                    svm_temp = data{bini};
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
                svm_perf(bini) = (length(find(total_accuracy == 1))...
                /length(labels))*100;
                svm_sem(bini)  = (std(total_accuracy)/...
                sqrt(length(total_accuracy)))*100;
                svm_std(bini)  = std(total_accuracy);

                % save total accuracy variable
                TotalAccuracy{bini} = total_accuracy;
            end

        % if you have slightly different numbers of trials, you can
        % iteratively downsample, grab the mean, then use that against
        % a chance level distribution. Also note that your data has to
        % be formatted so that each cell contains 1 neurons activity
        % across a bunch of trials (rows) and observations (columns)
        elseif leave1out == 1 && downsample_data == 1

            % display
            disp('Controlling for different numbers of trials by permutation')
            pause(1)

            % generate labels
            labels = vertcat(ones(numObs,1),-ones(numObs,1));                

            % shuffle trials
            for n = 1:1000  
                disp(['shuffle ', num2str(n)])

                % this randomizes the ordering of trials for each
                % cluster. This, therefore, breaks any temporal
                % component to the population coding
                for clusti = 1:length(data1) % loop over clusters

                    if controlLeftRight == 1 % control for varying lefts/rights
                        
                        % get lefts/rights
                        data1Left  = data1{clusti}(find(data1be{clusti}(:,3)==1),:);
                        data1Right = data1{clusti}(find(data1be{clusti}(:,3)==0),:);
                        data2Left  = data2{clusti}(find(data2be{clusti}(:,3)==1),:);
                        data2Right = data2{clusti}(find(data2be{clusti}(:,3)==0),:);
                        
                        % based on the number of observations set, randomly
                        % pull the same number of lefts and rights from
                        % both datasets
                        randPull1L = randsample(randperm(size(data1Left,1)),numObs/2);
                        randPull1R = randsample(randperm(size(data1Right,1)),numObs/2);
                        randPull2L = randsample(randperm(size(data2Left,1)),numObs/2);
                        randPull2R = randsample(randperm(size(data2Right,1)),numObs/2);
                        
                        % extract and put them together in a random order
                        data1Ltemp = data1Left(randPull1L,:);
                        data1Rtemp = data1Right(randPull1R,:);
                        data2Ltemp = data2Left(randPull2L,:); 
                        data2Rtemp = data2Right(randPull2R,:);
                        
                        % put back together randomly - note that this data
                        % set is now lefts and rights controlled
                        data1tempUnshuff = vertcat(data1Ltemp,data1Rtemp);
                        data2tempUnshuff = vertcat(data2Ltemp,data2Rtemp);
                        shuffIdx1 = randsample(numObs,numObs);
                        shuffIdx2 = randsample(numObs,numObs);
                        
                        % add back together
                        data1new{clusti} = data1tempUnshuff(shuffIdx1,:);
                        data2new{clusti} = data2tempUnshuff(shuffIdx2,:);
                        
                    else

                        % random permutate and draw n observations (trials)
                        randPull1 = randsample(randperm(size(data1{clusti},1)),numObs);
                        randPull2 = randsample(randperm(size(data2{clusti},1)),numObs);   

                        % extract data
                        data1new{clusti} = data1{clusti}(randPull1,:);
                        data2new{clusti} = data2{clusti}(randPull2,:);   
                        
                    end
                end
                % reformat - don't have to loop separately. This new
                % format will be an array where each cell element is an
                % observation, and within the first shell is the number
                % of neurons concatenated horizontally
                for m = 1:numbins
                    for mm = 1:length(data1)
                        data1form{m}(:,mm) = data1new{mm}(:,m);
                        data2form{m}(:,mm) = data2new{mm}(:,m);            
                    end
                end

                % concatenate the data vertically so that one class is
                % on top, one class is on bottom                    
                dataPerm = [];
                % generalized formatting for classifier
                for bini = 1:numbins % loop across bins
                    % concatenate horizontally
                    dataPerm{bini} = vertcat(data1form{bini}, data2form{bini});
                end

                % replace any NaNs with 0 - note that NaNs will drive
                % the accuracy of your model to 50%
                for bini = 1:numbins
                    dataPerm{bini}(find(isnan(dataPerm{bini})==1)) = 0;
                end

                addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\libsvm-3.20\matlab')

                % loop across bins and run classifier
                for bini = 1:numbins
                    % run classifier
                    total_accuracy = [];
                    % svm classifier
                    for i = 1:size(labels,1)
                        svm_temp = dataPerm{bini};
                        labels_temp = labels;
                        testing_data = dataPerm{bini}(i,:);
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

                    % convert to percentage - note that data perm is
                    % not randomized data. This is not a random
                    % distribution, its a way to control for different
                    % numbers of trials included. Its also a way to
                    % change the temporal component of neural activity
                    % (ie maybe trial specific neuronal activity is
                    % important for tracking the task or something...
                    % Who knows!)
                    svm_perf_dataPerm{bini}(n) = (length(find(total_accuracy == 1))...
                    /length(total_accuracy))*100;
                    svm_sem_dataPerm{bini}(n)  = (std(total_accuracy)/...
                    sqrt(length(total_accuracy)))*100;
                end
            end
            % get the average within the cell array
            svm_perf = cellfun(@mean,svm_perf_dataPerm);
            svm_std  = cellfun(@std,svm_perf_dataPerm);
        end
    end
            
    % if you want to shuffle your labels for chance distribution
    if permute_labels == 1
        disp('Shuffling labels')
        pause(1)
        
        for bini = 1:numbins
            % format labels
            if downsample_data == 0
                % permutate for shuffled labels
                % create labels for classifier parameters
                ones_var = ones(size(svm_cell{1},1)/2,1)'; % svm_cell deprecated
                neg_ones = (-ones(size(svm_cell{1},1)/2,1))';
                var = [ones_var;neg_ones];  
                labels_interleave = var(:);
            else
                ones_var = ones(size(dataPerm{1},1)/2,1)';
                neg_ones = (-ones(size(dataPerm{1},1)/2,1))';
                var = [ones_var;neg_ones];  
                labels_interleave = var(:);
            end

            % shuffle labels and make distribution to test against
            for n = 1:1000
               disp(['shuffle labels ', num2str(n)])
               % shuffle
               perm_idx = randperm(length(labels_interleave));
               % get labels
               labels_shuff = labels_interleave(perm_idx);
               % svm
                total_accuracy = [];
                if downsample_data == 1
                    data = [];
                    data = dataPerm{bini};
                end
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
                svm_perf_rand{bini}(n) = (length(find(total_accuracy == 1))...
                /length(labels_shuff))*100;
                svm_sem_rand{bini}(n)  = (std(total_accuracy)/...
                sqrt(length(total_accuracy)))*100;
            end
            clearvars -except svm_perf svm_perf_rand svm_cell permute_data ...
                permute_labels leave1out ii n p svm_sem shuff_mean svm_perf_rand TotalAccuracy ...
                shuff_mean individual data downsample_data dataPerm numbins FRdata ...
                data1 data2 numObs svm_perf_dataPerm svm_sem_dataPerm ...
                method_75Training_25Testing ci stat svm_std          
        end
        
        for bini = 1:numbins
            % ztest to determine if the mean observed of the real data differs from
            % the mean and std of the shuffled distribution
            [h,p(bini),ci{bini},stat{bini}] = ztest(svm_perf(bini),mean(svm_perf_rand{bini}),std(svm_perf_rand{bini}));

            % store shuffled average
            shuff_mean(bini) = mean(svm_perf_rand{bini});            
        end

            figure('color',[1 1 1]); hold on;
            for bini = 1:numbins
                subplot(numbins,1,bini)
                histogram(svm_perf_rand{bini},15)
                line([svm_perf(bini) svm_perf(bini)],[0 max(ylim)],'Color','r','linestyle','--','LineWidth',2)
                box off
                set(gca,'FontSize',9)
                ylabel(['bin ', num2str(bini)])
            end
            xlabel('Classifier Accuracy')
    end
    
    if method_75Training_25Testing == 1 && permute_labels == 1               
        figure('color',[1 1 1]); hold on;
        for bini = 1:numbins
            subplot(numbins,1,bini)
            histogram(Accuracy_iteration{bini},12)
            line([shuff_mean(bini) shuff_mean(bini)],[0 max(ylim)],'Color','r','linestyle','--','LineWidth',2)
            box off
            set(gca,'FontSize',9)
            ylabel(['bin ', num2str(bini)])
        end
        xlabel('Classifier Accuracy') 
    end
    
    if permute_labels == 1 && downsample_data == 1
        figure('color',[1 1 1]); hold on;
        for bini = 1:numbins
            subplot(numbins,1,bini)
            h1 = histogram(svm_perf_rand{bini},12);
            h1.FaceAlpha = .2;
            hold on;
            h2 = histogram(svm_perf_dataPerm{bini},12);
            h2.FaceColor = 'r'; 
            h2.FaceAlpha = 0.2;
            line([svm_perf(bini) svm_perf(bini)],[0 max(ylim)],'Color','r','linestyle','--','LineWidth',2)
            box off
            set(gca,'FontSize',9)
            ylabel(['bin ', num2str(bini)])
        end
        xlabel('Classifier Accuracy')        
    end

    % figure
    num_vars = 1:length(svm_perf);

    % please note that the sem variable is a filler. In the case where you
    % downsample, you use the standard deviation
    if downsample_data == 1
        svm_sem = svm_std;
    end
    
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
    %line([0 0],[40 100],'Color','k','linestyle','-','LineWidth',2)
    set(gca,'FontSize',14)
    ylim([0 100])

    % plot a line where significance is met
    x_label = 1:length(shuff_mean);
    line_data = NaN([1 length(shuff_mean)]);
    Yminmax = get(gca,'Ylim');
    line_data(find(p<0.05))=Yminmax(2);
    for i = 1:length(shuff_mean)
        y = line_data(i);
        line([i-0.4,i+0.4],[y,y],'Color','m','LineWidth',2)
    end         
    axis tight
    ylim([0 100])
    

    % line graph
    x_label = 1:length(svm_perf);
    figure('color',[1 1 1]); hold on;
    er                   = errorbar(x_label,svm_perf,svm_sem);    
    er.Color             = 'k';                            
    er.LineWidth         = 2;
    set(gca,'FontSize',14)
    ylim([0 100])
    
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

    for clusti = 1:length(data1)
        disp(['Neuron ', num2str(clusti),'/',num2str(length(data1))]);
        
        % define a dynamic variable
        data = vertcat(data1{clusti},data2{clusti});
        
        % replace nans with 0
        data(find(isnan(data)==1))=0;

        % number of trials
        numObs = size(data,1)/2;
        
        % generate labels
        labels = vertcat(ones(numObs,1),-ones(numObs,1));                

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
        svm_perf(clusti) = (length(find(total_accuracy == 1))...
        /length(labels))*100;
        svm_sem(clusti)  = (std(total_accuracy)/...
        sqrt(length(total_accuracy)))*100;
        svm_std(clusti)  = std(total_accuracy);
        
        % stats
        p(clusti)=myBinomTest(length(find(total_accuracy == 1)),length(total_accuracy)...
            ,.5,'two');     
    end
    
    % get p values that were above sig
    p_above = find(svm_perf > 50 & p < 0.05);
        
%{    
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
%}    
    
end

    prompt = 'Please briefly describe this dataset ';
    data_description = input(prompt,'s');

    prompt   = 'Please enter a unique name for this dataset ';
    unique_name = input(prompt,'s');

    prompt   = 'Enter the directory to save the data ';
    dir_name = input(prompt,'s');

    save_var = unique_name;

    cd(dir_name);
    save(save_var);  