clear; clc; close all;
% load data
sampleData = load('data_speedTimeSpent_7bins_sample');
choiceData = load('data_speedTimeSpent_7bins_choice');

% plot speed with task phase
figure('color','w'); hold on;
errorbar(sampleData.BehData.AvSessVel,sampleData.BehData.SEMSessVel,'b','LineWidth',2);
errorbar(choiceData.BehData.AvSessVel,choiceData.BehData.SEMSessVel,'r','LineWidth',2);
ylabel('Velocity (pixels/sec)')
xlabel('Bin number')
set(gca,'FontSize',12)
axis tight

% timespent
figure('color','w'); hold on;
errorbar(sampleData.BehData.AvSessSpent,sampleData.BehData.SEMSessSpent,'b','LineWidth',2);
errorbar(choiceData.BehData.AvSessSpent,choiceData.BehData.SEMSessSpent,'r','LineWidth',2);
ylabel('Time spent (sec)')
xlabel('Bin number')
set(gca,'FontSize',12)
axis tight

% 2 way anova
anovaMat      = vertcat(sampleData.BehData.MeanSpent,choiceData.BehData.MeanSpent);
[p,tbl,stats] = anova2(anovaMat,size(anovaMat,1)/2);
c             = multcompare(stats);

% bonferroni 
bonfCor = 0.05/size(anovaMat,2);

for i = 1:size(anovaMat,2)
    [h(i),p_ttest(i),ci,stat_ttest{i}]=ttest(sampleData.BehData.MeanSpent(:,i),choiceData.BehData.MeanSpent(:,i),'Alpha',bonfCor);
end

% cohens D
for i = 1:size(anovaMat,2)
    sdPooled(i) = sqrt((((std(sampleData.BehData.MeanSpent(:,i)))^2)+((std(choiceData.BehData.MeanSpent(:,i)))^2))/2);
    cohensD(i)  = ((mean(sampleData.BehData.MeanSpent(:,i)))-(mean(choiceData.BehData.MeanSpent(:,i))))/sdPooled(i);
end

figure('color','w')
bar(cohensD);
box off
ylabel('Cohens D')
xlabel('Stem Bin')
set(gca,'FontSize',12)

figure('color','w')
subplot 211
    plot(cohensD,'Color','m','LineWidth',2);
    box off
    ylabel('Cohens D')
    %xlabel('Stem Bin')
    set(gca,'FontSize',12)
    hold on;
    axis tight
    ylim([-0.3 1])
subplot 212
    hold on;
    errorbar(sampleData.BehData.AvSessSpent,sampleData.BehData.SEMSessSpent,'b','LineWidth',2);
    errorbar(choiceData.BehData.AvSessSpent,choiceData.BehData.SEMSessSpent,'r','LineWidth',2);
    ylabel('Time spent (sec)')
    xlabel('Stem Bin')
    set(gca,'FontSize',12)
    box off
    axis tight


% sample left/right
figure('color','w'); 
subplot 211
    hold on;
    e1 = errorbar(sampleData.BehData.L_AvSessVel./2,sampleData.BehData.L_SEMSessVel./2,'b','LineWidth',2);
    e2 = errorbar(sampleData.BehData.R_AvSessVel./2,sampleData.BehData.R_SEMSessVel./2,'r','LineWidth',2);
    ylabel('Velocity (pixels/sec)')
    xlabel('Bin number')
    set(gca,'FontSize',12)
    axis tight
    legend('sample Left','sample Right')
subplot 212
    hold on
    e1 = errorbar(sampleData.BehData.L_AvSessSpent,sampleData.BehData.L_SEMSessSpent,'b','LineWidth',2);
    e2 = errorbar(sampleData.BehData.R_AvSessSpent,sampleData.BehData.R_SEMSessSpent,'r','LineWidth',2);
    ylabel('Time (sec)')
    xlabel('Bin number')
    set(gca,'FontSize',12)
    axis tight
    legend('sample Left','sample Right')

% 2 way anova
anovaMat      = vertcat(sampleData.BehData.L_MeanVel,sampleData.BehData.R_MeanVel);
[p,tbl,stats] = anova2(anovaMat,size(anovaMat,1)/2);
c             = multcompare(stats);

for i = 1:size(anovaMat,2)
    [h(i),p_ttest(i),ci,stat_ttest{i}]=ttest(sampleData.BehData.L_MeanSpent(:,i),sampleData.BehData.R_MeanSpent(:,i),'Alpha',bonfCor);
end

% cohens D
for i = 1:size(anovaMat,2)
    sdPooled(i) = sqrt((((std(sampleData.BehData.L_MeanSpent(:,i)))^2)+((std(sampleData.BehData.R_MeanSpent(:,i)))^2))/2);
    cohensD(i)  = ((mean(sampleData.BehData.L_MeanSpentt(:,i)))-(mean(sampleData.BehData.R_MeanSpent(:,i))))/sdPooled(i);
end

% choice left/right
figure('color','w'); 
subplot 211
    hold on;
    e1 = errorbar(choiceData.BehData.L_AvSessVel./2,choiceData.BehData.L_SEMSessVel./2,'b','LineWidth',2);
    e2 = errorbar(choiceData.BehData.R_AvSessVel./2,choiceData.BehData.R_SEMSessVel./2,'r','LineWidth',2);
    ylabel('Velocity (pixels/sec)')
    xlabel('Bin number')
    set(gca,'FontSize',12)
    axis tight
    legend('Choice Left','Choice Right')
subplot 212
    hold on
    e1 = errorbar(choiceData.BehData.L_AvSessSpent,choiceData.BehData.L_SEMSessSpent,'b','LineWidth',2);
    e2 = errorbar(choiceData.BehData.R_AvSessSpent,choiceData.BehData.R_SEMSessSpent,'r','LineWidth',2);
    ylabel('Time (sec)')
    xlabel('Bin number')
    set(gca,'FontSize',12)
    axis tight
    legend('Choice Left','Choice Right')

% 2 way anova
anovaMat      = vertcat(choiceData.BehData.L_MeanVel,choiceData.BehData.R_MeanVel);
[p,tbl,stats] = anova2(anovaMat,size(anovaMat,1)/2);
c             = multcompare(stats);

% 2 way anova
anovaMat      = vertcat(choiceData.BehData.L_MeanSpent,choiceData.BehData.R_MeanSpent);
[p,tbl,stats] = anova2(anovaMat,size(anovaMat,1)/2);
c             = multcompare(stats);

% bonferroni 
bonfCor = 0.05/size(anovaMat,2);

for i = 1:size(anovaMat,2)
    [h(i),p_ttest(i),ci,stat_ttest{i}]=ttest(choiceData.BehData.L_MeanSpent(:,i),choiceData.BehData.R_MeanSpent(:,i),'Alpha',bonfCor);
end

for i = 1:size(anovaMat,2)
    [h(i),p_ttest(i),ci,stat_ttest{i}]=ttest(choiceData.BehData.L_MeanVel(:,i),choiceData.BehData.R_MeanVel(:,i),'Alpha',bonfCor);
end

% cohens D
for i = 1:size(anovaMat,2)
    sdPooled(i) = sqrt((((std(choiceData.BehData.L_MeanSpent(:,i)))^2)+((std(choiceData.BehData.R_MeanSpent(:,i)))^2))/2);
    cohensD(i)  = ((mean(choiceData.BehData.L_MeanSpentt(:,i)))-(mean(choiceData.BehData.R_MeanSpent(:,i))))/sdPooled(i);
end

% sample left choice left
figure('color','w'); hold on;
e1 = errorbar(sampleData.BehData.L_AvSessVel,sampleData.BehData.L_SEMSessVel,'b','LineWidth',2);
e2 = errorbar(choiceData.BehData.L_AvSessVel,choiceData.BehData.L_SEMSessVel,'r','LineWidth',2);
ylabel('Velocity (pixels/sec)')
xlabel('Bin number')
set(gca,'FontSize',12)
axis tight
legend('Sample Left','Choice Left')

% sample right choice right
figure('color','w'); hold on;
e1 = errorbar(sampleData.BehData.R_AvSessVel,sampleData.BehData.R_SEMSessVel,'b','LineWidth',2);
e2 = errorbar(choiceData.BehData.R_AvSessVel,choiceData.BehData.R_SEMSessVel,'r','LineWidth',2);
ylabel('Velocity (pixels/sec)')
xlabel('Bin number')
set(gca,'FontSize',12)
axis tight
legend('Sample Right','Choice Right')