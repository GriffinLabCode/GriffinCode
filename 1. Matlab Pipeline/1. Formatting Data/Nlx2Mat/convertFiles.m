%% convert session files
% This function converts neuralynx files to a usable matlab format


function [] = convertFiles(datafolder,strCSC)
cd(datafolder);

% define which CSCs to convert. Maybe you only want to convert CSCs 1 and
% 3. If you want CSCs 1:16: numCSC = 1:16;
%numCSC = [3,10,14]; % ** If your CSC are numbered, do this and comment below
%strCSC = [{'PFC_11'} {'PFC_10'} {'HPC_43'} {'HPC_41'} {'HPC_33'} {'HPC_31'}]; % if your csc are strings, do this and comment above
%strCSC = [{'PFC_red'} {'PFC_blue'} {'HPC_red'} {'HPC_green'} {'HPC_blue'} {'HPC_black'}]; % if your csc are strings, do this and comment above

%strCSC = [{'PFC_red'} {'PFC_blue'} {'HPC_red'} {'HPC_clear'} {'HPC_blue'} {'HPC_black'} {'REF'}]; % if your csc are strings, do this and comment above
%strCSC = [{'PFC_white'} {'PFC_blue'} {'HPC_white'} {'HPC_clear'} {'HPC_blue'} {'HPC_green'}]; % if your csc are strings, do this and comment above

%% Timestamps and events

% load & convert Video-Tracking data
try
    [TimeStamps, ExtractedX, ExtractedY,ExtractedAngle] = Nlx2MatVT(strcat(datafolder,'\VT1.nvt'), [1 1 1 0 0 0], 1, 1, []);
    save('VT1.mat','-regexp', '^(?!(datafolder|strCSC|numCSC)$).');
    clearvars -except datafolder numCSC strCSC
catch
    disp('Could not convert VT data - may be missing')
end

% load & convert Events data
try
    [TimeStamps, EventIDs, TTLs, Extras, EventStrings] = Nlx2MatEV(strcat(datafolder,'\events.nev'), [1 1 1 1 1], 0, 1, [] );
    save('Events.mat','-regexp', '^(?!(datafolder|strCSC|numCSC)$).');
    clearvars -except datafolder numCSC strCSC
catch
    disp('Could not convert Events - may be missing')
end

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
