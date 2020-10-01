%% svmFormatting_trajectoryCoding
% this function formats data for classification of task phase during stem
% traversals. It is for DNMP task.
%
% ~~~ INPUTS ~~~
% Datafolders: Master directory
% int_name: the name of the int_file you want to use (ie 'Int_file.mat')
% vt_name: the name of the video tracking file (ie 'VT1.mat')
% missing_data: can be 'interp', 'ignore', 'exclude'. This is for vt
%                   missing data
% task_type: Currently supports 'DNMP' or 'CA/DA/CD' 
% bin_num: number of bins
% stem_dir: the direction of stem (can be 'X' or 'Y' as in the x and y plane)
% correct: correct trials
%
% written by John Stout. Last update 2/21/20

function [FRdata] = svmFormatting_taskPhaseCoding_binnedStem(Datafolders,int_name,vt_name,missing_data,stem_dir,stemMin,stemMax,numbins,correct)

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
            clear Int            
            varlist = who; %Find the variables that already exist
            varlist = strjoin(varlist','$|'); %Join into string, separating vars by '|'
            load(int_name,'-regexp', ['^(?!' varlist ')\w']);
    
            % get vt_data 
            [ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);             

            % load TTs
            clusters = dir('TT*.txt');

            % only include correct trials
            if correct == 1
                Int = Int((Int(:,4)==0),:);
            end
            
            %% create bins
            %stemMin = 135; % do not underestimate - you'll end up in start-box
            %stemMax = 400; % over estimate - this doesn't hurt anything
            bins = round(linspace(stemMin,stemMax,numbins));

            %% Create firing rate arrays
            trials = 1:size(Int,1);
            
                for ci=1:length(clusters)
                    cd(datafolder);
                    spikeTimes = textread(clusters(ci).name);
                    cluster    = clusters(ci).name(1:end-4);
                    neuron_temp(1,ci).name = clusters(ci).name(1:end-4);                    

                    for triali = 1:size(Int,1)    

                        % get an index of timestamps and timestamps
                        ts_ind = find(TimeStamps > Int(trials(triali),1) & ...
                            TimeStamps < Int(trials(triali),6)); 
                        ts_temp = TimeStamps(ts_ind); 

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
                            numspikes_ind = find(spikeTimes>times_around(j) & ...
                                spikeTimes<times_around(j+1));
                            % total spike count per bin
                            numspikes = length(numspikes_ind);
                            % time diff
                            time_temp = times_around(j+1) - times_around(j); 
                            time_temp = time_temp/1e6;
                            % storage - FR bins shell1 = trial type
                            % shell 2 = session, shell3 =
                            % cluster, within the cluster shell there rows are
                            % trials columns are bins, each element is the
                            % corresponding firing rate
                            FRbins{nn-2}{ci}(triali,j) = numspikes/time_temp;
                        end                   
                    end 
                    
                    % find left and right trials
                    Int_trials    = Int(trials,:);
                    sample_trials = 1:2:size(Int,1);
                    choice_trials = 2:2:size(Int,1);

                    FRsam{nn-2}{ci}  = FRbins{nn-2}{ci}(sample_trials,:);
                    FRcho{nn-2}{ci}  = FRbins{nn-2}{ci}(choice_trials,:);
                    behCho{nn-2}{ci} = Int(choice_trials,:);
                    behSam{nn-2}{ci} = Int(sample_trials,:);
                end
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
