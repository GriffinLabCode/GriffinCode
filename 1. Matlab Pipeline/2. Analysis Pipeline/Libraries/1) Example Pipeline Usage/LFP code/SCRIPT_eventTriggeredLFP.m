%% getting event triggered LFP
% if you have preset times of interest, you could even take them from excel
% or something, then paste them into the eventTimes variable. As long as
% they are recorded on the same system as the LFP, it doesn't matter. Here,
% I used the Int file for the sake of demonstration
%
% JS

clear;
% first inputs
datafolder = 'X:\01.Experiments\R21\21-12\Sessions\DA Habituation\2021-11-12_10-04-30';
lfp_name = 'HPC_red';
eventsName = 'Events';
eventBoundaries = []; % this can be used with getLFPdata if you need to specify

% get LFP data
% lfp = converted LFP data
% lfpTimes = timestamps converted
% srate = sampling rate (#samples/sec)
% lfpEvents: cell array. Important if you have multiple stop and start
% events or if you defined eventBoundaries
% lfpTimesEvents: Like lfpEvents, but as timestamps
% ---if you have 1 start and 1 stop, just use lfp and lfpTimes -- %
[lfp,lfpTimes,srate,lfpEvents,lfpTimesEvents] = getLFPdata(datafolder,lfp_name,eventsName);

% define some points of interest. We'll just do choice point entry. But
% this can be anything! Note, you don't need an Int file.
int_name = 'Int_hybrid';
Int = getIntFile(datafolder,int_name);

% now lets define some parameters.
eventTimes = Int(:,5); % replace me with whatever event times you care about. This is a vector of time points of interest
edgeTimes  = [1 1]; % This tells the code how much time around each event (1sec before 1sec after). Can be set to whatever

% get event triggered LFP
[eventLFP,t] = getEventTriggeredLFP(lfp,lfpTimes,eventTimes,edgeTimes,srate);

% your event LFP should be +1 greater than the amount of samples you care
% about. For example if you set edgeTimes = [1 1]; you have a total of 2
% seconds, or 4000 samples (assuming srate = 2000). You should therefore
% have a matrix of events(rows) x samples(columns) being 4001. It is +1
% because the center point is 0, 0 = choice point entry in this case.
figure('color','w')
plot(t,eventLFP(1,:));
xlabel('Time (sec) around choice point entry')
ylabel('Example trace (voltage)')

% could do event triggered LFP average
eventLFPavg = nanmean(eventLFP,1);
eventLFPstr = stderr(eventLFP,1); % standard error of the mean
figure('color','w')
shadedErrorBar(t,eventLFPavg,eventLFPstr,'k',1)
box off;
xlabel('Time (sec) around choice point entry')
ylabel('Averaged voltage')

% could make a power spectrogram
movingwin = [0.5 0.05]; % window length and window stepper. Can also be empty
data2plot = eventLFP(1,:); % define variable for function - not necessary
f         = [1:1:100]; % frequencies
plotData  = 'y'; % plot output? Set to anything else except 1 if you dont want it to make fig
[S,f,t] = powerSpectrogram(data2plot,movingwin,srate,f,plotData);

% could also use chronux toolbox (super user friendly for power)
params=getCustomParams;
params.Fs=srate;
params.trialave=0;
clear S f
% loop across all trials, compute power
for i = 1:size(eventLFP,1)
    [S(i,:),f]=mtspectrumc(eventLFP(i,:),params);
end
figure('color','w')
plot(f,S)
title('All power traces')
figure('color','w')
shadedErrorBar(f,nanmean(S,1),stderr(S,1),'k',0);
title('Raw power')
figure('color','w')
shadedErrorBar(f,nanmean(log10(S),1),stderr(log10(S),1),'k',0);
title('log transformed')

% could use mscohere if you have multiple signals


