%% single unit analysis
clear;

data2load = 'data_mPFC_Choice_FRLvR_7bins';

% ~~ loading ~~ %
data_choice = split2Hz(data2load);

% get rates
fr_choice.rights_high = data_choice.FRdata.rights_More2Hz;
fr_choice.lefts_high  = data_choice.FRdata.lefts_More2Hz;
fr_choice.rights_low  = data_choice.FRdata.rights_Less2Hz;
fr_choice.lefts_low   = data_choice.FRdata.lefts_Less2Hz;

% get averages and sems
fr_choice.rights_highAvg = cellfun(@nanmean,fr_choice.rights_high,'UniformOutput',false);
fr_choice.lefts_highAvg  = cellfun(@nanmean,fr_choice.lefts_high,'UniformOutput',false);
fr_choice.rights_lowAvg  = cellfun(@nanmean,fr_choice.rights_low,'UniformOutput',false);
fr_choice.lefts_lowAvg   = cellfun(@nanmean,fr_choice.lefts_low,'UniformOutput',false);

% make sure to run startup to use stderr
fr_choice.rights_highSEM = cellfun(@stderr,fr_choice.rights_high,'UniformOutput',false);
fr_choice.lefts_highSEM  = cellfun(@stderr,fr_choice.lefts_high,'UniformOutput',false);
fr_choice.rights_lowSEM  = cellfun(@stderr,fr_choice.rights_low,'UniformOutput',false);
fr_choice.lefts_lowSEM   = cellfun(@stderr,fr_choice.lefts_low,'UniformOutput',false);

% two way analysis of variance (Ito et. al., 2015)
for i = 1:length(fr_choice.rights_high)
    clear anovaMat
    
    % find case with lower number of trials
    len1 = size(fr_choice.rights_high{i},1);
    len2 = size(fr_choice.lefts_high{i},1);
    
    % handle uneven number of observations
    if len1 == len2
        anovaMat = vertcat(fr_choice.rights_high{i},fr_choice.lefts_high{i});
    elseif len1 > len2 % use len 2 bc len 1 greater
        anovaMat = vertcat(fr_choice.rights_high{i}(1:len2,:),fr_choice.lefts_high{i}(1:len2,:));
    elseif len1 < len2 % use len 1 bc len 2 greater
        anovaMat = vertcat(fr_choice.rights_high{i}(1:len1,:),fr_choice.lefts_high{i}(1:len1,:));
    end    
    
    % replace NaNs with 0
    anovaMat(find(isnan(anovaMat)==1))=0;
    
    % two-way analysis of variance (Ito et al., 2015)
    [p,~,~] = anova2(anovaMat,size(anovaMat,1)/2,'off');
    
    % store data
    spatMod.high(i) = p(1);
    mainEff.high(i) = p(2);
    inteEff.high(i) = p(3);
end

% estimate the proportion of significantly modulated choice phase units
totalNum = numel(fr_choice.rights_highAvg);
sigMod   = unique(find(mainEff.high < 0.05 | inteEff.high < 0.05));
numMod   = numel(sigMod);
propMod  = (numMod/totalNum)*100;
propNot  = 100-propMod;

figure('color','w');
pie([propMod propNot])
title('High Rate')

% plot a sample figure - choice phase 9 and 55 are sig mod
neur_ID = 8;

figure('color','w'); hold on;
x_label = 1:7;
s1 = shadedErrorBar(x_label,fr_choice.rights_highAvg{neur_ID},fr_choice.rights_highSEM{neur_ID},'m',0)
s2 = shadedErrorBar(x_label,fr_choice.lefts_highAvg{neur_ID},fr_choice.lefts_highSEM{neur_ID},'b',0)
axis tight;
xlabel('Stem Bin')
ylabel('Avg. Firing Rate')
legend([s1.mainLine s2.mainLine],'Right Turn','Left Turn','location','SouthEast')


% low rate
for i = 1:length(fr_choice.rights_low)
    clear anovaMat
    
    % find case with lower number of trials
    len1 = size(fr_choice.rights_low{i},1);
    len2 = size(fr_choice.lefts_low{i},1);
    
    % handle uneven number of observations
    if len1 == len2
        anovaMat = vertcat(fr_choice.rights_low{i},fr_choice.lefts_low{i});
    elseif len1 > len2 % use len 2 bc len 1 greater
        anovaMat = vertcat(fr_choice.rights_low{i}(1:len2,:),fr_choice.lefts_low{i}(1:len2,:));
    elseif len1 < len2 % use len 1 bc len 2 greater
        anovaMat = vertcat(fr_choice.rights_low{i}(1:len1,:),fr_choice.lefts_low{i}(1:len1,:));
    end    
    
    % replace NaNs with 0
    anovaMat(find(isnan(anovaMat)==1))=0;
    
    % two-way analysis of variance (Ito et al., 2015)
    [p,~,~] = anova2(anovaMat,size(anovaMat,1)/2,'off');
    
    % store data
    spatMod.low(i) = p(1);
    mainEff.low(i) = p(2);
    inteEff.low(i) = p(3);
end

% estimate the proportion of significantly modulated choice phase units
totalNum = numel(fr_choice.rights_lowAvg);
sigModLow   = unique(find(mainEff.low < 0.05 | inteEff.low < 0.05));
numModLow   = numel(sigModLow);
propModLow  = (numModLow/totalNum)*100;
propNotLow  = 100-propModLow;

figure('color','w');
pie([propModLow propNotLow])
title('low rate pop')

% plot examples
neur_ID = 60;

figure('color','w'); hold on;
x_label = 1:7;
s1 = shadedErrorBar(x_label,fr_choice.rights_lowAvg{neur_ID},fr_choice.rights_lowSEM{neur_ID},'m',0)
s2 = shadedErrorBar(x_label,fr_choice.lefts_lowAvg{neur_ID},fr_choice.lefts_lowSEM{neur_ID},'b',0)
axis tight;
xlabel('Stem Bin')
ylabel('Avg. Firing Rate')
legend([s1.mainLine s2.mainLine],'Right Turn','Left Turn','location','SouthEast')
title('low rate')

%% prop sig mod during second bin and t-junction bin
% follow up t-tests were performed on the second and tjunction bin and
% alpha levels were corrected using Bonferronis method

% for t-tests, replace any nans with zeros

% define bonf correction
bonfCor = 0.05/2; % only running two t-tests (second stem bin and T-junction)

% first high rate neurons - only look at sig mod units
clear h p
for i = 1:length(sigMod)
        
    % replace nans with 0
    fr_choice.rights_high{i}(find(isnan(fr_choice.rights_high{sigMod(i)})==1))=0;
    fr_choice.lefts_high{i}(find(isnan(fr_choice.rights_high{sigMod(i)})==1))=0;
    
    % find case with lower number of trials
    len1 = size(fr_choice.rights_high{sigMod(i)},1);
    len2 = size(fr_choice.lefts_high{sigMod(i)},1);
    
    if len1 == len2    
        % second stem bin
        [h.second_high(i),p.second_high(i)] = ttest(fr_choice.rights_high{sigMod(i)}(:,2),fr_choice.lefts_high{sigMod(i)}(:,2),'alpha',bonfCor);
        % t-junction
        [h.tjun_high(i),p.tjun_high(i)] = ttest(fr_choice.rights_high{sigMod(i)}(:,7),fr_choice.lefts_high{sigMod(i)}(:,7),'alpha',bonfCor);
    elseif len1 > len2 % use len 2
        % second stem bin
        [h.second_high(i),p.second_high(i)] = ttest(fr_choice.rights_high{sigMod(i)}(1:len2,2),fr_choice.lefts_high{sigMod(i)}(1:len2,2),'alpha',bonfCor);
        % t-junction
        [h.tjun_high(i),p.tjun_high(i)] = ttest(fr_choice.rights_high{sigMod(i)}(1:len2,7),fr_choice.lefts_high{sigMod(i)}(1:len2,7),'alpha',bonfCor);        
    elseif len1 < len2 % use len 1
        % second stem bin
        [h.second_high(i),p.second_high(i)] = ttest(fr_choice.rights_high{sigMod(i)}(1:len1,2),fr_choice.lefts_high{sigMod(i)}(1:len1,2),'alpha',bonfCor);
        % t-junction
        [h.tjun_high(i),p.tjun_high(i)] = ttest(fr_choice.rights_high{sigMod(i)}(1:len1,7),fr_choice.lefts_high{sigMod(i)}(1:len1,7),'alpha',bonfCor);        
    end
end

for i = 1:length(sigModLow)
        
    % replace nans with 0
    fr_choice.rights_low{sigModLow(i)}(find(isnan(fr_choice.rights_low{sigModLow(i)})==1))=0;
    fr_choice.lefts_low{sigModLow(i)}(find(isnan(fr_choice.rights_low{sigModLow(i)})==1))=0;
    
    % find case with lower number of trials
    len1 = size(fr_choice.rights_low{sigModLow(i)},1);
    len2 = size(fr_choice.lefts_low{sigModLow(i)},1);
    
    if len1 == len2    
        % second stem bin
        [h.second_low(i),p.second_low(i)] = ttest(fr_choice.rights_low{sigModLow(i)}(:,2),fr_choice.lefts_low{sigModLow(i)}(:,2),'alpha',bonfCor);
        % t-junction
        [h.tjun_low(i),p.tjun_low(i)] = ttest(fr_choice.rights_low{sigModLow(i)}(:,7),fr_choice.lefts_low{sigModLow(i)}(:,7),'alpha',bonfCor);
    elseif len1 > len2 % use len 2
        % second stem bin
        [h.second_low(i),p.second_low(i)] = ttest(fr_choice.rights_low{sigModLow(i)}(1:len2,2),fr_choice.lefts_low{sigModLow(i)}(1:len2,2),'alpha',bonfCor);
        % t-junction
        [h.tjun_low(i),p.tjun_low(i)] = ttest(fr_choice.rights_low{sigModLow(i)}(1:len2,7),fr_choice.lefts_low{sigModLow(i)}(1:len2,7),'alpha',bonfCor);        
    elseif len1 < len2 % use len 1
        % second stem bin
        [h.second_low(i),p.second_low(i)] = ttest(fr_choice.rights_low{sigModLow(i)}(1:len1,2),fr_choice.lefts_low{sigModLow(i)}(1:len1,2),'alpha',bonfCor);
        % t-junction
        [h.tjun_low(i),p.tjun_low(i)] = ttest(fr_choice.rights_low{sigModLow(i)}(1:len1,7),fr_choice.lefts_low{sigModLow(i)}(1:len1,7),'alpha',bonfCor);        
    end
end

% ~~ make pie charts ~~ %

% high rate
totalHigh = numel(sigMod);
secModHigh = find(h.second_high == 1);
propHigh_sec = (numel(secModHigh)/totalHigh)*100;
propHigh_tjun = (numel(find(h.tjun_high == 1))/totalHigh)*100;

figure('color','w')
subplot 211
pie([propHigh_tjun, 100-propHigh_tjun])
title('Tjunction')
subplot 212
pie([propHigh_sec, 100-propHigh_sec])
title('Second Bin')

totalLow = numel(sigModLow);
secModLow = find(h.second_low == 1);
propLow_sec = (numel(secModLow)/totalLow)*100;
propLow_tjun = (numel(find(h.tjun_low == 1))/totalLow)*100;

figure('color','w')
subplot 211
pie([propLow_tjun, 100-propLow_tjun])
title('Tjunction')
subplot 212
pie([propLow_sec, 100-propLow_sec])
title('Second Bin')