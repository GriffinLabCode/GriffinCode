%% startup
% Run this first
%
% last edit 8/3/20 - JS

% clear workspace and command window
clear; clc;

% DEFINE ME!!! - if downloaded from github, make the analysis pipeline the
% directory
main_directory     = 'X:\03. Lab Procedures and Protocols\MATLABToolbox\1. GriffinCode_Github\GriffinCode\1. Matlab Pipeline';
analysis_directory = '\2. Analysis Pipeline';

% concatenate directories
add_directory = [main_directory,analysis_directory];

% adjust the looping index?
prompt  = 'Have you opened Startup_main and defined "add_directory" as the Analysis Pipeline directory? [Y/N] ';
resp = input(prompt,'s');

if resp == 'Y' || resp == 'y' 
else
    disp('Open Startup_main and define add_directory');
    return
end

% addpath to main folder
cd(add_directory)
folder_names = dir;

% adding paths to main directory
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

% display
disp('Paths necessary for Matlab Pipeline have been added')



