%% Determining real-time coherence detection threshold
% this code requires you to run 'time2calculateCoherence' and get the
% necessary outputs. A backup script, in case the actual one was modified,
% is in the 'Backup files' folder.
% JS - 8/12/20

clear; clc;

% load in example data
%load('data_example1_10minRec_halfSecResolution')
load('data_example1_20minRec')

% coh_theta: vector array of coherence estimates
% threshold: a scalar value indicating the threshold set according to
%               standard deviations
% threshold_indicator: can be 'greater than' or 'less than'. This tells the
%                        code to find instances greater than or less than
%                        the threshold you set.
% timing: a scalar indicating the time of the data in consideration. To get
%           this, divide the length of 

%coh_theta = dataIn.coh_theta;
threshold = 1;
threshold_indicator = 'greater than';
%timings = dataIn.timings;

% get average coherence
coh_theta_avg = mean(coh_theta);

% get standard deviations
coh_theta_std = zscore(coh_theta);

% find instances where std > threshold
if contains(threshold_indicator,'greater than')
    threshold_met = find(coh_theta_std > threshold);
elseif contains(threshold_indicator,'less than')
    threshold_met = find(coh_theta_std < threshold);
end    

% get coherence values
coh_threshold = coh_theta(threshold_met);

% -- we should set a criteria for time above threshold1 -- %

% use runLength to find instances of repeats. The third output is a
% variable that tells us where our criteria starts, and where it ends, such
% that the first element is the start index and second element is the end
% of the first event (but the second element does NOT reach threshold).
[~, ~, possible_events] = RunLength(coh_theta_std > threshold);

% sometimes the first value doesn't meet threshold
if contains(threshold_indicator,'greater than')
    if coh_theta_std(possible_events(1)) <= threshold
        possible_events(1) = [];
    end
elseif contains(threshold_indicator,'less than')
    if coh_theta_std(possible_events(1)) >= threshold
        possible_events(1) = [];
    end
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

% account for timings - note this is different from above, so not too
% redundant
idx_start = possible_events(1:2:length(possible_events));
idx_end   = possible_events(2:2:length(possible_events))-1; % -1 bc we want to include only events that met criteria

% loop across all possible events, then find times between them
for i = 1:length(idx_start)
    timing_events{i} = timings(idx_start(i):idx_end(i));
end

% add the events within each array
timing_total = cellfun(@sum,timing_events);

%% consider both event duration and std

%% figures
% plot distribution of coherence estimates
figure('color','w')
subplot 211;
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

% plot the distribution
if contains(threshold_indicator,'greater than')
    h2 = histogram(coh_threshold,'FaceColor','green')
    h2.BinWidth = h1.BinWidth;
    output_description = ['Coherence > ',num2str(threshold),' std.'];
elseif contains(threshold_indicator,'less than')
    h2 = histogram(coh_threshold,'FaceColor','red')
    h2.BinWidth = h1.BinWidth;
    output_description = ['Coherence < ',num2str(threshold),' std.'];    
end

% --  make legend -- %
legend('All coherence values',['Mean coherence of ',num2str(coh_theta_avg)],...
    [output_description],'Location','NorthWest')

% plot the distribution of event durations in seconds
subplot 212
histogram(timing_total,'FaceColor','m')
%ylabel(['Observation # in intervals of ',num2str(timing(1)),' seconds'])
xlabel('Coherence Event Duration (in seconds)')
title(['Threshold of ',num2str(threshold),' std.'])
box off
