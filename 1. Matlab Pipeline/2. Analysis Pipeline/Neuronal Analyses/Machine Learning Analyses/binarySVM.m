%% binary SVM
% this function uses binary support vector machine classification to
% classify two classes using the leave-1-out method
%
% -- INPUTS -- %
% data: a matrix of data to classify
% labels: 1s and -1s (although anything should work), that tells the
%           classifier which rows are 1s and which rows are -1s (separation
%           of classes). labels must be a vector

function [total_accuracy,dec_value,predict_label] = binarySVM(data,labels)

% replace nan with 0, destroys classification accuracy otherwise
data(isnan(data)) = 0;

% check sizes
checkSize = size(labels);
if isempty(find(checkSize == 1))
    error('Fix labels. Must be a vector.')
end

for i = 1:length(labels)
    
    % temp vars
    svm_temp = [];
    svm_temp    = data;
    labels_temp = labels;
    
    % get testing data
    testing_data  = data(i,:);
    testing_label = labels(i,:);
    
    % get training data
    svm_temp(i,:)    = [];
    labels_temp(i,:) = [];
    
    % train model
    model = svmtrain(labels_temp, svm_temp, '-c 1 -t 0');
    
    % test model
    [predict_label(i), accuracy, dec_value] = svmpredict(testing_label, testing_data, model);
    
    if accuracy(1,:) == 100
        total_accuracy(i,:) = 1;
    else
        total_accuracy(i,:) = 0;
    end
    dec_values(i,:) = dec_value;
end

end