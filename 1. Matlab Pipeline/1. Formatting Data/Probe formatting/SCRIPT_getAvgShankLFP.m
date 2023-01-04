%% SCRIPT avg csc
% this code is used to generate representative LFP signals from each probe
% shank by averaging across shanks. This is primarily used for the Tetrode
% style probes, where the recording surfaces are like a tetrode, reflecting
% highly similar activity as neighboring recording surfaces

clear;
numCSC = [1:4:64]; % 64ch - 16 tts
for i = 1:length(numCSC)
    try
        csc1 = ['CSC',num2str(numCSC(i))];
        csc2 = ['CSC',num2str(numCSC(i)+1)];
        csc3 = ['CSC',num2str(numCSC(i)+2)];
        csc4 = ['CSC',num2str(numCSC(i)+3)];
        lfp = [];
        try [lfp{1}] = getLFPdata(pwd,csc1,'Events'); catch; lfp1 = []; end
        try [lfp{2}] = getLFPdata(pwd,csc2,'Events'); catch; lfp2 = []; end
        try [lfp{3}] = getLFPdata(pwd,csc3,'Events'); catch; lfp3 = []; end
        try [lfp{4},times,srate(i)] = getLFPdata(pwd,csc4,'Events'); catch; lfp4 = []; end
        % remove wires with no signal
        lfp = emptyCellErase(lfp);
        % concatenate to avg over probe shanks
        lfpcat = [];
        lfpcat = vertcat(lfp{:});
        % save
        lfpShank{i} = mean(lfpcat,1);
        disp(['Finished creating LFP variable on shank ',num2str(i)])
        %save(['shankLFP',num2str(i)]);
    catch
        disp(['Could not handle shank',num2str(i)])
    end
end
lfpShank = vertcat(lfpShank{:});
info.shank = 'Row = shank, column = signal, element = avg LFP value over each shank recording surface';
info.srate = 'Each element representes the sampling rate per shank';
save('shankLFP','lfpShank','srate','info');

