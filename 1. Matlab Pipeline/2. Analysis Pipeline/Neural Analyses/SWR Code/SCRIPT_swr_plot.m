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
    ylimits = ylim;
    l1 = line([timingEntry timingEntry],[ylimits(1) ylimits(2)]);
    l1.Color = 'r';
    l1.LineStyle = '--';
    l1.LineWidth = 1.5;
    title('Red line indicates goal zone entry filter')
    box off; axis tight;
    
subplot 412
    plot(timingVar{trial},speed{trial},'Color',[.5 .5 .5],'LineWidth',2)
    xlabel('Start of trial to end of goal zone')
    ylabel('Speed (cm/sec)')
    box off; axis tight;
    % plot
    ylimits = ylim;
    l1 = line([timingEntry timingEntry],[ylimits(1) ylimits(2)]);
    l1.Color = 'r';
    l1.LineStyle = '--';
    l1.LineWidth = 1.5;    
    xlimits = xlim;
    l2 = line([xlimits(1) xlimits(2)],[speedFilt speedFilt]);
    l2.Color    = 'b';
    l2.LineStyle = '--';
    l2.LineWidth = 1.5;
    title('Blue line indicates speed filter')

    EntryIdx_lfp = []; ExitIdx_lfp = []; xTimes_ts = []; xTimes_sec = [];
    
    % stem entry to goal exit
    EntryIdx_lfp = dsearchn(Timestamps',position.TS{trial}(1)); % was Timestamps'
    ExitIdx_lfp  = dsearchn(Timestamps',position.TS{trial}(end));
    
    % lfp timestamps (in raw format) from entry to exit - was Timestamps
    xTimes_ts = Timestamps(EntryIdx_lfp:ExitIdx_lfp); % lfp timestamps from goal entry to exit
    
    %dsearchn(xTimes_ts',Timestamps(GoalIdx_lfp))
    
    % lfp timestamps (in seconds: 0 to N seconds) from entry to exit
    xTimes_sec = linspace(0,(xTimes_ts(end)-xTimes_ts(1))/1e6,numel(EntryIdx_lfp:ExitIdx_lfp));
    
% plot lfp data - was lfp and lfp_filtered
subplot 413; plot(xTimes_sec,lfp(EntryIdx_lfp:ExitIdx_lfp),'Color',[0 .4 0]); axis tight; box off;
subplot 414; plot(xTimes_sec,lfp_filtered(EntryIdx_lfp:ExitIdx_lfp),'Color',[0 .4 0]); axis tight; box off;
    
    % plot ripple events
    ripStart = []; ripEnd = []; ripStartIdx = []; ripEndIdx = []; xStart=[];
    for i = 1:length(SWRtimes{trial})
        ripStart(i) = SWRtimes{trial}{i}(1);
        ripEnd(i)   = SWRtimes{trial}{i}(end);
    end
    ripStartIdx = dsearchn(xTimes_ts',ripStart');
    ripEndIdx   = dsearchn(xTimes_ts',ripEnd');
    xStart      = xTimes_sec(ripStartIdx); % get seconds
    xEnd        = xTimes_sec(ripEndIdx);
    xCheck      = xTimes_ts(ripStartIdx);
    for i = 1:length(ripStartIdx)
        l1 = line([xStart(i) xStart(i)],[-2000 2000]);
        l1.Color = 'm';
        l1.LineWidth = 1;
    end 
    % instead of a line, try a rectangle
    
    % check speed
    timingVar_rip_idx = dsearchn(timingVar{trial}',xStart'); % get xStart times in the timingVar timestamps var
    check_speed = find(speed{trial}(timingVar_rip_idx) >= speedFilt);
    
    if check_speed >= speedFilt
        disp('Error - ripple start during speed >= 5 cm/sec')
    end
    
    set(gcf,'Position',[300 250 600 300])

% first 5 seconds or something
EarlyRun_lfp = dsearchn(Timestamps',position.TS{trial}(1)+5*1e6);
xTimesEarly_ts = Timestamps(EntryIdx_lfp:EarlyRun_lfp); % lfp timestamps from goal entry to exit
xTimesEarly_sec = linspace(0,(xTimesEarly_ts(end)-xTimesEarly_ts(1))/1e6,numel(EntryIdx_lfp:EarlyRun_lfp));

% plot
figure('color','w')
plot(xTimesEarly_sec,lfp(EntryIdx_lfp:EarlyRun_lfp),'Color',[0 .4 0]); axis tight; box off;
xlabel('Time (sec)')
box off
set(gcf,'Position',[300 250 350 150])
%set(gca,'ytick',[])
%set(gca,'ycolor',[1 1 1])

% -- zoom into ripple -- %
% plot lfp data
figure('color','w')
subplot 211; 
plot(xTimes_sec,lfp(EntryIdx_lfp:ExitIdx_lfp),'Color',[0 .4 0]); axis tight; box off;   
xlim([xStart(1) xStart(8)])
ylimits = ylim;
for i = 1:length(ripStartIdx)
    l1 = line([xStart(i) xStart(i)],[-10000 10000]);
    l1.Color = 'm';
    l1.LineWidth = 1.5;
    %l2 = line([xEnd(i) xEnd(i)],[ylimits(1) ylimits(2)]);
    %l2.Color = 'r';
    %l2.LineWidth = 1;   
end 
subplot 212; 
plot(xTimes_sec,lfp_filtered(EntryIdx_lfp:ExitIdx_lfp),'Color',[0 .4 0],'LineStyle','-'); axis tight; box off;
xlim([xStart(1) xStart(8)])
ylimits = ylim;
for i = 1:length(ripStartIdx)
    l1 = line([xStart(i) xStart(i)],[-2000 2000]);
    l1.Color = 'm';
    l1.LineWidth = 1.5;
    %l2 = line([xEnd(i) xEnd(i)],[ylimits(1) ylimits(2)]);
    %l2.Color = 'r';
    %l2.LineWidth = 1;   
end 
set(gcf,'Position',[300 250 350 150])

%{
% zoom in on at least 1 swr
timesAround = [0.5*1e6 2.5*1e6];
idxStart = dsearchn(xTimes_ts',ripStart(1)-timesAround(1)');
idxEnd   = dsearchn(xTimes_ts',ripStart(1)+timesAround(2)');

figure('color','w')
ripTimesPlot = xTimes_sec(idxStart:idxEnd);
subplot 211; plot(ripTimesPlot,lfp(idxStart:idxEnd),'Color',[0 .4 0]); axis tight; box off;
subplot 212; plot(ripTimesPlot,lfp_filtered(idxStart:idxEnd),'Color',[0 .4 0]); axis tight; box off;

for i = 1:length(xStart)
    if find(ripTimesPlot == xStart(i))
        idx = find(ripTimesPlot == xStart(i));
        l1 = line([ripTimesPlot(idx) ripTimesPlot(idx)],[-500 500]);
        l1.Color = 'm';
        l1.LineWidth = 1;
    end
end 
%}