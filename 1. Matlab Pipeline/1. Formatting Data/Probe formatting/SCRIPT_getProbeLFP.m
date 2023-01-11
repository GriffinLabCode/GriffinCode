%% SCRIPT_getProbeLFP
%
% this script is meant as a preprocessing step to remove any signals that
% look bad
disp('This code is meant to format your probe signals and should only be used if each shank has equal number of electrodes...')
warning('If your shank does NOT have equal number of electrodes per shank, do not use this code!!!')
clear; close all;

% interface with user - want to know how many electrode surfaces are on
% each shank
prompt = 'How many electrodes on on each shank? ';
elecPerShank = num2str(input(prompt,'s'));

% get signal
numCSC = 1:8:64; % Each shank has 8 recordings surfaces
for shanki = 1:length(numCSC)
    % define shank
    cscNames = numCSC(shanki):numCSC(shanki)+7;
    % loop over the electrodes on each shank to load them into matlab
    for ei = 1:length(cscNames)
        cscName = ['CSC',num2str(cscNames(ei))];
        try
            [lfp{shanki,ei},times,srate(shanki,ei)] = getLFPdata(pwd,cscName,'Events');
        catch
            disp(['Missing ',cscName])
            lfp{shanki,ei} = NaN;
        end
    end
    disp(['Loaded and converted signals from shank #',num2str(shanki)])
end

% the output "lfp" has shanks on rows, and electrodes on columns
numShanks     = size(lfp,1);
numElectrodes = size(lfp,2);
figure('color','w')
looper = 0;
for shanki = 1:numShanks
    for ei = 1:numElectrodes
        looper = looper+1;        
        subplot(numShanks,numElectrodes,looper)
        plot(lfp{shanki,ei})
        title(['Shank',num2str(shanki),' electrode',num2str(ei)])
        axis tight;
        ylim([-6000 6000])
        % keep track of the number of loops
    end
end

% enter which signals to remove (row/col)
data2rem = [];
for i = 1:numShanks
    % request the user to remove signals on each shank
    prompt=(['Which electrodes on shank',num2str(i), ' should be removed? ']);
    data2rem{i} = str2num(input(prompt,'s'));
end

% remove arrays by erasing them
for shanki = 1:numShanks
    for i = 1:length(data2rem{shanki})
        lfp{shanki,data2rem{shanki}(i)} = [];
    end
end

info.variable = 'lfp is a cell array with rows being shank and columns being electrode';
info.processing = 'Signals were visualized and excluded if artifacts were observed or 1) if the wires were missing or 2) if the signals were references (based on low voltage signals';
save('probeLFP','lfp','info','srate');
%savefig('probeLFP.fig')


