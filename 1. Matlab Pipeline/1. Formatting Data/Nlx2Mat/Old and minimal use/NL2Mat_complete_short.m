

clear; clc
close all

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat')

% set folder to draw from (copy/paste)
datafolder = 'X:\01.Experiments\R21\Experiment 1 - Treadmill Manipulation\Cheetah All Rats\Striga\Session 10 3-18-2020'; 

%%

% load VT
[TimeStamps, ExtractedX, ExtractedY, ExtractedAngle, Header] = Nlx2MatVT(strcat(datafolder,'\VT1.nvt'), [1 1 1 1 0 0], 1, 1, []);
    Header_VT = Header; clear Header;
    TimeStamps_VT = TimeStamps; clear TimeStamps;
        save(strcat(datafolder,'\VT1.mat'));
        clearvars -except datafolder


% load Events
[TimeStamps, EventIDs, TTls, Extras, EventStrings, Header] = Nlx2MatEV(strcat(datafolder,'\events.nev'), [1 1 1 1 1], 1, 1, [] );
    Header_EV = Header; clear Header;
    TimeStamps_EV = TimeStamps; clear TimeStamps;
        save(strcat(datafolder,'\Events.mat'));
        clearvars -except datafolder 

% CSC's

% 1
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc1.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC1 = Header; clear Header;
        save(strcat(datafolder,'\CSC1.mat'));
        clearvars -except datafolder
catch
    % if no csc, then do this...
end

% 2
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc2.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC2 = Header; clear Header;
        save(strcat(datafolder,'\CSC2.mat'));
        clearvars -except datafolder
catch
end

% 3
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc3.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC3 = Header; clear Header;
        save(strcat(datafolder,'\CSC3.mat'));
        clearvars -except datafolder
catch
end

% 4
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc4.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC4 = Header; clear Header;
        save(strcat(datafolder,'\CSC4.mat'));
        clearvars -except datafolder
catch
end
        
% 5
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc5.ncs'), [1 1 1 1 1], 1, 1, []);
     Header_CSC5 = Header; clear Header;
        save(strcat(datafolder,'\CSC5.mat'));
        clearvars -except datafolder
catch
end

% 6
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc6.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC6 = Header; clear Header;
        save(strcat(datafolder,'\CSC6.mat'));
        clearvars -except datafolder
catch
end

try
% 7
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc7.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC7 = Header; clear Header;
        save(strcat(datafolder,'\CSC7.mat'));
        clearvars -except datafolder
catch
end

% 8
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc8.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC8 = Header; clear Header;
        save(strcat(datafolder,'\CSC8.mat'));
        clearvars -except datafolder
catch
end


% 9
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc9.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC1 = Header; clear Header;
        save(strcat(datafolder,'\CSC9.mat'));
        clearvars -except datafolder
catch
end

% 10
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc10.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC2 = Header; clear Header;
        save(strcat(datafolder,'\CSC10.mat'));
        clearvars -except datafolder
catch
end

% 11
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc11.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC3 = Header; clear Header;
        save(strcat(datafolder,'\CSC11.mat'));
        clearvars -except datafolder
catch
end

% 12
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc12.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC4 = Header; clear Header;
        save(strcat(datafolder,'\CSC12.mat'));
        clearvars -except datafolder
catch
end
        
% 13
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc13.ncs'), [1 1 1 1 1], 1, 1, []);
     Header_CSC5 = Header; clear Header;
        save(strcat(datafolder,'\CSC13.mat'));
        clearvars -except datafolder
catch
end

% 14
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc14.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC6 = Header; clear Header;
        save(strcat(datafolder,'\CSC14.mat'));
        clearvars -except datafolder
catch
end

try
% 15
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc15.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC7 = Header; clear Header;
        save(strcat(datafolder,'\CSC15.mat'));
        clearvars -except datafolder
catch
end

% 16
try
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc16.ncs'), [1 1 1 1 1], 1, 1, []);
    Header_CSC8 = Header; clear Header;
        save(strcat(datafolder,'\CSC16.mat'));
        clearvars -except datafolder
catch
end





