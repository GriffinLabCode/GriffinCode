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
% event_boundaries: this variables lets us choose the boundaries for lfp.
%                       This must be in the format of a matrix, where rows
%                       denote number and columns denote start (1) and stop
%                       (2). For example: event_boundaries(1,1) = start(1)
%                       event_boundaries(1,2) = end(1); etc...
% conversion
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

function [lfp,lfpTimes,srate,lfpEvents,lfpTimesEvents] = getLFPdata(datafolder,csc_name,events_name,event_boundaries)

% change directory to datafolder
cd(datafolder)

% load data
varNames = [];
varNames = who('-file', csc_name);
cand_samples = varNames(contains(varNames,'Samples'));

% remove variables that are messing with loading
remData = [];
remData = contains(cand_samples,[{'umber'} {'quencies'} {'alid'}]);
cand_samples(remData)=[];
if length(cand_samples) > 1
    error('Need to specificy which samples variable to use')
end

% get timestamps
cand_times = varNames(contains(varNames,'tamp'));
if length(cand_times) > 1
    error('Need to specify which timestamp variable to use')
end
dataIn = []; dataNames = [];
dataIn = load(csc_name,cand_times{1},cand_samples{1});
dataNames = fieldnames(dataIn);
lfp_timestamps = dataIn.(dataNames{1});
lfp_samples    = dataIn.(dataNames{2});

%{
if isempty(find(contains(varNames,'Samples')==1))==0 && isempty(find(contains(varNames,'Timestamps')==1))==0
    load(csc_name,'Samples','Timestamps');
elseif isempty(find(contains(varNames,'CSC_Samples')==1))==0 && isempty(find(contains(varNames,'CSC_Timestamp')==1))==0
    load(csc_name,'CSC_Samples','CSC_Timestamp');
    Samples = CSC_Samples;
    Timestamps = CSC_Timestamp;
end
if isempty(find(contains(varNames,'SampleFrequencies')==1))==0
    load(csc_name,'SampleFrequencies');
else
    disp('SampleFrequencies not detected - will calculate srate')
end
%}

% load events and separate LFP based on the event markers
varNames = [];
varNames = who('-file', events_name);
idxEventTS = find(contains(varNames,[{'TimeStamps'} {'EV_Timestamps'} {'Timestamps'} {'TimeStamps_EV'}]));
idxEvents  = find(contains(varNames,[{'EventStrings'} {'EV_Eventstrings'} {'Eventstrings'} {'EventStrings_EV'}]));

% read data into a struct, get the names of the variables and generally
% store data as a general variable name
dataIn = []; dataNames = [];
dataIn = load(events_name,varNames{idxEventTS},varNames{idxEvents});
dataNames = fieldnames(dataIn);

% timestamps are pulled in first and are therefore the firstly extracted
% data
TimeStamps   = dataIn.(dataNames{1});
EventStrings = dataIn.(dataNames{2});

%{
if isempty(find(contains(varNames,'EventStrings')==1))==0 && isempty(find(contains(varNames,'TimeStamps')==1))==0
    load(events_name,'EventStrings','TimeStamps');
elseif isempty(find(contains(varNames,'EventStrings_EV')==1))==0 && isempty(find(contains(varNames,'TimeStamps_EV')==1))==0
    load(events_name,'EventStrings_EV','TimeStamps_EV');
    EventStrings = EventStrings_EV;
    TimeStamps   = TimeStamps_EV;
elseif isempty(find(contains(varNames,'EV_EventStrings')==1))==0 && isempty(find(contains(varNames,'EV_TimeStamps')==1))==0
    load(events_name,'EV_EventStrings','EV_TimeStamps');
    EventStrings = EV_EventStrings;
    TimeStamps   = EV_TimeStamps;    
end
%}
    
if exist('event_boundaries')
    evEdges = event_boundaries;
    correctedEdges = 0;
else
    evStarts = find(contains(EventStrings,'Starting Recording')==1);
    evEnds   = find(contains(EventStrings,'Stopping Recording')==1);
    % if the system was closed before "stopped recording" was selected...
    if isempty(evEnds)==1
        warning('Recording end was not found. Using the final Event timestamp as the LFP end boundary')
        evEnds = length(EventStrings);
    end
    try
        evEdges  = [TimeStamps(evStarts);TimeStamps(evEnds)]';
        correctedEdges = 0;
        %disp('Multiple stop/starts detected, ')
        %warning('***it is recommended that you enter your own event_boundaries***')
    catch
        warning('Starting/stopping recordings dont align, treating starts as stops')
        % sometimes in old data, there could be multiple starting recordings but not a clear stopping recording
        if numel(evStarts) ~= numel(evEnds)
            % if there is no true end (eg a "stopping recording")
            evTrueEnd = find(contains(EventStrings,'Stopping Recording')==1);
            if isempty(evTrueEnd)
                % treat the second start as the end
                if numel(evStarts) > numel(evEnds)
                    evTrueStarts = evStarts;
                    evTrueEnds   = evStarts(2:length(evStarts));
                    evTrueEnds(end+1) = length(EventStrings);
                    evTrueStarts = change_row_to_column(evTrueStarts);
                    evTrueEnds   = change_row_to_column(evTrueEnds);
                    % if the shape of evTrue and evEnds are the same, and if
                    % evEnd comes after evTrue, the issue should be resolved
                    if numel(evTrueStarts) == numel(evTrueEnds) && isempty(find(evTrueEnds-evTrueStarts < 0))
                        orderEvents = interleave_vars(evTrueStarts',evTrueEnds);
                        disp(['Issue should be resolved. Order of events = ' EV_EventStrings{orderEvents} ])
                        evStarts = []; evEnds = [];
                        evStarts = evTrueStarts;
                        evEnds   = evTrueEnds;
                        evStarts = change_row_to_column(evStarts);
                        evEnds   = change_row_to_column(evEnds);
                        evEdges  = [TimeStamps(evStarts);TimeStamps(evEnds)]';
                        correctedEdges = 1;
                    end
                end
            end
        end
    end
end

% loop across evnt markers
for i = 1:size(evEdges,1)

     % identify timestamps to keep
     if correctedEdges == 0
         idxKeep = [];
         idxKeep = find(lfp_timestamps >= evEdges(i,1) & lfp_timestamps <= evEdges(i,2));
     elseif correctedEdges == 1 % if edges were corrected, it means that there was no ending recording. 
         % Therefore the ending recording of edge 1 may be the start of
         % edge 2 and you will create interpolation artifacts
         idxKeep = [];
         idxKeep = find(lfp_timestamps >= evEdges(i,1) & lfp_timestamps < evEdges(i,2));         
     end
     
     % get new samples and times
     SamplesKeep = []; TimestampsKeep = [];
     SamplesKeep    = lfp_samples(:,idxKeep);
     TimestampsKeep = lfp_timestamps(idxKeep);

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
    srate = getLFPsrate(lfp_timestamps,lfp_samples);
end