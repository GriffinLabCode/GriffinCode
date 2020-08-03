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

function [BehData] = get_ratSpeed(Datafolders,int_name,vt_name,task_type,stem_dir,numbins,correct)

    % calculate firing rate for all sessions
    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions');
    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Useful Functions')
    cd(Datafolders);
    folder_names = dir;
    
    if task_type == 'DNMP'
        prompt = 'Sample or choice? [S/C] ';
        trial_type = input(prompt,'s');
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
            load(int_name);
            load(vt_name,'ExtractedX','ExtractedY','TimeStamps_VT');
            TimeStamps = TimeStamps_VT; % rename
            
            % correct tracking errors     
            [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);             

            %{
            % convert - this is for the left room in Wolf hall, may need
            % adjusting
            ExtractedX = round(ExtractedX./2.09);
            ExtractedY = round(ExtractedY./2.04);            
            %}
            
            % load TTs
            clusters = dir('TT*.txt');

            % only include correct trials
            if correct == 1
                Int = Int(find(Int(:,4)==0),:);
            end
            
            % set sampling frequency
            sfreq = ceil(29.97);            
            
            %% create bins
            ymin = 135; % do not underestimate - you'll end up in start-box
            ymax = 400; % over estimate - this doesn't hurt anything
            bins = round(linspace(ymin,ymax,numbins));
            
            % if DNMP was selected, separate sample and choice trials
            if task_type == 'DNMP'
                if trial_type == 'S'
                    trials = (1:2:size(Int,1));
                elseif trial_type == 'C'
                    trials = (2:2:size(Int,1)); 
                end
                task_params = 2;
            elseif task_type == 'CA/DA/CD'
                task_params = 1;
            end            
            
            %% Create firing rate arrays
            if task_params == 2 
                trials = trials;
            elseif task_params == 1
                trials = 1:size(Int,1);
            end                              

            for triali = 1:length(trials)

                % get position data
                PosX   = ExtractedX(TimeStamps_VT>Int(trials(triali),1) & TimeStamps_VT<Int(trials(triali),6));
                PosY   = ExtractedY(TimeStamps_VT>Int(trials(triali),1) & TimeStamps_VT<Int(trials(triali),6));  
                ts_ind = find(TimeStamps_VT>Int(trials(triali),1) & TimeStamps_VT<Int(trials(triali),6));
                trialTimes = TimeStamps_VT(ts_ind);

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
                times_around = trialTimes(k); 

                try
                    for j = 1:length(bins)-1
                        % index of positions
                        pos_ind = find(TimeStamps_VT>=times_around(j) & ...
                            TimeStamps_VT<times_around(j+1));

                        % get Y from index, estimate difference
                        if stem_dir == 'Y'
                            pos_ind = ExtractedY(pos_ind);
                        elseif stem_dir == 'X'
                            pos_ind = ExtractedX(pos_ind);    
                        end

                        % difference in position for start and end of bin
                        pos_end = pos_ind(end);
                        pos_st  = pos_ind(1);
                        posDiff(triali,j) = (pos_end-pos_st);

                        % difference in time spent
                        timeSpent(triali,j) = (times_around(j+1)-times_around(j))/1e6;

                        % velocity
                        velocity(triali,j) = posDiff(triali,j)/timeSpent(triali,j);
                    end 
                catch
                    % tracking errors can result in lost data. While
                    % the correct_tracking_errors can correct data lost
                    % at 0, it cannot correct for data that is recorded
                    % elsewhere on the maze somehow (like if the data
                    % was recorded as the rat being in return arm when
                    % actually in stem)
                    posDiff(triali,:) = NaN; 
                    timeSpent(triali,:) = NaN; 
                    velocity(triali,:) = NaN; 
                end
            end 
                   
            % find left and right trials
            L_trials = find(Int(trials,3)==1);
            R_trials = find(Int(trials,3)==0);

            % get sample/choice
            BehData.vel{nn-2}    = velocity;
            BehData.tSpent{nn-2} = timeSpent;

            % get left sample/choice
            BehData.L_vel{nn-2}    = velocity(L_trials,:);
            BehData.L_tSpent{nn-2} = timeSpent(L_trials,:);                

            % get right sample/choice
            BehData.R_vel{nn-2}    = velocity(R_trials,:);
            BehData.R_tSpent{nn-2} = timeSpent(R_trials,:);

            X = ['finished with session ',num2str(nn-2)];
            disp(X)

            clear velocity timeSpent posDiff
    end
    
    % reformat sample/choice
    BehData.MeanVel = cellfun(@nanmean,BehData.vel,'UniformOutput',false);
    BehData.MeanVel = vertcat(BehData.MeanVel{:});
    BehData.AvSessVel = mean(BehData.MeanVel);
    BehData.SEMSessVel = stderr(BehData.MeanVel);
       
    BehData.MeanSpent = cellfun(@nanmean,BehData.tSpent,'UniformOutput',false);
    BehData.MeanSpent = vertcat(BehData.MeanSpent{:});
    BehData.AvSessSpent = mean(BehData.MeanSpent);
    BehData.SEMSessSpent = stderr(BehData.MeanSpent);  
    
    % reformat left sample/choice
    BehData.L_MeanVel = cellfun(@nanmean,BehData.L_vel,'UniformOutput',false);
    BehData.L_MeanVel = vertcat(BehData.L_MeanVel{:});
    BehData.L_AvSessVel = mean(BehData.L_MeanVel);
    BehData.L_SEMSessVel = stderr(BehData.L_MeanVel);
    
    BehData.L_MeanSpent = cellfun(@nanmean,BehData.L_tSpent,'UniformOutput',false);
    BehData.L_MeanSpent = vertcat(BehData.L_MeanSpent{:});
    BehData.L_AvSessSpent = mean(BehData.L_MeanSpent);
    BehData.L_SEMSessSpent = stderr(BehData.L_MeanSpent);
 
    % reformat right sample/choice
    BehData.R_MeanVel = cellfun(@nanmean,BehData.R_vel,'UniformOutput',false);
    BehData.R_MeanVel = vertcat(BehData.R_MeanVel{:});
    BehData.R_AvSessVel = mean(BehData.R_MeanVel);
    BehData.R_SEMSessVel = stderr(BehData.R_MeanVel);
    
    BehData.R_MeanSpent = cellfun(@nanmean,BehData.R_tSpent,'UniformOutput',false);
    BehData.R_MeanSpent = vertcat(BehData.R_MeanSpent{:});
    BehData.R_AvSessSpent = mean(BehData.R_MeanSpent);
    BehData.R_SEMSessSpent = stderr(BehData.R_MeanSpent);
      
end   
