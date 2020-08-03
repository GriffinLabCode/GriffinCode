

%%% set DIR to draw files from then (un)comment CSC's desired

sessions = {'2','3','4','5','6','7','8','9','10','11','12','13'};
numSessions = length(sessions);

    

for i = 1: numSessions
    
    % set folder to draw from
  
    dir = 'X:\01.Experiments\Reuniens related_acg\Rats_all\AAA_all_rats\Lenny\Lenny_DNMP_Ses3'
    datafolder = strcat(dir,sessions{i});
    clear dir;
    
   
    
    %loads VT
    [TimeStamps, ExtractedX, ExtractedY] = Nlx2MatVT(strcat(datafolder,'\VT1.nvt'), [1 1 1 0 0 0], 0, 1, []);
    save(strcat(datafolder,'\VT1.mat'));
    clearvars -except datafolder sessions numSessions;
    
    
    %[TimeStamps, ExtractedX, ExtractedY] = Nlx2MatVT('X:\01.Experiments\Reuniens related_acg\Armadiller\data\9','\VT1.nvt'), [1 1 1 0 0 0], 0, 1, []);
    
    % load Events
    [TimeStamps, EventStrings] = Nlx2MatEV(strcat(datafolder,'\events.nev'), [1 0 0 0 1], 0, 1, [] );
    save(strcat(datafolder,'\Events.mat'));
    clearvars -except datafolder sessions numSessions;
    
    %%
    
    %%example
    %[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples,Samples, Header] = Nlx2MatCSC( 'X:\01.Experiments\Reuniens related_acg\ClaytonBixby\DNMP\12\CSC8.ncs', [1 1 1 1 1], 1, 1, []);
    
    %%
    
    % CSC 1
    [Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc1.ncs'), [1 0 0 0 1], 0, 1, []);
    save(strcat(datafolder,'\CSC1.mat'));
    clearvars -except datafolder sessions numSessions;
    
    % CSC 2
    [Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc2.ncs'), [1 0 0 0 1], 0, 1, []);
    save(strcat(datafolder,'\CSC2.mat'));
    clearvars -except datafolder sessions numSessions;
    
    % CSC 3
    [Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc3.ncs'), [1 0 0 0 1], 0, 1, []);
    save(strcat(datafolder,'\CSC3.mat'));
    clearvars -except datafolder sessions numSessions;
    
    % CSC 4
    [Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc4.ncs'), [1 0 0 0 1], 0, 1, []);
    save(strcat(datafolder,'\CSC4.mat'));
    clearvars -except datafolder sessions numSessions;
   
    % CSC 5
    [Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc5.ncs'), [1 0 0 0 1], 0, 1, []);
    save(strcat(datafolder,'\CSC5.mat'));
    clearvars -except datafolder sessions numSessions;
   
    % CSC 6
    [Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc6.ncs'), [1 0 0 0 1], 0, 1, []);
    save(strcat(datafolder,'\CSC6.mat'));
    clearvars -except datafolder sessions numSessions;
   
    % CSC 7
    [Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc7.ncs'), [1 0 0 0 1], 0, 1, []);
    save(strcat(datafolder,'\CSC7.mat'));
    clearvars -except datafolder sessions numSessions;
    
    % CSC 8
    [Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc8.ncs'), [1 0 0 0 1], 0, 1, []);
    save(strcat(datafolder,'\CSC8.mat'));
    clearvars -except datafolder sessions numSessions;
   
    % CSC 9
    %[Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc9.ncs'), [1 0 0 0 1], 0, 1, []);
    %save(strcat(datafolder,'\CSC9.mat'));
    %clearvars -except datafolder sessions numSessions;
    % CSC 10
    %[Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc10.ncs'), [1 0 0 0 1], 0, 1, []);
    %save(strcat(datafolder,'\CSC10.mat'));
    %clearvars -except datafolder sessions numSessions;
    % CSC 11
    %[Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc11.ncs'), [1 0 0 0 1], 0, 1, []);
    %save(strcat(datafolder,'\CSC11.mat'));
    %clearvars -except datafolder sessions numSessions;
    % CSC 12
    %[Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc12.ncs'), [1 0 0 0 1], 0, 1, []);
    %save(strcat(datafolder,'\CSC12.mat'));
    %clearvars -except datafolder sessions numSessions;
    % CSC 13
    %[Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc13.ncs'), [1 0 0 0 1], 0, 1, []);
    %save(strcat(datafolder,'\CSC13.mat'));
    %clearvars -except datafolder sessions numSessions;
    % CSC 14
    %[Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc14.ncs'), [1 0 0 0 1], 0, 1, []);
    %save(strcat(datafolder,'\CSC14.mat'));
    %clearvars -except datafolder sessions numSessions;
    % CSC 15
    %[Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc15.ncs'), [1 0 0 0 1], 0, 1, []);
    %save(strcat(datafolder,'\CSC15.mat'));
    %clearvars -except datafolder sessions numSessions;
    % CSC 16
    %[Timestamps, Samples] = Nlx2MatCSC(strcat(datafolder,'\csc16.ncs'), [1 0 0 0 1], 0, 1, []);
    %save(strcat(datafolder,'\CSC16.mat'));
    %clearvars -except datafolder sessions numSessions;
    
end



