%% testing if stout data requires a rereference
clear;
datafolder = pwd;
cd(datafolder);

% enter wire names
cscNames = [{'CSC3'} {'CSC9'} {'CSC12'} {'CSC13'} {'CSC10'} {'CSC14'}];
%cscNames = [{'CSC10'} {'CSC14'}];
for i = 1:length(cscNames)
    [lfp(i,:),lfpTimes] = getLFPdata(pwd,cscNames{i},'Events');
end

% common average
comAvg = mean(lfp,1);
lfpReref = lfp;
for i = 1:size(lfp,1)
    lfpReref(i,:) = lfp(i,:)-comAvg;
end

% save data
for i = 1:length(cscNames)
    saveName = [cscNames{i},'reref'];
    lfp = lfpReref(i,:);
    save([saveName],'lfp','lfpTimes');
    disp(['Saved ',saveName])
end
