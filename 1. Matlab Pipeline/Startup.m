%% startup
% Run this first
%
% last edit 8/3/20 - JS

% clear workspace and command window
clear; clc;

% This is the directory where the "Startup" function is located
try
    load('main_directory')
catch   
    main_directory = 'C:\Users\uggriffin\Documents\GitHub\GriffinCode\1. Matlab Pipeline';
end

% interface with user to redefine main_directory
disp(main_directory)
prompt = 'Is the directory above the same directory where your "Startup" function is located? [Y/N] ';
resp = input(prompt,'s');

if contains(resp,'N') || contains(resp,'n')
    prompt = 'Please enter the directory where "Startup" is located, then press "Enter" ';
    main_directory = input(prompt,'s');
else
end

% addpath to main directory
addpath(main_directory);
disp('Added path to main directory')

% these will have to change if you change the names of the formatting and
% analysis pipeline directory names
analysis_directory = '\2. Analysis Pipeline';
format_directory   = '\1. Formatting Data';

% concatenate directories
add_directory = [main_directory,analysis_directory];

% addpath to main folder
cd(add_directory)
folder_names = dir;

% adding analysis paths
for nn = 3:size(folder_names,1)
    
    % define a naming variable
    folder_name = folder_names(nn).name;
    
    % -- add paths to outside folders -- %
    
    % temporary variable to house current directory
    cur_dir = [];
    cur_dir = [add_directory,'\',folder_name];
    
    % addpath to outside folder
    addpath(cur_dir)
    
    % display path added to outside folder
    disp(['Added path to ', folder_name])
    
    % -- addpaths to inside folders -- %
    
    % addpath to inside folder
    cd(cur_dir) % cd to the current folder of interest
    folders_inside_dir = dir; % get the folders within the current folder of interest
    
    for nnn = 3:size(folders_inside_dir,1) 
        
        % define a naming variable
        folder_name_inside = folders_inside_dir(nnn).name;

        % temporary variable to house current directory
        add_inside_dir = [];
        add_inside_dir = [cur_dir,'\',folder_name_inside];

        % you can change this if you have specific subfolders you want to
        % add - this is primarily for chronux, but you can make if, elseif,
        % statements
        if strfind(folder_name_inside,'Chronux Toolbox') == 1
            
            % change directory
            cd(add_inside_dir);
            
            % define chronux directory
            funFolder_in_chronux = '\spectral_analysis\continuous';
        
            % addpath to the continuous folder - this is where the lfp
            % analyses are
            addpath([add_inside_dir,funFolder_in_chronux])
            
            disp(['Chronux toolbox directory ',funFolder_in_chronux, ' added to path'])
        
            % add the helper functions
            funFolder_in_chronux = '\spectral_analysis\helper';
            
            % addpath to the continuous folder - this is where the lfp
            % analyses are
            addpath([add_inside_dir,funFolder_in_chronux])
            
            disp(['Chronux toolbox directory ',funFolder_in_chronux, ' added to path'])        
            
        else
            
            % addpath to outside folder
            addpath(add_inside_dir)   

            % display path added to outside folder
            disp(['Added path to ', folder_name_inside, ' within ', folder_name])

        end
        
    end
        
end

% adding data formatting paths
format_full = [main_directory,format_directory];
cd(format_full);
folder_names = dir;

for nn = 3:size(folder_names,1)
    
    % define a naming variable
    folder_name = folder_names(nn).name;
    
    % -- add paths to outside folders -- %
    
    % temporary variable to house current directory
    cur_dir = [];
    cur_dir = [format_full,'\',folder_name];
    
    % addpath to outside folder
    addpath(cur_dir)
    
    % display path added to outside folder
    disp(['Added path to ', folder_name])
           
end

% display
disp('Paths necessary for Matlab Pipeline have been added')
cd(main_directory);
save('main_directory.mat','main_directory')

% clear workspace
clear;

