%% svmFormatting_trajectoryCoding
% this function formats data for classification of trajectory using stem
% bins
%
% ~~~ INPUTS ~~~
% Datafolders: Master directory
% int_name: the name of the int_file you want to use (ie 'Int_file.mat')
% vt_name: the name of the video tracking file (ie 'VT1.mat')
% task_type: Currently supports 'DNMP' or 'CA/DA/CD' 
% bin_num: number of bins
% stem_dir: the direction of stem (can be 'X' or 'Y' as in the x and y plane)
%
% ~~~ OUTPUTS ~~~
% FRdata: a struct array containing trajectory data
%
% written by John Stout. Last update 2/15/20

function [FRdata] = svmFormatting_delayTrajectoryCodingRetrospective(Datafolders,int_name,vt_name,task_type)

    % calculate firing rate for all sessions
    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');
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
            load(int_name);
            load(vt_name,'ExtractedX','ExtractedY','TimeStamps_VT');
            TimeStamps = TimeStamps_VT; % rename

            % load TTs
            clusters = dir('TT*.txt');

            % include all trials for retrospective

            % if DNMP was selected, separate sample and choice trials
            if task_type == 'DNMP'
                sample_trials = (1:2:size(Int,1));
                choice_trials = (2:2:size(Int,1)); 
                task_params   = 2;
            elseif task_type == 'CA/DA/CD'
                task_params = 1;
            end

            %% Create firing rate arrays
            if task_params == 2
                trials = sample_trials; % retrospective
            elseif task_params == 1
                trials = 1:size(Int,1);
            end

            for ci=1:length(clusters)
                cd(datafolder);
                spikeTimes = textread(clusters(ci).name);
                cluster    = clusters(ci).name(1:end-4);
                neuron_temp(1,ci).name = clusters(ci).name(1:end-4);                    

                for triali = 1:length(trials)    

                    % index the timestamps and make bins that contain
                    % timestamps - notice that each cell contains about
                    % 30 values. This is consistent with the srate of
                    % 30 samples/sec for camera
                    for i = 0:19
                        ts_bin{i+1} = TimeStamps(find(TimeStamps > Int(trials(triali),8)+(i*1e6) & ...
                            TimeStamps < Int(trials(triali),8)+((i+1)*1e6)));
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
    for ii = 1:length(FRdata.lefts{1})
        for iii = 1:length(FRdata.lefts)
            FRdata.leftsFormat{ii}(:,iii)  = FRdata.lefts{iii}(:,ii);
            FRdata.rightsFormat{ii}(:,iii) = FRdata.rights{iii}(:,ii);            
        end
    end 
    
    % generalized formatting for classifier
    for ii = 1:length(FRdata.leftsFormat) % loop across bins
        % concatenate horizontally such that left is top, right is bottom
        FRdata.svmFormat{ii} = vertcat(FRdata.leftsFormat{ii}, FRdata.rightsFormat{ii});
    end
end
