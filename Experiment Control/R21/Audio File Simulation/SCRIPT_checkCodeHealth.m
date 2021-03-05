load('data_122minutes')

figure('color','w');
stem(coh)
axis tight;
xlim([100 200])

% load in data_20min to keep working

%% coherence magnitudes 
coh(1) = [];

% plot the histogram of coherence magnitudes
figure('color','w')
h_og = histogram(coh,'FaceColor',[.6 .6 .6]); hold on;
h_og.FaceColor = [.6 .6 .6];
% zscore coherence
zscoredCoh = zscore(coh);
% remove first calculation
% get 1 std
cohHighStd = coh(zscoredCoh > 1);
cohHighVal = coh(dsearchn(zscoredCoh',1));
% plot
h_highS = histogram(cohHighStd,'FaceColor',[0 .6 0]);
h_highS.BinWidth = h_og.BinWidth;
% get -1std
cohLowStd = coh(zscoredCoh < -1);
cohLowVal = coh(dsearchn(zscoredCoh',-1));
% plot
h_lowS = histogram(cohLowStd,'FaceColor','r');
h_lowS.BinWidth = h_og.BinWidth;
box off;
legend(['All data'],['High Thresh. (1std = ',num2str(cohHighVal),')'],['Low Thresh. (-1std = ',num2str(cohLowVal),')'])
ylabel('Iteration')
xlabel('Coherence magnitude')

% chance of observing high/low coh
figure('color','w'); hold on;
prob_high = numel(cohHighStd)/numel(coh);
prob_low  = numel(cohLowStd)/numel(coh);
bar(1,prob_high,'FaceColor',[0 .6 0]);
bar(2,prob_low,'FaceColor','r');
ylabel('p(coherence)')
axes = gca;
axes.XTick = [ 1 2 ];
axes.XTickLabel = [{'High Coherence'} {'Low Coherence'}]
axes.XTickLabelRotation = 45;

%% coherence durations

% each sample is sampled at .25 seconds, therefore, if the size is 1, it
% was sampled at .25, if size is 2, then 0.5, etc..

% get sizes of timeStamps - to use cellfun2, run Startup in pipeline
timeSizes = cell2mat(cellfun2(timeStamps,'size',{'2'}));

% max of 
[maxTime, maxLoc] = max(timeSizes);

% convert to seconds
timeConv = zeros(size(timeSizes));
prob_observe = [];
for i = 1:maxTime
    timeConv(timeSizes == i) = i*amountOfData;
    
    % get p(i)
    prob_observe(i) = numel(find(timeSizes == i))/numel(timeConv);
end

% histogram of sampled times
figure('color','w')
plot(prob_observe,'k','LineWidth',2)
box off
ylabel('Coherence Magnitude')
xlabel('Duration Possibilities (ms)')
axes = gca;
axes.XTick = [1:maxTime];
for i = 1:maxTime
    axes.XTickLabel{i} = i*amountOfData;
end
axes.XTickLabelRotation = 45;

    
%% script function

% remove the very first 2 events, they will be excluded anyway. They take
% too long bc of initializing stuff
outtoc(1:2)=[];
outtoc_ms = outtoc*1000; % to ms
figure('color','w');
histogram(outtoc_ms);
ylabel('Number of streaming events')
xlabel('Time (ms) to stream and calculate coherence')
box off
title(['Events streamed at a rate of ', num2str(amountOfData),' seconds'])

%% Within the high and low coherence distributions, what durations are we working with?

% -- high coherence -- %

% get above threshold
idxAbove = [];
idxAbove = find(coh > cohHighVal);

% in other words, how long was coherence >1std or <1std?
% define std_above_mean start time
idxDiff = []; idxChangeDiff = []; idxStart = [];
idxDiff       = diff(idxAbove);
idxChangeDiff = [1 find(idxDiff ~= 1)+1];
idxStart      = idxAbove(idxChangeDiff);

% get end of ripple event (dips below 1)
idxEnd = []; idxRem = [];
for i = 1:length(idxStart)
    restOfData  = []; idxBelowAll = []; idxBelow = [];
    restOfData  = coh(idxStart(i):length(coh));
    idxBelowAll = find(restOfData < cohHighVal);
    % sometimes a ripple continues outside of your window. remove that
    % event
    if isempty(idxBelowAll)
        idxRem(i) = 1;
        continue
    end
    idxBelow    = idxBelowAll(1);
    idxEnd(i)   = idxStart(i)+(idxBelow-2);
end

% find numerical duration (is not actual duration)
cohNumIdx = []; cohNumDur = [];
cohNumIdx(1,:) = idxStart;
cohNumIdx(2,:) = idxEnd;
for i = 1:length(cohNumIdx)
    % get numerical duration
    cohNumDur{i} = cohNumIdx(1,i):cohNumIdx(2,i);
end

% find actual times
for i = 1:length(cohNumDur)
    cohDur(i) = sum(timeConv(cohNumDur{i})); % in sec
end
    
figure('color','w'); hold on;
histogram(cohDur,40,'FaceColor',[0 .6 0])
box off
ylabel('Number of high coherence epochs')
xlabel('Duration of sustained high coherence')

% find the 1st std
highCohDurZ   = zscore(cohDur);
cohHighDurStd = cohDur(highCohDurZ > 1);
cohHighDurVal = cohDur(dsearchn(highCohDurZ',1));

% plt line
ylimits = ylim;
line([cohHighDurVal cohHighDurVal], [ylimits(1) ylimits(2)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2);
text(2,600,['Duration 1std = ',num2str(cohHighDurVal), ' sec'])

% -- LOW COHERENCE -- %

% get above threshold
idxAbove = [];
idxAbove = find(coh < cohLowVal);

% in other words, how long was coherence >1std or <1std?
% define std_above_mean start time
idxDiff = []; idxChangeDiff = []; idxStart = [];
idxDiff       = diff(idxAbove);
idxChangeDiff = [1 find(idxDiff ~= 1)+1];
idxStart      = idxAbove(idxChangeDiff);

% get end of ripple event (dips below 1)
idxEnd = []; idxRem = [];
for i = 1:length(idxStart)
    restOfData  = []; idxBelowAll = []; idxBelow = [];
    restOfData  = coh(idxStart(i):length(coh));
    idxBelowAll = find(restOfData > cohLowVal);
    % sometimes a ripple continues outside of your window. remove that
    % event
    if isempty(idxBelowAll)
        idxRem(i) = 1;
        continue
    end
    idxBelow    = idxBelowAll(1);
    idxEnd(i)   = idxStart(i)+(idxBelow-2);
end

% find numerical duration (is not actual duration)
cohNumIdx = []; cohNumDur = [];
cohNumIdx(1,:) = idxStart;
cohNumIdx(2,:) = idxEnd;
for i = 1:length(cohNumIdx)
    % get numerical duration
    cohNumDur{i} = cohNumIdx(1,i):cohNumIdx(2,i);
end

% find actual times
cohDur = [];
for i = 1:length(cohNumDur)
    cohDur(i) = sum(timeConv(cohNumDur{i})); % in sec
end
    
figure('color','w'); hold on;
histogram(cohDur,40,'FaceColor','r')
box off
ylabel('Number of low coherence epochs')
xlabel('Duration of sustained low coherence')

% find the 1st std
lowCohDurZ   = zscore(cohDur);
cohLowDurStd = cohDur(lowCohDurZ > 1);
cohLowDurVal = cohDur(dsearchn(lowCohDurZ',1));

% plt line
ylimits = ylim;
line([cohLowDurVal cohLowDurVal], [ylimits(1) ylimits(2)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2);
text(2,600,['Duration 1std = ',num2str(cohLowDurVal), ' sec'])
