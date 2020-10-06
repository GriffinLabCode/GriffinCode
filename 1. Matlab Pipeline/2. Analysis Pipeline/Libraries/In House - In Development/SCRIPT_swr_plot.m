% plot
figure('color','w'); hold on;
subplot 411
    trialDur = []; % initialize
    trialDur  = (position.TS{trial}(end)-position.TS{trial}(1))/1e6; % trial duration
    timingVar{trial} = linspace(0,trialDur,length(position.TS{trial})); % variable indicating length of trial duration
    plot(timingVar{trial},linearPosition{trial},'k','LineWidth',2)
    xlabel('Start of trial to end of goal zone')
    ylabel('Linear Position (cm)')
    % find goalzone entry
    GZentryIdx  = find(position.TS{trial} == Int(trial,2));
    timingEntry = timingVar{trial}(GZentryIdx);
    % plot
    l1 = line([timingEntry timingEntry],[0 150]);
    l1.Color = 'r';
    l1.LineStyle = '--';
    l1.LineWidth = 2;
    title('Red line indicates goal zone entry filter')
    box off; axis tight;
    
subplot 412
    plot(timingVar{trial},speed{trial},'k','LineWidth',2)
    xlabel('Start of trial to end of goal zone')
    ylabel('Speed (cm/sec)')
    box off; axis tight;
    % plot
    l1 = line([timingEntry timingEntry],[0 40]);
    l1.Color = 'r';
    l1.LineStyle = '--';
    l1.LineWidth = 2;    
    xlimits = xlim;
    l2 = line([xlimits(1) xlimits(2)],[speedFilt speedFilt]);
    l2.Color    = 'b';
    l2.LineStyle = '--';
    l2.LineWidth = 2;
    title('Blue line indicates speed filter')

    EntryIdx_lfp = []; ExitIdx_lfp = []; xTimes_ts = []; xTimes_sec = [];
   
    % stem entry to goal exit
    EntryIdx_lfp = dsearchn(Timestamps',position.TS{trial}(1));
    ExitIdx_lfp  = dsearchn(Timestamps',position.TS{trial}(end));
    
    % lfp timestamps (in raw format) from entry to exit
    xTimes_ts = Timestamps(EntryIdx_lfp:ExitIdx_lfp); % lfp timestamps from goal entry to exit
    
    %dsearchn(xTimes_ts',Timestamps(GoalIdx_lfp))
    
    % lfp timestamps (in seconds: 0 to N seconds) from entry to exit
    xTimes_sec = linspace(0,(xTimes_ts(end)-xTimes_ts(1))/1e6,numel(EntryIdx_lfp:ExitIdx_lfp));
    
% plot lfp data
subplot 413; plot(xTimes_sec,lfp(EntryIdx_lfp:ExitIdx_lfp),'k'); axis tight; box off;
subplot 414; plot(xTimes_sec,lfp_filtered(EntryIdx_lfp:ExitIdx_lfp),'k'); axis tight; box off;
    
    % plot ripple events
    ripStart = []; ripEnd = []; ripStartIdx = []; ripEndIdx = []; xStart=[];
    for i = 1:length(SWRtimes{trial})
        ripStart(i) = SWRtimes{trial}{i}(1);
        ripEnd(i)   = SWRtimes{trial}{i}(end);
    end
    ripStartIdx = dsearchn(xTimes_ts',ripStart');
    ripEndIdx   = dsearchn(xTimes_ts',ripEnd');
    xStart      = xTimes_sec(ripStartIdx); % get seconds
    xCheck      = xTimes_ts(ripStartIdx);
    for i = 1:length(ripStartIdx)
        l1 = line([xStart(i) xStart(i)],[-2000 2000]);
        l1.Color = 'b';
        l1.LineWidth = 2;
    end 
    % instead of a line, try a rectangle
    
    % check speed
    timingVar_rip_idx = dsearchn(timingVar{trial}',xStart'); % get xStart times in the timingVar timestamps var
    check_speed = find(speed{trial}(timingVar_rip_idx) >= speedFilt);
    
    if check_speed >= speedFilt
        disp('Error - ripple start during speed >= 5 cm/sec')
    end
        
