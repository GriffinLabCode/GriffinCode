%% quick way to handle lfp data

folder     = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\';
session    = 'Groot 3-3-18'; 
dataName   = '\mPFC';
datafolder = strcat(folder,session);

% set parameter for threshold
threshold = 200; % removes trials with > 100 clipping artifacts

% set parameter for data exlusion. If the task is DNMP, then whenever a
% sample phase is detecting for removal, it will remove its respective
% choice phase
task_type = 'DNMP';

% set parameter for plotting
plotFigs = 1; % 0 for no plot

% change directory
cd(datafolder)

% load data
dataIN     = load(strcat(datafolder,dataName),'Samples','Timestamps','SampleFrequencies'); 

% reformat timestamps and samples to be an 1xN vector where N is lfp data
[dataIN.Times,dataIN.LFP] = interp_TS_to_CSC_length_non_linspaced(dataIN.Timestamps, dataIN.Samples); 

% define sampling rate
params.Fs = dataIN.SampleFrequencies(1,1); 

% load int file
load('Int_file.mat')

for triali=1:size(Int,1)
    
    % define times for getting data
    time = [];
    time = [(Int(triali,1)) Int(triali,5)];
    
    % define data
    data1{triali} = dataIN.LFP(dataIN.Times > time(1,1) & dataIN.Times < time(1,2));
    
    % clean data
    %data1_clean{triali} = DetrendDenoise(data1{triali},params.Fs);
    
    % find number of clippings - only put the ripple data
    [~,~,numClippings(triali)] = detect_clipping(data1{triali});
    
end

% plot data
if plotFigs == 1
    % trials to remove
    for figi = find(numClippings>0)

        figure('color','w')
        plot(data1{figi})
        title(['clipping event: trial ',num2str(figi),'. # clippings = ',num2str(numClippings(figi))])
        pause

    end

    % trials to keep
    for figi = find(numClippings==0)

        figure('color','w')
        plot(data1{figi})
        title(['Clean data: trial ',num2str(figi)])
        pause

    end
end

% user sets a threshold
if exist('threshold') == 0
    prompt    = 'Define a criteria for data exclusion (i.e. 100 indicates removal of trials with 100 or greater clippings) ';
    threshold = input(prompt,'s');
end

% if DNMP, then handle data 
if strfind(task_type,'DNMP') == 1
    % find clipping events for sample and choice trials
    clipIdx    = find(numClippings > 0); % trials with clippings events
    choice2rem = clipIdx(mod(clipIdx,2)==0);
    sample2rem = clipIdx(mod(clipIdx,2)~=0);
    % removed paired trials if a clipping occured to ensure even number of
    % sample and choice trials
    choice2rem_prevSam = choice2rem-1;
    sample2rem_nextCho = sample2rem+1;
    % combine arrays and account for cases where you've decided to remove a
    % trial 2 times (using the unique function)
    trials2rem = unique(horzcat(choice2rem,choice2rem_prevSam,sample2rem,sample2rem_nextCho));
end

% remove trials
Int(trials2rem,:)=[]; 

% make an info variable
info = 'Trials with clipping artifacts were removed from stem entry to T-junction entry';

% save int file
%save('Int_remClip','Int','info')

