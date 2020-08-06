%% get l-ratio 
%
% This script utilizes David Redish MClust L_ratio to estimate L_ratio. It
% should be used over SpikeSort3D, since the neuralynx program fails to
% estimate L-ratios using less than 4 wires. This method was published by
% Schmitzer Torbert et al., 2005 from the Redish lab
%
% VERY IMPORTANT: prior to running this script, make sure that you have
%                   saved your tetrode files using the multi-save option.
%                   Futhermore, make sure you've rename the electrode that
%                   you observed the tetrodes on to Master* (where *
%                   indicates whatever else you want to name it). Finally
%                   make sure you have the Nlx2MatSpike functions in the
%                   folder of interest. Finally, make sure the Master*.ntt
%                   file has ONLY the clusters you want cut! If there are
%                   more than what you have saved in .txt files, then you
%                   will have errors in indexing accurate values to your
%                   cluster name
%
% Note: this function will provide l-ratios that are consistent with
%       spikesort3D.
%
% written by John Stout

clear; clc

% define Datafolders
%Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';
Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Orbital Frontal';

% define folder_names variable for looping
cd(Datafolders);
folder_names = dir;    
    
% initialize struct variables
neuron = [];
neuron_temp = [];

% loop across all sessions
for nn = 3:length(folder_names)

    % format variables
    Datafolders = Datafolders;
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
        
    % define datafolder
    datafolder = pwd;
    cd(datafolder);
    % define master tetrode
    Tetrodes = dir('Master*.ntt');
    % save session variable for later
    session = datafolder;
    % add \ to end for Nlx2MatSpike function
    datafolder = strcat(datafolder, '\'); 
    
    % initialize variable
    Lratio = [];
    % loop across tetrodes and get lratio for each cluster
    for ci = 1:length(Tetrodes)
        % initialize variables
        Timestamps = []; ScNumbers = []; CellNumbers = []; Features = [];
        Samples = []; Header = []; Features_new = [];
        % run function to get spike features
        [Timestamps, ScNumbers, CellNumbers, Features, Samples, Header]...
            = Nlx2MatSpike(strcat(datafolder,Tetrodes(ci).name), [1 1 1 1 1], 1, 1, [] );
        % run get_Lratio function
        Features_new = Features(1:4,:);
        Lratio{ci} = get_Lratio(Samples,Features_new,CellNumbers);  
    end
        % make into a vector
        Lratio = horzcat(Lratio{:});
  
    %% store data in a user friendly format
    % initialize variable
    neuron_temp = [];
    
    % save session name
    C = [];
    C = strsplit(session,'\');
    session_name = C{end};
        
    % save cluster names
    clusters = dir('TT*.ntt');
    for cii = 1:length(clusters)
        neuron_temp(1,cii).sess_name = session_name;
        neuron_temp(1,cii).clust_name = clusters(cii).name(1:end-4);
        neuron_temp(1,cii).Lratio = Lratio(cii);
    end
    
    %% display progress and save
    X = ['finished with session ',num2str(nn-2)];
    disp(X)

    neuron = horzcat(neuron,neuron_temp);
    neuron_temp = [];  
    
    clearvars -except neuron neuron_temp folder_names Datafolders nn
end
        
% extract all l ratios
all_Lratios = extractfield(neuron,'Lratio');

% make sure none are above 0.1
TooHigh = find(all_Lratios>0.1);
        
        
