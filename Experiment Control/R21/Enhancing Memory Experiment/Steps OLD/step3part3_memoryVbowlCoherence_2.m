clear;
% the coherence estimates, in generaly, the spectral analyses struggle with
% 0.5 sec. Using 1 second data is better, but at the sacrifice of potential
% artifacts. The moving window method may actually be better. But if we
% ever lose any data, which neuralynx does, then we're screwed.

% define rat IDs
%rats{1} = '21-12';
rats{1} = '21-13';
rats{2} = '21-14';
%rats{4} = '21-15';
%rats{5} = '21-16';
rats{3} = '21-21';
%rats{7} = '21-22';

%% what if I do like Fernandez ruiz et al 2019, and test whether coherence events are changed
% when memory is at play?

% so I need to get rats performing the CA task and eating on all trials

%%

for i = 1:length(rats)
    % get datafolders (session names) into a cell array
    Datafolders = ['X:\01.Experiments\R21\',rats{i},'\Sessions\DA Habituation'];
    dir_content = [];
    dir_content = dir(Datafolders);
    dir_content = extractfield(dir_content,'name');
    remIdx = contains(dir_content,'.mat') | contains(dir_content,'.');
    dir_content(remIdx)=[];
    try
        % loop across
        for sessi = 1:length(dir_content)
            datafolder = [Datafolders,'\',dir_content{sessi}];
            cd(datafolder)
            % pull in data
            dataIN{i,:}{sessi} = load('MazeData','coh','cohBowl','LFP1name','LFP2name','fcoh');
        end
    end
end

% collapse data within each rat
coh = []; cohBowl = [];
for rowi = 1:size(dataIN,1)
    for nexti = 1:length(dataIN{rowi})
        coh{rowi}{nexti} = dataIN{rowi}{nexti}.coh;
        cohBowl{rowi}{nexti} = dataIN{rowi}{nexti}.cohBowl;
    end
end

for i = 1:length(coh)
    coh_rat{i} = vertcat(coh{i}{:});
    cohB_rat{i} = vertcat(cohBowl{i}{:});
end
coh_avg  = cellfun(@nanmean,coh_rat,'UniformOutput',false);
coh_std  = cellfun2(coh_rat,'stderr',{'1'});
cohB_avg = cellfun(@nanmean,cohB_rat,'UniformOutput',false);
cohB_std = cellfun2(cohB_rat,'stderr',{'1'});

% -- compare coh x freq plots -- %
rati = 2;
fcoh = dataIN{1}{1}.fcoh;
figure('color','w'); hold on;
s1 = shadedErrorBar(fcoh,coh_avg{rati},coh_std{rati},'b',0);
s2 = shadedErrorBar(fcoh,cohB_avg{rati},coh_std{rati},'k',0);
legend([s1.mainLine s2.mainLine],'memory','non-memory');
title(rats{rati})

for i = 1:length(coh_avg)
    coh_avg_diff{i} = (coh_avg{i}-cohB_avg{i})./(coh_avg{i}+cohB_avg{i});
end
figure('color','w'); hold on;
plot(coh_avg_diff{1},'r','LineWidth',2);
plot(coh_avg_diff{2},'b','LineWidth',2);
plot(coh_avg_diff{3},'m','LineWidth',2);



% testing power
dataHPC = dataClean(1:2:end,:);
dataPFC = dataClean(2:2:end,:);

fpass = [1 100];
[S_hc,f_hc] = pspectrum(dataHPC(2,:),2000,'FrequencyLimits',fpass);
[S_pf,f_pf] = pspectrum(dataPFC(2,:),2000,'FrequencyLimits',fpass);

figure('color','w')
plot(f_hc,log10(S_hc),'b','LineWidth',2)
hold on;
plot(f_pf,log10(S_pf),'r','LineWidth',2)
legend(hpcName,pfcName)

params = getCustomParams;
params.Fs = 2000;
params.tapers = [2 3];

[S_hc,f_hc] = mtspectrumc(dataHPC(2,:),params);
[S_pf,f_pf] = mtspectrumc(dataPFC(2,:),params);
figure('color','w')
plot(f_hc,log10(S_hc),'b','LineWidth',2)
hold on;
plot(f_pf,log10(S_pf),'r','LineWidth',2)


%% coherence distributions
fpass = [5 12];


data       = cohData;
xRange     = [0:.05:1];
colors{1}  = [1 0 1]; colors{2} = [1 0.3 1]; colors{3} = [1 .5 1];
colors{4}  = [0 0 1]; colors{5} = [0 .3 1]; colors{6} = [0 .5 1]; colors{7} = [0 .8 1];
dataLabels = rats;
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
