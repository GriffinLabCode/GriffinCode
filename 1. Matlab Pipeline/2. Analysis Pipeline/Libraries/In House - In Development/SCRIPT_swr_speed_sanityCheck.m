%% speed swr sanity check

for trial = 1:numTrials
    
    EntryIdx_lfp = []; ExitIdx_lfp = []; xTimes_ts = []; xTimes_sec = [];

    % entry idx
    EntryIdx_lfp = dsearchn(Timestamps',position.TS{trial}(1));
    ExitIdx_lfp  = dsearchn(Timestamps',position.TS{trial}(end));

    % lfp timestamps (in raw format) from entry to exit
    xTimes_ts = [];
    xTimes_ts = Timestamps(EntryIdx_lfp:ExitIdx_lfp); % lfp timestamps from goal entry to exit

    % lfp timestamps (in seconds: 0 to N seconds) from entry to exit
    xTimes_sec = [];
    xTimes_sec = linspace(0,(xTimes_ts(end)-xTimes_ts(1))/1e6,numel(EntryIdx_lfp:ExitIdx_lfp));

    % plot ripple events
    ripStart = []; ripEnd = []; ripStartIdx = []; ripEndIdx = []; xStart=[];
    for i = 1:length(SWRtimes{trial})
        ripStart(i) = SWRtimes{trial}{i}(1);
        ripEnd(i)   = SWRtimes{trial}{i}(end);
    end
    % skip trial if empty
    if isempty(ripStart) == 1
        continue
    end
    % do more stuff
    ripStartIdx = dsearchn(xTimes_ts',ripStart');
    ripEndIdx   = dsearchn(xTimes_ts',ripEnd');
    xStart      = xTimes_sec(ripStartIdx); % get seconds
    xCheck      = xTimes_ts(ripStartIdx);

    % check speed
    timingVar_rip_idx = dsearchn(timingVar{trial}',xStart'); % get xStart times in the timingVar timestamps var
    check_speed = find(speed{trial}(timingVar_rip_idx) >= speedFilt);

    % display if error exists
    if check_speed >= speedFilt
        disp('Error - ripple start during speed >= 5 cm/sec')
    end
end