% step3
clear; clc; close all;
place2store = getCurrentPath();
addpath(place2store)

% load coherence data
tic;
load('dataLFP_step2');
load('data_behavior','timeSpent_CP')
disp(['Loading time is ' num2str(toc), 's']);

% whenever a nan existed, it means that the trial was neither a VTE nor a
% non-VTE. Therefore, it should not count as anything.
rats = fieldnames(dataLFP);
% identify which rats to use
rats = rats(1:end);


% define a threshold
%threshold = 1; % zscore
for rati = 1:length(rats)

   try powerVTEpfc{rati,1} = dataLFP.(rats{rati}).Baseline.Baseline1.choicePointAnalysis.pfc.vte.powerS; end
   try powerNONpfc{rati,1} = dataLFP.(rats{rati}).Baseline.Baseline1.choicePointAnalysis.pfc.non.powerS; end
   try powerPFC   {rati,1} = dataLFP.(rats{rati}).Baseline.Baseline1.choicePointAnalysis.pfc.all.powerS; end

   try powerVTEpfc{rati,2} = dataLFP.(rats{rati}).Baseline.Baseline2.choicePointAnalysis.pfc.vte.powerS; end
   try powerNONpfc{rati,2} = dataLFP.(rats{rati}).Baseline.Baseline2.choicePointAnalysis.pfc.non.powerS; end
   try powerPFC   {rati,2} = dataLFP.(rats{rati}).Baseline.Baseline2.choicePointAnalysis.pfc.all.powerS; end    

   try powerVTEpfc{rati,3} = dataLFP.(rats{rati}).Saline.Baseline.choicePointAnalysis.pfc.vte.powerS; end
   try powerNONpfc{rati,3} = dataLFP.(rats{rati}).Saline.Baseline.choicePointAnalysis.pfc.non.powerS; end
   try powerPFC   {rati,3} = dataLFP.(rats{rati}).Saline.Baseline.choicePointAnalysis.pfc.all.powerS; end
    
   try powerVTEpfc{rati,4} = dataLFP.(rats{rati}).Saline.Saline.choicePointAnalysis.pfc.vte.powerS; end
   try powerNONpfc{rati,4} = dataLFP.(rats{rati}).Saline.Saline.choicePointAnalysis.pfc.non.powerS; end
   try powerPFC   {rati,4} = dataLFP.(rats{rati}).Saline.Saline.choicePointAnalysis.pfc.all.powerS; end      

   try powerVTEpfc{rati,5} = dataLFP.(rats{rati}).Muscimol.Baseline.choicePointAnalysis.pfc.vte.powerS; end
   try powerNONpfc{rati,5} = dataLFP.(rats{rati}).Muscimol.Baseline.choicePointAnalysis.pfc.non.powerS; end
   try powerPFC   {rati,5} = dataLFP.(rats{rati}).Muscimol.Baseline.choicePointAnalysis.pfc.all.powerS; end
    
   try powerVTEpfc{rati,6} = dataLFP.(rats{rati}).Muscimol.Muscimol.choicePointAnalysis.pfc.vte.powerS; end
   try powerNONpfc{rati,6} = dataLFP.(rats{rati}).Muscimol.Muscimol.choicePointAnalysis.pfc.non.powerS; end
   try powerPFC   {rati,6} = dataLFP.(rats{rati}).Muscimol.Muscimol.choicePointAnalysis.pfc.all.powerS; end 
    

    % -- hpc -- %

   try powerVTEhpc{rati,1} = dataLFP.(rats{rati}).Baseline.Baseline1.choicePointAnalysis.hpc.vte.powerS; end
   try powerNONhpc{rati,1} = dataLFP.(rats{rati}).Baseline.Baseline1.choicePointAnalysis.hpc.non.powerS; end
   try powerHPC   {rati,1} = dataLFP.(rats{rati}).Baseline.Baseline1.choicePointAnalysis.hpc.all.powerS; end
    
   try powerVTEhpc{rati,2} = dataLFP.(rats{rati}).Baseline.Baseline2.choicePointAnalysis.hpc.vte.powerS; end
   try powerNONhpc{rati,2} = dataLFP.(rats{rati}).Baseline.Baseline2.choicePointAnalysis.hpc.non.powerS; end
   try powerHPC   {rati,2} = dataLFP.(rats{rati}).Baseline.Baseline2.choicePointAnalysis.hpc.all.powerS; end    

   try powerVTEhpc{rati,3} = dataLFP.(rats{rati}).Saline.Baseline.choicePointAnalysis.hpc.vte.powerS; end
   try powerNONhpc{rati,3} = dataLFP.(rats{rati}).Saline.Baseline.choicePointAnalysis.hpc.non.powerS; end
   try powerHPC   {rati,3} = dataLFP.(rats{rati}).Saline.Baseline.choicePointAnalysis.hpc.all.powerS; end
    
   try powerVTEhpc{rati,4} = dataLFP.(rats{rati}).Saline.Saline.choicePointAnalysis.hpc.vte.powerS; end
   try powerNONhpc{rati,4} = dataLFP.(rats{rati}).Saline.Saline.choicePointAnalysis.hpc.non.powerS; end
   try powerHPC   {rati,4} = dataLFP.(rats{rati}).Saline.Saline.choicePointAnalysis.hpc.all.powerS; end      

   try powerVTEhpc{rati,5} = dataLFP.(rats{rati}).Muscimol.Baseline.choicePointAnalysis.hpc.vte.powerS; end
   try powerNONhpc{rati,5} = dataLFP.(rats{rati}).Muscimol.Baseline.choicePointAnalysis.hpc.non.powerS; end
   try powerHPC   {rati,5} = dataLFP.(rats{rati}).Muscimol.Baseline.choicePointAnalysis.hpc.all.powerS; end
    
   try powerVTEhpc{rati,6} = dataLFP.(rats{rati}).Muscimol.Muscimol.choicePointAnalysis.hpc.vte.powerS; end
   try powerNONhpc{rati,6} = dataLFP.(rats{rati}).Muscimol.Muscimol.choicePointAnalysis.hpc.non.powerS; end
   try powerHPC   {rati,6} = dataLFP.(rats{rati}).Muscimol.Muscimol.choicePointAnalysis.hpc.all.powerS; end 
    

    % coherence 
  try coherenceVTE{rati,1} = dataLFP.(rats{rati}).Baseline.Baseline1.choicePointAnalysis.coherence.vte.C; end
  try coherenceNON{rati,1} = dataLFP.(rats{rati}).Baseline.Baseline1.choicePointAnalysis.coherence.non.C; end
  try coherence   {rati,1} = dataLFP.(rats{rati}).Baseline.Baseline1.choicePointAnalysis.coherence.all.C; end
    
  try coherenceVTE{rati,2} = dataLFP.(rats{rati}).Baseline.Baseline2.choicePointAnalysis.coherence.vte.C; end
  try coherenceNON{rati,2} = dataLFP.(rats{rati}).Baseline.Baseline2.choicePointAnalysis.coherence.non.C; end
  try coherence   {rati,2} = dataLFP.(rats{rati}).Baseline.Baseline2.choicePointAnalysis.coherence.all.C; end    

  try coherenceVTE{rati,3} = dataLFP.(rats{rati}).Saline.Baseline.choicePointAnalysis.coherence.vte.C; end
  try coherenceNON{rati,3} = dataLFP.(rats{rati}).Saline.Baseline.choicePointAnalysis.coherence.non.C; end
  try coherence   {rati,3} = dataLFP.(rats{rati}).Saline.Baseline.choicePointAnalysis.coherence.all.C; end
    
  try coherenceVTE{rati,4} = dataLFP.(rats{rati}).Saline.Saline.choicePointAnalysis.coherence.vte.C; end
  try coherenceNON{rati,4} = dataLFP.(rats{rati}).Saline.Saline.choicePointAnalysis.coherence.non.C; end
  try coherence   {rati,4} = dataLFP.(rats{rati}).Saline.Saline.choicePointAnalysis.coherence.all.C; end      

  try coherenceVTE{rati,5} = dataLFP.(rats{rati}).Muscimol.Baseline.choicePointAnalysis.coherence.vte.C; end
  try coherenceNON{rati,5} = dataLFP.(rats{rati}).Muscimol.Baseline.choicePointAnalysis.coherence.non.C; end
  try coherence   {rati,5} = dataLFP.(rats{rati}).Muscimol.Baseline.choicePointAnalysis.coherence.all.C; end
    
  try coherenceVTE{rati,6} = dataLFP.(rats{rati}).Muscimol.Muscimol.choicePointAnalysis.coherence.vte.C; end
  try coherenceNON{rati,6} = dataLFP.(rats{rati}).Muscimol.Muscimol.choicePointAnalysis.coherence.non.C; end
  try coherence   {rati,6} = dataLFP.(rats{rati}).Muscimol.Muscimol.choicePointAnalysis.coherence.all.C; end     

end

% figures

% empty to nan
coherenceVTE = empty2nan(coherenceVTE);
coherenceNON = empty2nan(coherenceNON);
coherence    = empty2nan(coherence);

% normalize to account for between rat variability
for rowi = 1:size(coherence,1)
    for coli = 1:size(coherence,2)
        coherenceVTE{rowi,coli} = (normalize(coherenceVTE{rowi,coli}','range'))';
        coherenceNON{rowi,coli} = (normalize(coherenceNON{rowi,coli}','range'))';
        coherence{rowi,coli} = (normalize(coherence{rowi,coli}','range'))';
    end
end

% find nan and make into 1x39 array
for rowi = 1:size(coherenceVTE,1)
    for coli = 1:size(coherenceVTE,2)
        if isnan(coherenceVTE{rowi,coli})
            coherenceVTE{rowi,coli}(1:39) = NaN;
        end
        if isnan(coherenceNON{rowi,coli})
            coherenceNON{rowi,coli}(1:39) = NaN;
        end        
        if isnan(coherence{rowi,coli})
            coherence{rowi,coli}(1:39) = NaN;
        end        
    end
end

% collapse controls
cohereColVTE(:,1) = cellcat(coherenceVTE(:,1:5),'vertcat','col');
cohereColVTE(:,2) = coherenceVTE(:,6);
cohereColNON(:,1) = cellcat(coherenceNON(:,1:5),'vertcat','col');
cohereColNON(:,2) = coherenceNON(:,6);

tempVar =[]; tempVar = cellfun2(cohereColVTE(:,1),'nanmean',{'1'});
tempVar2 =[]; tempVar2 = cellfun2(cohereColNON(:,1),'nanmean',{'1'});

contColVTE = vertcat(tempVar{:});
muscColVTE = vertcat(cohereColVTE{:,2});
contColNON = vertcat(tempVar2{:});
muscColNON = vertcat(cohereColNON{:,2});
          
% rats2rem
rats2remVTE = [7];
rats2remNON = [1:2];

contColVTE(rats2remVTE,:)=NaN;
muscColVTE(rats2remVTE,:)=NaN;
contColNON(rats2remNON,:)=NaN;
muscColNON(rats2remNON,:)=NaN;

f = [1:.5:20];

figure('color','w')
hold on;
shadedErrorBar(f,nanmean(contColVTE,1),stderr(contColVTE,1),'k',0)
shadedErrorBar(f,nanmean(muscColVTE,1),stderr(muscColVTE,1),'r',0)
%xlim([4 12])
title('VTE')
xlim([1 20])
ylabel('Normalized Coherence')
xlabel('Frequency (Hz)')

figure('color','w')
hold on;
shadedErrorBar(f,nanmean(contColNON,1),stderr(contColNON,1),'k',0)
shadedErrorBar(f,nanmean(muscColNON,1),stderr(muscColNON,1),'r',0)
%xlim([4 12])
title('non-VTE')
xlim([1 20])
ylabel('Normalized Coherence')
xlabel('Frequency (Hz)')

% get theta and generate bar graphs
% average across frequencies, then across rats
thetaF = find(f > 5 & f < 10);
for rowi = 1:size(cohereColVTE,1)
    for coli = 1:size(cohereColVTE,2)
        cohereColVTEtheta(rowi,coli) = nanmean((nanmean(cohereColVTE{rowi,coli}(:,thetaF),2)),1);
    end
end
cohereColVTEtheta(3,:)=NaN; % after processing, this rat had no VTE lfp data
cohereColVTEtheta(rats2remVTE,:)=NaN; % this rat had 1 VTE trial

for rowi = 1:size(cohereColNON,1)
    for coli = 1:size(cohereColNON,2)
        cohereColNONtheta(rowi,coli) = nanmean((nanmean(cohereColNON{rowi,coli}(:,thetaF),2)),1);
    end
end
cohereColNONtheta(3,:)=NaN; % after processing, this rat had no lfp data
cohereColNONtheta(rats2remNON,:)=NaN;

% analysis
[h,p,ci,stat]=ttest(cohereColVTEtheta(:,1),cohereColVTEtheta(:,2))
d = computeCohen_d(cohereColVTEtheta(:,1),cohereColVTEtheta(:,2),'paired')

[h,p,ci,stat]=ttest(cohereColNONtheta(:,1),cohereColNONtheta(:,2))

% figures
c = [];
c = [1 1 0; 1 0 1; 0 1 1; 1 0 0; 0 1 0; 0 0 1;
0.2 1 0.6; 0.2 0.6 1; 1 0.2 0.6];
multiBarPlot(cohereColVTEtheta,[{'Controls'} {'Muscimol testing'}],'Norm. Theta Coherence','y',c)
ylim([0 .7])
multiBarPlot(cohereColNONtheta,[{'Controls'} {'Muscimol testing'}],'Norm. Theta Coherence','y',c)
ylim([0 .7])

% correlation between time spent and coherence
load('data_timeSpentVTE')
c = [];
c = [1 1 0; 1 0 1; 0 1 1; 1 0 0; 0 1 0; 0 0 1;
0.2 1 0.6; 0.2 0.6 1; 1 0.2 0.6];
multiBarPlot(tsVTEcolAvg,[{'Controls'} {'Muscimol testing'}],'TS (sec) on VTE','y',c)
[h,p,ci,stat]=ttest(tsVTEcolAvg(:,1),tsVTEcolAvg(:,2))

corrData = [];
corrData{1} = cohereColVTEtheta(:);
corrData{2} = tsVTEcolAvg(:);

% remove nan
idxRem = find(isnan(corrData{1})==1);
corrData{1}(idxRem)=[];
corrData{2}(idxRem)=[];

figure('color','w')
s1=scatter(corrData{1},corrData{2});
s1.MarkerEdgeColor = 'k';
s1.MarkerFaceColor = [0.6 0.6 0.6];
lsline
ylabel('Time spent on VTE (sec)')
xlabel('Norm. theta coherence')
[r,p]=corrcoef(corrData{1},corrData{2})


c = repmat([0.6 0.6 0.6],[7 1]);
c2 = repmat([1 0 0],[7 1]);
cc = vertcat(c,c2);
figure('color','w')
s1=scatter(corrData{1},corrData{2},[],cc,'filled');
s1.MarkerEdgeColor = 'k';
lsline
ylabel('Time spent on VTE (sec)')
xlabel('Norm. theta coherence')
[r,p]=corrcoef(corrData{1}(1:7),corrData{2}(1:7))
[r,p]=corrcoef(corrData{1}(8:14),corrData{2}(8:14))

figure('color','w')
scatter(corrData{1},corrData{2},[],cc,'filled'); hold on;
plot(corrData{1}(1:7),corrData{2}(1:7),'Marker','o','Color',[.6 .6 .6],'LineStyle','none')
plot(corrData{1}(8:14),corrData{2}(8:14),'Marker','o','Color','r','LineStyle','none')
lsline
%plot(corrData{1},corrData{2},'Marker','o','LineStyle','none');



load('data_pVTE_mat')
colVTE{1} = (nanmean(propVTE(:,1:5),2))*100;
colVTE{2} = (propVTE(:,6))*100;
colVTE2 = vertcat(colVTE{:});
colVTE2(idxRem)=[];

figure('color','w')
s1=scatter(colVTE2,corrData{1},[],cc,'filled');
s1.MarkerEdgeColor = 'k';
lsline
ylabel('Time spent on VTE (sec)')
xlabel('Norm. theta coherence')
[r,p]=corrcoef(colVTE2,corrData{1})
