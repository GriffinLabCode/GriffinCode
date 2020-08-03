%% example 1
%# Fisher Iris dataset
load fisheriris
[~,~,labels] = unique(species);   %# labels: 1/2/3
data = zscore(meas);              %# scale features
numInst = size(data,1); % total amount of observations
numLabels = max(labels); % otal number of labels

%# split training/testing
idx = randperm(numInst); % make a random index to train/test
numTrain = 100; 
numTest = numInst - numTrain; % decide on a number to test on

% get training data and testing data
trainData = data(idx(1:numTrain),:);  testData = data(idx(numTrain+1:end),:);
trainLabel = labels(idx(1:numTrain)); testLabel = labels(idx(numTrain+1:end));

%# train one-against-all models
model = cell(numLabels,1);
for k=1:numLabels % so we'll build model on each of the three datasets
    model{k} = svmtrain(double(trainLabel==k), trainData, '-c 1 -g 0.2 -b 1');
end

%# get probability estimates of test instances using each model
prob = zeros(numTest,numLabels);
for k=1:numLabels
    [~,accuracy{k},p] = svmpredict(double(testLabel==k), testData, model{k}, '-b 1');
    prob(:,k) = p(:,model{k}.Label==1);    %# probability of class==k
end

%# predict the class with the highest probability
[~,pred] = max(prob,[],2);
acc = sum(pred == testLabel) ./ numel(testLabel)    %# accuracy
C = confusionmat(testLabel, pred) 
figure('color','w')
imagesc(C)

%% our data
% multiclass
mat1 = lefts{7};
mat2 = rights{7};
mat3 = vertcat(mat1,mat2);

% num of observations
numObs = size(mat3,1);

% numFeatures - note in this case we're pretending that the num features is
% on columns
numFeats = size(mat3,2);

% labels
labels3 = repmat({'SL'},[numObs/4,1]);
labels4 = repmat({'SR'},[numObs/4,1]);
labels1 = repmat({'CL'},[numObs/4,1]);
labels2 = repmat({'CR'},[numObs/4,1]);

% labels - alphabetized
[~,~,Labels] = unique(horzcat(labels1,labels2,labels3,labels4));

% training labels
for i = 1:numel(Labels)
    clear trainData testData trainLabel testLabel
    
    % training data
    trainData       = mat3;
    trainLabel      = Labels;
    trainData(i,:)  = [];
    trainLabel(i,:) = [];

    % train model
    model{i} = svmtrain(trainLabel, trainData, '-c 1 -t 0');
        
    % testing data
    testData  = mat3(i,:);
    testLabel = Labels(i,:);
    
    % test classifier
    [predict_label{i}, accuracy{i}, p] = svmpredict(testLabel, testData, model{i}, '-b 1');
end

%# predict the class with the highest probability
[~,pred] = max(prob,[],2);
acc = sum(pred == testLabel) ./ numel(testLabel)    %# accuracy
C = confusionmat(testLabel, pred) 




%% older

% train classifier
cd('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\libsvm-3.20\matlab')           
model = svmtrain(labels_training, data_training, '-c 1 -t 0');
[predict_label, accuracy, prob] = svmpredict(labels_testing, data_testing, model);
% store accuracy - row is shuffled trials, column
