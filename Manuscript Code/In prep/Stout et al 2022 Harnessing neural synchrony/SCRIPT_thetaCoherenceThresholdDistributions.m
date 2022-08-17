%% generate threshold distributions
place2store = getCurrentPath();
cd(place2store);
load('data_ratThetaCohDistributions');

% formatting....
cohSB_cache = cohSB_cache_all;

for i = 1:length(cohSB_cache)
    cohSB_cache{i}.clean_cXf_mat_all = vertcat(cohSB_cache{i}.clean_cXf_mat{:});
    cohSB_cache{i}.dirty_cXf_mat_all = vertcat(cohSB_cache{i}.dirty_cXf_mat{:});
end

% frequencies
ftheta     = [6 11];
idxTheta   = find(f > 6 & f < 11);
idxDelta   = find(f > 1 & f <  4);

% use this variable ->>>> cohSB_cache{1, 1}.clean_cXf_mat
deltaEvents = []; thetaEvents = [];
for i = 1:length(cohSB_cache)
    for sessi = 1:length(cohSB_cache{i}.clean_cXf_mat)
        try
            deltaEvents{i}{sessi} = nanmean(cohSB_cache{i}.clean_cXf_mat{sessi}(:,idxDelta),2);
            thetaEvents{i}{sessi} = nanmean(cohSB_cache{i}.clean_cXf_mat{sessi}(:,idxTheta),2);
            % find epochs where theta is greater than delta
            theta2deltaIDX{i}{sessi} = find(thetaEvents{i}{sessi} > deltaEvents{i}{sessi});
        end
    end
    %deltaCoh{i} = nanmean(cohSB_cache{i}.clean_cXf_mat_all(:,idxDelta),2);
    %thetaCoh{i} = nanmean(cohSB_cache{i}.clean_cXf_mat_all(:,idxTheta),2);
end

deltaEventsD = []; thetaEventsD = [];
for i = 1:length(cohSB_cache)
    for sessi = 1:length(cohSB_cache{i}.dirty_cXf_mat)
        try
            deltaEventsD{i}{sessi} = nanmean(cohSB_cache{i}.dirty_cXf_mat{sessi}(:,idxDelta),2);
            thetaEventsD{i}{sessi} = nanmean(cohSB_cache{i}.dirty_cXf_mat{sessi}(:,idxTheta),2);
            % find epochs where theta is greater than delta
            theta2deltaIDXD{i}{sessi} = find(thetaEventsD{i}{sessi} > deltaEventsD{i}{sessi});
        end
    end
    %deltaCoh{i} = nanmean(cohSB_cache{i}.clean_cXf_mat_all(:,idxDelta),2);
    %thetaCoh{i} = nanmean(cohSB_cache{i}.clean_cXf_mat_all(:,idxTheta),2);
end

% use the theta2deltaIDX to get coherence data to keep from clean
for i = 1:length(theta2deltaIDX)
    for sessi = 1:length(theta2deltaIDX{i})
        cleanKeep{i}{sessi} = cohSB_cache{i}.clean_cXf_mat{sessi}(theta2deltaIDX{i}{sessi},:);
        deltaKeep{i}{sessi} = cohSB_cache{i}.clean_cXf_mat{sessi};   
        deltaKeep{i}{sessi}(theta2deltaIDX{i}{sessi},:)=[];  
        
        dirtyKeep{i}{sessi} = cohSB_cache{i}.dirty_cXf_mat{sessi}(theta2deltaIDX{i}{sessi},:);
    end
end

% create matrix per rat
for i = 1:length(cleanKeep)
    cleanKeepMat{i} = vertcat(cleanKeep{i}{:});
    deltaKeepMat{i} = vertcat(deltaKeep{i}{:});    
end

% get averages within each rat
for i = 1:length(cleanKeepMat)
    cleanFxC_avg{i} = nanmean(cleanKeepMat{i},1);
    cleanFxC_sem{i} = stderr(cleanKeepMat{i},1);    
    deltaFxC_avg{i} = nanmean(deltaKeepMat{i},1);
    deltaFxC_sem{i} = stderr(deltaKeepMat{i},1);       
end

% collapse
cleanFxC = vertcat(cleanFxC_avg{:});
deltaFxC = vertcat(deltaFxC_avg{:});

% averages
cleanFxC_ratAvg = nanmean(cleanFxC,1);
cleanFxC_ratSEM = stderr(cleanFxC,1);
deltaFxC_ratAvg = nanmean(deltaFxC,1);
deltaFxC_ratSEM = stderr(deltaFxC,1);

figure('color','w'); hold on;
s1 = shadedErrorBar(f,cleanFxC_ratAvg,cleanFxC_ratSEM,'k',0);
s2 = shadedErrorBar(f,deltaFxC_ratAvg,deltaFxC_ratSEM,'r',0);
ylabel(['Coherence (N = ',num2str(numel(rats)), ' rats)'])
xlabel('Frequency (Hz)')
box off
legend([s1.mainLine, s2.mainLine],'Theta > delta','delta > theta')

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on;
    s1 = shadedErrorBar(f,nanmean(cleanKeepMat{i},1),stderr(cleanKeepMat{i},1),'k',0);
    s2 = shadedErrorBar(f,nanmean(deltaKeepMat{i},1),stderr(deltaKeepMat{i},1),'r',0);
    legend([s1.mainLine, s2.mainLine],'Theta>Delta','Delta>=Theta')
    ylabel('Coherence')
    xlabel('Frequency')
    box off;
    ylim([0 1])
    title(rats{i})
end

%% rejected LFP
for i = 1:length(cohSB_cache)
    % first generate distributions
    cohOUT{i}.SB_cXf_avg   = nanmean(cohSB_cache{i}.clean_cXf_mat_all,1);
    cohOUT{i}.SB_cXf_ser   = stderr(cohSB_cache{i}.clean_cXf_mat_all,1);
    cohOUT{i}.SB_cXf_theta =  nanmean(cohSB_cache{i}.clean_cXf_mat_all(:,idxTheta),2);
    
    cohOUT{i}.d_cXf_avg   = nanmean(cohSB_cache{i}.dirty_cXf_mat_all,1);
    cohOUT{i}.d_cXf_ser   = stderr(cohSB_cache{i}.dirty_cXf_mat_all,1);
    cohOUT{i}.d_cXf_theta = nanmean(cohSB_cache{i}.dirty_cXf_mat_all(:,idxTheta),2);    
    %cohOUT{i}.B_cXf_avg   = nanmean(cohB_cache{i}.clean_cXf_mat_all,1);
    %cohOUT{i}.B_cXf_ser   = stderr(cohB_cache{i}.clean_cXf_mat_all,1);
end

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on
    data = [];
    data{1} = cohOUT{i}.SB_cXf_theta;
    data{2} = cohOUT{i}.d_cXf_theta;
    xRange     = [0:.05:1];
    colors{1}  = 'b'; colors{2} = 'r'; 
    dataLabels = [{'Accepted LFP'} {'Rejected LFP'}];
    distType   = 'normal';
    [y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
    xlabel('psd')
    xlabel('Coherence')
    box off;
    xlim([0 1])
    title(rats{i})
end

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on;
    s1 = shadedErrorBar(f,cohOUT{i}.SB_cXf_avg,cohOUT{i}.SB_cXf_ser,'k',0);
    s2 = shadedErrorBar(f,cohOUT{i}.d_cXf_avg,cohOUT{i}.d_cXf_ser,'r',0);
    
    ylabel('Coherence')
    xlabel('Frequency')
    box off;
    ylim([0 1])
    title(rats{i})
    if i == length(cohSB_cache)
        legend([s1.mainLine, s2.mainLine],'Accepted','Artifact Reject')
    end
end

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on;
    s1 = shadedErrorBar(f,nanmean(cleanKeepMat{i},1),stderr(cleanKeepMat{i},1),'k',0);
    s2 = shadedErrorBar(f,cohOUT{i}.d_cXf_avg,cohOUT{i}.d_cXf_ser,'r',0);
    
    ylabel('Coherence')
    xlabel('Frequency')
    box off;
    ylim([0 1])
    title(rats{i})
    if i == length(cohSB_cache)
        legend([s1.mainLine, s2.mainLine],'Accepted+theta>delta','Artifact Reject')
    end
end

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on;
    s1 = shadedErrorBar(f,nanmean(cleanKeepMat{i},1),stderr(cleanKeepMat{i},1),'k',0);
    s2 = shadedErrorBar(f,cohOUT{i}.SB_cXf_avg,cohOUT{i}.SB_cXf_ser,'r',0);
    %s2 = shadedErrorBar(f,cohOUT{i}.d_cXf_avg,cohOUT{i}.d_cXf_ser,'k',0);
    
    ylabel('Coherence')
    xlabel('Frequency')
    box off;
    ylim([0 1])
    title(rats{i})
    if i == length(cohSB_cache)
        legend([s1.mainLine, s2.mainLine],'Accepted+theta>delta','Accepted-theta>delta')
    end
end

%% theta distributions
cleanDist = []; dirtyDist = [];
idxTheta = find(f>6 & f<11);

for i = 1:length(cleanKeep)
    cleanDist{i} = nanmean(cleanKeepMat{i}(:,idxTheta),2);
    %dirtyDist{i} = nanmean(deltaMat(:,idxTheta),2);
end
zCleanDist = cellfun(@zscore_NaN,cleanDist,'UniformOutput',false);

data       = [];
data{1}    = zCleanDist{1}; data{2} = zCleanDist{2}; data{3} = zCleanDist{3};
data{4}    = zCleanDist{4}; data{5} = zCleanDist{5}; data{6} = zCleanDist{6};
data{7}    = zCleanDist{7}; data{8} = zCleanDist{8}; 
xRange     = [-3:.05:3];
colors{1}  = [1 0 0.4]; colors{2} = [1 0 0.6];  colors{3} = [1 0 0.8]; colors{4} = [1 0 1]; 
colors{5}  = [0 0 0.4]; colors{6} = [0 0 0.6];  colors{7} = [0 0 0.8]; colors{8} = [0 0 1];
dataLabels = rats;
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
ylabel('Probability density')
xlabel('Zscored Mean Coherence (6-11hz)')    

