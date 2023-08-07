%% Spike field coherence on high/low coherence epochs
clear; clc
rats{1} = 'BabyGroot'; % DNMP
rats{2} = 'Meusli';
rats{3} = 'Groot';
place2store = getCurrentPath;
addpath(place2store);

spkTimes = []; clusterID = [];
for rati = 1:length(rats)

    % get datafolders (session names) into a cell array
    Datafolders = ['X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\' rats{rati},'\'];        
    dir_content = [];
    dir_content = dir(Datafolders);
    if isempty(dir_content)
        continue
    end
    dir_content = extractfield(dir_content,'name');
    remIdx = contains(dir_content,'.mat') | contains(dir_content,'.');
    dir_content(remIdx)=[];
    rem2 = contains(dir_content,'DA');
    dir_content(rem2)=[];

    % loop across
    for sessi = 1:length(dir_content)

        % define datafolder
        datafolder = [Datafolders,dir_content{sessi}];        
        cd(datafolder)
        
        % load int
        load('Int_file');

        % choice accuracy
        if isempty(Int)
            continue
            disp('Session skipped')
        end
        
        % get spike data - the ISI will be wrong if there are stop/starts
        disp('Loading unit data')
        [~,clusterID{rati,sessi}] = getSpikeData(datafolder,'TT','Events');

        disp(['Finished with ' rats{rati} ' session', num2str(sessi)])
    end
    disp(['Finished with ' rats{rati}])
end

% get spike counts
clusterIDref = clusterID(:);
clusterIDref = emptyCellErase(clusterIDref);
cellCountsPerSess = cellfun(@numel,clusterIDref);
totalNeuronCount = sum(cellCountsPerSess);

%cd('C:\Users\uggriffin\Documents\BACKUP - Stout 2023 - dissertation\Stout et al 2022 Harnessing neural synchrony\data');
cd('C:\Users\uggriffin\Documents\BACKUP - Stout 2023 - dissertation\Stout et al 2022 Harnessing neural synchrony\data');
disp('Saving spk data...')
save('data_spkCounts.mat','clusterID','cellCountsPerSess','totalNeuronCount',"-v7.3");

