%% convert session files
% This script converts neuralynx files to a usable matlab format

%% Define data folder manually and add necessary path to working directory
clear; clc

% add neuralynx fun path
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat')

% designate folder where session-specfic files are located (most important)
datafolder = 'X:\01.Experiments\John n Andrew\SWR confirmation\Testing SWRs'
cd(datafolder)

%% Timestamps and events

% load & convert Video-Tracking data
try
    [TimeStamps, ExtractedX, ExtractedY,ExtractedAngle] = Nlx2MatVT(strcat(datafolder,'\VT1.nvt'), [1 1 1 0 0 0], 0, 1, []);
    save(strcat(datafolder,'\VT1.mat'));
    clearvars -except datafolder 
catch
    disp('Could not convert VT data - may be missing')
end

% load & convert Events data
try
    [TimeStamps, EventStrings] = Nlx2MatEV(strcat(datafolder,'\events.nev'), [1 0 0 0 1], 0, 1, [] );
    save(strcat(datafolder,'\Events.mat'));
    clearvars -except datafolder 
catch
    disp('Could not convert Events - may be missing')
end

%% CSC data
try
% CSC1
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc1.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC1.mat'));
clearvars -except datafolder 
catch
end

try
% CSC2
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc2.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC2.mat'));
clearvars -except datafolder 
catch
end

try
% CSC3
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc3.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC3.mat'));
clearvars -except datafolder 
catch
end

try
% CSC4
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc4.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC4.mat'));
clearvars -except datafolder
catch
end

try
% CSC5
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc5.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC5.mat'));
clearvars -except datafolder 
catch
end

try
% CSC6
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc6.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC6.mat'));
clearvars -except datafolder 
catch
end

try
% CSC7
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc7.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC7.mat'));
clearvars -except datafolder 
catch
end

try
% CSC8
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc8.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC8.mat'));
clearvars -except datafolder 
catch
end

try
% CSC9
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc9.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC9.mat'));
clearvars -except datafolder 
catch
end

try
% CSC10
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc10.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC10.mat'));
clearvars -except datafolder 
catch
end

try
% CSC11
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc11.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC11.mat'));
clearvars -except datafolder 
catch
end

try
% CSC12
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc12.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC12.mat'));
clearvars -except datafolder 
catch
end

try
% CSC13
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc13.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC13.mat'));
clearvars -except datafolder 
catch
end

try
% CSC14
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc14.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC14.mat'));
clearvars -except datafolder 
catch
end

try
% CSC15
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc15.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC15.mat'));
clearvars -except datafolder 
catch
end

try
% CSC16
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc16.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC16.mat'));
clearvars -except datafolder 
catch
end

% remove neuralynx fun path
rmpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat')



