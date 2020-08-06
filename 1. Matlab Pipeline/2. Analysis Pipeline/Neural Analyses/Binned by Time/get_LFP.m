%% svmFormatting_trajectoryCoding
% this function formats data for classification of task phase during stem
% traversals. It is for DNMP task.
%
% NOT FINISHED
%
% ~~~ INPUTS ~~~
% Datafolders: Master directory
% int_name: the name of the int_file you want to use (ie 'Int_file.mat')
% vt_name: the name of the video tracking file (ie 'VT1.mat')
% task_type: Currently supports 'DNMP' or 'CA/DA/CD' 
% bin_num: number of bins
% stem_dir: the direction of stem (can be 'X' or 'Y' as in the x and y plane)
% CSC1: name of first CSC: 'CSC1.mat'
% CSC2: name of second CSC
% CSC3: name of third CSC
% 
% written by John Stout. Last update 3/23/20

function [LFPdata] = get_LFP(Datafolders,int_name,vt_name,task_type,CSC1,CSC2)

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
            
            % only define these one time, on the very first loop
            if  nn == looper(1)
                prompt = 'Enter maze section based on Int (ie T-entry == 5) ';
                mazeIdx = str2num(input(prompt,'s'));  

                prompt = 'Enter time from that maze section (ie 1 == 1 second) ';
                timing = str2num(input(prompt,'s'));
            end            

            % load animal parameters 
            load(int_name);
            load(vt_name,'ExtractedX','ExtractedY','TimeStamps_VT');
            TimeStamps = TimeStamps_VT; % rename
            
            % correct tracking errors     
            [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);             

            % only include correct trials
            IntCorrect   = find(Int(:,4)==0);
            IntIncorrect = find(Int(:,4)==1);
            
            %% get lfp data
            
            % load data
            data1 = load(CSC1);
            data2 = load(CSC2);
            
            % set parameters - make default parameters with fun
            params.tapers    = [3 5];
            params.trialave  = 0;
            params.err       = [2 .05];
            params.pad       = 0;
            params.fpass     = [0 100]; % [1 100]
            params.movingwin = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
            params.Fs        = data1.SampleFrequencies(1);

            % convert timestamps
            LFPtimes = interp_TS_to_CSC_length_non_linspaced(data1.Timestamps, data1.Samples); % figure; subplot 121; plot(Timestamps); subplot 122; plot(Timestamps_new)
           
            % convert lfp data
            data1LFP = data1.Samples(:)';
            data2LFP = data2.Samples(:)';
              
            % index of trials
            trials = 1:size(Int,1);   
            
            for triali = 1:size(Int,1) % loop across trials
                
                % define where you want to perform the analysis
                time = [];                
                time = [(Int(triali,mazeIdx)-(timing*1e6)) (Int(triali,mazeIdx))];
                
                % get data
                data1LFP_binned{triali} = data1LFP(LFPtimes>time(1,1) & LFPtimes<time(1,2));
                data2LFP_binned{triali} = data2LFP(LFPtimes>time(1,1) & LFPtimes<time(1,2));  
            
                % get position data
                posX{triali} = ExtractedX(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
                posY{triali} = ExtractedY(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
                TS{triali}   = TimeStamps_VT(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
            end

            % get correct and incorrect
            LFPdata.data1LFP_cor{nn-2} = data1LFP_binned(IntCorrect);
            LFPdata.data2LFP_cor{nn-2} = data2LFP_binned(IntCorrect);
            
            LFPdata.data1LFP_inc{nn-2} = data1LFP_binned(IntIncorrect);
            LFPdata.data2LFP_inc{nn-2} = data2LFP_binned(IntIncorrect);

            % store bhavior
            LFPdata.beh{nn-2} = Int;
            
            % store parameters
            LFPdata.params{nn-2} = params;
            
            % store names of lfp
            LFPdata.names.data1 = CSC1;
            LFPdata.names.data2 = CSC2;
            
            % store position data
            LFPdata.posX{nn-2}     = posX;
            LFPdata.posY{nn-2}     = posY;
            LFPdata.posTimes{nn-2} = TS;

            X = ['finished with session ',num2str(nn-2)];
            disp(X)
            
            % offline steps should include cleaning, removing artifacts,
            % then running analyses.
    end
    
    clearvars -except LFPdata Datafolders int_name numbins stem_dir task_type vt_name correct timing mazeIdx
    
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
