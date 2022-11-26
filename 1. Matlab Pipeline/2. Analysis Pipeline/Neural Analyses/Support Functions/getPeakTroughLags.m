%% getPeakTroughLags
% needs checking
% --inputs--%
% filtered_signal: butterworth filtered signal in some frequency range
% srate: sampling rate
%
% --outputs--%
% peak2troughTime: time from peak to trough in seconds
% trough2peakTime: time from trough to peak in seconds
%
% JS

function [peak2troughTime,trough2peakTime] = getPeakTroughLags(filtered_signal,srate)

% peak-to-peak time wont give much info. Need peak-to-trough time
peakX = findpeaks(filtered_signal);
peakX = peakX.loc; % in samples
trouX = findpeaks(-filtered_signal);
trouX = trouX.loc; % in samples

% data into times
peakXtime = peakX/srate;
trouXtime = trouX/srate;

if peakXtime(1) < trouXtime(1) % if peak is less than trough, then its peak->trough
    
    % trough to peak
    p2t = sort(vertcat(peakXtime,trouXtime));
    peak2troughTime = diff(p2t);
    
    % get p2t peak to trough
    peakXtime(1) = [];
    if trouXtime(1) < peakXtime(1)
        % trough to peak
        t2p = sort(vertcat(peakXtime,trouXtime));
        trough2peakTime = diff(t2p);
    end
    
elseif trouXtime(1) < peakXtime(1) % if trough comes first
    
    % trough to peak
    t2p = sort(vertcat(peakXtime,trouXtime));
    trough2peakTime = diff(t2p);
    
    % get p2t peak to trough
    trouXtime(1) = [];
    if peakXtime(1) < trouXtime(1)
        p2t = sort(vertcat(peakXtime,trouXtime));
        peak2troughTime = diff(p2t);
    end
end
