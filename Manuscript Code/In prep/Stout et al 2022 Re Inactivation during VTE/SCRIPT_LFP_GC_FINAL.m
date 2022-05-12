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

% run GC to get bic value
orderRuns = 20; 
for rati = 1:length(rats)
    % get condition, then randomize the order
    cond = fieldnames(dataLFP.(rats{rati}));
    for condi = 1:length(cond)
        % get session, then randomize the order
        sess = fieldnames(dataLFP.(rats{rati}).(cond{condi}));
        for sessi = 1:length(sess)
            %tempHPCvte = []; tempPFCvte = [];
           % tempHPCnon = []; tempPFCnon = [];
            %tempHPCvte = GCy2xVTE.(rats{rati}).(cond{condi}).(sess{sessi}).choicePoint.hpc.vte;
            %tempPFCvte = GCy2xVTE.(rats{rati}).(cond{condi}).(sess{sessi}).choicePoint.pfc.vte;
            %tempHPCnon = GCy2xVTE.(rats{rati}).(cond{condi}).(sess{sessi}).choicePoint.hpc.non;
            %tempPFCnon = GCy2xVTE.(rats{rati}).(cond{condi}).(sess{sessi}).choicePoint.pfc.non;
            tempHPC = []; tempPFC = [];
            tempHPC = dataLFP.(rats{rati}).(cond{condi}).(sess{sessi}).choicePoint.hpc.all;
            tempPFC = dataLFP.(rats{rati}).(cond{condi}).(sess{sessi}).choicePoint.pfc.all;
                  
            if contains(rats{rati},[{'rat2114'} {'rat2116'}])
                srate = 2000;
            else
                srate = 2034;
            end
            
            [optimalorder{rati,condi}{sessi},bic_val{rati,condi}{sessi}] = bic_optimalorder(tempHPC',tempPFC',srate,orderRuns);
        end
    end
end


orderMat1 = [];
orderMat1 = vertcat(optimalorder{:});
orderMat2 = orderMat1(:);

figure('color','w'); hold on;
bar(nanmean(cell2mat(orderMat2)),'FaceColor',[0.6 0.6 0.6],'EdgeColor','k')
errorbar(nanmean(cell2mat(orderMat2)),stderr(cell2mat(orderMat2),1),'k');
ylabel('BIC')

orders = cell2mat(orderMat2);
order_time = orders*(1000/2034);

figure('color','w'); hold on;
bar(nanmean(order_time),'FaceColor',[0.6 0.6 0.6],'EdgeColor','k')
errorbar(nanmean(order_time),stderr(order_time,1),'k');
ylabel('Lag (sec)')

% set model order
moAvg = round(nanmean(orders));

% granger
GCy2xVTE = []; GCx2yVTE = [];
GCy2xNON = []; GCx2yNON = [];

for rati = 1:length(rats)
    % get condition, then randomize the order
    cond = fieldnames(dataLFP.(rats{rati}));
    for condi = 1:length(cond)
        % get session, then randomize the order
        sess = fieldnames(dataLFP.(rats{rati}).(cond{condi}));
        for sessi = 1:length(sess)
            tempHPCvte = []; tempPFCvte = [];
            tempHPCnon = []; tempPFCnon = [];
            tempHPCvte = dataLFP.(rats{rati}).(cond{condi}).(sess{sessi}).choicePoint.hpc.vte;
            tempPFCvte = dataLFP.(rats{rati}).(cond{condi}).(sess{sessi}).choicePoint.pfc.vte;
            tempHPCnon = dataLFP.(rats{rati}).(cond{condi}).(sess{sessi}).choicePoint.hpc.non;
            tempPFCnon = dataLFP.(rats{rati}).(cond{condi}).(sess{sessi}).choicePoint.pfc.non;
     
            if contains(rats{rati},[{'rat2114'} {'rat2116'}])
                srate = 2000;
            else
                srate = 2034;
            end
            
            % vte
            [GCy2xVTE.(rats{rati}).(cond{condi}).(sess{sessi}), GCx2yVTE.(rats{rati}).(cond{condi}).(sess{sessi}), frequencies] = GCspectral(tempHPCvte', tempPFCvte', moAvg, srate);
            % non vte
            [GCy2xNON.(rats{rati}).(cond{condi}).(sess{sessi}), GCx2yNON.(rats{rati}).(cond{condi}).(sess{sessi}), frequencies] = GCspectral(tempHPCnon', tempPFCnon', moAvg, srate);            
        
            if srate == 2000
                freq2000 = frequencies;
            else
                freq2034 = frequencies;
            end
        end
    end
    disp(['Finished with ',rats{rati}])
end

for rati = 1:length(rats)

   try pfc2hpcVTE{rati,1} = GCy2xVTE.(rats{rati}).Baseline.Baseline1; end
   try pfc2hpcNON{rati,1} = GCy2xNON.(rats{rati}).Baseline.Baseline1; end

   try pfc2hpcVTE{rati,2} = GCy2xVTE.(rats{rati}).Baseline.Baseline2; end
   try pfc2hpcNON{rati,2} = GCy2xNON.(rats{rati}).Baseline.Baseline2; end

   try pfc2hpcVTE{rati,3} = GCy2xVTE.(rats{rati}).Saline.Baseline; end
   try pfc2hpcNON{rati,3} = GCy2xNON.(rats{rati}).Saline.Baseline; end
    
   try pfc2hpcVTE{rati,4} = GCy2xVTE.(rats{rati}).Saline.Saline; end
   try pfc2hpcNON{rati,4} = GCy2xNON.(rats{rati}).Saline.Saline; end

   try pfc2hpcVTE{rati,5} = GCy2xVTE.(rats{rati}).Muscimol.Baseline; end
   try pfc2hpcNON{rati,5} = GCy2xNON.(rats{rati}).Muscimol.Baseline; end
    
   try pfc2hpcVTE{rati,6} = GCy2xVTE.(rats{rati}).Muscimol.Muscimol; end
   try pfc2hpcNON{rati,6} = GCy2xNON.(rats{rati}).Muscimol.Muscimol; end
   
    % -- HPC - -%
    
   try hpc2pfcVTE{rati,1} = GCx2yVTE.(rats{rati}).Baseline.Baseline1; end
   try hpc2pfcNON{rati,1} = GCx2yNON.(rats{rati}).Baseline.Baseline1; end

   try hpc2pfcVTE{rati,2} = GCx2yVTE.(rats{rati}).Baseline.Baseline2; end
   try hpc2pfcNON{rati,2} = GCx2yNON.(rats{rati}).Baseline.Baseline2; end

   try hpc2pfcVTE{rati,3} = GCx2yVTE.(rats{rati}).Saline.Baseline; end
   try hpc2pfcNON{rati,3} = GCx2yNON.(rats{rati}).Saline.Baseline; end
    
   try hpc2pfcVTE{rati,4} = GCx2yVTE.(rats{rati}).Saline.Saline; end
   try hpc2pfcNON{rati,4} = GCx2yNON.(rats{rati}).Saline.Saline; end

   try hpc2pfcVTE{rati,5} = GCx2yVTE.(rats{rati}).Muscimol.Baseline; end
   try hpc2pfcNON{rati,5} = GCx2yNON.(rats{rati}).Muscimol.Baseline; end
    
   try hpc2pfcVTE{rati,6} = GCx2yVTE.(rats{rati}).Muscimol.Muscimol; end
   try hpc2pfcNON{rati,6} = GCx2yNON.(rats{rati}).Muscimol.Muscimol; end
    
end

% now get data in theta range, and compute LI
for rowi = 1:size(hpc2pfcVTE,1)
    for coli = 1:size(hpc2pfcVTE,2)
        if length(hpc2pfcVTE{rowi,coli})==1001
            freq = freq2000;
        else
            freq = freq2034;
        end

        % get theta
        thetaIdx = [];
        thetaIdx = find(freq > 5 & freq < 10);
        
        % average
        try
            hpc2pfcVTE_theta(rowi,coli) = nanmean(hpc2pfcVTE{rowi,coli}(thetaIdx));
            pfc2hpcVTE_theta(rowi,coli) = nanmean(pfc2hpcVTE{rowi,coli}(thetaIdx));
        catch
            hpc2pfcVTE_theta(rowi,coli) = NaN;
            pfc2hpcVTE_theta(rowi,coli) = NaN;
        end
    end
end
        
for rowi = 1:size(hpc2pfcNON,1)
    for coli = 1:size(hpc2pfcNON,2)
        if length(hpc2pfcNON{rowi,coli})==1001
            freq = freq2000;
        else
            freq = freq2034;
        end

        % get theta
        thetaIdx = [];
        thetaIdx = find(freq > 5 & freq < 10);
        
        % average
        try
            hpc2pfcNON_theta(rowi,coli) = nanmean(hpc2pfcNON{rowi,coli}(thetaIdx));
            pfc2hpcNON_theta(rowi,coli) = nanmean(pfc2hpcNON{rowi,coli}(thetaIdx));
        catch
            hpc2pfcNON_theta(rowi,coli) = NaN;
            pfc2hpcNON_theta(rowi,coli) = NaN;
        end
    end
end

% remove appropriate rats
vte2rem = [3 7];
non2rem = [1:2];

hpc2pfcNON_theta(non2rem,:)=NaN;
pfc2hpcNON_theta(non2rem,:)=NaN;
hpc2pfcVTE_theta(vte2rem,:)=NaN;
pfc2hpcVTE_theta(vte2rem,:)=NaN;

% collapse across controls
hpc2pfcNON_con = nanmean(hpc2pfcNON_theta(:,1:5),2);
pfc2hpcNON_con = nanmean(pfc2hpcNON_theta(:,1:5),2);
hpc2pfcVTE_con = nanmean(hpc2pfcVTE_theta(:,1:5),2);
pfc2hpcVTE_con = nanmean(pfc2hpcVTE_theta(:,1:5),2);

hpc2pfcNON_mus = hpc2pfcNON_theta(:,6);
pfc2hpcNON_mus = pfc2hpcNON_theta(:,6);
hpc2pfcVTE_mus = hpc2pfcVTE_theta(:,6);
pfc2hpcVTE_mus = pfc2hpcVTE_theta(:,6);

% normalized difference
diffHPC2PFC_non = (hpc2pfcNON_mus-hpc2pfcNON_con)./(hpc2pfcNON_con+hpc2pfcNON_mus);
diffHPC2PFC_vte = (hpc2pfcVTE_mus-hpc2pfcVTE_con)./(hpc2pfcVTE_con+hpc2pfcVTE_mus);

diffPFC2HPC_non = (pfc2hpcNON_mus-pfc2hpcNON_con)./(pfc2hpcNON_con+pfc2hpcNON_mus);
diffPFC2HPC_vte = (pfc2hpcVTE_mus-pfc2hpcVTE_con)./(pfc2hpcVTE_con+pfc2hpcVTE_mus);

c = [];
c = [1 1 0; 1 0 1; 0 1 1; 1 0 0; 0 1 0; 0 0 1;
0.2 1 0.6; 0.2 0.6 1; 1 0.2 0.6];

multiBarPlot([diffHPC2PFC_vte diffHPC2PFC_non],[{'VTE'} {'non-VTE'}],'Norm Diff (testing-control)','y',c)
title('HPC to PFC')
[h,p,ci,stat]=ttest(diffHPC2PFC_vte,0)
[h,p,ci,stat]=ttest(diffHPC2PFC_non,0)
[h,p,ci,stat]=ttest(diffHPC2PFC_non,diffHPC2PFC_vte)


multiBarPlot([diffPFC2HPC_vte diffPFC2HPC_non],[{'VTE'} {'non-VTE'}],'Norm Diff (testing-control)','y',c)
title('PFC to HPC')
[h,p,ci,stat]=ttest(diffPFC2HPC_vte,0)
[h,p,ci,stat]=ttest(diffPFC2HPC_non,0)
[h,p,ci,stat]=ttest(diffPFC2HPC_vte,diffPFC2HPC_non)
computeCohen_d(diffPFC2HPC_vte,diffPFC2HPC_non,'paired')

multiBarPlot([pfc2hpcVTE_con pfc2hpcVTE_mus],[{'Controls'} {'Muscimol'}],'Granger Estimates (VTE)','y',c)
multiBarPlot([hpc2pfcVTE_con hpc2pfcVTE_mus],[{'Controls'} {'Muscimol'}],'Granger Estimates (VTE)','y',c)

