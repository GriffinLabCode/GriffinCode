%% getLFPdata
% this function wraps some other functions into something that will easily
% load and convert lfp data for easy extraction and use
%
% 'Events.mat' must be named as so
%
% -- INPUTS -- %
% datafolder: string directory for data of interest
% csc_name: string variable containing csc of interest (ie csc_name =
%             'CSC1.mat'
% events_name: name of the events variable
%
% -- OUTPUTS -- %
% lfp: vector of lfp
%		-> returned as a cell array if you do not specify sessionMarkers
% lfpTimes: vector of timestamps that correspond to each element of lfp
% srate: sampling rate of lfp
% lfpEvents: cell array containing lfp data organized by event start/stops
% lfpTimesEvents: same as lfp events, but for timestamps linearly spaced to
%                   match the size of LFP
%
% written by John Stout

function [lfp,lfpTimes,srate,lfpEvents,lfpTimesEvents] = getLFPdata(datafolder,csc_name,events_name)

% change directory to datafolder
cd(datafolder)

% load data
load(csc_name,'Samples','Timestamps');
try load(csc_name,'SampleFrequencies'); catch; end % try to load sample frequencies for srate

% load events and separate LFP based on the event markers
try load(events_name,'EventStrings','TimeStamps');
    if exist('TimeStamps')==0
        load(events_name,'TimeStamps_EV');
        TimeStamps = TimeStamps_EV;
    end
end
    
evStarts = find(contains(EventStrings,'Starting Recording')==1);
evEnds   = find(contains(EventStrings,'Stopping Recording')==1);
evEdges  = [TimeStamps(evStarts);TimeStamps(evEnds)]';

% loop across evnt markers
for i = 1:size(evEdges,1)

     % identify timestamps to keep
     idxKeep = [];
     idxKeep = find(Timestamps >= evEdges(i,1) & Timestamps <= evEdges(i,2));

     % get new samples and times
     SamplesKeep = []; TimestampsKeep = [];
     SamplesKeep    = Samples(:,idxKeep);
     TimestampsKeep = Timestamps(idxKeep);

     % linspacing this works great as long as you do not have multiple
     % starting recording epochs
     lfpEvents{i}      = SamplesKeep(:)';
     lfpTimesEvents{i} = linspace(TimestampsKeep(1),TimestampsKeep(end),length(lfpEvents{i}));
end
%disp('LFP will be returned as a cell array organized by starting and stopping recording epochs')

% now, you can concatenate LFP data as it contains all correct timestamps
lfp = []; lfpTimes = [];
lfp = horzcat(lfpEvents{:});
lfpTimes = horzcat(lfpTimesEvents{:});

%{
% fact check - you should have a straight line between epoch stop/start
    lfpTimesCat = horzcat(lfpTimesCell{:});
    figure; plot(lfpTimesCat) hold on; 
    plot(length(lfpTimes{1}),lfpTimes{1}(end),'*k')
    plot(length(lfpTimes{1})+1,lfpTimes{2}(1),'*r')
%}

if exist('SampleFrequencies')
    srate = mean(SampleFrequencies);
else
    srate = getLFPsrate(Timestamps,Samples);
end