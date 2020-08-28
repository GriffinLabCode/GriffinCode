%% svmFormatting_trajectoryCoding
% this function formats data for classification of trajectory using stem
% bins
%
% ~~~ INPUTS ~~~
% Datafolders: Master directory
% int_name: the name of the int_file you want to use (ie 'Int_file.mat')
% correct: correct trials only if 1, all if 0
% vt_name: the name of the video tracking file (ie 'VT1.mat')
% missing_data: 'ignore','interp','exclude' for handling missing vt data
% task_type: Currently supports 'DNMP' or 'CA/DA/CD' 
% bin_num: number of bins
% stem_dir: the direction of stem (can be 'X' or 'Y' as in the x and y plane)
%
% ~~~ OUTPUTS ~~~
% FRdata: a struct array containing trajectory data
%
% written by John Stout. Last update 2/15/20

function [FRdata] = svmFormatting_startbox(Datafolders,int_name,correct,vt_name,missing_data,task_type)

    % calculate firing rate for all sessions
    cd(Datafolders);
    folder_names = dir; 
    
    if strfind(task_type,'DNMP') == 1
        prompt = 'Delay v ITI? [Y/N] ';
        trial_type = input(prompt,'s');
    end
    
    % trajectory?
    if strfind(trial_type,'N')
        prompt   = 'Dissociate trajectory? [Y/N] ';
        traj_inc = input(prompt,'s');
    end
    
    prompt = 'Do you want data before stem entry (type: stem)? Or after Startbox entry (type: sb)?';
    timePoint = input(prompt,'s');
    if timePoint == 'stem'
        fromStem = 1;
        fromSb   = 0;
    elseif timePoint == 'sb'
        fromStem = 0;
        fromSb   = 1;
    end
    
    for nn = 3:length(folder_names)

            Datafolders = Datafolders;
            cd(Datafolders);
            folder_names = dir;
            temp_folder = folder_names(nn).name;
            cd(temp_folder);
            datafolder = pwd;
            cd(datafolder);    

            % load animal parameters 
            varlist = who; %Find the variables that already exist
            varlist = strjoin(varlist','$|'); %Join into string, separating vars by '|'
            load(int_name,'-regexp', ['^(?!' varlist ')\w']);
                
            % get vt_data 
            [~,~,TimeStamps] = getVTdata(datafolder,missing_data,vt_name); 

            % load TTs
            clusters = dir('TT*.txt');

            % only include correct trials
            if correct == 1
                Int = Int(find(Int(:,4)==0),:);
            end
           
            % if DNMP was selected, separate sample and choice trials
            % if DNMP was selected, separate sample and choice trials
            if contains(task_type,'DNMP')
                if trial_type == 'S'
                    trials = (1:2:size(Int,1));
                elseif trial_type == 'C'
                    trials = (2:2:size(Int,1)); 
                end
            elseif contains(task_type,'DA') || contains(task_type,'CA') || contains(task_type,'CD')
                trials = 2:size(Int,1);
            end                 

            %% Create firing rate arrays
            for ci=1:length(clusters)
                cd(datafolder);
                spikeTimes = textread(clusters(ci).name);
                cluster    = clusters(ci).name(1:end-4);

                % initialize
                ts_bin = [];
                
                for triali = 1:length(trials)    

                    % index the timestamps and make bins that contain
                    % timestamps - notice that each cell contains about
                    % 30 values. This is consistent with the srate of
                    % 30 samples/sec for camera
                    
                    if fromSb == 1
                        for i = 0:9
                            ts_bin{i+1} = TimeStamps((TimeStamps > Int(trials(triali),8)+(i*1e6) & ...
                                TimeStamps < Int(trials(triali),8)+((i+1)*1e6)));
                        end
                    elseif fromStem == 1
                        % note that the storage of this is backwards. so
                        % although i = 9, ts_bin{1} is not data from 9 to
                        % 8. Instead ts_bin{10} is 9 to 8
                        for i = flipud(flipud(0:9)')'
                            ts_bin{i+1} = TimeStamps(find(TimeStamps > Int(trials(triali),1)-((i+1)*1e6) & ...
                                TimeStamps < Int(trials(triali),1)-(i*1e6)));
                        end
                    
                        % remove the first trial if you are on DNMP task
                        % and looking at sample trials (i.e. -20s from the
                        % start of the first trial is not task data) or if
                        % you selected a task like DA/CA
                        if trial_type == 'S'
                            if triali == 1
                                continue % skip the first trial
                            end
                        end
                    end

                    % extract spike data for each bin
                    for j = 1:length(ts_bin)
                        % index of the spikes
                        numspikes_ind = find(spikeTimes>ts_bin{j}(1) & ...
                            spikeTimes<ts_bin{j}(end));
                        % total spike count per bin
                        numspikes = length(numspikes_ind);
                        % time diff - this isn't perfectly 1 sec
                        time_temp = (ts_bin{j}(end) - ts_bin{j}(1))/1e6; 
                        % storage - FR bins shell1 = trial type
                        % shell 2 = session, shell3 =
                        % cluster, within the cluster shell there rows are
                        % trials columns are bins, each element is the
                        % corresponding firing rate
                        FRbins{nn-2}{ci}(triali,j) = numspikes/time_temp;
                    end                   
                end  
                
                % find left and right trials
                Int_trials   = Int(trials,:);
                left_trials  = find(Int_trials(:,3)==1);
                right_trials = find(Int_trials(:,3)==0); 
                
                FRlefts{nn-2}{ci}  = FRbins{nn-2}{ci}(left_trials,:);
                FRrights{nn-2}{ci} = FRbins{nn-2}{ci}(right_trials,:);
                
            end

        % display progress
        X = ['finished with session ',num2str(nn-2)];
        disp(X)
        
    end   
    
    % reformat
    FRdata.lefts  = horzcat(FRlefts{:});
    FRdata.rights = horzcat(FRrights{:}); 
    
end
