%% svm

%   This script uses a linear classifier to decode which task the rat is
%   performing during stem traversals of dual-task sessions

%   Outputs:
%       mean_accuracy_stem(number) = Trial-averaged decoding accuracy of
%                                    classifier at (number) stem bin
%       AUC_STEM(number) =           Area underneath the ROC curve for
%                                    classifier performance at (number) stem bin

%%

clear all, clc, close all

netDrive = 'X:\';
expFolder = '01.Experiments\mPFC-Hippocampus_DualTask\';
session = '1202\1202-9\';

datafolder = strcat(netDrive,expFolder,session);
load(strcat(datafolder, 'Intervals.mat'));
load(strcat(datafolder, 'VT1.mat'));

cd(datafolder)
clusters = dir('TT*.txt');

clear rat session expFolder

xmin = 230; %   Manually define stem entry and stem exit coordinates
xmax = 530;
ymax = 280;
ymin = 220;

numbins = 7;    %   Right now, this code is hard set to six stem bins (7-1 = 6). The number of stem bins could be made flexible - however, this would take some tinkering

bins = linspace(xmin,xmax,numbins);
bins = round(bins);

% Populate matrix of bin-averaged firing rates for each cluster
% Rows = trials, columns = stem bin
for ci=1:length(clusters)
    cd(datafolder);
    spikeTimes = textread(clusters(ci).name);
    cluster = clusters(ci).name(1:end-4);
   for i = 2:size(Int1,1)
ts_ind = find(TimeStamps>Int1(i,1) & TimeStamps<Int1(i,5));
ts_temp = TimeStamps(ts_ind);
x_temp = ExtractedX(ts_ind);
x_temp = x_temp';
bins = bins';
k = dsearchn(x_temp,bins);
bins = bins';
x_temp = x_temp';
spk_ts = ts_temp(k);
for j = 1:length(bins)-1
numspikes_ind = find(spikeTimes>spk_ts(j) & spikeTimes<spk_ts(j+1));
numspikes = length(numspikes_ind);
time_temp = spk_ts(j+1) - spk_ts(j);
time_temp = time_temp/1e6;
fr_temp(j) = numspikes/time_temp;
end
fr_new(i-1,1:size(fr_temp,2)) = fr_temp;
   end 

% Give each stem bin its own population matrix, with rows corresponding to
% trials and columns corresponding to clusters
svm_da_1(:,ci) = fr_new(:,1);
svm_da_2(:,ci) = fr_new(:,2);
svm_da_3(:,ci) = fr_new(:,3);
svm_da_4(:,ci) = fr_new(:,4);
svm_da_5(:,ci) = fr_new(:,5);
svm_da_6(:,ci) = fr_new(:,6);

% Do the same thing as above, but for CD (this script assumes that Int1 =
% DA, and Int2 = CD)
for i = 1:size(Int2,1)
ts_ind = find(TimeStamps>Int2(i,1) & TimeStamps<Int2(i,5));
ts_temp = TimeStamps(ts_ind);
x_temp = ExtractedX(ts_ind);
x_temp = x_temp';
bins = bins';
k = dsearchn(x_temp,bins);
bins = bins';
x_temp = x_temp';
spk_ts = ts_temp(k);
for j = 1:length(bins)-1
numspikes_ind = find(spikeTimes>spk_ts(j) & spikeTimes<spk_ts(j+1));
numspikes = length(numspikes_ind);
time_temp = spk_ts(j+1) - spk_ts(j);
time_temp = time_temp/1e6;
fr_temp(j) = numspikes/time_temp;
end
fr_new(i,1:size(fr_temp,2)) = fr_temp;
   end

   
svm_cd_1(:,ci) = fr_new(:,1);
svm_cd_2(:,ci) = fr_new(:,2);
svm_cd_3(:,ci) = fr_new(:,3);
svm_cd_4(:,ci) = fr_new(:,4);
svm_cd_5(:,ci) = fr_new(:,5);
svm_cd_6(:,ci) = fr_new(:,6);

end

%%


% Combine the bin-averaged population matrices from DA and CD performance
% into one matrix
svm1 = svm_da_1;
svm1(size(svm_da_1,1)+1:size(svm_da_1,1)+size(svm_cd_1),:) = svm_cd_1;
svm2 = svm_da_2;
svm2(size(svm_da_2,1)+1:size(svm_da_2,1)+size(svm_cd_2),:) = svm_cd_2;
svm3 = svm_da_3;
svm3(size(svm_da_3,1)+1:size(svm_da_3,1)+size(svm_cd_3),:) = svm_cd_3;
svm4 = svm_da_4;
svm4(size(svm_da_4,1)+1:size(svm_da_4,1)+size(svm_cd_4),:) = svm_cd_4;
svm5 = svm_da_5;
svm5(size(svm_da_5,1)+1:size(svm_da_5,1)+size(svm_cd_5),:) = svm_cd_5;
svm6 = svm_da_6;
svm6(size(svm_da_6,1)+1:size(svm_da_6,1)+size(svm_cd_6),:) = svm_cd_6;


svm_da(:,1) = mean(svm_da_1,1)';
svm_da(:,2) = mean(svm_da_2,1)';
svm_da(:,3) = mean(svm_da_3,1)';
svm_da(:,4) = mean(svm_da_4,1)';
svm_da(:,5) = mean(svm_da_5,1)';
svm_da(:,6) = mean(svm_da_6,1)';

svm_cd(:,1) = mean(svm_cd_1,1)';
svm_cd(:,2) = mean(svm_cd_2,1)';
svm_cd(:,3) = mean(svm_cd_3,1)';
svm_cd(:,4) = mean(svm_cd_4,1)';
svm_cd(:,5) = mean(svm_cd_5,1)';
svm_cd(:,6) = mean(svm_cd_6,1)';

% Create labels for classifier training (1 = DA, -1 = CD)
labels(1:size(svm_da_1)) = 1;
labels(size(svm_da_1)+1:size(svm_da_1)+size(svm_cd_1)) = -1;
labels = labels';
ntrials = size(labels,1);

cd(strcat(netDrive, '03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\libsvm-3.20\matlab'));

% Run a linear classifier for each stem-binned population matrix
% Remove one trial for testing, and use all other trials for training
% Keep decision values for ROC analysis
for i = 1:ntrials
    svm_temp = svm1;
    labels_temp = labels;
    testing_data = svm1(i,:);
    testing_label = labels(i,:);
    svm_temp(i,:) = [];
    labels_temp(i,:) = [];
    model = svmtrain(labels_temp, svm_temp, '-c 1 -t 0');
    [predict_label, accuracy, dec_values] = svmpredict(testing_label, testing_data, model);
    if accuracy(1,:) == 100
        total_accuracy(i,:) = 1;
    else
        total_accuracy(i,:) = 0;
    end
    dec_value_stem1(i,:) = dec_values;
end

correct_idx = find(total_accuracy == 1);
mean_accuracy_stem1 = length(correct_idx)/length(labels);

for i = 1:ntrials
    svm_temp = svm2;
    labels_temp = labels;
    testing_data = svm2(i,:);
    testing_label = labels(i,:);
    svm_temp(i,:) = [];
    labels_temp(i,:) = [];
    model = svmtrain(labels_temp, svm_temp, '-c 1 -t 0');
    [predict_label, accuracy, dec_values] = svmpredict(testing_label, testing_data, model);
    if accuracy(1,:) == 100
        total_accuracy(i,:) = 1;
    else
        total_accuracy(i,:) = 0;
    end
    dec_value_stem2(i,:) = dec_values;
end

correct_idx = find(total_accuracy == 1);
mean_accuracy_stem2 = length(correct_idx)/length(labels);

for i = 1:ntrials
    svm_temp = svm3;
    labels_temp = labels;
    testing_data = svm3(i,:);
    testing_label = labels(i,:);
    svm_temp(i,:) = [];
    labels_temp(i,:) = [];
    model = svmtrain(labels_temp, svm_temp, '-c 1 -t 0');
    [predict_label, accuracy, dec_values] = svmpredict(testing_label, testing_data, model);
    if accuracy(1,:) == 100
        total_accuracy(i,:) = 1;
    else
        total_accuracy(i,:) = 0;
    end
    dec_value_stem3(i,:) = dec_values;
end

correct_idx = find(total_accuracy == 1);
mean_accuracy_stem3 = length(correct_idx)/length(labels);

for i = 1:ntrials
    svm_temp = svm4;
    labels_temp = labels;
    testing_data = svm4(i,:);
    testing_label = labels(i,:);
    svm_temp(i,:) = [];
    labels_temp(i,:) = [];
    model = svmtrain(labels_temp, svm_temp, '-c 1 -t 0');
    [predict_label, accuracy, dec_values] = svmpredict(testing_label, testing_data, model);
    if accuracy(1,:) == 100
        total_accuracy(i,:) = 1;
    else
        total_accuracy(i,:) = 0;
    end
    dec_value_stem4(i,:) = dec_values;
end

correct_idx = find(total_accuracy == 1);
mean_accuracy_stem4 = length(correct_idx)/length(labels);

for i = 1:ntrials
    svm_temp = svm5;
    labels_temp = labels;
    testing_data = svm5(i,:);
    testing_label = labels(i,:);
    svm_temp(i,:) = [];
    labels_temp(i,:) = [];
    model = svmtrain(labels_temp, svm_temp, '-c 1 -t 0');
    [predict_label, accuracy, dec_values] = svmpredict(testing_label, testing_data, model);
    if accuracy(1,:) == 100
        total_accuracy(i,:) = 1;
    else
        total_accuracy(i,:) = 0;
    end
    dec_value_stem5(i,:) = dec_values;
end

correct_idx = find(total_accuracy == 1);
mean_accuracy_stem5 = length(correct_idx)/length(labels);

for i = 1:ntrials
    svm_temp = svm6;
    labels_temp = labels;
    testing_data = svm6(i,:);
    testing_label = labels(i,:);
    svm_temp(i,:) = [];
    labels_temp(i,:) = [];
    model = svmtrain(labels_temp, svm_temp, '-c 1 -t 0');
    [predict_label, accuracy, dec_values] = svmpredict(testing_label, testing_data, model);
    if accuracy(1,:) == 100
        total_accuracy(i,:) = 1;
    else
        total_accuracy(i,:) = 0;
    end
    dec_value_stem6(i,:) = dec_values;
end

correct_idx = find(total_accuracy == 1);
mean_accuracy_stem6 = length(correct_idx)/length(labels);

DA_Correct = find(Int1(:,4) == 0);
DA_Performance = length(DA_Correct)/size(Int1,1);
CD_Correct = find(Int2(:,4) == 0);
CD_Performance = length(CD_Correct)/size(Int2,1);

% Verify classifier accuracy with ROC analysis for each stem-binned
% population matrix
[X,Y,T,AUC_STEM1] = perfcurve(labels,dec_value_stem1,1);
[X,Y,T,AUC_STEM2] = perfcurve(labels,dec_value_stem2,1);
[X,Y,T,AUC_STEM3] = perfcurve(labels,dec_value_stem3,1);
[X,Y,T,AUC_STEM4] = perfcurve(labels,dec_value_stem4,1);
[X,Y,T,AUC_STEM5] = perfcurve(labels,dec_value_stem5,1);
[X,Y,T,AUC_STEM6] = perfcurve(labels,dec_value_stem6,1);

clear X Y T Int1 accuracy bins CD_Correct ci cluster clusters correct_idx DA_Correct datafolder ExtractedAngle ExtractedX ExtractedY fr_new fr_temp i Int2 Int2 Int2 j k labels_temp netDrive ntrials numspikes numspikes_ind predict_label sessiontype spikeTimes spk_temp spk_ts svm1 svm2 svm3 svm4 svm5 svm6 svm7 svm_cd_1 svm_cd_2 svm_cd_3 svm_cd_4 svm_cd_5 svm_cd_6 svm_cd_7 svm_da_1 svm_da_2 svm_da_3 svm_da_4 svm_da_5 svm_da_6 svm_da_7 svm_temp testing_data testing_label time_temp TimeStamps ts_ind ts_temp x_temp xmax xmin ymax ymin total_accuracy svm_da svm_cd numbins model labels Int3 dec_values dec_value_stem6 dec_value_stem5 dec_value_stem4 dec_value_stem3 dec_value_stem2 dec_value_stem1