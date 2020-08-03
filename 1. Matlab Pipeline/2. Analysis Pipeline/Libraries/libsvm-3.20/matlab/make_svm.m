function [total_accuracy, mean_accuracy] = make_svm(svm, labels)



ntrials = size(labels,1);

for i = 1:ntrials
    svm_temp = svm;
    labels_temp = labels;
    testing_data = svm(i,:);
    testing_label = labels(i,:);
    svm_temp(i,:) = [];
    labels_temp(i,:) = [];
    model = svmtrain(labels_temp, svm_temp, '-c 1 -g 0.01');
    [predict_label, accuracy, dec_values] = svmpredict(testing_label, testing_data, model);
    if accuracy(1,:) == 100
        total_accuracy(i,:) = 1;
    else
        total_accuracy(i,:) = 0;
    end
end

correct_idx = find(total_accuracy == 1);
mean_accuracy = length(correct_idx)/length(labels);


end

