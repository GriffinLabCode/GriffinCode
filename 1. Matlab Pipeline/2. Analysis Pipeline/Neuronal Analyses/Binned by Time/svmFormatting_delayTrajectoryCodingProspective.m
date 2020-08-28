%% svmFormatting_trajectoryCoding
% this function formats data for classification of trajectory using stem
% bins
%
% ~~~ INPUTS ~~~
% Datafolders: Master directory
% int_name: the name of the int_file you want to use (ie 'Int_file.mat')
% vt_name: the name of the video tracking file (ie 'VT1.mat')
% missing_data: missing vt data, 'interp','ignore','exclude'
% task_type: Currently supports 'DNMP' or 'CA/DA/CD' 
% bin_num: number of bins
% stem_dir: the direction of stem (can be 'X' or 'Y' as in the x and y plane)
% correct_only: 1 or 0, 1 if you want correct only
%
% ~~~ OUTPUTS ~~~
% FRdata: a struct array containing trajectory data
%
% written by John Stout. Last update 8/11/20

function [FRdata] = svmFormatting_delayTrajectoryCodingProspective(Datafolders,int_name,vt_name,missing_data,task_type,correct_only)

    % calculate firing rate for all sessions
    cd(Datafolders);
    folder_names = dir;  
    
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

            % include only correct?
            if correct_only == 1
                Int((Int(:,4)==1),:)=[];
            end
            
            % if DNMP was selected, separate sample and choice trials
            if contains(task_type,'DNMP')
                sample_trials = (1:2:size(Int,1));
                choice_trials = (2:2:size(Int,1)); 
                trials = choice_trials; % set to choice_trials if prospective
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
                
                for triali = 2:length(trials)    

                    % index the timestamps and make bins that contain
                    % timestamps - notice that each cell contains about
                    % 30 values. This is consistent with the srate of
                    % 30 samples/sec for camera
                    
                    % cell array element 1 is -(max you set). So if you set
                    % vari = -19:0, element 1 is from -20 to -19. final
                    % element is -1 to 0.
                    vari = -19:2;
                    for i = 1:length(vari) % set it to -19:0 for delay, but -19:2 is delay and first two sec of stem
                        ts_bin{i} = TimeStamps((TimeStamps > Int(trials(triali),1)+((vari(i)-1)*1e6) & ...
                            TimeStamps < Int(trials(triali),1)+(vari(i)*1e6)));
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
    
    % remove the first row, there is zero spks bc I'm doing 2:length... so
    % the first row is nothing
    for ii = 1:length(FRdata.lefts)
        FRdata.lefts{ii}(1,:)=[];
        FRdata.rights{ii}(1,:)=[];
    end

end
