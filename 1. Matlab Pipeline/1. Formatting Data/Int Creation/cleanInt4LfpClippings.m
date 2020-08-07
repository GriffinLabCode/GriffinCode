%% quick way to handle lfp data
% this code is designed to detect clipping events, then generate a new int
% file that has them removed. this only really works for dnmp, but can be
% easily adapted for DA, CD, CA etc...
%
% -- INPUTS -- %
% Datafolders: master directory containing sub directories that contain
%               data
% int_name: int name 'Int_file.mat'
% Int_newName: new int name
% cscName: for example 'CSC1.mat'
% threshold: number of clippings that warrant exclusion. > 100 seems to be
%             conservative enough when i plotted the data out (JS)
% task_type: 'DNMP' - note that you do not need to define this. However,
%              you may want to consider the fact that it will selectively
%              remove trials that have clipping events. If you used DNMP,
%              you may want to control for the number of sample and choice
%              phases included.
% mazeIdx: set this to whatever you're interested in looking at with
%           respect to Int. For example, if you want time between stem
%           entry and t-entry, mazeIdx = [1 5]; ... if you want to look at
%           timing around t-entry, set mazeIdx = [5 5]; and define
%           time_around (below).
% time_around: timing around the event of interest. Make sure to scale this
%               number (i.e. 1 second = 1*1e6). Example: time_around =
%               [2*1e6 1*1e6] means it will take 2 seconds before and 1
%               second after the int location designated by mazeIdx.
%               mazeIdx should be the same value. Example: mazeIdx = [5 5];
%               If you don't want to use this, set it to empty array.
%               Example: time_around = [];
% plotFigs: 0 indicates do not plog. 1 indicates plot
%
% TIPS: if you want to consider multiple data, like say you have 2 regions
% and want to exlude trials with clippings in both, consider running the
% function on one of the LFP datasets, store the Int file, then use that
% new int file (the one you just stored) with the next LFP dataset. This
% will make it so you only include clean trials from lfp1 on lfp2
%
% -- OUPUTS -- %
% This function has no outputs. Instead, it saves Int_remClip, a modified
%   int file where trials that had significant clipping events (as defined
%   by user 'threshold' variable) are removed. Another variable named
%   "info" is also saved. "Info" is a structure array containing the
%   history and information regarding the modified Int file.
% 
% written by John Stout - 6/16/2020

function [] = cleanInt4LfpClippings(Datafolders,int_name,Int_newName,cscName,threshold,task_type,mazeIdx,time_around,plotFigs)

% define folder_names
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

% loop across folders
for nn = looper

    Datafolders = Datafolders;
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
    datafolder = pwd;
    cd(datafolder);    

    % load data - this may not always work if data isnt saved with
    % appropriate name
    try
        dataIN = load(strcat(datafolder,cscName),'Samples','Timestamps','SampleFrequencies'); 
    catch
        disp(['no LFP with the name of ',cscName,' found']);
        continue
    end
    
    % reformat timestamps and samples to be an 1xN vector where N is lfp data
    [dataIN.Times,dataIN.LFP] = interp_TS_to_CSC_length_non_linspaced(dataIN.Timestamps, dataIN.Samples); 

    % define sampling rate
    params.Fs = dataIN.SampleFrequencies(1,1); 

    % load int file
    clear Int info
    
    try
        load(int_name)
    catch
        disp(['no Int file by the name of ',int_name])
        continue
    end
    
    % if the int file is empty, skip 
    if isempty('Int') == 1
        disp([int_name, ' is empty'])
        continue
    end

    % loop across trials and get data, then detect clippings
    clear data1 numClippings
    for triali=1:size(Int,1)

        % define times for getting data
        time = [];
        
        % if your focus is time around specific LFP events, then include
        % time_around
        if isempty(time_around)==0
            time = [(Int(triali,mazeIdx(1))-(time_around(1))) (Int(triali,mazeIdx(2))+(time_around(2)))];
        else
            time = [(Int(triali,mazeIdx(1))) Int(triali,mazeIdx(2))];
        end
        
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
    try
        clear clipIdx choice2rem sample2rem choice2rem_prevSam sample2rem_nextCho trials2rem
        if strfind(task_type,'DNMP') == 1
            if size(Int,2) > 8 == 1 % in the case of 9th column, used to remove stuff
                clipIdx = find(Int(:,9) == 1);
            else
                % find clipping events for sample and choice trials
                clipIdx    = find(numClippings > threshold); % trials with clippings events
            end
            choice2rem = clipIdx(mod(clipIdx,2)==0);
            sample2rem = clipIdx(mod(clipIdx,2)~=0);
            % removed paired trials if a clipping occured to ensure even number of
            % sample and choice trials
            choice2rem_prevSam = choice2rem-1;
            sample2rem_nextCho = sample2rem+1;
            % combine arrays and account for cases where you've decided to remove a
            % trial 2 times (using the unique function)
            trials2rem = unique(horzcat(choice2rem,choice2rem_prevSam,sample2rem,sample2rem_nextCho));
        else
            % if you don't define a task
            trials2rem = find(numClippings > threshold);
        end
    catch
        disp('Cannot define trials to remove')
        continue
    end

    % remove trials
    Int(trials2rem,:)=[]; 

    % make an info variable
    info.purpose  = 'Trials with clipping artifacts were removed from Int file';
    info.location = mazeIdx;
    info.timing   = time_around;
    
    % ~~ store naming variables (the history) ~~ %
    
    % try to define the csc testVar variable to see if csc is in the
    % information variable
    try
        testVar = extractfield(info,'csc');
    catch
    end
    
    % define info.csc
    if exist("testVar")
        info.csc = strcat(info.csc,'_and_',cscName); % compound saving
    else
        info.csc = cscName;
    end
    
    % save int file
    %save('Int_remClip','Int','info')
    save(Int_newName,'Int','info')
    
    % display progress
    disp(['finished with session ',num2str(nn-2)]);    
    
end
