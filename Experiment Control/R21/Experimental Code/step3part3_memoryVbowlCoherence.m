clear;

% define rat IDs
rats{1} = '21-12';
rats{2} = '21-13';
rats{3} = '21-14';
rats{4} = '21-15';
rats{5} = '21-16';
rats{6} = '21-21';
rats{7} = '21-22';

for i = 1:length(rats)
    try
        cd(['X:\01.Experiments\R21\',rats{i},'\step3-definingCoherenceThresholds']);
        dataIN{i,:} = load(['CoherenceDistribution',rats{i}],'coh');
    end
end

for i = 1:length(dataIN)
    cohData{i} = dataIN{i}.coh;
end

data       = cohData;
xRange     = [0:.05:1];
colors{1}  = [1 0 1]; colors{2} = [1 0.3 1]; colors{3} = [1 .5 1];
colors{4}  = [0 0 1]; colors{5} = [0 .3 1]; colors{6} = [0 .5 1]; colors{7} = [0 .8 1];
dataLabels = rats;
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);


%% what if I do like Fernandez ruiz et al 2019, and test whether coherence events are changed
% when memory is at play?

% so I need to get rats performing the CA task and eating on all trials

%% 21-13
% rat did well, so gonna test if coherence differs bw bowl and CP
datafolder = 'X:\01.Experiments\R21\21-13\2021-11-02_15-07-45 - use';
cd(datafolder);
load('Int_IR');
mazeData = load('mazeData');
cd('X:\01.Experiments\R21\21-13\step3-definingCoherenceThresholds')
cohDistBowl = load('CoherenceDistribution21-13');
cd(datafolder);

% load lfp
[lfp_pfc,lfp_ts,srate] = getLFPdata(datafolder,cohDistBowl.LFP2name);
[lfp_hpc,~,srate_hc] = getLFPdata(datafolder,cohDistBowl.LFP1name);

% get data into usable format
lfp_pfc = lfp_pfc{:};
lfp_hpc = lfp_hpc{:};
lfp_ts  = lfp_ts{:};

% get times and lfp around cp
numTrials = size(Int,1);
for triali = 1:numTrials
    idx = find(lfp_ts > (Int(triali,5)) & lfp_ts < (Int(triali,6)));
    lfp_pf_cp{triali} = lfp_pfc(idx);
    lfp_hc_cp{triali} = lfp_hpc(idx);
end

% randomly pull 500ms of data, 1000 times
%rng('shuffle')
%outRand = randi([1 10],1); % was 3
rng(3);
k = 1000;
clear lfp_pf_rand lfp_hc_rand lfp_pf_det lfp_hc_det coh
for triali = 1:numTrials
    % define instances to pull from, min to max
    % subtract 1/2 second, give some leeway (eg add 1/4 sec)
    idxPull = 1:length(lfp_pf_cp{triali})-((srate));
    % define your start idx's
    try 
        randPull = randperm(length(idxPull),k);
    catch
        randPull = randperm(length(idxPull),length(idxPull));
    end
    % get data
    for i = 1:length(randPull)
        % pull data
        lfp_pf_rand = lfp_pf_cp{triali}(randPull(i):randPull(i)+srate/2);
        lfp_hc_rand = lfp_hc_cp{triali}(randPull(i):randPull(i)+srate/2);
        % detrend
        lfp_pf_det = detrend(lfp_pf_rand);
        lfp_hc_det = detrend(lfp_hc_rand);
        % coherence
        fpass = [1:20];
        window = []; noverlap = [];
        [coh{triali}{i},f] = mscohere(lfp_hc_det,lfp_pf_det,window,noverlap,fpass,srate);
        disp(['finished with iteration',num2str(i)])
    end
    disp(['finished with trial ',num2str(triali)])
end

% first, check the coherence distribution, is 6-12hz similar to what it was
% using real-time coh methods?

% second, perform averaging across 6-12hz bands, generate probability
% density function and compare with real-time coh methods. Is there a
% 'memory' bump, like Fernandez ruiz 2019 found with SWRs?
for i = 1:length(coh)
    coh_mat{i} = vertcat(coh{i}{:});
end
coh_mat_avg = cellfun(@nanmean,coh_mat,'UniformOutput',false);
coh_mat_trial = vertcat(coh_mat_avg{:});
coh_mat_tAvg = nanmean(coh_mat_trial);
coh_mat_tSEM = stderr(coh_mat_trial,1);

cd('X:\01.Experiments\R21\21-13\step2-definingCoherenceFrequency')
bowlCoherence = load('step2_definingCoherenceFrequencies');
% bowl coherence
bowlCoh = bowlCoherence.coh;
coh_mat_bAvg = nanmean(bowlCoh);
coh_mat_bSEM = stderr(bowlCoh,1);

figure('color','w'); hold on;
s1 = shadedErrorBar(f,coh_mat_tAvg,coh_mat_tSEM,'k',0);
s2 = shadedErrorBar(f,coh_mat_bAvg,coh_mat_bSEM,'b',0);
ylabel('Coherence')
xlabel('Frequency(Hz)')
box off
legend([s1.mainLine s2.mainLine],'Trial Avg','Bowl Avg')
%legend(s2.mainLine,'Bowl Avg')

% now compare 6-12hz distributions
clear coh_mat_theta
for i = 1:length(coh_mat)
    idxTheta = find(f > 6 & f < 12);
    % select 600
    %randPull = randperm(length(coh_mat{i}),400);
    % average across frequencies, then across iterations
    coh_mat_theta{i} = nanmean(coh_mat{i}(:,idxTheta),2);
end
cohMatAll = vertcat(coh_mat_theta{:});

randPull = randperm(length(cohMatAll),600);
coh_mat_use = cohMatAll(randPull);

data2plot{1} = cohData{1}; data2plot{2} = coh_mat_use;
xRange     = [0:.05:1];
colors = [];
colors{1}  = 'b'; colors{2} = 'k'; 
dataLabels = [];
dataLabels{1} = 'Bowl distribution 6-12hz'; dataLabels{2} = 'Trial distribution 6-12hz';
distType   = 'normal';
[y,a] = plotCurves(data2plot,xRange,colors,dataLabels,distType);

