%cd('X:\01.Experiments\R21\Figures\Method parameters')
%load('data_defineFrequencies','cohSB_cache','cohB_cache','rats','f')

%% notice of change
% as of 3/2022, the way in which data is loaded is different. Before, I
% put all rats data into one variable. But this kind of sucked because if I
% ever needed to run more sessions on a rat, but one rat was ready for
% testing, I would have to recreate that variable. Now, everything is done
% rat-to-rat in entirety. 
%
% ***Note that this changes nothing methodologically, its a practical thing. 
%
% this was tested on 21-14. 21-12->21-22 will not have the required folders
% for this code. It does not matter, they're data is saved in the method
% parameters folder. I just wanted to change things so that all data was
% saved in each rats folder separately for user friendly access.

%% goals:
% 1) generate coherence frequency plot with rats as the sample size
% 2) create distribution of 

%% method that works
% 1) reject movement artifact data
% 2) only include coherence if coherence in theta > that of delta
% we get beautiful graphs

% but can we acheive this with just 2)?
% the answer is YES
% and theta is 6-11hz
%load('data_cohBowl_cohDelay')

%% ONLY RUN AFTER DA TRAINING IS COMPLETED!!!!!

%% IMPORTANT NOTICE
% in "defineThetaFrequency", I was defining theta as 6-10hz by mistake
% rather than 6-11Hz. Because of this, if you attempt replication of my
% thresholds, you will need to run 'defineThetaFrequency' with that
% definition. It's really not a problem, it changes the upper limit theta
% coherence estimate by a fraction of a decimal. 

%% define parameters
ratName = '21-33';
cd(['X:\01.Experiments\R21\' ratName '\ThetaFreqDist'])
load('data_defineFrequencies')

%% loop across rats
%clearvars -except cohSB_cache cohB_cache rats f
cohSB_cache.clean_cXf_mat_all = vertcat(cohSB_cache.clean_cXf_mat{:});
cohSB_cache.dirty_cXf_mat_all = vertcat(cohSB_cache.dirty_cXf_mat{:});

% f is bw 1 and 20, identify delta, and test for instances where theta
% coherence is higher than delta on clean data
ftheta     = [6 11];
idxTheta   = find(f > 6 & f < 11);
idxDelta   = find(f > 1 & f <  4);

% 
% use this variable ->>>> cohSB_cache{1, 1}.clean_cXf_mat
deltaEvents = []; thetaEvents = [];
for sessi = 1:length(cohSB_cache.clean_cXf_mat)
    try
        deltaEvents{sessi} = nanmean(cohSB_cache.clean_cXf_mat{sessi}(:,idxDelta),2);
        thetaEvents{sessi} = nanmean(cohSB_cache.clean_cXf_mat{sessi}(:,idxTheta),2);
        % find epochs where theta is greater than delta
        theta2deltaIDX{sessi} = find(thetaEvents{sessi} > deltaEvents{sessi});
        delta2thetaIDX{sessi} = find(thetaEvents{sessi} < deltaEvents{sessi});
        
    end
end

% use the theta2deltaIDX to get coherence data to keep from clean
for sessi = 1:length(theta2deltaIDX)
    cleanKeep{sessi} = cohSB_cache.clean_cXf_mat{sessi}(theta2deltaIDX{sessi},:);
    deltaRem{sessi}  = cohSB_cache.clean_cXf_mat{sessi}(delta2thetaIDX{sessi},:);    
end

% create matrix per rat
cleanKeepMat = vertcat(cleanKeep{:});
deltaMat     = vertcat(deltaRem{:});


% get averages within each rat
%cleanFxC_avg = nanmean(cleanKeepMat,1);
%cleanFxC_sem = stderr(cleanKeepMat,1);    

% averages
cleanFxC_ratAvg = nanmean(cleanKeepMat,1);
cleanFxC_ratSEM = stderr(cleanKeepMat,1);
deltaFxC_ratAvg = nanmean(deltaMat,1);
deltaFxC_ratSEM = stderr(deltaMat,1);


figure('color','w'); hold on;
s1=shadedErrorBar(f,cleanFxC_ratAvg,cleanFxC_ratSEM,'k',1)
s2=shadedErrorBar(f,deltaFxC_ratAvg,deltaFxC_ratSEM,'r',1)
ylabel('Coherence')
xlabel('Frequency (Hz)')
box off
title(['N = ',num2str(size(cleanKeepMat,1)),' rtEpochs with theta coh > delta'])
legend([s1.mainLine s2.mainLine],'Theta>Delta','Delta>Theta')

% generate coherence distributions
cleanDist = []; dirtyDist = [];
idxTheta = find(f>6 & f<11);
cleanDist = nanmean(cleanKeepMat(:,idxTheta),2);
dirtyDist = nanmean(deltaMat(:,idxTheta),2);

data       = [];
data{1}    = cleanDist;
%data{2}    = dirtyDist;
xRange     = [0:.05:1];
colors{1}  = 'b'; colors{2} = 'k'; 
dataLabels = [{'Clean'} {'Rejected'}];
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
ylabel('Probability density')
xlabel('Mean coherence (6-11hz)')      
title(ratName)

% use zscore - std > 1 and std < 1
zCleanDist =zscore(cleanDist);
figure;
histogram(zCleanDist)

%{
for i = 1:length(cleanDist)
        data       = [];
        data{1}    = zCleanDist;
        xRange     = [-3:.05:3];
        colors{1}  = 'b'; colors{2} = 'k'; 
        dataLabels = [{'zScored'}];
        distType   = 'normal';
        [y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
        ylabel('Probability density')
        xlabel('Mean coherence (6-11hz)')      
        title(rats)
end


%close all
data       = [];
data{1}    = zCleanDist{1}; data{2} = zCleanDist{2}; data{3} = zCleanDist{3};
data{4}    = zCleanDist{4}; data{5} = zCleanDist{5}; data{6} = zCleanDist{6};
data{7}    = zCleanDist{7}; 
xRange     = [-3:.05:3];
colors{1}  = [1 0 0.6]; colors{2} = [1 0 0.8];  colors{3} = [1 0 1];
colors{4}  = [0 0 0.4]; colors{5} = [0 0 0.6];  colors{6} = [0 0 0.8]; colors{7} = [0 0 1];
dataLabels = rats;
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
ylabel('Probability density')
xlabel('Zscored Mean Coherence (6-11hz)')     

data       = [];
data{1}    = cleanDist{1}; data{2} = cleanDist{2}; data{3} = cleanDist{3};
data{4}    = cleanDist{4}; data{5} = cleanDist{5}; data{6} = cleanDist{6};
data{7}    = cleanDist{7}; 
xRange     = [0:.05:1];
colors{1}  = [1 0 0.6]; colors{2} = [1 0 0.8];  colors{3} = [1 0 1];
colors{4}  = [0 0 0.4]; colors{5} = [0 0 0.6];  colors{6} = [0 0 0.8]; colors{7} = [0 0 1];
dataLabels = rats;
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
ylabel('Probability density')
xlabel('Mean Coherence (6-11hz)')   
       
 %}

% what is -1 and 1 standard deviation?
cohLowThreshold  = nanmean(cleanDist(dsearchn(zCleanDist,-1)));
cohHighThreshold = nanmean(cleanDist(dsearchn(zCleanDist,1)));

mkdir(['X:\01.Experiments\R21\' ratName,'\thresholds'])
cd(['X:\01.Experiments\R21\' ratName,'\thresholds'])

prompt = 'Are you ready to save? (y/n) - DO NOT SAVE OVER OLD DATA!';
answer = input(prompt,'s');
if contains(answer,[{'y'} {'Y'}])
    save('thresholdData','cohLowThreshold','cohHighThreshold','ratName')
else
end

%{
for i = 1:length(cohLow)
    mkdir(['X:\01.Experiments\R21\' rats,'\thresholds'])
    cd(['X:\01.Experiments\R21\' rats,'\thresholds'])
    cohLowThreshold = []; cohHighThreshold = [];
    cohLowThreshold = cohLow(i);
    cohHighThreshold = cohHigh(i);
    %save('thresholdData.mat','cohLowThreshold','cohHighThreshold')
end
%}

%{
%% Do we even need artifact reject? Or can we reject on the grounds of coherence alone?
% The answer to this is yes, we need both. Below, it wont look it, but in
% person, delta > theta doesn't always reject artifacts
for i = 1:length(cohSB_cache)
    for sessi = 1:length(cohSB_cache.clean_cXf_mat)
        try
            % concatenate 
            datacohAll{sessi} = vertcat(cohSB_cache.clean_cXf_mat{sessi},cohSB_cache.dirty_cXf_mat{sessi});
        end
    end
end

% use this variable ->>>> cohSB_cache{1, 1}.clean_cXf_mat
deltaEvents = []; thetaEvents = []; theta2deltaIDX = []; delta2thetaIDX = [];
for i = 1:length(datacohAll)
    for sessi = 1:length(datacohAll)
        try
            deltaEvents{sessi} = nanmean(datacohAll{sessi}(:,idxDelta),2);
            thetaEvents{sessi} = nanmean(datacohAll{sessi}(:,idxTheta),2);
            % find epochs where theta is greater than delta
            theta2deltaIDX{sessi} = find(thetaEvents{sessi} > deltaEvents{sessi});
            % find when delta is greater than theta
            delta2thetaIDX{sessi} = find(thetaEvents{sessi} < deltaEvents{sessi});
        end
    end
end

% use the theta2deltaIDX to get coherence data to keep from clean
cleanKeep = []; dirtyRem = [];
for i = 1:length(datacohAll)
    for sessi = 1:length(datacohAll)
        cleanKeep{sessi} = datacohAll{sessi}(theta2deltaIDX{sessi},:);
        dirtyRem{sessi}  = datacohAll{sessi}(delta2thetaIDX{sessi},:);        
    end
end

% create matrix per rat
cleanKeepMat = []; DirtyRemMat = [];
for i = 1:length(cleanKeep)
    cleanKeepMat = vertcat(cleanKeep{:});
    DirtyRemMat  = vertcat(dirtyRem{:});    
end

% get averages within each rat
cleanFxC_avg = []; cleanFxC_sem = []; dirtyFxC_avg = []; dirtyFxC_sem = [];
for i = 1:length(cleanKeepMat)
    cleanFxC_avg = nanmean(cleanKeepMat,1);
    cleanFxC_sem = stderr(cleanKeepMat,1);  
    dirtyFxC_avg = nanmean(DirtyRemMat,1);
    dirtyFxC_sem = stderr(DirtyRemMat,1);         
end

% collapse
cleanFxC = []; dirtyFxC = [];
cleanFxC = vertcat(cleanFxC_avg{:});
dirtyFxC = vertcat(dirtyFxC_avg{:});

% averages
cleanFxC_ratAvg = []; cleanFxC_ratSEM = []; dirtyFxC_ratAvg = []; dirtyFxC_ratSEM = [];
cleanFxC_ratAvg = nanmean(cleanFxC,1);
cleanFxC_ratSEM = stderr(cleanFxC,1);
dirtyFxC_ratAvg = nanmean(dirtyFxC,1);
dirtyFxC_ratSEM = stderr(dirtyFxC,1);

figure('color','w'); hold on;
s1 = shadedErrorBar(f,cleanFxC_ratAvg,cleanFxC_ratSEM,'k',0);
s2 = shadedErrorBar(f,dirtyFxC_ratAvg,dirtyFxC_ratSEM,'r',0);
ylimits = ylim;
r = rectangle('Position',[6 0.1 5 .6]);
ylabel('Coherence (N = 7 rats)')
xlabel('Frequency (Hz)')
legend([s1.mainLine, s2.mainLine],'theta>delta','delta>theta')
box off

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on;
    s1 = shadedErrorBar(f,nanmean(cleanKeepMat,1),stderr(cleanKeepMat,1),'k',0);
    s2 = shadedErrorBar(f,nanmean(DirtyRemMat,1),stderr(DirtyRemMat,1),'r',0);
    legend([s1.mainLine, s2.mainLine],'Clean','Dirty')
    ylabel('Coherence')
    xlabel('Frequency')
    box off;
    ylim([0 1])
    title(rats)
end

% generate coherence distributions
cleanDist = []; dirtyDist = [];
idxTheta = find(f>6 & f<11);
for i = 1:length(cleanKeepMat)
    cleanDist = nanmean(cleanKeepMat(:,idxTheta),2);
    dirtyDist = nanmean(DirtyRemMat(:,idxTheta),2);
end

for i = 1:length(cleanDist)
        data       = [];
        data{1}    = cleanDist;
        data{2}    = dirtyDist;
        xRange     = [0:.05:1];
        colors{1}  = 'b'; colors{2} = 'k'; 
        dataLabels = [{'Clean'} {'Rejected'}];
        distType   = 'normal';
        [y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
        ylabel('Probability density')
        xlabel('Mean coherence (6-11hz)')      
        title(rats)
end

% use zscore - std > 1 and std < 1
zCleanDist = cellfun(@zscore,cleanDist,'UniformOutput',false);
figure;
histogram(zCleanDist{1})

for i = 1:length(cleanDist)
        data       = [];
        data{1}    = zCleanDist;
        xRange     = [-3:.05:3];
        colors{1}  = 'b'; colors{2} = 'k'; 
        dataLabels = [{'zScored'}];
        distType   = 'normal';
        [y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
        ylabel('Probability density')
        xlabel('Mean coherence (6-11hz)')      
        title(rats)
end


%close all
data       = [];
data{1}    = zCleanDist{1}; data{2} = zCleanDist{2}; data{3} = zCleanDist{3};
data{4}    = zCleanDist{4}; data{5} = zCleanDist{5}; data{6} = zCleanDist{6};
data{7}    = zCleanDist{7}; 
xRange     = [-3:.05:3];
colors{1}  = [1 0 0.6]; colors{2} = [1 0 0.8];  colors{3} = [1 0 1];
colors{4}  = [0 0 0.4]; colors{5} = [0 0 0.6];  colors{6} = [0 0 0.8]; colors{7} = [0 0 1];
dataLabels = rats;
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
ylabel('Probability density')
xlabel('Zscored Mean Coherence (6-11hz)')     

data       = [];
data{1}    = cleanDist{1}; data{2} = cleanDist{2}; data{3} = cleanDist{3};
data{4}    = cleanDist{4}; data{5} = cleanDist{5}; data{6} = cleanDist{6};
data{7}    = cleanDist{7}; 
xRange     = [0:.05:1];
colors{1}  = [1 0 0.6]; colors{2} = [1 0 0.8];  colors{3} = [1 0 1];
colors{4}  = [0 0 0.4]; colors{5} = [0 0 0.6];  colors{6} = [0 0 0.8]; colors{7} = [0 0 1];
dataLabels = rats;
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
ylabel('Probability density')
xlabel('Mean Coherence (6-11hz)')   
        
% what is -1 and 1 standard deviation?
for i = 1:length(cleanDist)
    cohLow(i)  = nanmean(cleanDist(dsearchn(zCleanDist,-1)));
    cohHigh(i) = nanmean(cleanDist(dsearchn(zCleanDist,1)));
end


for i = 1:length(cohLow)
    mkdir(['X:\01.Experiments\R21\' rats,'\thresholds'])
    cd(['X:\01.Experiments\R21\' rats,'\thresholds'])
    cohLowThreshold = []; cohHighThreshold = [];
    cohLowThreshold = cohLow(i);
    cohHighThreshold = cohHigh(i);
    save('thresholdData.mat','cohLowThreshold','cohHighThreshold')
end


%}
