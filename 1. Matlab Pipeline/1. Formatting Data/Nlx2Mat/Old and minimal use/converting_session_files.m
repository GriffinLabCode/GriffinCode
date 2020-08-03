

% this function allows you to....

%%

clear; clc

% designate folder where session-specfic files are located (most important)
datafolder = 'X:\03. Lab Procedures and Protocols\Matlab Practice\Session X'


%%

% load & convert Video-Tracking data

[TimeStamps, ExtractedX, ExtractedY] = Nlx2MatVT(strcat(datafolder,'\VT1.nvt'), [1 1 1 0 0 0], 0, 1, []);
save(strcat(datafolder,'\VT1.mat'));
clearvars -except datafolder 

% load & convert Events data

[TimeStamps, EventStrings] = Nlx2MatEV(strcat(datafolder,'\events.nev'), [1 0 0 0 1], 0, 1, [] );
save(strcat(datafolder,'\Events.mat'));
clearvars -except datafolder 


% load & convert CSC data


% CSC1
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc1.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC1.mat'));
clearvars -except datafolder 


% CSC2
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc2.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC2.mat'));
clearvars -except datafolder 

% CSC3
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc3.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC3.mat'));
clearvars -except datafolder 

% CSC4
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc4.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC4.mat'));
clearvars -except datafolder

% CSC5
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc5.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC5.mat'));
clearvars -except datafolder 

% CSC6
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc6.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC6.mat'));
clearvars -except datafolder 

% CSC7
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc7.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC7.mat'));
clearvars -except datafolder 

% CSC8
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc8.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC8.mat'));
clearvars -except datafolder 

% CSC9
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc9.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC9.mat'));
clearvars -except datafolder 

% CSC10
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc10.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC10.mat'));
clearvars -except datafolder 

% CSC11
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc11.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC11.mat'));
clearvars -except datafolder 

% CSC12
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc12.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC12.mat'));
clearvars -except datafolder 

% CSC13
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc13.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC13.mat'));
clearvars -except datafolder 

% CSC14
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc14.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC14.mat'));
clearvars -except datafolder 

% CSC15
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc15.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC15.mat'));
clearvars -except datafolder 

% CSC16
[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC(strcat(datafolder,'\csc16.ncs'), [1 1 1 1 1], 1, 1, []);
save(strcat(datafolder,'\CSC16.mat'));
clearvars -except datafolder 




