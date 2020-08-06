%% Multi-class classification
% this code uses the svmLIB toolbox to run a multi-class linear SVM
% classifier on your dataset. It does so using a leave 1 out approach.
%
%
% INPUTS
% data: should be in the following format cell array format:
%           data{1} = bin (so if you were using 7 stem bins, you would have
%           a length(data) = 7. data{n} (where n is a bin) will be of size
%           (row = classes of interest, column = cluster). If you were to
%           select data{1}{1,1} you will have a vector whereby firing rates
%           are in each element, and the firing rates are all in the first
%           column. In other words data{1}{1,1}(:,1) will be your vector of
%           firing rates whereby rows indicate trial number and elements
%           are firing rates. if you were to do data{1}{1,1}(1,:) you
%           should get an error because the data should not be formatted
%           this way.
%
% numClass: a scalar indicating the number of classes. So size(data{1},1)
%           tells you the number of classes if you've correctly formatted
%
% classNames: a cell array with the names of each class
%
% numIter: number of iterations whereby you are drawing random neurons and
%     mixing up the trial ordering. This controls for any spurious effects,
%     however removes any temporal component of the data.
%
% numFeats: number of features (neurons). This will be apparent in your
%           data variable as data{1} columns are the different clusters
%
% numObs: number of observations (trials). Note this should be the smallest
%          number of trials observed. So if one of your neurons only had 12
%          trials, but the rest had 18, and you want to include all data,
%          set numObs = 12
%
% numbins: the number of bins you're analyzing. This is good for analyzing
%           data from multiple stem bins or something. This the primary
%           organization factor for your data cell array, so data{1} is
%           data from say stem bin 1, with the rows of data{1} being the
%           multiple classes of interest (say various things like sample
%           left choice left or something).
%
% ~~~ OUTPUTS ~~~
% probMat: probability matrix
%
% NOTE - This does not work yet, it is in progress to becoming a function
% ALSO NOTE: THIS IS ONLY FOR TJUNCTION RIGHT NOW - NEED TO FIX

%% define these
% the script format implies you have the data variable in your workspace
clear; clc
load('data_mazeLocations_multiclass_Format')

numIter        = 1000;
numFeats       = 187;
numObs         = 14;
numbins        = 1;
numClasses     = 12;
normalize_data = 1;

%% Initialization
disp('Checking that inputs are organized appropriately...')
pause(1);

% do some brief checks
checkForm1 = length(data)    == numbins;
checkForm2 = size(data{1},1) == numClasses;
checkForm3 = size(data{1},2) == numFeats;

if checkForm1 ~= 1 || checkForm2 ~= 1 || checkForm3 ~= 1
    disp('Error in data formatting, please open this function and read instructions')
    return
else
    disp('Data organized correctly')
    pause(1);
end

% make an array containing all data (organized by class on rows and
% features on columns)
dataCell = data;

% make labels vector
clear labels
for feati = 1:numClasses
    labels(:,feati) = ones(numObs,1)+(feati-1);
end
labels = labels(:);

% extract data, controlling for sample size
for bini = 1:numbins
    for nIt = 1:numIter 
        clear dataNew dataForm dataPerm

        disp(['shuffle trials ', num2str(nIt)])

        % this randomizes the ordering of trials for each
        % cluster. This, therefore, breaks any temporal
        % component to the population coding
        for classi = 1:numClasses   % loop across classes (rows)
            for clusti = 1:numFeats % loop across features (col)

                % random permutate and draw n observations (trials)
                clear randPull1
                randPull1 = randsample(randperm(size(dataCell{bini}{classi,clusti},1)),numObs);

                % extract data
                dataNew{classi,clusti} = dataCell{bini}{classi,clusti}(randPull1,:);

            end
        end
        % reformat - don't have to loop separately. This new
        % format will be an array where each cell element is an
        % observation, and within the first shell is the number
        % of neurons concatenated horizontally
        for m = 1:numbins       % loop across number of bins
            for classi = 1:numClasses
                for mm = 1:numFeats % loop across number of feats
                    dataForm{classi,m}(:,mm) = dataNew{classi,mm}(:,m);
                end
            end
        end

        % concatenate the data vertically so that one class is
        % on top, one class is on bottom                    
        dataPerm = [];
        % generalized formatting for classifier
        for binii = 1:numbins % loop across bins
             clear temp
             % isolate one bin
             temp = dataForm(:,binii);

             % concatenate vertically
             dataPerm{binii} = vertcat(temp{:});
        end

        % replace any NaNs with 0 - note that NaNs will drive
        % the accuracy of your model to 50%
        for binii = 1:numbins
            dataPerm{binii}(find(isnan(dataPerm{binii})==1)) = 0;
        end
        
        % normalize
        if normalize_data == 1
            for binii = 1:numbins
                dataPerm{binii} = normalize(dataPerm{binii},'range');
            end   
        end


        % need to make this a loop across bins
        clear performance predict_label accuracy p

        for nLab = 1:numel(labels) % this needs to change, it needs to be a permutative test, so prob 1000

            % clear important variables
            clear trainData testData trainLabel testLabel

            % ~~~~~~~~~~~~~ Training ~~~~~~~~~~~~~~ %
            % training data
            trainData          = dataPerm{bini}; 
            trainLabel         = labels;
            trainData(nLab,:)  = [];
            trainLabel(nLab,:) = [];

            % train model
            clear model
            model = svmtrain(trainLabel, trainData, '-c 1 -t 0 -b 1');

            % ~~~~~~~~~ Testing ~~~~~~~~~~~ %
            % testing data - need one observation per class
            testData  = dataPerm{bini}(nLab,:); % IMPORTANT - CHANGE TO DYNAMIC
            testLabel = labels(nLab,:);

            % test classifier
            [predict_label(nLab,:), accuracy, p{nLab}] = svmpredict(testLabel, testData, model,'-b 1');

            % store accuracy
            performance(nLab,:) = accuracy(1);

        end

        % averaged accuracy
        meanPerf{nIt} = mean(performance);

        % probability of predicting classes
        classMat = [1:numClasses]'; % variable indicating different classes

        % make a matrix that contains probabilities of hits and misses, where
        % mat(1,1) = 1 predicted as 1, mat(1,2) = 1 predicted as 2, mat(2,1) =
        % 2 predicted as 1, mat(2,2) = 2 predicted as 2
        for i = 1:numClasses
            clear idxClass trueClass predClass idxHit numTest idx
            % define true and predicted classes
            idxClass  = find(labels == classMat(i)); % an index of the first group of classes
            trueClass = labels(idxClass);            % true classes        
            predClass = predict_label(idxClass);     % predicted classes

            % total number of labels per class
            numTest = length(trueClass); % total number of cases where 1 should have been

            % fill in matrix
            for ii = 1:numClasses
                % predClass is defined once above and limited to one class
                idx = find(predClass == classMat(ii));
                probMat{bini}{nIt}(i,ii) = length(idx)/numTest;
            end
        end
    end   
    % get probability matrix
    prob3d{bini}  = cat(3,probMat{bini}{:});
    probAvg{bini} = mean(prob3d{bini},3);
    probStd{bini} = std(prob3d{bini},[],3);
end

figure('color','w')
imagesc(probAvg{bini})
colorbar

% loop iteratively
for nShuff = 1:numIter
    disp(['shuffle # ',num2str(nShuff)]);

    % shuffle labels
    shuffIdx = randperm(length(labels));
    labelShuff = labels(shuffIdx);
    
    for nLab = 1:numel(labelShuff) % this needs to change, it needs to be a permutative test, so prob 1000
        
        % clear important variables
        clear trainData testData trainLabel testLabel

        % ~~~~~~~~~~~~~~~~~~~~~~~~~ CHANGE
        % training data
        trainData          = dataPerm{7}; % CHANGE ME TO DYNAMIC
        trainLabel         = labelShuff;
        trainData(nLab,:)  = [];
        trainLabel(nLab,:) = [];
        
        % train model
        clear model
        model = svmtrain(trainLabel, trainData, '-c 1 -t 0 -b 1');

        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CHANGE
        % testing data - need one observation per class
        testData  = dataPerm{7}(nLab,:); % IMPORTANT - CHANGE TO DYNAMIC
        testLabel = labels(nLab,:);

        % test classifier
        clear accuracy
        [predict_label(nLab,:), accuracy, p{nLab}] = svmpredict(testLabel, testData, model,'-b 1');
   
        % store accuracy
        performanceShuff(nLab,:) = accuracy(1);
        
    end
    
    % averaged accuracy
    meanShuff{nShuff} = mean(performanceShuff);
    
    % probability of predicting classes
    classMat = [1:numClasses]'; % variable indicating different classes

    % make a matrix that contains probabilities of hits and misses, where
    % mat(1,1) = 1 predicted as 1, mat(1,2) = 1 predicted as 2, mat(2,1) =
    % 2 predicted as 1, mat(2,2) = 2 predicted as 2
    for i = 1:numClasses
        clear idxClass trueClass predClass idxHit numTest idx
        % define true and predicted classes
        idxClass  = find(labelShuff == classMat(i)); % an index of the first group of classes
        trueClass = labelShuff(idxClass);            % true classes        
        predClass = predict_label(idxClass);     % predicted classes

        % total number of labels per class
        numTest = length(trueClass); % total number of cases where 1 should have been
        
        % fill in matrix
        for ii = 1:numClasses
            % predClass is defined once above and limited to one class
            idx = find(predClass == classMat(ii));
            probShuff{nShuff}(i,ii) = length(idx)/numTest;
        end
    end    
end
 
prob3dShuff  = cat(3,probShuff{:});
probAvgShuff = mean(prob3dShuff,3);
probStdShuff = std(prob3dShuff,[],3);

% statistics
for i = 1:numClasses
    for ii = 1:numClasses
        [hZ(i,ii),pZ(i,ii),ci,statZ{i,ii}] = ztest(probAvg(i,ii),probAvgShuff(i,ii),probStdShuff(i,ii));
    end
end

% figure
figure('color','w')
subplot 211
    imagesc(probAvg)
    c = colorbar;
    shading 'interp'
    title('Multi-class performance')
    ylabel(c,'Prob. of prediction')
    ax = gca;
    ax.XTick = 1:numClasses;
    ax.YTick = 1:numClasses;    
    ax.XTickLabel = classNames;
    ax.YTickLabel = classNames;
subplot 212
    imagesc(probAvgShuff)
    c = colorbar;
    shading 'interp'
    title('Multi-class shuffle')
    ylabel(c,'Prob. of prediction')
    ax = gca;
    ax.XTick = 1:numClasses;
    ax.YTick = 1:numClasses;    
    ax.XTickLabel = classNames;
    ax.YTickLabel = classNames; 
cd('X:\07. Manuscripts\In preparation\Stout - JNeuro\Data\mPFC 2-2020')
save('data_multiClass_taskPhaseLocations')
