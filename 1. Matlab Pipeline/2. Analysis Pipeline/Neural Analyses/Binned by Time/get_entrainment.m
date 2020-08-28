%% entrainment
% get entrainment data. This script was redone to save time
%
% modified by John Stout

clear; clc; close all

%% Define a datafolder and load some variables
Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';

% define what units will be entrained to
lfpName = 'HPC.mat';

% int name
int_name = 'Int_file.mat';

% define folder to save data
folderSave = 'X:\07. Manuscripts\In preparation\StoutGriffin2020\Data figures and manuscript\Stout&Griffin data and matlab figures';

% define if delay or iti
choice = 1;
sample = 0;

% choose if you want to split lefts and rights
left  = 0;
right = 0;

% do you want to shuffle your phases?
shuffle = 0; % 0 does not shuffle, 1 shuffles phases. Shuffle this for random distribution

% downsample filtered lfp?
downSample = 0;

% how to handle missing vt data?
vt_name = 'VT1.mat';
missing_data = 'interp';
            
% cd to datafolders to define folder_names
cd(Datafolders);
folder_names = dir;

% adjust the looping index?
prompt  = 'Adjust the looping index? [Y/N] ';
adjLoop = input(prompt,'s');

if adjLoop == 'Y'
    prompt = 'Enter the loop index ';
    looper = str2num(input(prompt,'s'));
else
    looper = 3:length(folder_names);
end

% spike count to include
spkCount = 20;

% define frequency filter
phase_bandpass = [4 12];

% loop across folders
for nn = looper    % 35 is for simultaneous sessions % length(folder_names) % may need to change this depending on where script left off
    
    Datafolders = Datafolders;
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
    datafolder = pwd;
    cd(datafolder);
    
    % only define these one time, on the very first loop
    if  nn == looper(1)
        prompt = 'Enter maze section based on Int (ie T-entry == 5) ';
        mazeIdx = str2num(input(prompt,'s'));  

        prompt = 'Enter time from that maze section (ie 1 == 1 second) ';
        timing = str2num(input(prompt,'s'));
    end     
    
    % Populate Int
    try 
        % only load undefined variables
        varlist = who; %Find the variables that already exist
        varlist = strjoin(varlist','$|'); %Join into string, separating vars by '|'
        load(int_name,'-regexp', ['^(?!' varlist ')\w']);
    catch
        continue
    end
    cd(Datafolders);
    folder_names = dir;
    cd(datafolder);    
    
    % get correct trials  
    Int((Int(:,4)==1),:)=[];
    
    % remove clipped trials
    %Int(Int(:,9)==1,:)=[];
    
    if choice == 1
        Int = Int(2:2:size(Int,1),:);
    elseif sample == 1
        Int = Int(1:2:size(Int,1),:);
    end
    
    if left == 1
        Int = Int((Int(:,3)==1),:);
    elseif right == 1
        Int = Int((Int(:,3)==0),:);
    end
    
    % population VT data
    cd(datafolder);
    [ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);   
    
    % load clusters
    cd(datafolder);
    clusters = dir('TT*.txt');

    %% Load and define variables for entrainment analysis   
    cd(datafolder)

    % load lfp data
    try
        % only load undefined variables
        varlist = who; %Find the variables that already exist
        varlist = strjoin(varlist','$|'); %Join into string, separating vars by '|'
        load(lfpName,'-regexp', ['^(?!' varlist ')\w']);
    catch
        disp(['No file by the name of ',lfpName,' found in session ',num2str(nn-2)])
        continue
    end
    
    % define some variables
    srate = SampleFrequencies(1);

    % format lfp timestamps
    [Timestamps_new, phase_EEG] = interp_TS_to_CSC_length_non_linspaced(Timestamps,Samples);
    Timestamps = []; Timestamps = Timestamps_new;

    % Get all CSC data from start-box occupancy periods into one cell array
    numTrials = size(Int,1);
    phase_EEG_temp = cell(1,numTrials);
    signal_ts      = cell(1,numTrials);
    for i = 1:numTrials                  
        % lfp
        phase_EEG_temp{i} = phase_EEG(Timestamps>((Int(i,mazeIdx))-(timing*1e6)) & Timestamps<(Int(i,mazeIdx)));
        phase_EEG_temp{i} = phase_EEG_temp{i}'; 

        % timestamps
        signal_ts{i} = find(Timestamps>((Int(i,mazeIdx))-(timing*1e6)) & Timestamps<(Int(i,mazeIdx)));
        signal_ts{i} = signal_ts{i}'; 
    end
    % Concatenate CSC data into one array
    LFP         = vertcat(phase_EEG_temp{:});
    signalTimes = Timestamps(vertcat(signal_ts{:}));

    %% get spk data then run entrainment function
    close all
    for ci=1:length(clusters) 
        % clear out old data
        spk = []; spk_new = []; spikes = [];

        % load in spike data
        cd(datafolder);
        spk = textread(clusters(ci).name);
        cluster = clusters(ci).name(1:end-4);

        % get data across trials
        s   = cell(1,numTrials);
        for i = 1:numTrials
            s{i} = find(spk>((Int(i,mazeIdx))-(timing*1e6)) & spk<(Int(i,mazeIdx)));
            s{i} = s{i};    
        end 
        spk_new = vertcat(s{:});
        spikes  = spk(spk_new);   

        if spikes >= spkCount
            % get entrainment
            [mrl{nn-2}{ci},mrl_subbed{nn-2}{ci},p{nn-2}{ci},...
                spkPhaseRad{nn-2}{ci},spkPhaseDeg{nn-2}{ci},z{nn-2}{ci}] = ...
                entrainment_fun(LFP,spikes,signalTimes,phase_bandpass,srate,downSample,shuffle,spkCount); 
        else
            mrl{nn-2}{ci}         = NaN;
            mrl_subbed{nn-2}{ci}  = NaN;
            p{nn-2}{ci}           = NaN;
            spkPhaseRad{nn-2}{ci} = NaN;
            spkPhaseDeg{nn-2}{ci} = NaN;
            z{nn-2}{ci}           = NaN;
        end
    end

    % display progress
    try
        X = ['finished with session ',num2str(nn)];
        disp(X);
    catch
    end
end

% save data
cd(folderSave);

% this is not flexible yet
if choice == 1
    if left == 1
        X_save_loc = 'choiceLeft';
    elseif right == 1
        X_save_loc = 'choiceRight';
    else
        X_save_loc = 'choice';
    end
elseif sample == 1
    if left == 1
        X_save_loc = 'sampleLeft';
    elseif right == 1
        X_save_loc = 'sampleRight';
    else
        X_save_loc = 'sample';
    end
end

if shuffle == 1
    shuff = 'shuffled_phases_';
else
    shuff = '';
end

% save data
X_save = ['data_',X_save_loc,'_',shuff,'Entrain2',lfpName];
save(X_save);
   