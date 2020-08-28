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
% missing_data: what to do about missing vt_data?
%               'interp','ignore','exclude' - I suggest interp for this.
% task_type: Currently supports 'DNMP' or 'CA/DA/CD' 
% bin_num: number of bins
% stem_dir: the direction of stem (can be 'X' or 'Y' as in the x and y plane)
% CSC1: name of first CSC: 'CSC1.mat'
% CSC2: name of second CSC
% CSC3: name of third CSC
% 
% written by John Stout. Last update 3/23/20

function [LFPdata] = get_LFP_binnedStem(Datafolders,int_name,vt_name,missing_data,stem_dir,stemMin,stemMax,numbins,CSC1,CSC2,CSC3)

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
            % only load undefined variables
            varlist = who; %Find the variables that already exist
            varlist = strjoin(varlist','$|'); %Join into string, separating vars by '|'
            load(int_name,'-regexp', ['^(?!' varlist ')\w']);

            % get vt_data 
            [ExtractedX,ExtractedY,TimeStamps_VT] = getVTdata(datafolder,missing_data,vt_name);             

            % only include correct trials
            IntCorrect   = find(Int(:,4)==0);
            IntIncorrect = find(Int(:,4)==1);
            
            %% create bins
            %stemMin = 135; % do not underestimate - you'll end up in start-box
            %stemMax = 400; % over estimate - this doesn't hurt anything
            bins = round(linspace(stemMin,stemMax,numbins));

            %% get lfp data

            % set parameters - make default parameters with fun
            params.tapers    = [3 5];
            params.trialave  = 0;
            params.err       = [2 .05];
            params.pad       = 0;
            params.fpass     = [0 100]; % [1 100]
            params.movingwin = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
            params.Fs        = data1.SampleFrequencies(1);
            
            % do csc specific actions
            if isempty(CSC1)==0
                % load
                data1 = load(CSC1);
                % convert
                data1LFP = data1.Samples(:)';
                % initialize
                data1LFP_binned = [];                
            end
            if isempty(CSC2)==0
                % load
                data2 = load(CSC2);
                % convert
                data2LFP = data2.Samples(:)';
                % initialize
                data2LFP_binned = [];                   
            end
            if isempty(CSC3)==0
                % load
                data3 = load(CSC3); 
                % convert
                data3LFP = data3.Samples(:)';
                % initialize
                data3LFP_binned = [];                   
            end          
            
            % convert timestamps
            LFPtimes = interp_TS_to_CSC_length_non_linspaced(data1.Timestamps, data1.Samples); % figure; subplot 121; plot(Timestamps); subplot 122; plot(Timestamps_new)
           
            % index of trials
            trials = 1:size(Int,1);   
            
            for triali = 1:size(Int,1)    

                % get an index of timestamps and timestamps
                ts_ind = []; ts_temp = [];
                ts_ind = find(TimeStamps_VT > Int(trials(triali),1) & ...
                    TimeStamps_VT < Int(trials(triali),6)); 
                ts_temp = TimeStamps_VT(ts_ind); 

                % use X or Y data depending on the maze orientation
                loc_temp = [];
                if stem_dir == 'Y'
                    loc_temp = ExtractedY(ts_ind);
                elseif stem_dir == 'X'
                    loc_temp = ExtractedX(ts_ind);
                else
                    disp('Must define the direction of stem')
                    return
                end

                % find locations that closely match the bins you defined
                k = [];
                k = dsearchn(loc_temp',bins'); 

                % index the timestamps using k to get timestamps around the
                % bins selected
                times_aroundVT = [];
                times_aroundVT = ts_temp(k); 
                
                % now get times_aroundLFP
                %k2 = dsearchn(LFPtimes',times_aroundVT'); 
                %times_aroundLFP = LFPtimes(k2);
                
                for j = 1:length(bins)-1
                    % index of the spikes
                    if isempty(CSC1)==0
                        data1LFP_binned{triali}{j} = data1LFP((LFPtimes>times_aroundVT(j) & ...
                            LFPtimes<times_aroundVT(j+1)));
                    end
                    if isempty(CSC2)==0
                        data2LFP_binned{triali}{j} = data2LFP((LFPtimes>times_aroundVT(j) & ...
                            LFPtimes<times_aroundVT(j+1)));
                    end
                    if isempty(CSC3)==0
                        data3LFP_binned{triali}{j} = data3LFP((LFPtimes>times_aroundVT(j) & ...
                            LFPtimes<times_aroundVT(j+1))); 
                    end
                end                   
            end 

            % get correct and incorrect
            if isempty(CSC1)==0
                LFPdata.data1LFP_cor{nn-2} = data1LFP_binned(IntCorrect);
                LFPdata.data1LFP_inc{nn-2} = data1LFP_binned(IntIncorrect);    
            end
            
            if isempty(CSC2)==0
                LFPdata.data2LFP_cor{nn-2} = data2LFP_binned(IntCorrect);
                LFPdata.data2LFP_inc{nn-2} = data2LFP_binned(IntIncorrect);
            end
            
            if isempty(CSC3)==0
                LFPdata.data3LFP_cor{nn-2} = data3LFP_binned(IntCorrect);          
                LFPdata.data3LFP_inc{nn-2} = data3LFP_binned(IntIncorrect);
            end

            % store bhavior
            LFPdata.beh{nn-2} = Int;
            
            % store parameters
            LFPdata.params{nn-2} = params;
            
            % store names of lfp
            LFPdata.names.data1 = CSC1;
            LFPdata.names.data2 = CSC2;
            LFPdata.names.data3 = CSC3;

            X = ['finished with session ',num2str(nn-2)];
            disp(X)
            
            % offline steps should include cleaning, removing artifacts,
            % then running analyses.
    end
    
    clearvars -except LFPdata Datafolders int_name numbins stem_dir task_type vt_name correct
    
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
