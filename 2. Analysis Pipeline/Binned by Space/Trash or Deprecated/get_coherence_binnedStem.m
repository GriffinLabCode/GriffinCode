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
% correct: correct trials
%
% written by John Stout. Last update 2/21/20

function [FRdata] = get_coherence_binnedStem(Datafolders,int_name,vt_name,task_type,stem_dir,numbins,correct)

    % calculate firing rate for all sessions
    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');
    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions');
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
            load(int_name);
            load(vt_name,'ExtractedX','ExtractedY','TimeStamps_VT');
            TimeStamps = TimeStamps_VT; % rename
            
            % correct tracking errors     
            [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);             

            % only include correct trials
            IntCorrect   = find(Int(:,4)==0);
            IntIncorrect = find(Int(:,4)==1);
            
            %% create bins
            ymin = 135; % do not underestimate - you'll end up in start-box
            ymax = 400; % over estimate - this doesn't hurt anything
            bins = round(linspace(ymin,ymax,numbins));

            %% get lfp data
            
            % load data
            data1 = load('HPC.mat');
            data2 = load('mPFC.mat');
            data3 = load('Re.mat');      
            
            % set parameters
            params.tapers    = [2 3];
            params.trialave  = 1;
            params.err       = [2 .05];
            params.pad       = 0;
            params.fpass     = [0 100]; % [1 100]
            params.movingwin = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
            params.Fs        = data1.SampleFrequencies(1);

            % convert timestamps
            Timestamps = interp_TS_to_CSC_length_non_linspaced(data1.Timestamps, data1.Samples); % figure; subplot 121; plot(Timestamps); subplot 122; plot(Timestamps_new)
           
            % convert lfp data
            data1LFP = data1.Samples(:)';
            data2LFP = data2.Samples(:)';
            data3LFP = data3.Samples(:)';
              
            % index of trials
            trials = 1:size(Int,1);   
            
            for triali = 1:size(Int,1)    

                % get an index of timestamps and timestamps
                ts_ind = find(TimeStamps_VT > Int(trials(triali),1) & ...
                    TimeStamps_VT < Int(trials(triali),6)); 
                ts_temp = TimeStamps_VT(ts_ind); 

                % use X or Y data depending on the maze orientation
                if stem_dir == 'Y'
                    loc_temp = ExtractedY(ts_ind);
                elseif stem_dir == 'X'
                    loc_temp = ExtractedX(ts_ind);
                else
                    disp('Must define the direction of stem')
                    return
                end

                % find locations that closely match the bins you defined
                k = dsearchn(loc_temp',bins'); 

                % index the timestamps using k to get timestamps around the
                % bins selected
                times_around = ts_temp(k); 

                for j = 1:length(bins)-1
                    % index of the spikes
                    data1LFP_binned{triali}{j} = data1LFP(find(Timestamps>times_around(j) & ...
                        Timestamps<times_around(j+1)));
                    data2LFP_binned{triali}{j} = data2LFP(find(Timestamps>times_around(j) & ...
                        Timestamps<times_around(j+1)));
                    data3LFP_binned{triali}{j} = data3LFP(find(Timestamps>times_around(j) & ...
                        Timestamps<times_around(j+1)));                    
                end                   
            end 

            % get correct and incorrect
            data1LFP_cor = data1LFP_binned(IntCorrect)

            FRsam{nn-2}{ci}  = FRbins{nn-2}{ci}(sample_trials,:);
            FRcho{nn-2}{ci}  = FRbins{nn-2}{ci}(choice_trials,:);
            behCho{nn-2}{ci} = Int(choice_trials,:);
            behSam{nn-2}{ci} = Int(sample_trials,:);

             X = ['finished with session ',num2str(nn-2)];
             disp(X)
    end
    
    % reformat
    FRdata.sample = horzcat(FRsam{:});
    FRdata.choice = horzcat(FRcho{:}); 
    FRdata.behSam = horzcat(behSam{:});
    FRdata.behCho = horzcat(behCho{:});
    
    clearvars -except FRdata Datafolders int_name numbins stem_dir task_type vt_name correct
    
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
