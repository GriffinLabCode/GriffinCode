%% svmFormatting_trajectoryCoding
% this function formats data for classification of trajectory using stem
% bins
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
%
% written by John Stout. Last update 2/15/20

function [FRdata] = svmFormatting_trajectoryCoding_binnedStem(Datafolders,int_name,vt_name,task_type,stem_dir,numbins)


    % calculate firing rate for all sessions
    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');
    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions');
    cd(Datafolders);
    folder_names = dir;
    
    if strfind(task_type,'DNMP') == 1
        prompt = 'Sample or choice? [S/C] ';
        trial_type = input(prompt,'s');
    end
    
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
            vtData = load(vt_name);
            ExtractedX = vtData.ExtractedX;
            ExtractedY = vtData.ExtractedY;
            try
                TimeStamps = vtData.TimeStamps_VT; % rename
            catch % sometimes the ..._VT variable is not defined
                TimeStamps = vtData.TimeStamps;
            end
            
            % correct tracking errors     
            [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);             

            % load TTs
            clusters = dir('TT*.txt');

            % only include correct trials
            Int = Int(find(Int(:,4)==0),:);

            % if DNMP was selected, separate sample and choice trials
            if strfind(task_type,'DNMP') == 1
                if trial_type == 'S'
                    trials = (1:2:size(Int,1));
                elseif trial_type == 'C'
                    trials = (2:2:size(Int,1)); 
                end
                task_params = 2;
            elseif strfind(task_type,'DA') == 1 || strfind(task_type,'CA') == 1 || strfind(task_type,'CD') == 1
                task_params = 1;
            end
            
            %% create bins
            if stem_dir == 'Y'
                PosMin = 135; % do not underestimate - you'll end up in start-box
                PosMax = 400; % over estimate - this doesn't hurt anything
            elseif stem_dir == 'X'
                PosMin = 215;
                PosMax = 641;
            end
            bins = round(linspace(PosMin,PosMax,numbins));

            %% Create firing rate arrays
                if task_params == 2 
                    trials = trials;
                elseif task_params == 1
                    trials = 1:size(Int,1);
                end
            
                for ci=1:length(clusters)
                    cd(datafolder);
                    spikeTimes = textread(clusters(ci).name);
                    cluster    = clusters(ci).name(1:end-4);
                    neuron_temp(1,ci).name = clusters(ci).name(1:end-4);                    

                    for triali = 1:length(trials)    

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
                            time_temp(triali,j) = times_around(j+1) - times_around(j); 
                            time_temp(triali,j) = time_temp(triali,j)/1e6;
                            % storage - FR bins shell1 = trial type
                            % shell 2 = session, shell3 =
                            % cluster, within the cluster shell there rows are
                            % trials columns are bins, each element is the
                            % corresponding firing rate
                            FRbins{nn-2}{ci}(triali,j) = numspikes/time_temp(triali,j);
                        end                   
                    end 
                    
                    % find left and right trials
                    Int_trials   = Int(trials,:);
                    left_trials  = find(Int_trials(:,3)==1);
                    right_trials = find(Int_trials(:,3)==0); 

                    FRlefts{nn-2}{ci}  = FRbins{nn-2}{ci}(left_trials,:);
                    FRrights{nn-2}{ci} = FRbins{nn-2}{ci}(right_trials,:);
                end
             X = ['finished with session ',num2str(nn-2)];
             disp(X)
    end
    
    % reformat
    FRdata.lefts  = horzcat(FRlefts{:});
    FRdata.rights = horzcat(FRrights{:}); 
    
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
