%% convert session files
% This script converts neuralynx files to a usable matlab format

%% Define data folder manually and add necessary path to working directory

% clear workspace
clear; clc

% designate folder where session-specfic files are located (most important)
datafolder = 'X:\01.Experiments\John n Andrew\SWR confirmation\Testing SWRs'
cd(datafolder)

% define which CSCs to convert. Maybe you only want to convert CSCs 1 and
% 3. If you want CSCs 1:16: numCSC = 1:16;
numCSC = [1 3];

%% Timestamps and events

% load & convert Video-Tracking data
try
    [TimeStamps, ExtractedX, ExtractedY,ExtractedAngle] = Nlx2MatVT(strcat(datafolder,'\VT1.nvt'), [1 1 1 0 0 0], 0, 1, []);
    save(strcat(datafolder,'\VT1.mat'));
    clearvars -except datafolder numCSC
catch
    disp('Could not convert VT data - may be missing')
end

% load & convert Events data
try
    [TimeStamps, EventStrings] = Nlx2MatEV(strcat(datafolder,'\events.nev'), [1 0 0 0 1], 0, 1, [] );
    save(strcat(datafolder,'\Events.mat'));
    clearvars -except datafolder numCSC
catch
    disp('Could not convert Events - may be missing')
end

%% CSC data

for i = numCSC
    try
        % define csc name in raw format
        varName  = ['\csc',num2str(i),'.ncs'];
        % define variable name to save it as
        saveName = ['\CSC',num2str(i),'.mat'];
        % convert CSC
        [Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,...
            Samples, Header] = Nlx2MatCSC(strcat(datafolder,varName), [1 1 1 1 1], 1, 1, []);
        % save CSC.mat file
        save(strcat(datafolder,saveName), 'Timestamps', 'ChannelNumbers', 'SampleFrequencies', 'NumberOfValidSamples',...
            'Samples', 'Header');
        disp(['Successfully converted and saved CSC',num2str(i)])
        % house keeping
        clearvars -except datafolder i numCSC
    catch
        disp(['Could not convert CSC',num2str(i)])
    end
end

% remove neuralynx fun path
rmpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat')



