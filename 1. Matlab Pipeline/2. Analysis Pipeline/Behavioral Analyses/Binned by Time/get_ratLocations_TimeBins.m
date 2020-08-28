%% get rat locations
%
% this function uses a directory to flip over individual sessions and
% estimates the position data corresponding to a large area. Note this, as of
% 2/24/20 is strictly for DNMP. - JS
%
% NOTE - THIS CODE ONLY WORKS IF STEM IS ON Y AXIS. IF YOU WANT TO CHANGE
% OR FIX, GO TO THE rat_locationPosition FUNCTION!! - JS 3/4/20
%
% ~~~ INPUTS ~~~
% Datafolders: Master directory
% int_name: name of int file. for example -> int_name = 'Int_file.mat';
% correct: set to 1 if only examine correct -> correct = 1;
% incorrect: set to 1 if only incorrect, note correct MUST be set to 0:
%               correct = 0; incorrect = 1;
% If you want to ignore correct/incorrect trials and analyze everything,
% set both to 0
%
% ~~~ OUTPUTS ~~~
% data: a struct array containing a variety of features for task phase.
%
% written by John Stout last edit 3/4/2020

function [data] = get_ratLocations_SpatialBin(Datafolders, int_name, task_type, correct, incorrect)

cd(Datafolders);
folder_names = dir;    

correct_trajectory = 0;

% see if the user wants to separate by trajectory
if task_type == 'DNMP'
    prompt   = 'Separate trajectory? [Y/N] ';
    sep_traj = input(prompt,'s');
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
    
    % store session name
    C = [];
    C = strsplit(datafolder,'\');
    sessions{nn-2} = C;
    
    % int_name will be the int file name
    cd(datafolder);
    
    % only load undefined variables
    varlist = who; %Find the variables that already exist
    varlist = strjoin(varlist','$|'); %Join into string, separating vars by '|'
    load(int_name,'-regexp', ['^(?!' varlist ')\w']);

    cd(Datafolders);
    folder_names = dir;
    cd(datafolder);
    
    % get correct trials
    if correct == 1
        Int(find(Int(:,4)==1),:)=[];
    elseif incorrect == 1
        Int(find(Int(:,4)==0),:)=[]; 
    else
        Int = Int;
    end
    
    % if DNMP was selected, separate sample and choice trials
    if task_type == 'DNMP'
        % split into sample and choice trials
        Int_sample = Int(1:2:size(Int,1),:);
        Int_choice = Int(2:2:size(Int,1),:);        
        task_params = 2;
    elseif task_type == 'CA/DA/CD'
        % this needs to be completed
        task_params = 1;
    end            
    
    % what about trajectory?
    if sep_traj == 'Y'
        Int_sampleL = Int_sample(find(Int_sample(:,3)==1),:);
        Int_sampleR = Int_sample(find(Int_sample(:,3)==0),:);
        Int_choiceL = Int_choice(find(Int_choice(:,3)==1),:);
        Int_choiceR = Int_choice(find(Int_choice(:,3)==0),:);
    end
        
    % remove clipped data - if you entered it this way
    if size(Int,2) >= 9
        try
            % remove clipped trials
            Int(Int(:,9)==1,:)=[];

            % control for differing number of sample and choice trials by
            % removing the entire trial. 
            Int_og = Int;
            Int = [];
            Int = correct_taskphase_counts_nonsubsample(Int_og); 

            % control for differing number of left and right trials during sample
            % and choice. But also make sure theres an equal number of different
            % trial-type combinations (sampleL sampleR choiceL choiceR)
            if correct_trajectory == 1
                [Int_corrected,corrected_trials,num_orig{nn-2},num_types{nn-2},...
                    turn_nam{nn-2}]=correct_trajectory_differences(Int);
                Int_og2 = Int;
                Int = [];
                Int = Int_corrected;
            else
                Int = Int;
            end            
            
            % end script if either a choice trial is first or sample is last. This
            % would mess up odd even distinction of sample and choice trials
            if Int(1,10) == 1 || Int(end,10) == 0
                disp('Int file not formatted correctly')
                continue
            end

            % split into sample and choice trials
            Int_sample = Int(1:2:size(Int,1),:);
            Int_choice = Int(2:2:size(Int,1),:);

            % check that Int file is formatted correctly again
            if isempty(find(Int_sample(:,10)==1))==0 || isempty(find(Int_choice(:,10)==0))==0
                disp('Int file not formatted correctly')
                continue
            end        
            
        catch
            continue
        end
    else
        if task_params == 2
            if sep_traj == 'N'
                % run rat_location function
                [data.sample_X{nn-2},data.sample_Y{nn-2},data.sampleTs{nn-2},data.ExtractedX{nn-2},data.ExtractedY{nn-2}] = rat_locationPosition(datafolder,Int_sample);
                [data.choice_X{nn-2},data.choice_Y{nn-2},data.choiceTs{nn-2},~,~] = rat_locationPosition(datafolder,Int_choice);
            elseif sep_traj == 'Y'
                % run rat_location function
                [data.sampleL_X{nn-2},data.sampleL_Y{nn-2},data.sampleTsL{nn-2},data.ExtractedX{nn-2},data.ExtractedY{nn-2}] = rat_locationPosition(datafolder,Int_sampleL);
                [data.sampleR_X{nn-2},data.sampleR_Y{nn-2},data.sampleTsR{nn-2}] = rat_locationPosition(datafolder,Int_sampleR);
                [data.choiceL_X{nn-2},data.choiceL_Y{nn-2},data.choiceTsL{nn-2}] = rat_locationPosition(datafolder,Int_choiceL);  
                [data.choiceR_X{nn-2},data.choiceR_Y{nn-2},data.choiceTsR{nn-2}] = rat_locationPosition(datafolder,Int_choiceR);                
            end
        end
    end
          
    
    % display progress
   disp(['Finished with session ', num2str(nn-2),'/',num2str(size(folder_names,1)-2)]);
    
    
end

    % save sessions data
    data.sessions = sessions;
    
    clearvars -except data

    prompt   = 'Please enter a unique name for this dataset ';
    unique_name = input(prompt,'s');

    prompt   = 'Enter the directory to save the data ';
    dir_name = input(prompt,'s');

    save_var = unique_name;

    cd(dir_name);
    save(save_var);
    
end

