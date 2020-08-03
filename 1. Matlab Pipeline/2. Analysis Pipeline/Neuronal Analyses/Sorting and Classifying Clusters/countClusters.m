%% countClusters
% function that returns the number of clusters in a directory
%
% -- INPUTS -- %
% Datafolders: Master directory
%
% -- OUTPUTS -- %
% numClusters: number of clusters
%
% written by John Stout

function [numClusters,allClusters] = countClusters(Datafolders)

% define folder_names
cd(Datafolders);
folder_names = dir;
    
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
    
    % load TTs
    clusters = dir('TT*.txt');
    
    % number of units
    allClusters{nn-2} = length(clusters);
    
    % total number 
    numClusters = sum(cell2mat(allClusters));
        
end

