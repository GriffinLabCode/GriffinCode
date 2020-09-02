%% plot_all_delay

%   This script plots firing rate values across time during start-box
%   occupancy for simultaneously recorded neuronal populations

%%

clear all, clc, close all

netDrive = 'X:\';
expFolder = '01.Experiments\RERh Inactivation Recording\Ratticus\';
session = 'Baseline\1\';

delay_length = 30;  %   Manually define delay length
bin = 0.2;  %   Manually define temporal bin size

datafolder = strcat(netDrive,expFolder,session);
load(strcat(datafolder, 'Int.mat'));

cd(datafolder)
clusters = dir('TT*.txt');

clear rat session expFolder

% Define parameters for start-box occupancy
nTrials=length(Int(:,1));
TrialStart = (Int(2:nTrials,1)-delay_length*1e6)/1e6;
TrialEnd = Int(2:nTrials,1)/1e6;
DelayCenter = (Int(2:nTrials,1)-(delay_length/2)*1e6)/1e6;
intsec = Int/1e6;
ntrials = size(Int,1);

edges = (-(delay_length/2):bin:delay_length/2);

% Calculate firing rates during start-box occupancy for all clusters
for ci=1:length(clusters)
    cd(datafolder);
    spikeTimes = textread(clusters(ci).name);
    spksec = spikeTimes/1e6;
    for i = 2:nTrials
    s=spksec(find(spksec>TrialStart(i-1) & spksec<TrialEnd(i-1)));
    ev=DelayCenter(i-1);
    s0=s-ev; 
    n(:,i-1) = histc(s0,edges);
    end
    FR = n./bin;
    nAvg = mean(FR,2);
    nAll(ci,:) = zscore(nAvg);
end

% Sort firing rate matrix according to when peak firing rate occurs
for si = 1:size(nAll,1)
    max(nAll(si,:));
    loc = find(nAll(si,:) == ans);
    sorted(si,:) = loc(1,1);
end

sorted(:,2) = (1:1:size(nAll,1));

sorted = sortrows(sorted,1);

for ni = 1:size(sorted,1)
    sorted_n(ni,:) = nAll(sorted(ni,2),:);
end

imagesc(sorted_n)
colormap(jet)
ylabel('Single Unit')
xlabel('Time')
set(gca,'XTick',[]);

clear TrialStart TrialEnd spksec spikeTimes sorted si s0 s nTrials ntrials ni netDrive nAvg nAll n loc intsec Int i FR ev edges DelayCenter delay_length datafolder ci bin ans

    
    
