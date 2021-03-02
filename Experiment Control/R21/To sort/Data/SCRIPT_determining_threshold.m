%% Determining real-time coherence detection threshold
% this code requires you to run 'time2calculateCoherence' and get the
% necessary outputs. A backup script, in case the actual one was modified,
% is in the 'Backup files' folder.
% JS - 8/12/20

clear; clc;

% load in example data
load('data_example1_10minRec_halfSecResolution')

% start with a plot of the streaming time
figure('color','w');
subplot 311
histogram(outtoc_ms,'FaceColor',[0.8 0.8 0.8]);
ylabel('# of streaming events')
xlabel('Time (ms) to stream and calculate coherence')
box off
title(['Events streamed at a rate of ', num2str(amountOfData),' seconds'])

% get average coherence
coh_theta_avg = mean(coh_theta);

% plot distribution of coherence estimates
subplot 312;
hold on;
h1 = histogram(coh_theta);
box off
ylimits = ylim;
l1 = line([coh_theta_avg coh_theta_avg],[ylimits(1) ylimits(2)]);
l1.Color = 'k';
l1.LineWidth = 2;
l1.LineStyle = '--';
xlabel(['Coherence Estimates (',num2str(params.fpass(1)),'-',num2str(params.fpass(2)),'Hz)',...
    ' Tapers = ',num2str(params.tapers(1)),' and ',num2str(params.tapers(2))])
ylabel(['Observation # in intervals of ',num2str(timing(1)),' seconds'])
title([num2str(loop_time),' minutes of coherence detection'])

% get standard deviations
coh_theta_std = zscore(coh_theta);

% find instances where std > 1
threshold1 = 1;
above_threshold = find(coh_theta_std > threshold1);

% get coherence values
coh_above_threshold = coh_theta(above_threshold);

% plot the distribution
h2 = histogram(coh_above_threshold,'FaceColor','green')
h2.BinWidth = h1.BinWidth;

% -- less than threshold -- %
thresholdLow = -1;
lower_threshold = find(coh_theta_std < thresholdLow);

% get coherence values
coh_below_threshold = coh_theta(lower_threshold);

% plot the distribution
h4 = histogram(coh_below_threshold,'FaceColor','red')
h4.BinWidth = h1.BinWidth;

% --  find instances where std > 2 -- %
threshold2 = 2;
above_threshold = find(coh_theta_std > threshold2);

% get coherence values
coh_above_threshold = coh_theta(above_threshold);

% plot the distribution
h3 = histogram(coh_above_threshold,'FaceColor','m')
h3.BinWidth = h1.BinWidth;

% --  make legend -- %
legend('All coherence values',['Mean coherence of ',num2str(coh_theta_avg)],...
    ['Coherence > ',num2str(threshold1),' std.'],['Coherence < ',num2str(thresholdLow),' std.'],...
    ['Coherence > ',num2str(threshold2),' std.'],'Location','NorthWest')

% -- we should set a criteria for time above threshold1 -- %

% use runLength to find instances of repeats. The third output is a
% variable that tells us where our criteria starts, and where it ends, such
% that the first element is the start index and second element is the end
% of the first event (but the second element does NOT reach threshold).
[~, ~, possible_events] = RunLength(coh_theta_std > threshold1);

% sometimes the first value doesn't meet threshold
if coh_theta_std(possible_events(1)) <= threshold1
    possible_events(1) = [];
end

% get start and end points of coherence thresholds
startPos  = possible_events(1:2:length(possible_events));
endPos    = possible_events(2:2:length(possible_events)); % note that the endPos is one element after it actually ends

% the duration of the event is going to be the end of the event - the start
% of the event. Note that these are epochs, not time. So if you get
% eventDur(1) = 2, it indicates that the threshold was met for 2
% consecutive epochs. It does NOT indicate that the event was met for 2
% seconds or any amount of time. THe amount of time is set by you, and can
% be found in the timing variable in the workspace
eventDur  = endPos-startPos;

% convert to time
eventDur_time = eventDur*timing(1);

% plot the distribution of event durations in seconds
subplot 313
histogram(eventDur_time,'FaceColor','m')
%ylabel(['Observation # in intervals of ',num2str(timing(1)),' seconds'])
xlabel('Coherence Event Duration (in seconds)')
title(['Threshold of ',num2str(threshold1),' std.'])
box off

% -- less than 1std -- %

% runLength
[~, ~, possible_events_less] = RunLength(coh_theta_std < threshold1);

% sometimes the first value doesn't meet threshold
if coh_theta_std(possible_events_less(1)) <= threshold1
    possible_events_less(1) = [];
end

% get start and end points of coherence thresholds
startPosLess  = possible_events_less(1:2:length(possible_events_less));
endPosLess    = possible_events_less(2:2:length(possible_events_less)); % note that the endPos is one element after it actually ends

% the duration of the event is going to be the end of the event - the start
% of the event. Note that these are epochs, not time. So if you get
% eventDur(1) = 2, it indicates that the threshold was met for 2
% consecutive epochs. It does NOT indicate that the event was met for 2
% seconds or any amount of time. THe amount of time is set by you, and can
% be found in the timing variable in the workspace
eventDurLess  = endPosLess-startPosLess;

% convert to time
eventDurLess_time = eventDurLess*timing(1);

% plot the distribution of event durations in seconds
histogram(eventDurLess_time,'FaceColor','m')
%ylabel(['Observation # in intervals of ',num2str(timing(1)),' seconds'])
xlabel('Coherence Event Duration (in seconds)')
title(['Threshold of ',num2str(threshold1),' std.'])
box off





