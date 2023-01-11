%% SCRIPT avg csc
%  the buzsaki 64chL probe has 8 shanks, each with 2 arrays along the edge
%  of the probe. This code gets those arrays into variables for processing

disp('This code uses buzsaki64L probes and calculates LFP averages over arrays')
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
        % now visually inspect and discard any arrays that are bad
        figure('color','w')
        for lfpi = 1:length(lfp) 
            subplot(length(lfp),1,lfpi)
            plot(lfp{lfpi})
            title(['signal',num2str(lfpi)])
            axis tight;
        end
        prompt = ['Denote if any signals should be eliminated (IGNORE EMPTY ARRAYS) '];
        lfpErase = [];
        lfpErase = str2num(input(prompt,'s'));
        lfp(lfpErase)=[];
        % remove wires with no signal
        lfp = emptyCellErase(lfp);
        % concatenate to avg over probe shanks
        lfpArray{i} = vertcat(lfp{:});
        disp(['Finished creating LFP variable on array ',num2str(i)])
        %save(['shankLFP',num2str(i)]);
    catch
        disp(['Could not handle shank',num2str(i)])
    end
end

% take common average
comAvg = mean(vertcat(lfpArray{:}),1);

% subtract
for arrayi = 1:length(lfpArray)
    for ei = 1:size(lfpArray{arrayi},1)
        lfpArrayReRef{arrayi}(ei,:) = lfpArray{arrayi}(ei,:)-comAvg;
    end
end
        
info.shank = 'Row = shank, column = signal, element = avg LFP value over each array recording surface';
info.srate = 'Each element representes the sampling rate per shank';
save('probeLFP','lfpArray','srate','info');

