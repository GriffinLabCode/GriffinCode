%% compare svm not-zscored
clear; clc

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Linear Classifier')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');

% not sure why its called startbox_mean1 - its all the maze
input = get_classifier_inputs;
[svm_perf,svm_sem,svm_categories,trial_accuracy,svm_iterat,...
    svm_data,svm_perf_it,svm_sem_it,svm_rand_perf_it,svm_rand_sem_it,...
    svm_perf_rand,svm_sem_rand,trial_accuracy_rand,svm_rand_iterat,roc] = svm_taskphase(input,input.hz_filter);


% x_label
x_label = linspace(1,length(svm_perf),length(svm_perf));

figure('color',[1 1 1]);
shadedErrorBar(x_label(3:end),svm_perf(3:end),svm_sem(3:end),'-k',1);
hold on;
shadedErrorBar(x_label(3:end),svm_perf_rand(3:end),svm_sem_rand(3:end),'-r',1);

    %set(gca, 'XTick',[1,2,3,4,5,6,7])
    %set(gca, 'xticklabel',{'early delay v iti','late delay v iti', 'stem SvC','t-junction SvC',...
        %'goal-arm SvC','goal-zone SvC', 'return-arm SvC'})
    set(gca, 'XTick',[3,4,5,6,7])
    set(gca, 'xticklabel',{'stem SvC','t-junction SvC',...
        'goal-arm SvC','goal-zone SvC', 'return-arm SvC'})        
    ax = gca;
    ax.XTickLabelRotation = 45;    

box off
ylabel('Classifier Accuracy (%)')
%xlabel('time')
axis tight
ylim([0 100])
hold on;
xlim=get(gca,'xlim');
hold on
plot(xlim,[50 50],'LineWidth',1,'Color','r','linestyle','--')
%legend('good performance','poor performance','Location','southeast')
%legend('Good Performance','Poor Performance','Location','southeast')

% stats
[h,p,ks2test] = kstest2(svm_perf(3:end),svm_perf_rand(3:end));

for i = 1:size(trial_accuracy,1)
    [fisher_p{i},var_fisher{i}] = fisher_test(trial_accuracy{i},trial_accuracy_rand{i});
    binomial_p{i}=myBinomTest(length(find(trial_accuracy{i}==1)),length(trial_accuracy{i}),0.5,'two');        
end


figure();
plot(roc.X{6},roc.Y{6},'k')
hold on; 
plot(roc.X_rand{6},roc.Y_rand{6},'r') % 'r'
axis tight
%legend('mPFC early','mPFC late','location','southeast') % 
%legend('AUC Choice-Point','AUC 20s Delay','location','east') % 
xlabel('False Positive Rate')
ylabel('True Positive Rate')
box off


