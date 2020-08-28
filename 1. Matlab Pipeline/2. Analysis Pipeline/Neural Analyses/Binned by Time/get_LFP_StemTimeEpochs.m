%% get_LFP_StemTimeEpochs
% gets lfp in stem bins, binned by time
%
%
% ~~~ INPUTS ~~~
% Datafolders: Master directory
% int_name: the name of the int_file you want to use (ie 'Int_file.mat')
% vt_name: the name of the video tracking file (ie 'VT1.mat')
% missing_data: what to do about missing vt data?
%               'interp','ignore','exclude'. I suggest 'interp' for this.
% task_type: Currently supports 'DNMP' or 'CA/DA/CD' 
% bin_num: number of bins
% stem_dir: the direction of stem (can be 'X' or 'Y' as in the x and y plane)
% CSC1: name of first CSC: 'CSC1.mat'
% CSC2: name of second CSC
% CSC3: name of third CSC
%
% -- OUTPUTS --%
% LFPdata: lfp data for all csc's included
% 
% written by John Stout. Last update 3/23/20

function [LFPdata] = get_LFP_StemTimeEpochs(Datafolders,int_name,vt_name,missing_data,CSC1,CSC2,CSC3)

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
            
            % get vt data
            [ExtractedX,ExtractedY,TimeStamps_VT] = getVTdata(datafolder,missing_data,vt_name);             

            % only include correct trials
            IntCorrect   = find(Int(:,4)==0);
            IntIncorrect = find(Int(:,4)==1);
            
            %% get lfp data
            
            % load data
            try
                try data1 = []; data1 = load(CSC1); catch; end            
                try data2 = []; data2 = load(CSC2); catch; end
                try data3 = []; data3 = load(CSC3); catch; end    
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
            params.Fs        = data1.SampleFrequencies(1);

            % convert timestamps
            LFPtimes = interp_TS_to_CSC_length_non_linspaced(data1.Timestamps, data1.Samples); % figure; subplot 121; plot(Timestamps); subplot 122; plot(Timestamps_new)
           
            % convert lfp data
            try data1LFP = []; data1LFP = data1.Samples(:)'; data1LFP_binned = []; catch; end
            try data2LFP = []; data2LFP = data2.Samples(:)'; data2LFP_binned = []; catch; end
            try data3LFP = []; data3LFP = data3.Samples(:)'; data3LFP_binned = []; catch; end
            
            % initialize position data
            posX = []; posY = []; TS = [];
            
            % index of trials
            trials = 1:size(Int,1);   
            
            for lagi = 1:6
                for triali = 1:size(Int,1) % loop across trials
                    % define where you want to perform the analysis
                    time = [];

                    if lagi == 1 
                        time = [(Int(triali,5)-(2*1e6)) (Int(triali,5)-(1.5*1e6))];
                    elseif lagi == 2
                        time = [(Int(triali,5)-(1.5*1e6)) (Int(triali,5)-(1*1e6))];                                        
                    elseif lagi == 3 
                        time = [(Int(triali,5)-(1*1e6)) (Int(triali,5)-(0.5*1e6))]; 
                    elseif lagi == 4
                        time = [(Int(triali,5)-(0.5*1e6)) (Int(triali,5))]; 
                    elseif lagi == 5
                        time = [(Int(triali,5)) (Int(triali,5)+(0.5*1e6))];    
                    elseif lagi == 6
                        time = [(Int(triali,5)+(0.5*1e6)) (Int(triali,5)+(1*1e6))];
                    end

                    % get data
                    try data1LFP_binned{triali}{lagi} = data1LFP(LFPtimes>time(1,1) & LFPtimes<time(1,2)); catch; end
                    try data2LFP_binned{triali}{lagi} = data2LFP(LFPtimes>time(1,1) & LFPtimes<time(1,2)); catch; end
                    try data3LFP_binned{triali}{lagi} = data3LFP(LFPtimes>time(1,1) & LFPtimes<time(1,2)); catch; end    

                    % get position data
                    posX{triali}{lagi} = ExtractedX(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
                    posY{triali}{lagi} = ExtractedY(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
                    TS{triali}{lagi}   = TimeStamps_VT(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
                end
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
            
            clearvars -except LFPdata Datafolders int_name task_type vt_name CSC1 CSC2 CSC3 info
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
