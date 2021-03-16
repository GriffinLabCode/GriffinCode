%% scat_data
% 4 henrys

function [Corr,model,regression_summary] = scat_data(data1,data2,data_labels)

% pearsons 
[Corr.r,Corr.p] = corrcoef(data1,data2);
Corr.r = Corr.r(2);
Corr.p = Corr.p(2);

% regression
%disp(['Regression with ',data_labels{1},' used to predict ',data_labels{2}])
model = fitlm(data1',data2','linear'); % for pvalue

% figure
figure('color','w');
scat1 = scatter(data1,data2);
scat1.MarkerEdgeColor = 'k';
scat1.MarkerFaceColor = [.8 .8 .8];
l_scat1 = lsline;
l_scat1.Color = 'r';
axis tight
xlabel(data_labels{1})
ylabel(data_labels{2})
set(gcf,'Position',[300 250 350 300])

% plot R and p values
x_lim = xlim;
y_lim = ylim;
text(x_lim(2)/1.25,y_lim(2)/1.25,['R = ',num2str(Corr.r) newline 'p = ',num2str(Corr.p)]);

% get summary
regression_summary = anova(model,'summary');

