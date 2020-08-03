%% This script is meant to convert files across folders within a directory.
% last edit 12/11/17 by JS created a loop across folders in a directory
% COPY AND PASTE NEW DIRECTORY INTO THE VARIABLE "Datafolders" - YOU WILL HAVE TO DO THIS TWICE
clear all
%% Loop across all folders and convert
Functionfolder = 'X:\03. Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat';

% !!!!!!!!!CHANGE ME!!!!!!!!!
Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\Subjects\Baby Groot\Good';

cd(Datafolders);
folder_names = dir;


in.csc1  = 0;
in.csc2  = 0;
in.csc3  = 1;
in.csc4  = 0;
in.csc5  = 0;
in.csc6  = 0;
in.csc7  = 0;
in.csc8  = 0;
in.csc9  = 0;
in.csc10 = 1;
in.csc11 = 0;
in.csc12 = 0;
in.csc13 = 0;
in.csc14 = 1;
in.csc15 = 0;
in.csc16 = 0;

for n = 3:length(folder_names) % the first two elements "." and ".." are used for navigation
    
    % !!!!!!!!!CHANGE ME!!!!!!!!!
    Datafolders = Datafolders;

    %Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\Subjects\Count chocula\Light Sessions';
    Functionfolder = 'X:\03. Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat';
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(n).name;
    cd(temp_folder);
    datafolder = pwd; % pwd identifies current folder
    cd(Functionfolder);

%cd ('X:\03. Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat')

% set folder to draw from (copy/paste)

% load VT

[TimeStamps, ExtractedX, ExtractedY, ExtractedAngle, Header] = Nlx2MatVT(strcat(datafolder,'\VT1.nvt'), [1 1 1 1 0 0], 1, 1, []);
    Header_VT = Header; clear Header;
    TimeStamps_VT = TimeStamps; clear TimeStamps;
        save(strcat(datafolder,'\VT1.mat'));
        clearvars -except datafolder n in Datafolders

% load Events
[TimeStamps, EventIDs, TTls, Extras, EventStrings, Header] = Nlx2MatEV(strcat(datafolder,'\events.nev'), [1 1 1 1 1], 1, 1, [] );
    Header_EV = Header; clear Header;
    TimeStamps_EV = TimeStamps; clear TimeStamps;
        save(strcat(datafolder,'\Events.mat'));
        clearvars -except datafolder n  in Datafolders

% CSC's
if in.csc1 == 1
% 1
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc1.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC1 = Header; clear Header;
        save(strcat(datafolder,'\CSC1.mat'));
        clearvars -except datafolder n in Datafolders
catch
    % if no csc, then do this...
end
end
if in.csc2 == 1
% 2
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc2.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC2 = Header; clear Header;
        save(strcat(datafolder,'\CSC2.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc3 == 1
% 3
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc3.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC3 = Header; clear Header;
        save(strcat(datafolder,'\CSC3.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc4 == 1
% 4
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc4.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC4 = Header; clear Header;
        save(strcat(datafolder,'\CSC4.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc5 == 1
% 5
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc5.ncs'), [1 1 1 1 1], 1, 1, []);
     Header_CSC5 = Header; clear Header;
        save(strcat(datafolder,'\CSC5.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end


if in.csc6 == 1
% 6
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc6.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC6 = Header; clear Header;
        save(strcat(datafolder,'\CSC6.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc7 == 1
try
% 7
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc7.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC7 = Header; clear Header;
        save(strcat(datafolder,'\CSC7.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc8 == 1
% 8
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc8.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC8 = Header; clear Header;
        save(strcat(datafolder,'\CSC8.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc9 == 1
% 9
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc9.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC1 = Header; clear Header;
        save(strcat(datafolder,'\CSC9.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc10 == 1
% 10
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc10.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC2 = Header; clear Header;
        save(strcat(datafolder,'\CSC10.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc11 == 1
% 11
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc11.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC3 = Header; clear Header;
        save(strcat(datafolder,'\CSC11.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc12 == 1
% 12
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc12.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC4 = Header; clear Header;
        save(strcat(datafolder,'\CSC12.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc13 == 1
% 13
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc13.ncs'), [1 1 1 1 1], 1, 1, []);
     Header_CSC5 = Header; clear Header;
        save(strcat(datafolder,'\CSC13.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc14 == 1
% 14
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc14.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC6 = Header; clear Header;
        save(strcat(datafolder,'\CSC14.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc15 == 1
try
% 15
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc15.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC7 = Header; clear Header;
        save(strcat(datafolder,'\CSC15.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

if in.csc16 == 1
% 16
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc16.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC8 = Header; clear Header;
        save(strcat(datafolder,'\CSC16.mat'));
        clearvars -except datafolder n in Datafolders
catch
end
end

% display progress
X = ['finished with session ',num2str(n)];
disp(X);

end



