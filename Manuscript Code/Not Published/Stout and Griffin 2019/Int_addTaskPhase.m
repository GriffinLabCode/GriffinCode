%% add task-phase
%
% this script adds a 10th column to Int_lfp.mat where 0s are sample phase
% and 1s are choice phase
% 
% written by John Stout

% really important to interface with user with this code as it can
% dangerously overwrite
prompt = 'Would you like to continue with adding task phase to column 10? [Y/N]';
ans1   = input(prompt,'s');

if ans1 == 'Y'
    prompt = 'Please define the name of the Int to load after a "\" and with a ".mat" in the end ';
    File2Load = input(prompt,'s');
    prompt = 'Please define a name to save the Int as with a ".mat" at the end ';
    Name2Save = input(prompt,'s');
else
    return
end

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
[input]=get_lfp_inputs();

% flip over all folders    
    if input.Prelimbic == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic';
    elseif input.OFC ==1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Orbital Frontal';    
    elseif input.AnteriorCingulate == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Anterior Cingulate';
    elseif input.mPFC_good == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';
    elseif input.mPFC_poor == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Poor Performance\Medial Prefrontal Cortex'; 
    elseif input.VentralOrbital == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Ventral Orbital';
    elseif input.MedialOrbital == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Orbital';
    else
        disp('Warning - Error in loading Datafolders')
    end
    
    cd(Datafolders);
    folder_names = dir;    
    
% loop across folders
for nn = 3:length(folder_names)
    
        Datafolders = Datafolders;
        cd(Datafolders);
        folder_names = dir;
        temp_folder = folder_names(nn).name;
        cd(temp_folder);
        datafolder = pwd;
        cd(datafolder); 
        
        try
            % load Int_lfp.mat file 
            load(strcat(datafolder,File2Load));         
            
            % create an index of 1s and 0s where 0s are sample and 1s are
            % choice trials
            ones_var = ones(size(Int,1)/2,1)';
            zero_var = zeros(size(Int,1)/2,1)';
            var = [zero_var;ones_var];
            labels = var(:);
            
            % add the labels variable to the Int_lfp.mat file
            Int(:,10)=labels;
            
            % save the variable
            save(Name2Save,'Int');
            
            % display
            C = [];
            C = strsplit(datafolder,'\');
            X = [];
            X = ['finished adding task-phase index to ', C{end}];
            disp(X);          
        catch
            % display
            C = [];
            C = strsplit(datafolder,'\');
            X = [];
            X = [C{end}, ' had no Int_lfp.mat file'];
            disp(X);              
            
            continue
        end
        
        % house keeping
        clearvars -except Datafolders input nn folder_names temp_folder File2Load Name2Save
        


end



