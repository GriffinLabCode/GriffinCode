%% This script is meant to convert files across folders within a directory.
% last edit 12/11/17 by JS created a loop across folders in a directory
% COPY AND PASTE NEW DIRECTORY INTO THE VARIABLE "Datafolders" - YOU WILL HAVE TO DO THIS TWICE
clear all
%% Loop across all folders and convert
Functionfolder = 'X:\03. Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat';

% !!!!!!!!!CHANGE ME!!!!!!!!!
Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';

cd(Datafolders);
folder_names = dir;


for n = 3:length(folder_names) % the first two elements "." and ".." are used for navigation
    
    % !!!!!!!!!CHANGE ME!!!!!!!!!
    Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';

    Functionfolder = 'X:\03. Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat';
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(n).name;
    cd(temp_folder);
    datafolder = pwd; % pwd identifies current folder
    cd(Functionfolder);

% load VT
[TimeStamps, ExtractedX, ExtractedY, ExtractedAngle, Header] = Nlx2MatVT(strcat(datafolder,'\VT1.nvt'), [1 1 1 1 0 0], 1, 1, []);
    Header_VT = Header; clear Header;
    TimeStamps_VT = TimeStamps; clear TimeStamps;
        save(strcat(datafolder,'\VT1.mat'));
        clearvars -except datafolder n

% load Events
[TimeStamps, EventIDs, TTls, Extras, EventStrings, Header] = Nlx2MatEV(strcat(datafolder,'\events.nev'), [1 1 1 1 1], 1, 1, [] );
    Header_EV = Header; clear Header;
    TimeStamps_EV = TimeStamps; clear TimeStamps;
        save(strcat(datafolder,'\Events.mat'));
        clearvars -except datafolder n 

% display progress
X = ['finished with session ',num2str(n)];
disp(X);

end



