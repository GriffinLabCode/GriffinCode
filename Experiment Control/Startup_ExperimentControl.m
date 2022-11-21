

disp('Make sure you have run Startup in the Matlab Pipeline')

% main folder path
path = getCurrentPath();

% addpath to main folder
cd(path)
folder_names = dir;

for nn = 3:size(folder_names,1)
    
    % define a naming variable
    folder_name = folder_names(nn).name;
    
    % -- add paths to outside folders -- %
    
    % temporary variable to house current directory
    cur_dir = [];
    cur_dir = [path,'\',folder_name];
    
    % addpath to outside folder
    addpath(cur_dir)
    
    % display path added to outside folder
    disp(['Added path to ', folder_name])
end
