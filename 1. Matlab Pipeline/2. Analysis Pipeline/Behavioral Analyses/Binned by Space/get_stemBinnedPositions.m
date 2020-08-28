%% get rat locations
%
% this function uses a directory to flip over individual sessions and
% estimates the position data corresponding to a large area.
%
% NOTE - THIS CODE ONLY WORKS IF STEM IS ON Y AXIS. IF YOU WANT TO CHANGE
% OR FIX, GO TO THE rat_locationPosition FUNCTION!! - JS 3/4/20
%
% ~~~ INPUTS ~~~
% Datafolders: Master directory
% int_name: name of int file. for example -> int_name = 'Int_file.mat';
% task_type: can be DNMP, CA, DA, or CD
% correct: set to 1 if only examine correct -> correct = 1;
% incorrect: set to 1 if only incorrect, note correct MUST be set to 0:
%               correct = 0; incorrect = 1;
% If you want to ignore correct/incorrect trials and analyze everything,
% set both to 0
% missing_data: 'interp', 'ignore', or 'exclude'
% stemMin: minimum y estimate for binning
% stemMax: maximum y estimate for binning
% numbins: number of bins to examine
%
% ~~~ OUTPUTS ~~~
% data: a struct array containing a variety of features for task phase.
%       For a particular array, say the Ts variable within the data struct,
%       the first cell array is organized by session. If you enter the
%       first cell (so data.TsL{1}), the data is organized into trials,
%       where each cell array contains trial specific data. Then, if you
%       enter data.TsL{1}{1}, you've entered the first trial of the first
%       session and you will see a cell array of double type. This is the
%       timestamps binned across the stem. So if you open
%       data.TsL{1}{1}{1}, you will be viewing N number of timestamps that
%       occured during session 1, trial 1, stem bin 1.
%
%       As a short cut, {1}{1}{1} = session 1, trial 1, stem bin 1.
%       {1}{2}{2} = session 1, trial 2, stem bin 2, etc...
%
% written by John Stout last edit 8/11/2020

function [data] = get_stemBinnedPositions(Datafolders, int_name, task_type, correct, incorrect, missing_data, stemDir, stemMin, stemMax, numbins)

cd(Datafolders);
folder_names = dir;    

% see if the user wants to separate by trajectory
prompt   = 'Separate trajectory? [Y/N] ';
sep_traj = input(prompt,'s');

% adjust the looping index?
prompt  = 'Adjust the looping index? [Y/N] ';
adjLoop = input(prompt,'s');

if contains(adjLoop,'Y') || contains(adjLoop,'y')
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
    cd(datafolder)
    
    % only load undefined variables
    varlist = who; %Find the variables that already exist
    varlist = strjoin(varlist','$|'); %Join into string, separating vars by '|'
    load(int_name,'-regexp', ['^(?!' varlist ')\w']);

    % get correct trials
    if correct == 1
        Int((Int(:,4)==1),:)=[];
    elseif incorrect == 1
        Int((Int(:,4)==0),:)=[]; 
    else
        Int = Int;
    end
    
    % if DNMP was selected, separate sample and choice trials
    if contains(task_type,'DNMP')
        
        % split into sample and choice trials
        Int_sample = Int(1:2:size(Int,1),:);
        Int_choice = Int(2:2:size(Int,1),:);        
        
        % what about trajectory?
        if contains(sep_traj,'Y') || contains(sep_traj,'y')
            Int_sampleL = Int_sample((Int_sample(:,3)==1),:);
            Int_sampleR = Int_sample((Int_sample(:,3)==0),:);
            Int_choiceL = Int_choice((Int_choice(:,3)==1),:);
            Int_choiceR = Int_choice((Int_choice(:,3)==0),:);
        end    
        
    elseif contains(task_type,'CA') || contains(task_type,'CD') || contains(task_type,'DA')
       
        % what about trajectory?
        if contains(sep_traj,'Y') || contains(sep_traj,'y')
            Int_L = Int((Int(:,3)==1),:);
            Int_R = Int((Int(:,3)==0),:);
        end
        
    end            
    
        
    % remove clipped data - if you entered it this way
    if size(Int,2) >= 9
        
        % remove clipped trials - note that your int file should be
        % balanced if you do this. (ie similar number of sample/choice
        % trials or left/right trials)
        Int(Int(:,9)==1,:)=[];

    else
        
        if contains(task_type,'DNMP')
            if contains(sep_traj,'N') || contains(sep_traj,'n')
                % run rat_location function
                [data.sample_X{nn-2},data.sample_Y{nn-2},data.sampleTs{nn-2},data.ExtractedX{nn-2},data.ExtractedY{nn-2}] = rat_locationPosition(datafolder,Int_sample,vt_name,missing_data,stemDir,stemMin,stemMax,numbins);
                [data.choice_X{nn-2},data.choice_Y{nn-2},data.choiceTs{nn-2},~,~] = rat_locationPosition(datafolder,Int_choice,vt_name,missing_data,stemDir,stemMin,stemMax,numbins);
            elseif contains(sep_traj,'Y') || contains(sep_traj,'y')
                % run rat_location function
                [data.sampleL_X{nn-2},data.sampleL_Y{nn-2},data.sampleTsL{nn-2},data.ExtractedX{nn-2},data.ExtractedY{nn-2}] = rat_locationPosition(datafolder,Int_sampleL,vt_name,missing_data,stemDir,stemMin,stemMax,numbins);
                [data.sampleR_X{nn-2},data.sampleR_Y{nn-2},data.sampleTsR{nn-2}] = rat_locationPosition(datafolder,Int_sampleR,vt_name,missing_data,stemDir,stemMin,stemMax,numbins);
                [data.choiceL_X{nn-2},data.choiceL_Y{nn-2},data.choiceTsL{nn-2}] = rat_locationPosition(datafolder,Int_choiceL,vt_name,missing_data,stemDir,stemMin,stemMax,numbins);  
                [data.choiceR_X{nn-2},data.choiceR_Y{nn-2},data.choiceTsR{nn-2}] = rat_locationPosition(datafolder,Int_choiceR,vt_name,missing_data,stemDir,stemMin,stemMax,numbins);                
            end
            
        else
            
            % DA/CA task
            if contains(sep_traj,'N') || contains(sep_traj,'n')
                % run rat_location function
                [data.X{nn-2},data.Y{nn-2},data.Ts{nn-2},data.ExtractedX{nn-2},data.ExtractedY{nn-2}] = rat_locationPosition(datafolder,Int,vt_name,missing_data,stemDir,stemMin,stemMax,numbins);
            elseif contains(sep_traj,'Y') || contains(sep_traj,'y')
                % run rat_location function
                [data.L_X{nn-2},data.L_Y{nn-2},data.TsL{nn-2},data.ExtractedX{nn-2},data.ExtractedY{nn-2}] = rat_locationPosition(datafolder,Int_L,vt_name,missing_data,stemDir,stemMin,stemMax,numbins);
                [data.R_X{nn-2},data.R_Y{nn-2},data.TsR{nn-2}] = rat_locationPosition(datafolder,Int_R,vt_name,missing_data,stemDir,stemMin,stemMax,numbins);            
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

