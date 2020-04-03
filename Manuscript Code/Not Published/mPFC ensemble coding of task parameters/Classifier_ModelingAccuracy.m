%% modeling data
% First, run Classifier_SampleSizeAndAccuracy
% This code is meant to model your classifier results in terms of adding
% neurons. In other words, you need to have pre-existing data whereby you
% iteratively and randomly added neurons to the classifier
%
% PURPOSE: If you acheive a trending effect on your classifier, you may
% wonder if you didn't have sufficient power. Here, you can address that
% question. 
%
% written by John Stout

%% prep stuff
clear; clc; close all
cd('X:\07. Manuscripts\In preparation\Stout - JNeuro\Data\mPFC 2-2020')

% if a dataName error comes up, you've loaded the wrong file (an old one)
%load('data_numNeurons_choiceLvR_5000Iterations_185neurons_Tjunction');
%load('data_numNeurons_sampleLvR_5000Iterations_Tjunction_185Neurons')
%load('data_numNeurons_sampleLvR_HighRate_5000Iterations_Tjunction')
load('data_numNeurons_choicelvR_5000_TjunctionHighRate')
%load('data_numNeurons_choiceLvR_5000Iterations_earlyStemBin')
%load('data_numNeurons_choiceLvR_HighRate_5000Iterations_secondBin')
%load('data_numNeurons_sampleLvR_5000Iterations_Tjunction')

%% Plotting and modeling
% NOTE - selectIdx variable has the number of added neurons. So if
% selectIdx(1) = 10, and the average classification accuracy is 100, your
% classifier only required 10 neurons to acheive 100% performance.

% define a variable used in the future
x_label = selectIdx;

% get avg and std of classifications
svm_avg = cellfun(@mean,svm_perf);
svm_std = cellfun(@std,svm_perf);

% chance level - pulled from full blown classifier - note if you get an
% error here, you have not loaded correct dataset. You need the dataName
% variable from the Classifier_SampleSizeAndAccuracy
data_comp = load(dataName);
chance_dist = data_comp.svm_perf_rand{binDraw};

% ztest from og data
for neuri = 1:length(x_label)
    [~,p(neuri),~,stat{neuri}] = ztest(svm_avg(neuri),mean(chance_dist),std(chance_dist));
end 

% figure - scatter plot
figure('color','w'); hold on;
s1 = scatter(x_label,svm_avg);
s1.MarkerFaceColor = [0.75 0.75 0.75];
s1.MarkerEdgeColor = 'k';
line1 = lsline;
line1.Color = 'k';
xlimits = xlim;
line([xlimits(1) xlimits(2)],[mean(chance_dist) mean(chance_dist)],'Color','r','LineStyle','--','LineWidth',2)
ylim([30 100])
ylabel('Classifier Accuracy')
xlabel('Number of Neurons added')
set(gca,'FontSize',12)
% plot significance
line_data = NaN([1 length(x_label)]);
Yminmax = get(gca,'Ylim');
line_data(find(p<0.05))=Yminmax(2);
for i = 1:length(x_label)
    y = line_data(i);
    line([x_label(i)-2,x_label(i)+2],[y,y],'Color','m','LineWidth',2)
end 

% this tells you the minimum number of neurons required to acheive
% significance
LeastNumReqIdx = min(find(p<0.05));
LeastNumReq    = selectIdx(LeastNumReqIdx);

% pearsons linear correlation
[r,pcorr] = corrcoef(x_label,svm_avg)

% least squares regression - this is between number of neurons and svm
% performance - note that x_label and selectIdx are interchangeable if
% defined before this
[popNormAll,gofNormAll,outNormAll] = fit(selectIdx',svm_avg','poly1');

% ~~~~ log transform your dataset ~~~~ %
logX = 10*log10(x_label);
logY = 10*log10(svm_avg);

% plot data
figure('color','w'); hold on;
s1 = scatter(logX,logY);
s1.MarkerFaceColor = [0.75 0.75 0.75];
s1.MarkerEdgeColor = 'k';
line1 = lsline;
line1.Color = 'k';
xlimits = xlim;
line([xlimits(1) xlimits(2)],[10*log10(mean(chance_dist)) 10*log10(mean(chance_dist))],'Color','r','LineStyle','--','LineWidth',2)
ylim([10*log10(40) 10*log10(100)])
ylabel('Log Transformed Accuracy')
xlabel('Log Transformed # of Neurons')
set(gca,'FontSize',12)
% plot significance
line_data = NaN([1 length(x_label)]);
Yminmax = get(gca,'Ylim');
line_data(find(p<0.05))=Yminmax(2);
for i = 1:length(x_label)
    y = line_data(i);
    line([logX(i)-0.1,logX(i)+0.1],[y,y],'Color','m','LineWidth',2)
end 

% pearsons linear correlation bw log transformed variables
[rLog,pcorrLog] = corrcoef(10*log10(x_label),10*log10(svm_avg))

% least squares regression on  log transformed data
[popModelAll,gofModelAll,outModelAll] = fit(logX',logY','poly1');

% this variable is the actual line, were you to plot a regression line on
% your log data. for example: figure(); scatter(logX,logY); lsline; gives
% you an identical result if you were to plot this predY variable. Note
% that if you just do: figure(); plot(predY); the line is curved. This is
% because the Y-axis is not log corrected.
for i = 1:length(logX)
    predY(i) = popModelAll.p1*logX(i) + popModelAll.p2;
end

%% model future accuracy using all data
% define an x-axis with future estimates. So if you have 100 neurons and
% you trained the classifier in increments of 5, try 5:5:200 or 5:5:400 or
% something. 5:5:100 would model your current data and not extend into the
% future.
futureAdded = 5:5:300;

% log transform new x-axis
logXfuture = 10*log10(futureAdded);

% predict future estimates using the equation obtained from your regression
% on log data
clear predFuture
for i = 1:length(futureAdded)
    predFuture(i) = popModelAll.p1*logXfuture(i) + popModelAll.p2;
end

% predicted intervals
clear ci
ci = predint(popModelAll,logXfuture);

% transform to percentage data - this is the antilog
clear AccuracyFuture
for i = 1:length(predFuture)
    AccuracyFuture(i) = 10^(predFuture(i)/10);
end

% transform confidence intervals - antilog
clear ciConv
for i = 1:size(ci,1)
    for ii = 1:size(ci,2)
        ciConv(i,ii) = 10^(ci(i,ii)/10);
    end
end

% subtract/add from mean - the CI is given as actual estimates surrounding
% the mean, but for you to plot it, you'll need the difference from the
% mean and CIs
clear ciFromMean ciLogFrmMean
for i = 1:size(ci,1)
    for ii = 1:size(ci,2)
        ciFromMean(i,ii) = AccuracyFuture(i)-ciConv(i,ii);
        ciLogFrmMean(i,ii) = predFuture(i)-ci(i,ii);
    end
end
ciFromMean = abs(ciFromMean);
ciLogFrmMean = abs(ciLogFrmMean);

% currently, this model does not correct for the regression eventually
% predicting over 100%, future iterations should
% remove anything above 100%
TooHigh = find(AccuracyFuture>100);
AccuracyFuture(TooHigh)=[];
predFuture(TooHigh)=[];
futureAdded(TooHigh)=[];
ci(TooHigh,:)=[];
ci = ci';
ciConv(TooHigh,:)=[];
ciConv = ciConv';
ciFromMean(TooHigh,:)=[];
ciFromMean = ciFromMean';
ciLogFrmMean(TooHigh,:)=[];
ciLogFrmMean = ciLogFrmMean';
logXfuture(TooHigh)=[];

% model significance - with your new modeled data, model significance
% against a known estimate of chance level
clear pFut statFut
for neuri = 1:length(futureAdded)
    [~,pFut(neuri),~,statFut{neuri}] = ztest(AccuracyFuture(neuri),mean(chance_dist),std(chance_dist));
end

% plot modeled data with confidence intervals - log data
figure('color','w');
shadedErrorBar(logXfuture,predFuture,ciLogFrmMean,'b',0)
axis tight
xlimits = xlim;
%line([xlimits(1) xlimits(2)],[10*log10(mean(chance_dist)) 10*log10(mean(chance_dist))],'Color','r','LineStyle','--','LineWidth',2)
ylabel('Predicted Accuracy (10*log10)')
xlabel('Number of Neurons added (10*log10)')
set(gca,'FontSize',12)
box off
set(gca,'FontSize',12)
box off

% plot converted data - with CIs
figure('color','w');
shadedErrorBar(futureAdded,AccuracyFuture,ciFromMean,'b',0)
axis tight
xlimits = xlim;
line([xlimits(1) xlimits(2)],[mean(chance_dist) mean(chance_dist)],'Color','r','LineStyle','--','LineWidth',2)
ylabel('Classifier Accuracy')
xlabel('Number of Neurons added')
set(gca,'FontSize',12)
box off
title('Forcasting Future Prediction Accuracies')
ylabel('Classifier Accuracy')
xlabel('# of Added Neurons')
set(gca,'FontSize',12)
box off
% plot significance of log data
line_data = NaN([1 length(x_label)]);
Yminmax = get(gca,'Ylim');
line_data(find(pFut<0.05))=Yminmax(2);
for i = 1:length(futureAdded)
    y = line_data(i);
    line([futureAdded(i)-2,futureAdded(i)+2],[y+1,y+1],'Color','m','LineWidth',2)
end 
set(gca,'FontSize',12)
ylim([30 110])

% Now do a scatter plot to show individual datapoints
figure('color','w'); hold on;
s1 = scatter(futureAdded,AccuracyFuture);
s1.MarkerFaceColor = [0.7 0.7 0.7];
s1.MarkerEdgeColor = 'r';
s2 = scatter(x_label,svm_avg);
s2.MarkerFaceColor = [0.9 0.9 0.9];
s2.MarkerEdgeColor = 'k';
title('Forcasting Future Prediction Accuracies')
ylabel('Classifier Accuracy')
xlabel('# of Added Neurons')
set(gca,'FontSize',12)
box off
xlimits = xlim;
line([xlimits(1) xlimits(2)],[mean(chance_dist) mean(chance_dist)],'Color','r','LineStyle','--','LineWidth',2)

% plot significance of original data
line_data = NaN([1 length(x_label)]);
Yminmax = get(gca,'Ylim');
line_data(find(p<0.05))=Yminmax(2);
for i = 1:length(x_label)
    y = line_data(i);
    line([x_label(i)-2,x_label(i)+2],[y+2,y+2],'Color','k','LineWidth',2)
end 

% plot significance of log data
line_data = NaN([1 length(x_label)]);
Yminmax = get(gca,'Ylim');
line_data(find(pFut<0.05))=Yminmax(2);
for i = 1:length(futureAdded)
    y = line_data(i);
    line([futureAdded(i)-2,futureAdded(i)+2],[y+1,y+1],'Color','r','LineWidth',2)
end 
set(gca,'FontSize',12)
%title([num2str(numNeurons),' Added in increments of 2'])
ylim([30 120])

% this is the least number of neurons required to reach significance
LeastNumReqPredIdx = min(find(pFut<0.05));
LeastNumReqPred = futureAdded(LeastNumReqPredIdx);

%% future accuracy on a small sample size
% number of neurons to model future features
numNeurons  = 50;
numSelected = find(selectIdx == numNeurons);

% least squares regression - SS stands for 'small sample'
clear popModelSS gofModelSS outModelSS
[popModelSS,gofModelSS,outModelSS] = fit(logX(1:numSelected)',logY(1:numSelected)','poly1');

% predicted Y data
clear predFutSS
for i = 1:length(logX)
    predFutSS(i) = popModelSS.p1*logX(i) + popModelSS.p2;
end

% predicted intervals
clear ciSS
ciSS = predint(popModelSS,logX);

% transform to percentage data
clear AccuracyConvertSS
for i = 1:length(predY)
    AccuracyConvertSS(i) = 10^(predFutSS(i)/10);
end

% modeling significance
% ztest
clear pSS statSS
for neuri = 1:length(x_label)
    [~,pSS(neuri),~,statSS{neuri}] = ztest(AccuracyConvertSS(neuri),mean(chance_dist),std(chance_dist));
end

% reconverted
figure('color','w'); hold on;
s2 = scatter(selectIdx,svm_avg);
s2.MarkerFaceColor = [0.9 0.9 0.9];
s2.MarkerEdgeColor = 'k';
s1 = scatter(selectIdx,AccuracyConvertSS);
s1.MarkerFaceColor = [0.7 0.7 0.7];
s1.MarkerEdgeColor = 'r';
% plot significance of original data
line_data = NaN([1 length(x_label)]);
Yminmax = get(gca,'Ylim');
line_data(find(p<0.05))=Yminmax(2);
for i = 1:length(x_label)
    y = line_data(i);
    line([x_label(i)-2,x_label(i)+2],[y+2,y+2],'Color','k','LineWidth',2)
end 
% plot significance of log data
line_data = NaN([1 length(x_label)]);
Yminmax = get(gca,'Ylim');
line_data(find(pSS<0.05))=Yminmax(2);
for i = 1:length(x_label)
    y = line_data(i);
    line([x_label(i)-2,x_label(i)+2],[y+1,y+1],'Color','r','LineWidth',2)
end 
set(gca,'FontSize',12)
title([num2str(numNeurons),' Added in increments of 5'])
LeastNumReqPredSS = selectIdx(find(pSS<0.05))



