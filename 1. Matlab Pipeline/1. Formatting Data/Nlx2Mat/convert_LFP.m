%% convert session files
% This script converts neuralynx files to a usable matlab format

%% Define data folder manually and add necessary path to working directory

% clear workspace
clear; clc

% designate folder where session-specfic files are located (most important)
datafolder = pwd;
cd(datafolder)

% define which CSCs to convert. Maybe you only want to convert CSCs 1 and
% 3. If you want CSCs 1:16: numCSC = 1:16;
%numCSC = [3,10,14]; % ** If your CSC are numbered, do this and comment below
%strCSC = [{'PFC_11'} {'PFC_10'} {'HPC_43'} {'HPC_41'} {'HPC_33'} {'HPC_31'}]; % if your csc are strings, do this and comment above
%strCSC = [{'PFC_red'} {'PFC_black'} {'HPC_red'} {'HPC_green'} {'HPC_blue'} {'HPC_black'}]; % if your csc are strings, do this and comment above
strCSC = [{'PFC_red'} ]; % if your csc are strings, do this and comment above

%strCSC = [{'PFC_red'} {'PFC_blue'} {'HPC_red'} {'HPC_clear'} {'HPC_blue'} {'HPC_black'} {'REF'}]; % if your csc are strings, do this and comment above
%strCSC = [{'PFC_white'} {'PFC_blue'} {'HPC_white'} {'HPC_clear'} {'HPC_blue'} {'HPC_green'}]; % if your csc are strings, do this and comment above

%% CSC data

if exist('numCSC')
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
            clearvars -except datafolder i numCSC strCSC
        catch
            disp(['Could not convert CSC',num2str(i)])
        end
    end
elseif exist('strCSC')
    for i = 1:length(strCSC)
        try
            % define csc name in raw format
            varName  = ['\',strCSC{i},'.ncs'];
            % define variable name to save it as
            saveName = ['\',strCSC{i},'.mat'];
            % convert CSC
            [Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,...
                Samples, Header] = Nlx2MatCSC(strcat(datafolder,varName), [1 1 1 1 1], 1, 1, []);
            % save CSC.mat file
            save(strcat(datafolder,saveName), 'Timestamps', 'ChannelNumbers', 'SampleFrequencies', 'NumberOfValidSamples',...
                'Samples', 'Header');
            disp(['Successfully converted and saved ',strCSC{i}])
            % house keeping
            clearvars -except datafolder i numCSC strCSC
        catch
            disp(['Could not convert ',strCSC{i}])
        end
    end
end
