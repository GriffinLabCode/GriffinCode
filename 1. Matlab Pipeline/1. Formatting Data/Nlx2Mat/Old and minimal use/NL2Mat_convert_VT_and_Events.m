%% NL2Mat_convert...
% This function uses a main directory that houses a bunch of directories
% that are your sessions, then converts the events and vt data
%
% Last edit 2/7/20 JS

function [] = NL2Mat_convert_VT_and_Events(Datafolders)
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
       
    % load VT
    [TimeStamps, ExtractedX, ExtractedY, ExtractedAngle, Header] = Nlx2MatVT(strcat(datafolder,'\VT1.nvt'), [1 1 1 1 0 0], 1, 1, []);
        Header_VT = Header; clear Header;
        TimeStamps_VT = TimeStamps; clear TimeStamps;
            save('VT1.mat','ExtractedX','ExtractedY','Header_VT','TimeStamps_VT','ExtractedAngle');
            clearvars -except datafolder nn Datafolders temp_folder folder_names

    % load Events
    [TimeStamps, EventIDs, TTls, Extras, EventStrings, Header] = Nlx2MatEV(strcat(datafolder,'\events.nev'), [1 1 1 1 1], 1, 1, [] );
        Header_EV = Header; clear Header;
        TimeStamps_EV = TimeStamps; clear TimeStamps;
            save('Events.mat','Header_EV','TimeStamps_EV','EventStrings','EventIDs','Extras');
            clearvars -except datafolder nn Datafolders temp_folder folder_names
            
    % display progress
    disp(['Finshed with session ', num2str(nn-2),'/',num2str(size(folder_names,1)-2)]);
                
end
end
