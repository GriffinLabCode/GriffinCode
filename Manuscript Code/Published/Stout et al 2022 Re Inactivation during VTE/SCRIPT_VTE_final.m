%% some preperation steps
% VTE = pause and reorienting behaviors
% this includes simple pausing, then choosing (Hu and Amsel, Redish)
% and the iconic head sweeping.

clear; clc; %close all;
place2store = getCurrentPath();
addpath(place2store)

%% get VTE data
load('data_oopsTrialsVTE_step1');
load('data_oopsTrialsVTE_step2');
load('data_behavior');
load('data_vte_step2');
load('data_remove');

% manually select this
combineVTE = 1;
oops  = 0;
idphi = 0;

% main Datafolder
Datafolders   = 'X:\01.Experiments\RERh Inactivation Recording';

% int name and vt name
int_name     = 'Int_2022_corrected';  % Int_JS_fixed
vt_name      = 'VT1.mat';
missing_data = 'interp'; % interpolate missing data

% rats
rats{1} = 'Usher';
rats{2} = 'Rick';
rats{3} = 'Ratticus';
rats{4} = 'Ratdle'; % Ratdle excluded, see above
rats{5} = 'Eric2';
rats{6} = 'rat1422';
rats{7} = 'Morty';
rats{8} = 'rat2114';
rats{9} = 'rat2116';

% color map
c = [];
c = [1 1 0; 1 0 1; 0 1 1; 1 0 0; 0 1 0; 0 0 1;
0.2 1 0.6; 0.2 0.6 1; 1 0.2 0.6];

% condition
Day_cond{1} = 'Saline';
Day_cond{2} = 'Muscimol';
Day_cond{3} = 'Baseline';

% infusion treatment
infusion{1} = '\Baseline';
infusion{2} = '\Saline';
infusion{3} = '\Muscimol'; % within day infusion

%% ACCOUNT for trials removed
for rati = 1:length(rats)
    % get condition, then randomize the order
    cond = fieldnames(oopsTrials.(rats{rati}));
    for condi = 1:length(cond)
        % get session, then randomize the order
        sess = fieldnames(oopsTrials.(rats{rati}).(cond{condi}));
        for sessi = 1:length(sess)
            remData = [];
            remData = remTrials.(rats{rati}).(cond{condi}).(sess{sessi});

            % account for trials to remove 
            % for idphi data, this was already done. But not for other
            % variables. remData refers to trajectories to remove, so
            % the choice is N-1. 
            % this is complicated. Essentially, I grabbed the Int file,
            % but in doing so, did not account for trials removed when
            % getting VTE data
            
            % I cannot remove data, I must set them to nan. Those variables
            % with this already removed must be fixed
            accuracy.(rats{rati}).(cond{condi}).(sess{sessi})(remData)=NaN;
            turnDirection.(rats{rati}).(cond{condi}).(sess{sessi})(remData)=NaN;
            timeSpent_CP.(rats{rati}).(cond{condi}).(sess{sessi})(remData)=NaN;
            
            for i = 1:length(remData)
                idxtemp = [];
                idxtemp = 1:remData(i)-1;
                vartemp1 = [];
                vartemp1 = oopsTrials.(rats{rati}).(cond{condi}).(sess{sessi});
            
                datasplit1 = [];
                datasplit1 = vartemp1(idxtemp);
                datasplit2 = [];
                datasplit2 = vartemp1(remData(i):end);
                
                % add in missing data, then piece it back together
                datasplit1(end+1) = NaN;
                % merge
                oopsTrials.(rats{rati}).(cond{condi}).(sess{sessi}) = [];
                oopsTrials.(rats{rati}).(cond{condi}).(sess{sessi}) = horzcat(datasplit1,datasplit2);
               
                % do the same for zidphi
                vartemp1 = [];
                vartemp1 = zIdPhi.(rats{rati}).(cond{condi}).(sess{sessi});
            
                datasplit1 = [];
                datasplit1 = vartemp1(idxtemp);
                datasplit2 = [];
                datasplit2 = vartemp1(remData(i):end);
                
                % add in missing data, then piece it back together
                datasplit1(end+1) = NaN;
                % merge
                zIdPhi.(rats{rati}).(cond{condi}).(sess{sessi}) = [];
                zIdPhi.(rats{rati}).(cond{condi}).(sess{sessi}) = horzcat(datasplit1,datasplit2);               
            end

       end
    end
end

%% 

combinedVTE = [];
if combineVTE == 1
    for rati = 1:length(rats)
        % get condition, then randomize the order
        cond = fieldnames(oopsTrials.(rats{rati}));
        cond = randsample(cond,3,'false');
        for condi = 1:length(cond)
            % get session, then randomize the order
            sess = fieldnames(oopsTrials.(rats{rati}).(cond{condi}));
            sess = randsample(sess,2,'false');
            for sessi = 1:length(sess)
                oopsData = []; idphiVTE = []; remData = []; accuracyData = [];
                remData = remTrials.(rats{rati}).(cond{condi}).(sess{sessi});
                oopsData = oopsTrials.(rats{rati}).(cond{condi}).(sess{sessi});
                idphiVTE = (zIdPhi.(rats{rati}).(cond{condi}).(sess{sessi}) > 0);
                
                % combine data
                combinedVTE.(rats{rati}).(cond{condi}).(sess{sessi}) = sum(vertcat(oopsData,idphiVTE));
            end
        end
    end
end
if combineVTE == 1
    dataVTE = combinedVTE;
    threshold = 1;
elseif oops == 1
    dataVTE = oopsTrials;
    threshold = 1;
elseif idphi == 1
    dataVTE = zIdPhi;
    threshold = 0;
end

%% clean up all variables
% whenever a nan existed, it means that the trial was neither a VTE nor a
% non-VTE. Therefore, it should not count as anything.
%rats = fieldnames(dataVTE);
for rati = 1:length(rats)
    cond = fieldnames(dataVTE.(rats{rati}));
    for condi = 1:length(cond)
        sess = fieldnames(dataVTE.(rats{rati}).(cond{condi}));
        for sessi = 1:length(sess)
            nanRem1 = []; nanRem2 = []; nanRem = [];
            nanRem1 = find(isnan(zIdPhi.(rats{rati}).(cond{condi}).(sess{sessi}))==1);
            nanRem2 = find(isnan(oopsTrials.(rats{rati}).(cond{condi}).(sess{sessi}))==1);
            nanRem = unique([nanRem1 nanRem2]);
            % replace as NaN
            dataVTE.(rats{rati}).(cond{condi}).(sess{sessi})(nanRem) = NaN;
        end
    end
end

%% proportion of VTE

% define a threshold
clear propVTE numVTE numVTE2
for rati = 1:length(rats)

    % get a percentage
    propVTE(rati,1) = (numel(find(dataVTE.(rats{rati}).Baseline.Baseline1(2:end) >= threshold)))/(numel(dataVTE.(rats{rati}).Baseline.Baseline1(2:end)));
    propVTE(rati,2) = (numel(find(dataVTE.(rats{rati}).Baseline.Baseline2(2:end)  >= threshold)))/ (numel(dataVTE.(rats{rati}).Baseline.Baseline2(2:end)));    
    propVTE(rati,3) = (numel(find(dataVTE.(rats{rati}).Saline.Baseline(2:end)  >= threshold)))/ (numel(dataVTE.(rats{rati}).Saline.Baseline(2:end)));
    propVTE(rati,4) = (numel(find(dataVTE.(rats{rati}).Saline.Saline(2:end)  >= threshold)))/(numel(dataVTE.(rats{rati}).Saline.Saline(2:end)));
    propVTE(rati,5) = (numel(find(dataVTE.(rats{rati}).Muscimol.Baseline(2:end) >= threshold)))/(numel(dataVTE.(rats{rati}).Muscimol.Baseline(2:end)));
    propVTE(rati,6) = (numel(find(dataVTE.(rats{rati}).Muscimol.Muscimol(2:end)  >= threshold)))/(numel(dataVTE.(rats{rati}).Muscimol.Muscimol(2:end)));  

    numVTE(rati,1) = (numel(find(dataVTE.(rats{rati}).Baseline.Baseline1(2:end) >= threshold)));
    numVTE(rati,2) = (numel(find(dataVTE.(rats{rati}).Baseline.Baseline2(2:end)  >= threshold)));    
    numVTE(rati,3) = (numel(find(dataVTE.(rats{rati}).Saline.Baseline(2:end)  >= threshold)));
    numVTE(rati,4) = (numel(find(dataVTE.(rats{rati}).Saline.Saline(2:end)  >= threshold)));
    numVTE(rati,5) = (numel(find(dataVTE.(rats{rati}).Muscimol.Baseline(2:end) >= threshold)));
    numVTE(rati,6) = (numel(find(dataVTE.(rats{rati}).Muscimol.Muscimol(2:end)  >= threshold)));      
    
    numNON(rati,1) = (numel(find(dataVTE.(rats{rati}).Baseline.Baseline1(2:end) == 0)));
    numNON(rati,2) = (numel(find(dataVTE.(rats{rati}).Baseline.Baseline2(2:end) ==0)));    
    numNON(rati,3) = (numel(find(dataVTE.(rats{rati}).Saline.Baseline(2:end)  ==0)));
    numNON(rati,4) = (numel(find(dataVTE.(rats{rati}).Saline.Saline(2:end)  ==0)));
    numNON(rati,5) = (numel(find(dataVTE.(rats{rati}).Muscimol.Baseline(2:end) ==0)));
    numNON(rati,6) = (numel(find(dataVTE.(rats{rati}).Muscimol.Muscimol(2:end)  ==0)));       
    
end

numVTE2(:,1) = sum(numVTE(:,1:5),2);
numVTE2(:,2) = (numVTE(:,6));
numNON2(:,1) = sum(numNON(:,1:5),2);
numNON2(:,2) = (numNON(:,6));

figure('color','w');
b = bar(numVTE2)
b(1).FaceColor = [0.6 0.6 0.6];
b(2).FaceColor = 'r';
box off;
ylabel('Number of VTE')
xlabel('Rat ID')
legend('Control','Muscimol')


figure('color','w');
b = bar(numNON2)
b(1).FaceColor = [0.6 0.6 0.6];
b(2).FaceColor = 'r';
box off;
ylabel('Number of non-VTE')
xlabel('Rat ID')
legend('Control','Muscimol')

% difference score normalized
diffpVTE = [];
diffpVTE{1} = (propVTE(:,2)-propVTE(:,1))./(propVTE(:,1)+propVTE(:,2));
diffpVTE{2} = (propVTE(:,4)-propVTE(:,3))./(propVTE(:,3)+propVTE(:,4));
diffpVTE{3} = (propVTE(:,6)-propVTE(:,5))./(propVTE(:,6)+propVTE(:,5));
multiBarPlot(diffpVTE,[{'No Inf'} {'Saline'} {'Muscimol'}],'pVTE (Testing-Baseline)','y',c)
[h,pI,ciI,statI] = ttest(diffpVTE{1},0)
[h,pS,ciS,statS] = ttest(diffpVTE{2},0)
[h,pM,ciM,statM] = ttest(diffpVTE{3},0)

% run repeated measures anova in R, but in long format
conditions = [];
conditions = [conditions; cellstr(repmat('noInf',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Saline',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Muscimol',[length(rats) 1]))];

table_pVTE = table(horzcat(rats,rats,rats)',conditions,vertcat(diffpVTE{:}),...
    'VariableNames',{'Rats','Conditions','pVTE'});
cd(place2store);
writetable(table_pVTE,'data_pVTE_R.csv');


cd('X:\07. Manuscripts\In preparation\VTE and ReRh suppression - Scientific Reports\Second Submission\Experiment 1\Behavior figures')
save('data_pVTE','diffpVTE','propVTE','pI','pS','pM','ciI','ciS','ciM','statI','statS','statM')


%set(gcf,'Renderer', 'painters', 'Position', [250 250 250 250])
%title('Head-sweep VTE events')
%print -painters -depsc fig_pVTE_headSweep.eps
%savefig('fig_pVTE_headSweep.fig')
%{
% run repeated measures anova in R, but in long format
conditions = [];
conditions = [conditions; cellstr(repmat('noInf',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Saline',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Muscimol',[length(rats) 1]))];

table_pVTE = table(horzcat(rats',rats',rats')',conditions,vertcat(diffpVTE{:}),...
    'VariableNames',{'Rats','Conditions','pVTE'});
cd(place2store);
writetable(table_pVTE,'data_pVTE_R.csv');
%}
%% Fig. 2C
percent_accurate=[];
for rati = 1:length(rats)    
    % get performance
    percent_accurate(rati,1) = performance_accuracy.(rats{rati}).Baseline.Baseline1;
    percent_accurate(rati,2) = performance_accuracy.(rats{rati}).Baseline.Baseline2;
    percent_accurate(rati,3) = performance_accuracy.(rats{rati}).Saline.Baseline;
    percent_accurate(rati,4) = performance_accuracy.(rats{rati}).Saline.Saline;
    percent_accurate(rati,5) = performance_accuracy.(rats{rati}).Muscimol.Baseline;
    percent_accurate(rati,6) = performance_accuracy.(rats{rati}).Muscimol.Muscimol;    
end

% difference score
diffAcc = normDiffScore(percent_accurate);
data = []; data{1} = diffAcc(:,1); data{2} = diffAcc(:,2); data{3} = diffAcc(:,3);
multiBarPlot(data,[{'No Inf'} {'Saline'} {'Muscimol'}],'% accurate (Testing-Baseline)','y',c)
[h,pI,ciI,statI] = ttest(data{1},0)
[h,pS,ciS,statS] = ttest(data{2},0)
[h,pM,ciM,statM] = ttest(data{3},0)
cd('X:\07. Manuscripts\In preparation\VTE and ReRh suppression - Scientific Reports\Second Submission\Experiment 1\Behavior figures')
save('data_choiceAccuracy','data','diffAcc','percent_accurate','pI','pS','pM','ciI','ciS','ciM','statI','statS','statM')

conditions = [];
conditions = [conditions; cellstr(repmat('noInf',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Saline',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Muscimol',[length(rats) 1]))];
table_Acc = table(horzcat(rats,rats,rats)',conditions,(diffAcc(:)),...
    'VariableNames',{'Rats','Conditions','acc'});
cd(place2store);
writetable(table_Acc,'data_acc_R.csv');



turningBias=[]; 
for rati = 1:length(rats)    
    % get perveration data
    turningBias(rati,1) = turnBias.(rats{rati}).Baseline.Baseline1;
    turningBias(rati,2) = turnBias.(rats{rati}).Baseline.Baseline2;
    turningBias(rati,3) = turnBias.(rats{rati}).Saline.Baseline;
    turningBias(rati,4) = turnBias.(rats{rati}).Saline.Saline;
    turningBias(rati,5) = turnBias.(rats{rati}).Muscimol.Baseline;
    turningBias(rati,6) = turnBias.(rats{rati}).Muscimol.Muscimol;    
end

% difference score
diffBias = normDiffScore(turningBias);
data = []; data{1} = diffBias(:,1); data{2} = diffBias(:,2); data{3} = diffBias(:,3);
multiBarPlot(data,[{'No Inf'} {'Saline'} {'Muscimol'}],'% bias (Testing-Baseline)','y',c)
[h,pI,ciI,statI] = ttest(data{1},0);
[h,pS,ciS,statS] = ttest(data{2},0);
[h,pM,ciM,statM] = ttest(data{3},0);
cd('X:\07. Manuscripts\In preparation\VTE and ReRh suppression - Scientific Reports\Second Submission\Experiment 1\Behavior figures')
save('data_turnBias','turningBias','diffBias','data','pI','pS','pM','ciI','ciS','ciM','statI','statS','statM')

conditions = [];
conditions = [conditions; cellstr(repmat('noInf',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Saline',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Muscimol',[length(rats) 1]))];

table_persev = table(horzcat(rats,rats,rats)',conditions,diffBias(:),...
    'VariableNames',{'Rats','Conditions','persev'});
cd(place2store);
writetable(table_persev,'data_bias_R.csv');

%% Fig 2F and 2H setup
% use traj_change and vte variables. However, make sure you only look at
% the vte variables from trial 2 and on. This is because traj_change is the
% quantification of left/rights, so you inherintly lose a trial
% (specifically the first one). Think of it this way, how can you have an
% alternation value on the first trial? Alternation estimates like
% perseveration depend on the previous trajectory.
% IMPORTANT: a "1" indicates an alternation in the traj_change variable. a
% "0" indicates a perseveration

VTE_accuracy = []; remTrial = [];
for rati = 1:length(rats)    
 
    VTE_accuracy{rati,1} = [dataVTE.(rats{rati}).Baseline.Baseline1(2:end)',accuracy.(rats{rati}).Baseline.Baseline1(2:end)];
    VTE_accuracy{rati,2} = [dataVTE.(rats{rati}).Baseline.Baseline2(2:end)',accuracy.(rats{rati}).Baseline.Baseline2(2:end)];
    VTE_accuracy{rati,3} = [dataVTE.(rats{rati}).Saline.Baseline(2:end)',accuracy.(rats{rati}).Saline.Baseline(2:end)];
    VTE_accuracy{rati,4} = [dataVTE.(rats{rati}).Saline.Saline(2:end)',accuracy.(rats{rati}).Saline.Saline(2:end)];
    VTE_accuracy{rati,5} = [dataVTE.(rats{rati}).Muscimol.Baseline(2:end)',accuracy.(rats{rati}).Muscimol.Baseline(2:end)];
    VTE_accuracy{rati,6} = [dataVTE.(rats{rati}).Muscimol.Muscimol(2:end)',accuracy.(rats{rati}).Muscimol.Muscimol(2:end)];
    
end

% analysis below requires that 0 = incorrect, 1 = correct
for rowi = 1:size(VTE_accuracy,1)
    for coli = 1:size(VTE_accuracy,2)
        idx0 = find(VTE_accuracy{rowi,coli}(:,2)==0);
        idx1 = find(VTE_accuracy{rowi,coli}(:,2)==1);
        % flip flop
        VTE_accuracy{rowi,coli}(idx0,2) = 1;
        VTE_accuracy{rowi,coli}(idx1,2) = 0;
    end
end

VTE_accuracyCol = [];
VTE_accuracyCol = (cellcat(VTE_accuracy(:,1:5),'vertcat','col'))';
VTE_accuracyCol(:,2) = VTE_accuracy(:,6);
percAccVTE = []; percAccNON = [];
for rowi = 1:size(VTE_accuracyCol,1)
    for coli = 1:size(VTE_accuracyCol,2)
        idxVTE = find(VTE_accuracyCol{rowi,coli}(:,1) >= threshold); 
        % not sure why, but I used find in first half, then logical
        % indexing on second half. Whats here is correct, it just looks
        % funny at first sight
        percAccVTE(rowi,coli) = (numel(find(VTE_accuracyCol{rowi,coli}(idxVTE,2)==1))/numel(VTE_accuracyCol{rowi,coli}(idxVTE,2)==1))*100;
    end
end

% remove rat 7 bc he only contributed 1 trial
percAccVTE(7,:)=[];
% we have to collapse our sessions
cVTE= c;
cVTE(7,:)=[];
[h,p,ci,stat]=ttest(percAccVTE(:,1),percAccVTE(:,2))
multiBarPlot(percAccVTE,[{'Controls'} {'Muscimol Testing'}],'% Accurate on VTE','y',cVTE)
d = computeCohen_d(percAccVTE(:,1),percAccVTE(:,2),'paired')

% there are way more non-VTE so we can use anova
percAccNON = [];
for rowi = 1:size(VTE_accuracy,1)
    for coli = 1:size(VTE_accuracy,2)
        idxNON = find(VTE_accuracy{rowi,coli}(:,1) < threshold);   
        percAccNON(rowi,coli) = (numel(find(VTE_accuracy{rowi,coli}(idxNON,2)==1))/numel(VTE_accuracy{rowi,coli}(idxNON,2)==1))*100;   
    end
end

% remove rats based on condition if they have NaN
noInfNan    = find(isnan(percAccNON(:,1))==1 | isnan(percAccNON(:,2))==1);
SalineNan   = find(isnan(percAccNON(:,3))==1 | isnan(percAccNON(:,4))==1);
MuscimolNan = find(isnan(percAccNON(:,5))==1 | isnan(percAccNON(:,6))==1);

dataPlot = [];
dataPlot{1} = (percAccNON(:,2)-percAccNON(:,1))./(percAccNON(:,2)+percAccNON(:,1));
dataPlot{2} = (percAccNON(:,4)-percAccNON(:,3))./(percAccNON(:,4)+percAccNON(:,3));
dataPlot{3} = (percAccNON(:,6)-percAccNON(:,5))./(percAccNON(:,6)+percAccNON(:,5));
multiBarPlot(dataPlot,[{'NoIn'} {'Sal'} {'Musc'}],'% Correct on nonVTE (Testing-Baseline)','y',c)
cd('X:\07. Manuscripts\In preparation\VTE and ReRh suppression - Scientific Reports\Second Submission\Experiment 1\Behavior figures')
save('data_nonVTE_choiceAccuracy','percAccNON','dataPlot','pI','pS','pM','ciI','ciS','ciM','statI','statS','statM')

accNONmat = horzcat(dataPlot{:});

idxNaN = [];
for i = 1:size(accNONmat,2)
    idxNaN{i} = find(isnan(accNONmat(:,i)));
end
idxNaN = unique(vertcat(idxNaN{:}));
accNONmat(idxNaN,:)=[];
ratsNew = rats;
ratsNew(idxNaN)=[];
accNONmatOG = accNONmat;
accNONmat = accNONmat(:);

conditions = [];
conditions = [conditions; cellstr(repmat('noInf',[length(ratsNew) 1]))];
conditions = [conditions; cellstr(repmat('Saline',[length(ratsNew) 1]))];
conditions = [conditions; cellstr(repmat('Muscimol',[length(ratsNew) 1]))];

table_accNON = table(horzcat(ratsNew,ratsNew,ratsNew)',conditions,accNONmat,...
    'VariableNames',{'Rats','Conditions','accNON'});
cd(place2store);
writetable(table_accNON,'data_accNON_R.csv');

cNON = c;
cNON(1:2,:)=[];
[h,p,ci,stat] = ttest(accNONmatOG,0)
multiBarPlot(accNONmatOG,[{'No Infusion'} {'Saline'} {'Muscimol'}],'Testing-Baseline','y',cNON)
d = computeCohen_d(percAccNON(:,5),percAccNON(:,6),'paired')

%% Learning figure
persevCount = [];
for rowi = 1:size(VTE_accuracy,1)
    for coli = 1:size(VTE_accuracy,2)
        tempData = [];
        tempData = VTE_accuracy{rowi,coli};
        % identify persevs (2 choice errors in a row = 1 count)
        for triali = 1:size(tempData,1)-1
            % by extracting [error]->error, we know exactly what the
            % current VTE will lead to, an error. Thus, its a rich case of
            % perseveration
            if tempData(triali,2) == 0 && tempData(triali+1,2) == 0 %tempData(triali,2) == 0 && tempData(triali+1,2) == 0
                persevCount{rowi,coli}(triali,1) = 1; % perseveration
                persevCount{rowi,coli}(triali,2) = tempData(triali,1); % VTE data
            else
                persevCount{rowi,coli}(triali,1) = 0;
                persevCount{rowi,coli}(triali,2) = tempData(triali,1); % VTE data                
            end
        end
    end
end

% first identify prop of persevs
for rowi = 1:size(persevCount,1)
    for coli = 1:size(persevCount,2)
        pPersev(rowi,coli) = nanmean(persevCount{rowi,coli}(:,1))*100;
    end
end                
pPersevDiff(:,1) = pPersev(:,2)-pPersev(:,1);  
pPersevDiff(:,2) = pPersev(:,4)-pPersev(:,3);  
pPersevDiff(:,3) = pPersev(:,6)-pPersev(:,5);  
[h,p,ci,stat] = ttest(pPersevDiff,0)
d = computeCohen_d(pPersev(:,5),pPersev(:,6),'paired')

multiBarPlot(pPersevDiff,[{'No inf'} {'Saline'} {'Muscimol'}],'% Perseveration','y',c)

conditions = [];
conditions = [conditions; cellstr(repmat('noInf',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Saline',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Muscimol',[length(rats) 1]))];

table_persev = table(horzcat(rats,rats,rats)',conditions,pPersevDiff(:),...
    'VariableNames',{'Rats','Conditions','persev'});
cd(place2store);
writetable(table_persev,'data_persev_R.csv');


pPersevCont = nanmean(pPersev(:,1:5),2)
figure('color','w')
subplot 121;
b = bar([pPersevCont(1),pPersev(1,6)])
%b(1).FaceColor = [0.6 0.6 0.6];
%b(2).FaceColor = 'r';
box off
subplot 122;
    b = bar([nanmean(propVTE(1,1:5),2)*100,propVTE(1,6)*100])
box off

% ---- %

multiBarPlot(pPersevDiff,[{'No inf'} {'Saline'} {'Muscimol'}],'% Perseveration','y',c)

[h,p,ci,stat]=ttest(pPersevDiff(:,3),0); 
d = computeCohen_d(pPersev(:,6),pPersev(:,5),'paired')

%
[h,p]=ttest(pPersevDiff(:,2),0)
[h,p]=ttest(pPersevDiff(:,1),0)
             
% pVTE on persevs - need to collapse for controls
clear persevCount2
persevCount2(:,1) = cellcat(persevCount(:,1:5),'vertcat','col');
persevCount2(:,2) = persevCount(:,6);

pVTEpersev = []; pNONpersev = [];
for rowi = 1:size(persevCount2,1)
    for coli = 1:size(persevCount2,2)
        % identify perseveration
        idxPersev = [];
        idxPersev = find(persevCount2{rowi,coli}(:,1) == 1);
        % perseverations
        tempPersev2vte = [];
        tempPersev2vte = persevCount2{rowi,coli}(idxPersev,2); % column 2 is VTE where 1/2 = VTE and 0=nonVTE
        % % persev on VTE and persevs that were nonVTE
        pVTEpersev(rowi,coli) = (numel(find(tempPersev2vte > 0))/(numel(tempPersev2vte)))*100;
        pNONpersev(rowi,coli) = (numel(find(tempPersev2vte == 0))/(numel(tempPersev2vte)))*100;
    end
end
pVTEpersev(7,:)=NaN;
pNONpersev(1:2,:)=NaN;

% do they persev more on VTE or nonVTE?
data2plot = [];
data2plot{1} = [normDiffScore(pVTEpersev)]
data2plot{2} = [normDiffScore(pNONpersev)];
multiBarPlot(data2plot,[{'% VTE+persev'} {'% nonVTE+persev'}],'% trials (muscimol-control)','y',c);
[h,p,ci,stat] = ttest(data2plot{1},0)
[h,p,ci,stat] = ttest(data2plot{2},0)
[h,p,ci,stat]=ttest(data2plot{1},data2plot{2})

d = computeCohen_d(pVTEpersev(:,1),pVTEpersev(:,2),'paired')

% visualize all data
data2plot = [];
data2plot{1} = pVTEpersev(:,1);
data2plot{2} = pVTEpersev(:,2);
data2plot{3} = pNONpersev(:,1);
data2plot{4} = pNONpersev(:,2);
multiBarPlot(data2plot,[{'VTE control'} {'VTE muscimol'} {'non control'} {'non muscimol'}],'% perseverations that are...','y',c);

%{
% VTE nonVTE and perseveration
data2plot = [];
data2plot = horzcat(pVTEpersev,pNONpersev);
multiBarPlot(data2plot,[{'Con VTE'} {'Mus VTE'} {'Con nonVTE'} {'Mus nonVTE'}],'% Perseveration','y',c);

conditions = [];
conditions = [conditions; cellstr(repmat('Control',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Muscimol',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Control',[length(rats) 1]))];
conditions = [conditions; cellstr(repmat('Muscimol',[length(rats) 1]))];

behavior = [];
behavior = [behavior; cellstr(repmat('VTE',[length(rats) 1]))];
behavior = [behavior; cellstr(repmat('VTE',[length(rats) 1]))];
behavior = [behavior; cellstr(repmat('non',[length(rats) 1]))];
behavior = [behavior; cellstr(repmat('non',[length(rats) 1]))];

persevBehavior = [];
persevBehavior = data2plot(:);

table_persevBehavior = table(horzcat(rats,rats,rats,rats)',conditions,behavior,...
    persevBehavior,'VariableNames',{'Rats','Conditions','Behavior','perseveration'});

cd(place2store);
writetable(table_persevBehavior,'data_persevBeh_R.csv');
%}


%% compare to early learning data

% SA

%  CD Day 1 data 
array_day1_CA = {};
array_day1_CA{1,1} = [1,0,1,0,0,0,1,1,0,0,1,0,0,0,1,0,1,1,0,0,0,1,0,1,1,1,0,0,0,1,0,1,0,0,0,1,1,0,0,1];
array_day1_CA{2,1} = [0,0,1,1,1,0,0,0,0,1,0,1,0,1,1,1,1,0,1,0,1,1,1,1,0,0,1,0,1,0,1,0,0,1,1,0,0,0,0,1];
array_day1_CA{3,1} = [1,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,1,0,0,1,1,0,0,1,1,0,0,0,0,1,1,0,0];
array_day1_CA{4,1} = [0,0,0,0,0,0,1,0,1,0,1,1,0,0,1,0,0,0,0,0,1,1,0,0,0,0,1,0,1,1,0,1,0,1,0,0,1,0,1,0];
array_day1_CA{5,1} = [NaN,1,0,0,1,0,0,1,0,0,1,0,1,1,0,0,0,0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,1];
array_day1_CA{6,1} = [0,0,0,1,0,1,0,0,1,1,0,0,1,1,0,1,0,1,0,1,0,0,1,1,1,1,1,0,0,1,1,1,0,0,1,1,1,1,1,1];
array_day1_CA{7,1} = [NaN,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0];
array_day1_CA{8,1} = [0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,1,0,1,1,1,1,1,0,0,1,1,1,1,1,1,0,0,1,1,1,0];
%remove NaN values (theres a NaN in col 1 so every 1st val must be removed)(this is not the most efficient way to do it...)
for x = 1:size(array_day1_CA,1)
    array_day1_CA{x,1}(1) = [];
end
for rowi = 1:size(array_day1_CA,1)
    for coli = 1:size(array_day1_CA,2)
        array_day1_CA{rowi,coli} = array_day1_CA{rowi,coli}';
    end
end

persevCountCA = [];
for rowi = 1:size(array_day1_CA,1)
    for coli = 1:size(array_day1_CA,2)
        tempData = [];
        tempData = array_day1_CA{rowi,coli};
        % identify persevs (2 choice errors in a row = 1 count)
        for triali = 2:size(array_day1_CA{rowi,coli},1)-1
            if tempData(triali) == 1 && tempData(triali+1) == 1
                persevCountCA{rowi,coli}(triali) = 1; % choice accuracy
            else
                persevCountCA{rowi,coli}(triali) = 0;
            end
        end
    end
end
persevCountCA_avg = (cellfun(@nanmean,persevCountCA))*100;



%  DA Day 1 data
array_day1_DA = {};
array_day1_DA{1,1} = [0,0,1,0,0,1,0,1,0,0,0,0];
array_day1_DA{2,1} = [0,0,1,1,0,0,0,0,0,0,1,0];
array_day1_DA{3,1} = [0,0,0,0,0,1,0,0,0,0,0,0];
array_day1_DA{4,1} = [0,0,1,0,0,0,0,0,0,0,1,1];
array_day1_DA{5,1} = [1,1,0,0,0,1,0,0,1,0,1,0];
array_day1_DA{6,1} = [0,0,0,1,1,0,0,0,0,0,0,0];
array_day1_DA{7,1} = [0,0,0,0,0,0,0,1,0,1,0,0];
array_day1_DA{8,1} = [1,0,0,0,1,0,1,0,0,0,0,1];
%array_day1_DA{9,1} = [0,0,0,1,0,0,0,0,0,0,1,0];
%array_day1_DA{10,1} = [0,0,0,0,1,0,0,0,0,0,0,1];
%array_day1_DA{11,1} = [0,0,1,0,0,1,0,0,0,0,0,0];
%array_day1_DA{12,1} = [0,0,0,0,0,0,0,0,0,0,1,1];

%orient
for rowi = 1:size(array_day1_DA,1)
    for coli = 1:size(array_day1_DA,2)
        array_day1_DA{rowi,coli} = array_day1_DA{rowi,coli}';
    end
end

persevCountDA = [];
for rowi = 1:size(array_day1_DA,1)
    for coli = 1:size(array_day1_DA,2)
        tempData = [];
        tempData = array_day1_DA{rowi,coli};
        % identify persevs (2 choice errors in a row = 1 count)
        for triali = 2:size(array_day1_DA{rowi,coli},1)-1
            if tempData(triali) == 1 && tempData(triali+1) == 1
                persevCountDA{rowi,coli}(triali) = 1; % choice accuracy
            else
                persevCountDA{rowi,coli}(triali) = 0;
            end
        end
    end
end
persevCountDA_avg = (cellfun(@nanmean,persevCountDA))*100;

diffPersevTasks = persevCountDA_avg-persevCountCA_avg;
multiBarPlot([persevCountCA_avg persevCountDA_avg],[{'CA'} {'DA'}],'% trials as perseveration','y')
[h,p,ci,stat]=ttest(persevCountDA_avg,persevCountCA_avg)
d = computeCohen_d(persevCountDA_avg,persevCountCA_avg,'paired')

data2plot = [];
data2plot{1} = persevCountCA_avg;
data2plot{2} = persevCountDA_avg;
data2plot{3} = pPersev(:,6);
multiBarPlot(data2plot,[{'day 1 ALT'} {'day 1 SWM'} {'muscimol'}],'% persev.','y')

[h,p,ci,stat]=ttest2(data2plot{1},data2plot{2})
[h,p,ci,stat]=ttest2(data2plot{1},data2plot{3})
[h,p,ci,stat]=ttest2(data2plot{2},data2plot{3})

%% visualizing all rats behavior

td = [];
for rati = 1:length(rats)    
    td{rati,1} = turnDirection.(rats{rati}).Baseline.Baseline1(2:end);
    td{rati,2} = turnDirection.(rats{rati}).Baseline.Baseline2(2:end);
    td{rati,3} = turnDirection.(rats{rati}).Saline.Baseline(2:end);
    td{rati,4} = turnDirection.(rats{rati}).Saline.Saline(2:end);
    td{rati,5} = turnDirection.(rats{rati}).Muscimol.Baseline(2:end);
    td{rati,6} = turnDirection.(rats{rati}).Muscimol.Muscimol(2:end);
    
    % error correction error    
    eCe(rati,1) = er_cor_er.(rats{rati}).Baseline.Baseline1;
    eCe(rati,2) = er_cor_er.(rats{rati}).Baseline.Baseline2;
    eCe(rati,3) = er_cor_er.(rats{rati}).Saline.Baseline;
    eCe(rati,4) = er_cor_er.(rats{rati}).Saline.Saline;
    eCe(rati,5) = er_cor_er.(rats{rati}).Muscimol.Baseline;
    eCe(rati,6) = er_cor_er.(rats{rati}).Muscimol.Muscimol;   
    
    ts{rati,1} = timeSpent_CP.(rats{rati}).Baseline.Baseline1(2:end);
    ts{rati,2} = timeSpent_CP.(rats{rati}).Baseline.Baseline2(2:end);
    ts{rati,3} = timeSpent_CP.(rats{rati}).Saline.Baseline(2:end);
    ts{rati,4} = timeSpent_CP.(rats{rati}).Saline.Saline(2:end);
    ts{rati,5} = timeSpent_CP.(rats{rati}).Muscimol.Baseline(2:end);
    ts{rati,6} = timeSpent_CP.(rats{rati}).Muscimol.Muscimol(2:end);    
end

% get time spent during VTE
for rowi = 1:size(ts,1)
    for coli = 1:size(ts,2)
        idxVTE = [];
        idxVTE = find(VTE_accuracy{rowi,coli}(:,1) >= threshold);
        % get ts
        tsVTE{rowi,coli} = ts{rowi,coli}(idxVTE);
    end
end
% collapse controls
clear tsVTEcol
tsVTEcol = cellcat(tsVTE(:,1:5),'vertcat','col')';
tsVTEcol(:,2) = tsVTE(:,6);

% to compare against LFP data, we must remove the same rats as we did in
% those analyses
clear tsVTEcolAvg
tsVTEcolAvg = cellfun(@nanmean,tsVTEcol);
tsVTEcolAvg([3,7],:)=NaN;
c = [];
c = [1 1 0; 1 0 1; 0 1 1; 1 0 0; 0 1 0; 0 0 1;
0.2 1 0.6; 0.2 0.6 1; 1 0.2 0.6];
multiBarPlot(tsVTEcolAvg,[{'Controls'} {'Muscimol testing'}],'TS (sec) on VTE','y',c)
[h,p,ci,stat]=ttest(tsVTEcolAvg(:,1),tsVTEcolAvg(:,2))
save('data_timeSpentVTE','tsVTEcolAvg')
