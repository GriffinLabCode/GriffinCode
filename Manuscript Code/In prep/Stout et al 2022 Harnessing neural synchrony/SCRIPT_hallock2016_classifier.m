% When scaling neurons between 0 and 1, my model is performing near 100%
%
rng('shuffle')
clear; clc;
% load CD/DA data
place2store = getCurrentPath();
cd(place2store);
load('dataSVM_hallock2016_epochRatesStruct2')

% libsvm doesnt handle nan well
%{
for i = 1:length(svmData.rawHighDA)
    svmData.rawHighDA{i}(svmData.rawHighDA{i}==0)=[];
    svmData.rawLowDA{i}(svmData.rawLowDA{i}==0)=[];
    svmData.rawHighCD{i}(svmData.rawHighCD{i}==0)=[];
    svmData.rawLowCD{i}(svmData.rawLowCD{i}==0)=[];    
end
%}
% remove neurons that don't fire once
avgHD = cellfun(@nanmean,svmData.rawHighDA);
avgHC = cellfun(@nanmean,svmData.rawHighCD);
avgLD = cellfun(@nanmean,svmData.rawLowDA);
avgLC = cellfun(@nanmean,svmData.rawLowCD);
idxRem = find(avgHD==0 | avgHC==0 | avgLD ==0 | avgLC==0);
svmData.rawHighDA(idxRem)=[];
svmData.rawHighCD(idxRem)=[];
svmData.rawLowDA(idxRem)=[];
svmData.rawLowCD(idxRem)=[];
% standardized data
svmData.stanHighDA(idxRem)=[];
svmData.stanHighCD(idxRem)=[];
svmData.stanLowDA(idxRem)=[];
svmData.stanLowCD(idxRem)=[];

% smallest unit of neuron sample size
neurSize = min([min(cellfun(@numel,svmData.normHighDA)) min(cellfun(@numel,svmData.normHighCD)) ...
    min(cellfun(@numel,svmData.normLowDA)) min(cellfun(@numel,svmData.normLowCD))]);
neurSize = neurSize; % to improve randomization

% get 1000 random combinations of observations
for k = 1:1000

    % for each feature, get 10 random observations, 1000 times
    numFeats = length(svmData.rawHighDA);
    for i = 1:numFeats
        svmData.randCombHighDA{k}(:,i) = randsample(svmData.stanHighDA{i},neurSize);
        svmData.randCombHighCD{k}(:,i) = randsample(svmData.stanHighCD{i},neurSize);
        svmData.randCombLowDA{k}(:,i)  = randsample(svmData.stanLowDA{i},neurSize);
        svmData.randCombLowCD{k}(:,i)  = randsample(svmData.stanLowCD{i},neurSize);
    end
    disp(['Finished with random sampling ',num2str(k)])
end
% generate variable for labels
numobs = neurSize;
svmData.labels_highDA = -ones([numobs 1]);
svmData.labels_highCD = zeros([numobs 1]);
svmData.labels_lowDA  = ones([numobs 1]);
svmData.labels_lowCD  = 1+ones([numobs 1]);


%% first, lets do binary classification comparing high DA to high CD
performance = []; predict_label = [];  p = [];
performanceS = []; predict_labelS = [];  pS = [];
for k = 1:1000 % do 1000 classifications
    
    % assign svm data
    svmInputs = []; svmLabels = [];
    svmInputs = vertcat(svmData.randCombHighDA{k},svmData.randCombHighCD{k}); 
    %svmInputs = rand([20 125]);
    svmLabels = vertcat(svmData.labels_highDA,svmData.labels_highCD);   
    labelsShuff = datasample(svmLabels,numel(svmLabels));
    svmData.labels_shuffHigh(:,k) = labelsShuff;
    
    for nLab = 1:numel(svmLabels) % leave one out approach

        % clear important variables
        clear trainData testData trainLabel testLabel

        % ~~~~~~~~~~~~~ Training ~~~~~~~~~~~~~~ %

        % training data
        trainData          = svmInputs; 
        trainLabel         = svmLabels;
        trainData(nLab,:)  = [];
        trainLabel(nLab,:) = [];

        % train model
        clear model
        model = svmtrain(trainLabel, trainData, '-c 1 -t 0');

        % ~~~~~~~~~ Testing ~~~~~~~~~~~ %
        % testing data - need one observation per class
        testData = []; testLabel = [];
        testData  = svmInputs(nLab,:); % IMPORTANT - CHANGE TO DYNAMIC
        testLabel = svmLabels(nLab,:);

        % test classifier
        [predict_label(nLab,:), accuracy, dec(nLab,k)] = svmpredict(testLabel, testData, model);

        % store accuracy
        performance{k}(nLab,:) = accuracy(1);

        % do the same thing with shuffled labels
        
        % ~~~~~~~~~~~~~ Training ~~~~~~~~~~~~~~ %
        
        % training data
        trainData          = svmInputs; 
        trainLabel         = labelsShuff;
        trainData(nLab,:)  = [];
        trainLabel(nLab,:) = [];

        % train model
        clear model
        model = svmtrain(trainLabel, trainData, '-c 1 -t 0');

        % ~~~~~~~~~ Testing ~~~~~~~~~~~ %
        % testing data - need one observation per class
        testData = []; testLabel = [];
        testData  = svmInputs(nLab,:); % IMPORTANT - CHANGE TO DYNAMIC
        testLabel = labelsShuff(nLab,:);

        % test classifier
        [predict_labelS(nLab,:), accuracyS, decShuff(nLab,k)] = svmpredict(testLabel, testData, model);

        % store accuracy
        performanceS{k}(nLab,:) = accuracyS(1);
        
    end
    disp(['Finished with iteration ',num2str(k)])
end

% average across performances at predicting 
svmPerformance.High.daVScd_trueAll       = performance;
svmPerformance.High.daVScd_shuffAll      = performanceS;
svmPerformance.High.daVScd_trueAvg       = cellfun(@nanmean,performance);
svmPerformance.High.daVScd_shuffAvg      = cellfun(@nanmean,performanceS);
svmPerformance.High.daVScd_truePopAvg    = nanmean(cellfun(@nanmean,performance));
svmPerformance.High.daVScd_shuffPopAvg   = nanmean(cellfun(@nanmean,performanceS));
svmPerformance.High.daVScd_truePopStd    = nanstd(cellfun(@nanmean,performance));
svmPerformance.High.daVScd_shuffPopStd   = nanstd(cellfun(@nanmean,performanceS));
svmPerformance.High.decValue             = dec;
svmPerformance.High.decValueShuff        = decShuff;

%% next work with low da vs low cd
performance = []; predict_label = [];  p = [];
performanceS = []; predict_labelS = [];  pS = [];
for k = 1:1000 % do 1000 classifications
    
    % assign svm data
    svmInputs = []; svmLabels = [];
    svmInputs = vertcat(svmData.randCombLowDA{k},svmData.randCombLowCD{k}); 
    svmLabels = vertcat(svmData.labels_lowDA,svmData.labels_lowCD);   
    labelsShuff = datasample(svmLabels,numel(svmLabels));
    svmData.labels_shuffLow(:,k) = labelsShuff;
        
    for nLab = 1:numel(svmLabels) % leave one out approach

        % clear important variables
        clear trainData testData trainLabel testLabel

        % ~~~~~~~~~~~~~ Training ~~~~~~~~~~~~~~ %

        % training data
        trainData          = svmInputs; 
        trainLabel         = svmLabels;
        trainData(nLab,:)  = [];
        trainLabel(nLab,:) = [];

        % train model
        clear model
        model = svmtrain(trainLabel, trainData, '-c 1 -t 0');

        % ~~~~~~~~~ Testing ~~~~~~~~~~~ %
        % testing data - need one observation per class
        testData = []; testLabel = [];
        testData  = svmInputs(nLab,:); % IMPORTANT - CHANGE TO DYNAMIC
        testLabel = svmLabels(nLab,:);

        % test classifier
        [predict_label(nLab,:), accuracy, dec(nLab,k)] = svmpredict(testLabel, testData, model);

        % store accuracy
        performance{k}(nLab,:) = accuracy(1);

        % do the same thing with shuffled labels
        
        % ~~~~~~~~~~~~~ Training ~~~~~~~~~~~~~~ %
        
        % training data
        trainData          = svmInputs; 
        trainLabel         = labelsShuff;
        trainData(nLab,:)  = [];
        trainLabel(nLab,:) = [];

        % train model
        clear model
        model = svmtrain(trainLabel, trainData, '-c 1 -t 0');

        % ~~~~~~~~~ Testing ~~~~~~~~~~~ %
        % testing data - need one observation per class
        testData = []; testLabel = [];
        testData  = svmInputs(nLab,:); % IMPORTANT - CHANGE TO DYNAMIC
        testLabel = labelsShuff(nLab,:);

        % test classifier
        [predict_labelS(nLab,:), accuracyS, decShuff(nLab,k)] = svmpredict(testLabel, testData, model);

        % store accuracy
        performanceS{k}(nLab,:) = accuracyS(1);
        
    end
    disp(['Finished with iteration ',num2str(k)])
end

svmPerformance.Low.daVScd_trueAll    = performance;
svmPerformance.Low.daVScd_shuffAll   = performanceS;
svmPerformance.Low.daVScd_trueAvg    = cellfun(@nanmean,performance);
svmPerformance.Low.daVScd_shuffAvg   = cellfun(@nanmean,performanceS);
svmPerformance.Low.daVScd_truePopAvg = nanmean(cellfun(@nanmean,performance));
svmPerformance.Low.daVScd_shuffAvg   = nanmean(cellfun(@nanmean,performanceS));
svmPerformance.Low.daVScd_truePopStd = nanstd(cellfun(@nanmean,performance));
svmPerformance.Low.daVScd_shuffStd   = nanstd(cellfun(@nanmean,performanceS));
svmPerformance.Low.decValue          = dec;
svmPerformance.Low.decValueShuff     = decShuff;

%save('data_svmOutputs2016','svmPerformance');

% distributions
figure('color','w'); hold on;
bar(1,nanmean(svmPerformance.High.daVScd_trueAvg),'FaceColor','b');
errorbar(1,nanmean(svmPerformance.High.daVScd_trueAvg),nanstd(svmPerformance.High.daVScd_trueAvg),'color','k','LineWidth',2)
line([0.6 1.4],[svmPerformance.Low.daVScd_shuffAvg svmPerformance.Low.daVScd_shuffAvg],'Color','w','LineWidth',2,'LineStyle','--')
bar(2,nanmean(svmPerformance.Low.daVScd_trueAvg),'FaceColor','r');
errorbar(2,nanmean(svmPerformance.Low.daVScd_trueAvg),nanstd(svmPerformance.Low.daVScd_trueAvg),'color','k','LineWidth',2)
line([1.6 2.4],[svmPerformance.Low.daVScd_shuffAvg svmPerformance.Low.daVScd_shuffAvg],'Color','w','LineWidth',2,'LineStyle','--')

%[pHigh, obsHigh, effectsizeHigh] = permutationTest(svmPerformance.High.daVScd_trueAvg, svmPerformance.High.daVScd_shuffAvg, 1000);
%[pLow, obsLow, effectsizeLow] = permutationTest(svmPerformance.Low.daVScd_trueAvg, svmPerformance.Low.daVScd_shuffAvg, 1000);
%[h,p,ci,z]=ztest(mean(svmPerformance.High.daVScd_trueAvg),mean(svmPerformance.High.daVScd_shuffAvg),std(svmPerformance.High.daVScd_shuffAvg))

[h,p,ci,z]=ztest(mean(svmPerformance.High.daVScd_shuffAvg),mean(svmPerformance.High.daVScd_trueAvg),std(svmPerformance.High.daVScd_trueAvg))

% this is what sangiamo 2017 did.  - its identical to just using ztest
z = (mean(svmPerformance.High.daVScd_shuffAvg)-mean(svmPerformance.High.daVScd_trueAvg))/std(svmPerformance.High.daVScd_trueAvg)


%{
% area under the curve
for i = 1:size(svmPerformance.High.decValue,2)
    % high coherence auc
    decVal = svmPerformance.High.decValue(:,i);
    labels = vertcat(svmData.labels_highDA,svmData.labels_highCD);
    [xHigh(:,i),yHigh(:,i),tHigh(:,i),auc_high(i)] = perfcurve(labels,decVal,-1);
    % high shuffled auc
    decVal = svmPerformance.High.decValueShuff(:,i);
    labels = svmData.labels_shuffHigh(:,i);
    [xHighS(:,i),yHighS(:,i),tHighS(:,i),auc_highS(i)] = perfcurve(labels,decVal,-1);
    
    % low coherence auc
    decVal = svmPerformance.Low.decValue(:,i);
    labels = vertcat(svmData.labels_lowDA,svmData.labels_lowCD);
    [xLow(:,i),yLow(:,i),tLow(:,i),auc_low(i)] = perfcurve(labels,decVal,1);
    % low shuffled auc
    decVal = svmPerformance.Low.decValueShuff(:,i);
    labels = svmData.labels_shuffLow(:,i);
    [xLowS(:,i),yLowS(:,i),tLowS(:,i),auc_lowS(i)] = perfcurve(labels,decVal,1);

    disp([num2str((i/1000)*100),'% complete']);
end

figure('color','w'); 
subplot 211;
    hold on;
    plot(nanmean(xHigh,2),nanmean(yHigh,2),'LineWidth',2,'Color','b')
    plot(nanmean(xHighS,2),nanmean(yHighS,2),'LineWidth',2,'Color',[.6 .6 .6])
subplot 212;
    hold on;
    plot(nanmean(xLow,2),nanmean(yLow,2),'LineWidth',2,'Color','r')
    plot(nanmean(xLowS,2),nanmean(yLowS,2),'LineWidth',2,'Color',[.6 .6 .6])
%}
    
%% now compare high da to low da
performance = []; predict_label = [];  p = [];
performanceS = []; predict_labelS = [];  pS = [];
for k = 1:1000 % do 1000 classifications
    
    % assign svm data
    svmInputs = []; svmLabels = [];
    svmInputs = vertcat(svmData.randCombHighDA{k},svmData.randCombLowDA{k}); 
    svmLabels = vertcat(svmData.labels_highDA,svmData.labels_lowDA);   
    labelsShuff = datasample(svmLabels,numel(svmLabels));
    svmData.labels_shuffDA(:,k) = labelsShuff;
    
    for nLab = 1:numel(svmLabels) % leave one out approach

        % clear important variables
        clear trainData testData trainLabel testLabel

        % ~~~~~~~~~~~~~ Training ~~~~~~~~~~~~~~ %

        % training data
        trainData          = svmInputs; 
        trainLabel         = svmLabels;
        trainData(nLab,:)  = [];
        trainLabel(nLab,:) = [];

        % train model
        clear model
        model = svmtrain(trainLabel, trainData, '-c 1 -t 0');

        % ~~~~~~~~~ Testing ~~~~~~~~~~~ %
        % testing data - need one observation per class
        testData = []; testLabel = [];
        testData  = svmInputs(nLab,:); % IMPORTANT - CHANGE TO DYNAMIC
        testLabel = svmLabels(nLab,:);

        % test classifier
        [predict_label(nLab,:), accuracy, dec(nLab,k)] = svmpredict(testLabel, testData, model);

        % store accuracy
        performance{k}(nLab,:) = accuracy(1);

        % do the same thing with shuffled labels
        
        % ~~~~~~~~~~~~~ Training ~~~~~~~~~~~~~~ %
        
        % training data
        trainData          = svmInputs; 
        trainLabel         = labelsShuff;
        trainData(nLab,:)  = [];
        trainLabel(nLab,:) = [];

        % train model
        clear model
        model = svmtrain(trainLabel, trainData, '-c 1 -t 0');

        % ~~~~~~~~~ Testing ~~~~~~~~~~~ %
        % testing data - need one observation per class
        testData = []; testLabel = [];
        testData  = svmInputs(nLab,:); % IMPORTANT - CHANGE TO DYNAMIC
        testLabel = labelsShuff(nLab,:);

        % test classifier
        [predict_labelS(nLab,:), accuracyS, decShuff(nLab,k)] = svmpredict(testLabel, testData, model);

        % store accuracy
        performanceS{k}(nLab,:) = accuracyS(1);
        
    end
    disp(['Finished with iteration ',num2str(k)])
end

% average across performances at predicting 
svmPerformance.DA.trueAll       = performance;
svmPerformance.DA.shuffAll      = performanceS;
svmPerformance.DA.trueAvg       = cellfun(@nanmean,performance);
svmPerformance.DA.shuffAvg      = cellfun(@nanmean,performanceS);
svmPerformance.DA.truePopAvg    = nanmean(cellfun(@nanmean,performance));
svmPerformance.DA.shuffPopAvg   = nanmean(cellfun(@nanmean,performanceS));
svmPerformance.DA.truePopStd    = nanstd(cellfun(@nanmean,performance));
svmPerformance.DA.shuffPopStd   = nanstd(cellfun(@nanmean,performanceS));
svmPerformance.DA.decValue             = dec;
svmPerformance.DA.decValueShuff        = decShuff;

figure('color','w'); hold on;
bar(1,nanmean(svmPerformance.DA.trueAvg),'FaceColor',[.6 .6 .6]);
errorbar(1,nanmean(svmPerformance.DA.trueAvg),nanstd(svmPerformance.DA.trueAvg),'color','k','LineWidth',2)
line([0.6 1.4],[nanmean(svmPerformance.DA.shuffAvg) nanmean(svmPerformance.DA.shuffAvg)],'Color','w','LineWidth',2,'LineStyle','--')
%[pDA, obsDA, effectsizeDA] = permutationTest(svmPerformance.DA.trueAvg, svmPerformance.DA.shuffAvg, 1000);
%{
% area under the curve
for i = 1:size(svmPerformance.DA.decValue,2)
    % high coherence auc
    decVal = svmPerformance.DA.decValue(:,i);
    labels = vertcat(svmData.labels_highDA,svmData.labels_lowDA);
    [xDA(:,i),yDA(:,i),tDA(:,i),auc_da(i)] = perfcurve(labels,decVal,1);
    % high shuffled auc
    decVal = svmPerformance.DA.decValueShuff(:,i);
    labels = svmData.labels_shuffDA(:,k);
    [xDAS(:,i),yDAS(:,i),tDAS(:,i),auc_daS(i)] = perfcurve(labels,decVal,1);
end
%}

%% add neurons 1 by 1 and see when classifier accuracies emerge
%{
numNeurons = length(svmData.randCombHighDA{1});
for k = 1:1000 % do 1000 classifications
    for celli = 1:length(svmData.randCombHighDA{1})
        
        % get random number of units
        unit2grab = randsample(numNeurons,celli,false);

        % assign svm data
        svmInputs = []; svmLabels = [];
        svmInputs = vertcat(svmData.randCombHighDA{k}(:,unit2grab),svmData.randCombLowDA{k}(:,unit2grab)); 
        svmLabels = vertcat(svmData.labels_highDA,svmData.labels_lowDA);   
        labelsShuff = datasample(svmLabels,numel(svmLabels));
        svmData.labels_shuffDA(:,k) = labelsShuff;

        clear predict_label accuracy dec
        clear predict_labelS accuracyS decShuff
        for nLab = 1:numel(svmLabels) % leave one out approach

            % clear important variables
            clear trainData testData trainLabel testLabel

            % ~~~~~~~~~~~~~ Training ~~~~~~~~~~~~~~ %

            % training data
            trainData          = svmInputs; 
            trainLabel         = svmLabels;
            trainData(nLab,:)  = [];
            trainLabel(nLab,:) = [];

            % train model
            clear model
            model = svmtrain(trainLabel, trainData, '-c 1 -t 0');

            % ~~~~~~~~~ Testing ~~~~~~~~~~~ %
            % testing data - need one observation per class
            testData = []; testLabel = [];
            testData  = svmInputs(nLab,:); % IMPORTANT - CHANGE TO DYNAMIC
            testLabel = svmLabels(nLab,:);

            % test classifier
            [predict_label(nLab,:), accuracy, dec(nLab,k)] = svmpredict(testLabel, testData, model);

            % store accuracy
            performance{celli,k}(nLab,:) = accuracy(1);

            % do the same thing with shuffled labels

            % ~~~~~~~~~~~~~ Training ~~~~~~~~~~~~~~ %

            % training data
            trainData          = svmInputs; 
            trainLabel         = labelsShuff;
            trainData(nLab,:)  = [];
            trainLabel(nLab,:) = [];

            % train model
            clear model
            model = svmtrain(trainLabel, trainData, '-c 1 -t 0');

            % ~~~~~~~~~ Testing ~~~~~~~~~~~ %
            % testing data - need one observation per class
            testData = []; testLabel = [];
            testData  = svmInputs(nLab,:); % IMPORTANT - CHANGE TO DYNAMIC
            testLabel = labelsShuff(nLab,:);

            % test classifier
            [predict_labelS(nLab,:), accuracyS, decShuff(nLab,k)] = svmpredict(testLabel, testData, model);

            % store accuracy
            performanceS{celli,k}(nLab,:) = accuracyS(1);

        end
    end
    disp(['Finished with iteration ',num2str(k)])
end
svmPerformance.DAunit       = performance;
svmPerformance.DAunitShuff  = performanceS;
svmPerformance.DAunitDEC    = dec;
svmPerformance.DAunitDECs   = decShuff;
svmPerformance.DAunitAvg    = cellfun(@nanmean,performance);
svmPerformance.DAunitAvgS   = cellfun(@nanmean,performanceS);
svmPerformance.DAunitAvg2   = nanmean(svmPerformance.DAunitAvg,2);
svmPerformance.DAunitStd2   = std(svmPerformance.DAunitAvg')';
svmPerformance.DAunitAvgS2  = nanmean(svmPerformance.DAunitAvgS,2);
svmPerformance.DAunitStdS2  = std(svmPerformance.DAunitAvgS')';

figure('color','w')
neurAdd = 1:length(svmData.randCombHighDA{1}); hold on;
shadedErrorBar(neurAdd,svmPerformance.DAunitAvg2,svmPerformance.DAunitStd2,'k',0)
shadedErrorBar(neurAdd,svmPerformance.DAunitAvgS2,svmPerformance.DAunitStdS2,'r',0)
ylabel('Classifier Accuracy')
xlabel('Number of neurons')
save('data_svm2016','svmPerformance','svmData')
%}