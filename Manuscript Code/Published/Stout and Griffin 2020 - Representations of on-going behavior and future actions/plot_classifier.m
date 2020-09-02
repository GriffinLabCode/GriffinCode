clear

addpath('X:\07. Manuscripts\In preparation\StoutGriffin2020 - LearningMemory\Data figures and manuscript\Stout&Griffin data and matlab figures')
load('data_classify_LvR_sample_GreaterThan2Hz');

% use standard deviation
svm_sem = cellfun(@std,svm_perf_dataPerm);

% plot classifier accuracy as a mean line against the random distribution
figure('color',[1 1 1]); hold on;
for bini = 1:numbins
    subplot(numbins,1,bini)
    histogram(svm_perf_rand{bini},20)
    line([svm_perf(bini) svm_perf(bini)],[0 max(ylim)],'Color','r','linestyle','--','LineWidth',2)
    box off
    set(gca,'FontSize',9)
    ylabel(['bin ', num2str(bini)])
end
xlabel('Classifier Accuracy')

% plot classifier distribution against the random distribution if you used
% permutation. This will also plot a mean line
figure('color',[1 1 1]); hold on;
for bini = 1:numbins
    subplot(numbins,1,bini)
    h1 = histogram(svm_perf_rand{bini},10);
    h1.FaceAlpha = .2;
    h1.FaceColor = 'r';
    hold on;
    h2 = histogram(svm_perf_dataPerm{bini},10);
    h2.FaceColor = 'k'; 
    h2.FaceAlpha = 0.2;
    line([svm_perf(bini) svm_perf(bini)],[0 max(ylim)],'Color','k','linestyle','--','LineWidth',2)
    box off
    set(gca,'FontSize',9)
    ylabel(['bin ', num2str(bini)])
end
xlabel('Classifier Accuracy')

figure('color','w')
h1 = histogram(svm_perf_rand{7},10);
h1.FaceAlpha = .2;
h1.FaceColor = 'r';
line([shuff_mean(7) shuff_mean(7)],[0 max(ylim)],'Color','r','linestyle','--','LineWidth',2)
hold on;
h2 = histogram(svm_perf_dataPerm{7},10);
h2.FaceColor = 'k'; 
h2.FaceAlpha = 0.2;
line([svm_perf(7) svm_perf(7)],[0 max(ylim)],'Color','k','linestyle','--','LineWidth',2)
box off
set(gca,'FontSize',12)
ylabel(['bin ', num2str(bini)])

% plot line graph where significance is denoted by magenta bar at top and
% random distribution mean is denoted by a dotted line. Note that this
% dotted line will change per bin due to different data being used for the
% generation of a random distribution. This is normal.
x_label = 1:length(svm_perf);
figure('color',[1 1 1]); hold on;
er                   = errorbar(x_label,svm_perf,svm_sem);    
er.Color             = 'k';                            
er.LineWidth         = 2;
set(gca,'FontSize',14)

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

% shaded error bar
x_label = 1:length(svm_perf);
figure('color',[1 1 1]); hold on;
s = shadedErrorBar(x_label,svm_perf,svm_sem,'k',0);    
set(gca,'FontSize',14)

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
axis tight