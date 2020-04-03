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
            
            %% select trial types
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
            
            trials = 1:size(Int,1);                   

                for triali = 1:size(Int,1)    

                    % get position data
                    PosX   = ExtractedX(TimeStamps_VT>Int(triali,1) & TimeStamps_VT<Int(triali,6));
                    PosY   = ExtractedY(TimeStamps_VT>Int(triali,1) & TimeStamps_VT<Int(triali,6));  
                    ts_ind = find(TimeStamps_VT>Int(triali,1) & TimeStamps_VT<Int(triali,6));
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
                sample_trials  = 1:2:size(Int,1);
                choice_trials  = 2:2:size(Int,1);
                Int_sample     = Int(sample_trials,:);
                Int_choice     = Int(choice_trials,:);
                sampleL_trials = find(Int_sample(:,3)==1);
                sampleR_trials = find(Int_sample(:,3)==0);
                choiceL_trials = find(Int(:,3)==1);
                choiceR_trials = find(Int(:,3)==0);

                % get sample/choice
                BehData.sam_vel{nn-2}    = velocity(sample_trials,:);
                BehData.cho_vel{nn-2}    = velocity(choice_trials,:);
                BehData.sam_tSpent{nn-2} = timeSpent(sample_trials,:);
                BehData.cho_tSpent{nn-2} = timeSpent(choice_trials,:);                
                  
                % get left sample/choice
                BehData.samL_vel{nn-2}    = velocity(sampleL_trials,:);
                BehData.choL_vel{nn-2}    = velocity(choiceL_trials,:);
                BehData.samL_tSpent{nn-2} = timeSpent(sampleL_trials,:);
                BehData.choL_tSpent{nn-2} = timeSpent(choiceL_trials,:);                
                
                % get right sample/choice
                BehData.samR_vel{nn-2}    = velocity(sampleR_trials,:);
                BehData.choR_vel{nn-2}    = velocity(choiceR_trials,:);
                BehData.samR_tSpent{nn-2} = timeSpent(sampleR_trials,:);
                BehData.choR_tSpent{nn-2} = timeSpent(choiceR_trials,:);                
                                  
                X = ['finished with session ',num2str(nn-2)];
                disp(X)
                 
                clear velocity timeSpent posDiff
    end
    
    % reformat sample/choice
    BehData.sam_MeanVel = cellfun(@nanmean,BehData.sam_vel,'UniformOutput',false);
    BehData.sam_MeanVel = vertcat(BehData.sam_MeanVel{:});
    BehData.sam_AvSessVel = mean(BehData.sam_MeanVel);
    BehData.sam_SEMSessVel = stderr(BehData.sam_MeanVel);
    
    BehData.cho_MeanVel = cellfun(@nanmean,BehData.cho_vel,'UniformOutput',false);
    BehData.cho_MeanVel = vertcat(BehData.cho_MeanVel{:}); 
    BehData.cho_AvSessVel = mean(BehData.cho_MeanVel);
    BehData.cho_SEMSessVel = stderr(BehData.cho_MeanVel);
    
    BehData.sam_MeanSpent = cellfun(@nanmean,BehData.sam_tSpent,'UniformOutput',false);
    BehData.sam_MeanSpent = vertcat(BehData.sam_MeanSpent{:});
    BehData.sam_AvSessSpent = mean(BehData.sam_MeanSpent);
    BehData.sam_SEMSessSpent = stderr(BehData.sam_MeanSpent);
    
    BehData.cho_MeanSpent = cellfun(@nanmean,BehData.cho_tSpent,'UniformOutput',false);
    BehData.cho_MeanSpent = vertcat(BehData.cho_MeanSpent{:}); 
    BehData.cho_AvSessSpent = mean(BehData.cho_MeanSpent);
    BehData.cho_SEMSessSpent = stderr(BehData.cho_MeanSpent);    
    
    % reformat left sample/choice
    BehData.samL_MeanVel = cellfun(@nanmean,BehData.samL_vel,'UniformOutput',false);
    BehData.samL_MeanVel = vertcat(BehData.samL_MeanVel{:});
    BehData.samL_AvSessVel = mean(BehData.samL_MeanVel);
    BehData.samL_SEMSessVel = stderr(BehData.samL_MeanVel);
    
    BehData.choL_MeanVel = cellfun(@nanmean,BehData.choL_vel,'UniformOutput',false);
    BehData.choL_MeanVel = vertcat(BehData.choL_MeanVel{:}); 
    BehData.choL_AvSessVel = mean(BehData.choL_MeanVel);
    BehData.choL_SEMSessVel = stderr(BehData.choL_MeanVel);
    
    BehData.samL_MeanSpent = cellfun(@nanmean,BehData.samL_tSpent,'UniformOutput',false);
    BehData.samL_MeanSpent = vertcat(BehData.samL_MeanSpent{:});
    BehData.samL_AvSessSpent = mean(BehData.samL_MeanSpent);
    BehData.samL_SEMSessSpent = stderr(BehData.samL_MeanSpent);
    
    BehData.choL_MeanSpent = cellfun(@nanmean,BehData.choL_tSpent,'UniformOutput',false);
    BehData.choL_MeanSpent = vertcat(BehData.choL_MeanSpent{:}); 
    BehData.choL_AvSessSpent = mean(BehData.choL_MeanSpent);
    BehData.choL_SEMSessSpent = stderr(BehData.choL_MeanSpent);    
    
    % reformat right sample/choice
    BehData.samR_MeanVel = cellfun(@nanmean,BehData.samR_vel,'UniformOutput',false);
    BehData.samR_MeanVel = vertcat(BehData.samR_MeanVel{:});
    BehData.samR_AvSessVel = mean(BehData.samR_MeanVel);
    BehData.samR_SEMSessVel = stderr(BehData.samR_MeanVel);
    
    BehData.choR_MeanVel = cellfun(@nanmean,BehData.choR_vel,'UniformOutput',false);
    BehData.choR_MeanVel = vertcat(BehData.choR_MeanVel{:}); 
    BehData.choR_AvSessVel = mean(BehData.choR_MeanVel);
    BehData.choR_SEMSessVel = stderr(BehData.choR_MeanVel);
    
    BehData.samR_MeanSpent = cellfun(@nanmean,BehData.samR_tSpent,'UniformOutput',false);
    BehData.samR_MeanSpent = vertcat(BehData.samR_MeanSpent{:});
    BehData.samR_AvSessSpent = mean(BehData.samR_MeanSpent);
    BehData.samR_SEMSessSpent = stderr(BehData.samR_MeanSpent);
    
    BehData.choR_MeanSpent = cellfun(@nanmean,BehData.choR_tSpent,'UniformOutput',false);
    BehData.choR_MeanSpent = vertcat(BehData.choR_MeanSpent{:}); 
    BehData.choR_AvSessSpent = mean(BehData.choR_MeanSpent);
    BehData.choR_SEMSessSpent = stderr(BehData.choR_MeanSpent);    
end   
