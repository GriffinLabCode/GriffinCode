%% NL2Mat_convert...
% This function uses a main directory that houses a bunch of directories
% that are your sessions, then converts the events and vt data
%
% Last edit 2/7/20 JS


function [] = NL2Mat_convert_CSC_individuals(Datafolders)
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat')
 
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
       
    [Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\HPC.ncs'), [1 1 1 1 1], 1, 1, []);
        Header_CSC1 = Header; clear Header;
            save(strcat(datafolder,'\HPC.mat'));
            clearvars -except datafolder nn Datafolders temp_folder folder_names
            
    [Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\mPFC.ncs'), [1 1 1 1 1], 1, 1, []);
        Header_CSC1 = Header; clear Header;
            save(strcat(datafolder,'\mPFC.mat'));
            clearvars -except datafolder nn Datafolders temp_folder folder_names
           
    % display progress
    disp(['Finshed with session ', num2str(nn-2),'/',num2str(size(folder_names,1)-2)]);
                
end
end
