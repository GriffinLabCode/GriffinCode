%% svmFormatting_trajectoryCoding
% this function formats data for classification of trajectory using stem
% bins
%
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

function [FRdata] = svmFormatting_trajectoryCoding_MazePlace(Datafolders,int_name,vt_name,missing_data,task_type)


    % calculate firing rate for all sessions
    cd(Datafolders);
    folder_names = dir;
    
    if task_type == 'DNMP'
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
            % only load undefined variables
            clear Int
            varlist = who; %Find the variables that already exist
            varlist = strjoin(varlist','$|'); %Join into string, separating vars by '|'
            load(int_name,'-regexp', ['^(?!' varlist ')\w']);

            % get vt_data 
            [~,~,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);                      

            % load TTs
            clusters = dir('TT*.txt');

            % only include correct trials
            if correct == 1
                Int = Int((Int(:,4)==0),:);
            end

            % if DNMP was selected, separate sample and choice trials
            if contains(task_type,'DNMP')
                if trial_type == 'S'
                    trials = (1:2:size(Int,1));
                elseif trial_type == 'C'
                    trials = (2:2:size(Int,1)); 
                end
            elseif contains(task_type,'DA') || contains(task_type,'CA') || contains(task_type,'CD')
                trials = 1:size(Int,1);
            end

            %% Create firing rate arrays           
            for ci=1:length(clusters)
                cd(datafolder);
                spikeTimes = textread(clusters(ci).name);
                cluster    = clusters(ci).name(1:end-4);

                for triali = 1:length(trials)    

                    % get an index of timestamps and timestamps
                    times_around = TimeStamps((TimeStamps > Int(trials(triali),7) & ...
                        TimeStamps < Int(trials(triali),8))); 

                    try
                        % index of the spikes
                        numspikes_ind = find(spikeTimes>times_around(1) & ...
                            spikeTimes<times_around(end));

                        % total spike count per bin
                        numspikes = length(numspikes_ind);

                        % time diff
                        time_temp = Int(trials(triali),8) - Int(trials(triali),7); 
                        time_diff = time_temp/1e6;
                        % storage - FR bins shell1 = trial type
                        % shell 2 = session, shell3 =
                        % cluster, within the cluster shell there rows are
                        % trials columns are bins, each element is the
                        % corresponding firing rate
                        FRbins{nn-2}{ci}(triali) = numspikes/time_diff;
                    catch
                        FRbins{nn-2}{ci}(triali) = NaN;
                    end   
                end 

                % find left and right trials
                Int_trials   = Int(trials,:);
                left_trials  = find(Int_trials(:,3)==1);
                right_trials = find(Int_trials(:,3)==0); 

                FRlefts{nn-2}{ci}  = FRbins{nn-2}{ci}(left_trials);
                FRrights{nn-2}{ci} = FRbins{nn-2}{ci}(right_trials);
            end
                
             X = ['finished with session ',num2str(nn-2)];
             disp(X)
    end
    
    % reformat
    FRdata.lefts  = horzcat(FRlefts{:});
    FRdata.rights = horzcat(FRrights{:}); 
    
    % invert
    for i = 1:length(FRdata.lefts)
        FRdata.lefts{i}  = FRdata.lefts{i}';
        FRdata.rights{i} = FRdata.rights{i}';
    end
    
end   
