%% get_LFP_timeAround
% gets lfp surrounding an int location of interest
%
% ~~~ INPUTS ~~~
% Datafolders: Master directory
% int_name: the name of the int_file you want to use (ie 'Int_file.mat')
% vt_name: the name of the video tracking file (ie 'VT1.mat')
% task_type: Currently supports 'DNMP' or 'CA/DA/CD' 
% bin_num: number of bins
% stem_dir: the direction of stem (can be 'X' or 'Y' as in the x and y plane)
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
% CSC1: name of first CSC: 'CSC1.mat'
% CSC2: name of second CSC
% CSC3: name of third CSC
%
% -- OUTPUTS --%
% LFPdata: lfp data for all csc's included
% 
% written by John Stout. Last update 3/23/20

function [LFPdata] = get_LFP_timeAround(Datafolders,int_name,mazeIdx,time_around,CSC1,CSC2,CSC3)

    % calculate firing rate for all sessions
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

            % load animal parameters 
            try
                % only load undefined variables
                varlist = who; %Find the variables that already exist
                varlist = strjoin(varlist','$|'); %Join into string, separating vars by '|'
                load(int_name,'-regexp', ['^(?!' varlist ')\w']);
            catch
                disp(['Could not load ', int_name])
                continue
            end
            
            % if int file is empty, skip
            if isempty(Int) == 1
                disp('Int file empty - skipping session')
                continue
            end 

            % only include correct trials
            IntCorrect   = find(Int(:,4)==0);
            IntIncorrect = find(Int(:,4)==1); 
    
            %% get lfp data
            
            % load data
            try
                try data1 = load(CSC1); catch; end            
                try data2 = load(CSC2); catch; end
                try data3 = load(CSC3); catch; end    
            catch
                disp('Could not load any CSC data')
                continue
            end
            
            % set parameters - make default parameters with fun
            params.tapers    = [3 5];
            params.trialave  = 0;
            params.err       = [2 .05];
            params.pad       = 0;
            params.fpass     = [0 100]; % [1 100]
            params.movingwin = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
            
            % define sampling rate. note that this will overwrite, but
            % thats okay. I want to make sure we're actually defining it.
            try params.Fs = data1.SampleFrequencies(1); catch; end
            try params.Fs = data2.SampleFrequencies(1); catch; end
            try params.Fs = data3.SampleFrequencies(1); catch; end

            % convert timestamps
            if exist("data1")
                LFPtimes = interp_TS_to_CSC_length_non_linspaced(data1.Timestamps, data1.Samples); % figure; subplot 121; plot(Timestamps); subplot 122; plot(Timestamps_new)
            elseif exist("data2")
                LFPtimes = interp_TS_to_CSC_length_non_linspaced(data2.Timestamps, data2.Samples); % figure; subplot 121; plot(Timestamps); subplot 122; plot(Timestamps_new)                
            elseif exist("data3")
                LFPtimes = interp_TS_to_CSC_length_non_linspaced(data3.Timestamps, data3.Samples); % figure; subplot 121; plot(Timestamps); subplot 122; plot(Timestamps_new)
            end                
                
            % convert lfp data and initialize a variable
            try data1LFP = []; data1LFP = data1.Samples(:)'; data1LFP_binned = []; catch; end
            try data2LFP = []; data2LFP = data2.Samples(:)'; data2LFP_binned = []; catch; end
            try data3LFP = []; data3LFP = data3.Samples(:)'; data3LFP_binned = []; catch; end
              
            % initialize position data
            posX = []; posY = []; TS = [];
            
            % index of trials
            trials = 1:size(Int,1);   
            
            for triali = 1:size(Int,1) % loop across trials
                % define where you want to perform the analysis
                time = [];
                time = [(Int(triali,mazeIdx(1))-(time_around(1))) (Int(triali,mazeIdx(2))+(time_around(2)))];

                % get data
                try data1LFP_binned{triali} = data1LFP(LFPtimes>time(1,1) & LFPtimes<time(1,2)); catch; end
                try data2LFP_binned{triali} = data2LFP(LFPtimes>time(1,1) & LFPtimes<time(1,2)); catch; end
                try data3LFP_binned{triali} = data3LFP(LFPtimes>time(1,1) & LFPtimes<time(1,2)); catch; end    

                % get position data
                posX{triali} = ExtractedX(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
                posY{triali} = ExtractedY(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
                TS{triali}   = TimeStamps_VT(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
            end

            % get correct and incorrect
            try LFPdata.data1LFP_cor{nn-2} = data1LFP_binned(IntCorrect); catch; end
            try LFPdata.data2LFP_cor{nn-2} = data2LFP_binned(IntCorrect); catch; end
            try LFPdata.data3LFP_cor{nn-2} = data3LFP_binned(IntCorrect); catch; end
            
            try LFPdata.data1LFP_inc{nn-2} = data1LFP_binned(IntIncorrect); catch; end
            try LFPdata.data2LFP_inc{nn-2} = data2LFP_binned(IntIncorrect); catch; end
            try LFPdata.data3LFP_inc{nn-2} = data3LFP_binned(IntIncorrect); catch; end

            % store bhavior
            LFPdata.beh{nn-2} = Int;
            
            % store parameters
            LFPdata.params{nn-2} = params;
            
            % store names of lfp
            LFPdata.names.data1 = CSC1;
            LFPdata.names.data2 = CSC2;
            LFPdata.names.data3 = CSC3;
            
            % store position data
            LFPdata.posX{nn-2}     = posX;
            LFPdata.posY{nn-2}     = posY;
            LFPdata.posTimes{nn-2} = TS;
            
            X = ['finished with session ',num2str(nn-2)];
            disp(X)
            
            % offline steps should include cleaning, removing artifacts,
            % then running analyses.
            
            clearvars -except LFPdata Datafolders int_name task_type vt_name CSC1 CSC2 CSC3 info mazeIdx time_around
    end
    
    % update history
    info.data = 'LFP extracted from multiple stem epochs';
        
    % save data
    prompt = 'Please briefly describe this dataset ';
    data_description = input(prompt,'s');

    prompt   = 'Please enter a unique name for this dataset ';
    unique_name = input(prompt,'s');

    prompt   = 'Enter the directory to save the data ';
    dir_name = input(prompt,'s');

    save_var = unique_name;

    cd(dir_name);
    save(save_var);    
    
end   
