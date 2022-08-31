%% script to plot classifier figs
place2store = getCurrentPath;
cd(place2store);
load('data_svm2016');

% classifier trained to predict high vs low states
figure('color','w'); hold on;
bar(1,nanmean(svmPerformance.DA.trueAvg),'FaceColor',[.6 .6 .6]);
errorbar(1,nanmean(svmPerformance.DA.trueAvg),nanstd(svmPerformance.DA.trueAvg),'color','k','LineWidth',2)
line([0.6 1.4],[nanmean(svmPerformance.DA.shuffAvg) nanmean(svmPerformance.DA.shuffAvg)],'Color','w','LineWidth',2,'LineStyle','--')
[pDA, obsDA, effectsizeDA] = permutationTest(svmPerformance.DA.trueAvg, svmPerformance.DA.shuffAvg, 1000);
ylabel('Classifier Accuracy')
title('Predict high vs low')

% sangiamo style
[h,p,ci,z] = ztest(nanmean(svmPerformance.DA.shuffAvg),nanmean(svmPerformance.DA.trueAvg),std(svmPerformance.DA.trueAvg))

% classifier trained to predict cd from da
figure('color','w'); hold on;
bar(1,nanmean(svmPerformance.High.daVScd_trueAvg),'FaceColor','b');
errorbar(1,nanmean(svmPerformance.High.daVScd_trueAvg),nanstd(svmPerformance.High.daVScd_trueAvg),'color','k','LineWidth',2)
line([0.6 1.4],[svmPerformance.Low.daVScd_shuffAvg svmPerformance.Low.daVScd_shuffAvg],'Color','w','LineWidth',2,'LineStyle','--')
bar(2,nanmean(svmPerformance.Low.daVScd_trueAvg),'FaceColor','r');
errorbar(2,nanmean(svmPerformance.Low.daVScd_trueAvg),nanstd(svmPerformance.Low.daVScd_trueAvg),'color','k','LineWidth',2)
line([1.6 2.4],[svmPerformance.Low.daVScd_shuffAvg svmPerformance.Low.daVScd_shuffAvg],'Color','w','LineWidth',2,'LineStyle','--')
ylabel('Classifier Accuracy')
title('Predict Task')

% sangiamo style
[h,p,ci,z] = ztest(nanmean(svmPerformance.High.daVScd_shuffAvg),nanmean(svmPerformance.High.daVScd_trueAvg),std(svmPerformance.High.daVScd_trueAvg))
p*3
[h,p,ci,z] = ztest(nanmean(svmPerformance.Low.daVScd_shuffAvg),nanmean(svmPerformance.Low.daVScd_trueAvg),std(svmPerformance.Low.daVScd_trueAvg))
p*3
[h,p,ci,z] = ztest(nanmean(svmPerformance.High.daVScd_trueAvg),nanmean(svmPerformance.Low.daVScd_trueAvg),std(svmPerformance.Low.daVScd_trueAvg))
p*3
