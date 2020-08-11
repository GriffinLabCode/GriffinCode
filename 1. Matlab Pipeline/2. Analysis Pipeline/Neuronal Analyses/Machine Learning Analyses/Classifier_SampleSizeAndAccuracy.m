%% number of neurons required for above chance classification 
%
% this code iteratively adds neurons to the classifier to determine the
% number required for above chance classification at T-junction. It leans
% heavily on T-junction and task phase discrimination as this was a robust
% effect.

%% Change these things!

% shuffle seed
rng('shuffle')
clear; clc

% this is the output from ClassifierPermutate
dataName = 'data_classify_LvR_choice_lessThan2Hz';

% select a bin to draw from
binDraw = 2;

load(dataName)

%data1 = FRdata.lefts;
%data2 = FRdata.rights;

clearvars -except data1 data2 dataName binDraw

% define a dynamic variable
data1Master  = data1; % to get this, run formatData_Cleaning_...
data2Master  = data2;
    
% least number of possible observations
numObs = 6;

% number of neurons
numNeurons = length(data1);

% make an index for numbers of neurons to draw
roundDown = 5*floor(numNeurons/5);
selectIdx = 5:5:roundDown;

% How many iterations?
Niterat = 5000;

%% analyze
for numi = 1:length(selectIdx)
    % run the classifier on all combinations of 1 neuron, all combinations of 2 neurons, all combinations of 3 neurons, etc...
    % due to the time it would take to do this, the data will be compared
    % against a theoretical 50% line drawn from the last iteration from the
    % same dataset (load in the classifier data, grab chance level from shuffled dist).
 
    % randomly do each selection process N-times
    for n = 1:Niterat
        disp(['Iteration ',num2str(n),' ',num2str(selectIdx(numi)), ' neurons added to the classifier'])
    
        % randomly selected numi number of values
        randSelect = randperm(length(data1Master),selectIdx(numi));

        % pull from data
        data1Select = data1Master(randSelect);
        data2Select = data2Master(randSelect);

        % grab random data
        for i = 1:length(data1Select)
            % pick random numbers of trials to draw
            trialSelect1   = randperm(size(data1Select{i},1),numObs);
            trialSelect2   = randperm(size(data2Select{i},1),numObs);

            % draw random trials from the bin of interest
            data1New{i} = data1Select{i}(trialSelect1,binDraw);
            data2New{i} = data2Select{i}(trialSelect2,binDraw);

            % concatenate data
            dataSelect{i} = vertcat(data1New{i},data2New{i});
        end

        % concatenate data across neurons
        dataSVM = horzcat(dataSelect{:});

        % remove any nans
        dataSVM(find(isnan(dataSVM)==1))=0;
        
        % generate labels
        labels = vertcat(ones(numObs,1),-ones(numObs,1)); 

        % run classifier
        total_accuracy = [];
        % svm classifier
        for i = 1:size(labels,1)
            svm_temp = dataSVM;
            labels_temp = labels;
            testing_data = dataSVM(i,:);
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
        svm_perf{numi}(n) = (length(find(total_accuracy == 1))...
        /length(total_accuracy))*100;
    end

end

% plot data
x_label = selectIdx;

svm_avg = cellfun(@mean,svm_perf);
svm_std = cellfun(@std,svm_perf);

% chance level - pulled from full blown classifier
data_comp = load(dataName);
chance_dist = data_comp.svm_perf_rand{binDraw};

% ztest
for neuri = 1:length(x_label)
    [~,p(neuri),~,stat{neuri}] = ztest(svm_avg(neuri),mean(chance_dist),std(chance_dist));
end 

figure('color','w'); hold on;
s1 = scatter(x_label,svm_avg);
s1.MarkerFaceColor = [0.75 0.75 0.75];
s1.MarkerEdgeColor = 'k';
line1 = lsline;
line1.Color = 'k';
xlimits = xlim;
line([xlimits(1) xlimits(2)],[50 50],'Color','r','LineStyle','--','LineWidth',2)
ylim([40 100])
ylabel('Classifier Accuracy')
xlabel('Number of Neurons added')
set(gca,'FontSize',12)

line_data = NaN([1 length(x_label)]);
Yminmax = get(gca,'Ylim');
line_data(find(p<0.05))=Yminmax(2);
for i = 1:length(x_label)
    y = line_data(i);
    line([x_label(i)-2,x_label(i)+2],[y,y],'Color','m','LineWidth',2)
end 

[r,pcorr] = corrcoef(x_label,svm_avg)

% data seems to fit a polynomial line of best fit
[population2,gof] = fit(x_label',svm_avg','poly2')

plot(population2,'c')

% what about log transforming
figure('color','w'); hold on;
s1 = scatter(10*log10(x_label),10*log10(svm_avg));
s1.MarkerFaceColor = [0.75 0.75 0.75];
s1.MarkerEdgeColor = 'k';
line1 = lsline;
line1.Color = 'k';
xlimits = xlim;
line([xlimits(1) xlimits(2)],[10*log10(50) 10*log10(50)],'Color','r','LineStyle','--','LineWidth',2)
ylim([10*log10(40) 10*log10(100)])
ylabel('Log Transformed Accuracy')
xlabel('Log Transformed # of Neurons')
set(gca,'FontSize',12)
line_data = NaN([1 length(x_label)]);
Yminmax = get(gca,'Ylim');
line_data(find(p<0.05))=Yminmax(2);
for i = 1:length(x_label)
    y = line_data(i);
    line([x_label(i)-2,x_label(i)+2],[y,y],'Color','m','LineWidth',2)
end 

[rLog,pcorrLog] = corrcoef(10*log10(x_label),10*log10(svm_avg))

%% log transformed modeling
logX = 10*log10(x_label);
logY = 10*log10(svm_avg);

figure('color','w'); hold on;
s2 = scatter(logX,logY);
s2.MarkerFaceColor = [0.9 0.9 0.9];
s2.MarkerEdgeColor = 'k';
s1 = scatter(logX(1:10),logY(1:10));
s1.MarkerFaceColor = [0.75 0.75 0.75];
s1.MarkerEdgeColor = 'r';
line1 = lsline;
% plot significance
line_data = NaN([1 length(x_label)]);
Yminmax = get(gca,'Ylim');
line_data(find(p<0.05))=Yminmax(2);
for i = 1:length(x_label)
    y = line_data(i);
    line([logX(i)-0.1,logX(i)+0.1],[y,y],'Color','m','LineWidth',2)
end 

% least squares regression
[popModel,gofModel] = fit(logX',logY','poly1')

% modeling significance
% ztest
for neuri = 1:length(x_label)
    [~,p(neuri),~,stat{neuri}] = ztest(svm_avg(neuri),mean(chance_dist),std(chance_dist));
end 

%{
%% how well does the polynomial model the classifier?

% give the model 75% of the data
numObs = length(x_label);
numGive = floor(numObs*.75);

% data seems to fit a polynomial line of best fit
[popModel,gofModel] = fit(x_label(1:numGive)',svm_avg(1:numGive)','poly2')

figure('color','w'); hold on;
s1 = scatter(x_label,svm_avg);
s1.MarkerFaceColor = [0.75 0.75 0.75];
s1.MarkerEdgeColor = 'k';
plot(popModel,'c')

%}

%{
for clusti = 1:length(data1Master)
    
    % number of trials
    numObs = size(data1{clusti},1);
    
    % create labels for classifier parameters
    labels = vertcat(ones(numObs,1),-ones(numObs,1));

    % define data variables
    
    
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
end

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
%}