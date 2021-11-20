clear;

% define rat IDs
rats{1} = '21-12';
rats{2} = '21-13';
rats{3} = '21-14';
%rats{4} = '21-15';
rats{4} = '21-16';
rats{5} = '21-21';
rats{7} = '21-22';

for i = 1:length(rats)
    try
        cd(['X:\01.Experiments\R21\',rats{i},'\step3-definingCoherenceThresholds']);
        dataIN{i,:} = load(['CoherenceDistribution',rats{i}],'coh','LFP1name','LFP2name');
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
title('Bowl')
ylabel('Cumulative density')
xlabel('Mean coherence (6-12hz)')

%% what if I do like Fernandez ruiz et al 2019, and test whether coherence events are changed
% when memory is at play?

% so I need to get rats performing the CA task and eating on all trials

%%
clearvars -except cohData dataIN rats dataOUT

% now get data for every session and compute coherence like for 21-13 below
%Datafolders = 'X:\01.Experiments\R21';

for i = 1:length(rats)
    
    % get datafolders (session names) into a cell array
    Datafolders = ['X:\01.Experiments\R21\',rats{i},'\Sessions'];
    dir_content = [];
    dir_content = dir(Datafolders);
    dir_content = extractfield(dir_content,'name');
    remIdx = contains(dir_content,'.mat') | contains(dir_content,'.');
    dir_content(remIdx)=[];
    rem2 = contains(dir_content,'DA');
    dir_content(rem2)=[];

    % define LFP names
    hpcName = dataIN{i}.LFP1name;
    pfcName = dataIN{i}.LFP2name;

    % loop across
    for sessi = 1:length(dir_content)

        clear lfp_pf_cp lfp_hc_cp lfp_pfc lfp_hpc lfp_ts Int

        % define datafolder
        datafolder = [Datafolders,'\',dir_content{sessi}];

        % load INT
        cd(datafolder);
        load('Int_IR')

        % load lfp
        [lfp_pfc,lfp_ts,srate] = getLFPdata(datafolder,pfcName);
        [lfp_hpc,~,srate_hc] = getLFPdata(datafolder,hpcName);

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

        %% first, create coherence across frequencies plot
        % randomly pull 500ms of data, 1000 times
        %rng('shuffle')
        %outRand = randi([1 10],1); % was 3
        rng(3);
        k = 10;
        clear lfp_pf_rand lfp_hc_rand lfp_pf_det lfp_hc_det coh
        for triali = 1:numTrials
            try
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
                for n = 1:length(randPull)
                    % pull data
                    lfp_pf_rand = lfp_pf_cp{triali}(randPull(n):randPull(n)+srate/2);
                    lfp_hc_rand = lfp_hc_cp{triali}(randPull(n):randPull(n)+srate/2);
                    % detrend
                    lfp_pf_det = detrend(lfp_pf_rand);
                    lfp_hc_det = detrend(lfp_hc_rand);
                    % coherence
                    fpass = [1:20];
                    window = []; noverlap = [];
                    [coh{triali}{n},f] = mscohere(lfp_hc_det,lfp_pf_det,window,noverlap,fpass,srate);
                    disp(['finished with iteration',num2str(n)])
                end
                disp(['finished with trial ',num2str(triali)])
            end
        end

        % first, check the coherence distribution, is 6-12hz similar to what it was
        % using real-time coh methods?

        % second, perform averaging across 6-12hz bands, generate probability
        % density function and compare with real-time coh methods. Is there a
        % 'memory' bump, like Fernandez ruiz 2019 found with SWRs?
        coh_mat = [];
        clear remData
        for j = 1:length(coh)
            remData(j) = isempty(coh{j});
        end
        % remove data
        coh(remData)=[];

        % vertcat
        for n = 1:length(coh)
            coh_mat{n} = vertcat(coh{n}{:});
        end
        coh_mat_avg = []; coh_mat_trial = []; coh_mat_tAvg = []; coh_mat_tSEM = [];
        coh_mat_avg = cellfun(@nanmean,coh_mat,'UniformOutput',false);
        coh_mat_trial = vertcat(coh_mat_avg{:});
        coh_mat_tAvg = nanmean(coh_mat_trial);
        coh_mat_tSEM = stderr(coh_mat_trial,1);

        % store
        dataOUT{i}.fXc_avg = coh_mat_tAvg;
        dataOUT{i}.fXc_sem = coh_mat_tSEM;

        %% next get the distribution averaged across 6-12hz

        % now compare 6-12hz distributions
        clear coh_mat_theta
        for n = 1:length(coh_mat)
            idxTheta = find(f > 6 & f < 12);
            % select 600
            %randPull = randperm(length(coh_mat{i}),400);
            % average across frequencies, then across iterations
            coh_mat_theta{n} = nanmean(coh_mat{n}(:,idxTheta),2);
        end
        cohMatAll = []; randPull = [];
        cohMatAll = vertcat(coh_mat_theta{:});

        randPull = randperm(length(cohMatAll),length(cohMatAll));
        coh_mat_use = cohMatAll(randPull);

        dataOUT{i}.thetaCoh = coh_mat_use;
    end       

    disp(['Finished with ' rats{i}])
end

for i = 1:length(dataOUT)
    cohAvg{i} = dataOUT{i}.fXc_avg;
    cohSer{i} = dataOUT{i}.fXc_sem;
    thetaDist{i} = dataOUT{i}.thetaCoh;
end

data       = thetaDist;
xRange     = [0:.05:1];
colors{1}  = [1 0 1]; colors{2} = [1 0.3 1]; colors{3} = [1 .5 1];
colors{4}  = [0 0 1]; colors{5} = [0 .3 1]; colors{6} = [0 .5 1]; colors{7} = [0 .8 1];
dataLabels = rats;
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
title('CA Choice-point')
ylabel('Cumulative density')
xlabel('Mean coherence (6-12hz)')

for rat = 1:length(rats)
    data =[];
    data = [{thetaDist{rat}} {cohData{rat}}]
    xRange     = [0:.05:1];
    colors{1}  = 'k'; colors{2} = 'r';
    dataLabels = [{'CA CP'} {'Bowl'}];
    distType   = 'normal';
    [y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
    ylabel('probability density')
    xlabel('Mean coherence (6-12hz)')
    title(rats{rat})
end

%% pull in coherence x frequency data
for i = 1:length(rats)
    try
        cd(['X:\01.Experiments\R21\',rats{i},'\step2-definingCoherenceFrequency']);
        dataIN_cohXf{i,:} = load('step2_definingCoherenceFrequencies','coh','LFP1name','LFP2name');
    end
end

for i = 1:length(dataIN)
    cohData_cohXf{i} = dataIN_cohXf{i}.coh;
end
coh_mat_avg = []; coh_mat_trial = []; coh_mat_tAvg = []; coh_mat_tSEM = [];
coh_mat_avg = cellfun(@nanmean,cohData_cohXf,'UniformOutput',false);
cohB_all = vertcat(coh_mat_avg{:});
cohB_avg = nanmean(cohB_all);
cohB_std = stderr(cohB_all,1);

cohCP_all = vertcat(cohAvg{:});
cohCP_avg = nanmean(cohCP_all);
cohCP_std = stderr(cohCP_all,1);


figure('color','w'); hold on;
s1 = shadedErrorBar(f,cohB_avg,cohB_std,'k',1);
s2 = shadedErrorBar(f,cohCP_avg,cohCP_std,'r',1);
ylabel('Coherence')
xlabel('Frequency')
box off
legend([s1.mainLine s2.mainLine],'Bowl','CA - choice point')

% diff score
coh_diff = (cohB_all-cohCP_all)./(cohB_all+cohCP_all);
cohD_avg = nanmean(coh_diff);
cohD_std = stderr(coh_diff,1);

figure('color','w')
shadedErrorBar(f,cohD_avg,cohD_std,'k',1)
ylabel('Coherence normalized diff. (bowl-choice point)')
xlabel('Frequency')
box off


%% is it our method?
datafolder = ('X:\01.Experiments\R21\21-13\Sessions\DA Habituation\2021-11-08_15-17-42');
cd(datafolder);
load('MazeData')

% testing power
dataHPC = dataClean(1:2:end,:);
dataPFC = dataClean(2:2:end,:);

fpass = [1 100];
[S_hc,f_hc] = pspectrum(dataHPC(1,:),2000,'FrequencyLimits',fpass);
[S_pf,f_pf] = pspectrum(dataPFC(1,:),2000,'FrequencyLimits',fpass);

figure('color','w')
plot(f_hc,log10(S_hc),'b','LineWidth',2)
hold on;
plot(f_pf,log10(S_pf),'r','LineWidth',2)

params = getCustomParams;
params.Fs = 2000;
params.tapers = [2 3];

[S_hc,f_hc] = mtspectrumc(dataHPC(2,:),params);
[S_pf,f_pf] = mtspectrumc(dataPFC(2,:),params);
figure('color','w')
plot(f_hc,log10(S_hc),'b','LineWidth',2)
hold on;
plot(f_pf,log10(S_pf),'r','LineWidth',2)

% test against data in bowl
[hpc_lfp,hpc_times] = getLFPdata(datafolder,'HPC_green');
hpc_lfp = hpc_lfp{:};
hpc_times = hpc_times{:};

idx = find(hpc_times > Int(1,8) & hpc_times < Int(2,5));
sb_lfp = hpc_lfp(idx);

[S_hc,f_hc] = pspectrum(sb_lfp(1:4000),2000,'FrequencyLimits',fpass);

figure('color','w')
plot(f_hc,log10(S_hc),'b','LineWidth',2); hold on;
[S_hc,f_hc] = mtspectrumc(sb_lfp(1:4000),params);
plot(f_hc,log10(S_hc),'k','LineWidth',2); hold on;


%{     
%% 21-13
% rat did well, so gonna test if coherence differs bw bowl and CP
datafolder = 'X:\01.Experiments\R21\21-13\2021-11-02_15-07-45 - use';
cd(datafolder);
load('Int_IR');
mazeData = load('MazeData');
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

%}