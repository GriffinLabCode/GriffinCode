%% swr extraction
% this code is designed to extract sharp-wave ripples. Note that SWR
% extraction does not guarantee that what you're analyzing are true SWR
% events. User should examine data.
%
% specific details: ripples are included if their duration is greater than
%                    15 ms. Exclusion of ripples occurs if duration is less
%                    than 15ms or if two ripples are < 1 second apart.
%                    (Jadhav et al., 2016 - "coordinated excitation and
%                    inhibition...")
%
% -- INPUTS -- %
% lfp:            vector of raw lfp values
% mazeLoc:        An index that tells the function which maze locations to
%                 look at. So mazeLoc = [1 5] would tell the function to
%                 look at lfp from stem entry to t-junction entry
% Int:            Int file with all trials that you are interested in
%                 looking at.
% Timestamps:     Vector of timestamps
% srate:          samples/second
% phase_bandpass: [150 250] or whatever you choose
% gauss:          1 if smooth hilbert transformed data with gaussian, 0
%                  otherwise
% plotFig:        1 if you want to plot out individual steps, 0 otherwise
% std_above_mean: how many standard deviations above the mean? This is how
%                   you extract ripples. Anywhere from 3 to 6 is used in
%                   literature
% InterRippleInterval: time (in sec) where if a ripple occurs within this
%                       time window, following another ripple, it is
%                       removed. See Jadhav et al., 2016. This is relevant
%                       for instances where you want to extract spiking
%                       data around ripples or something.
%
% -- OUTPUTS -- %
% note that the outputs in this function are organized by trials in a cell
% array.
% SWRevents:    SWR events
% SWRdurations: variable indicating the length of each ripple event
% SWRtimes:     timestamps of swr
% SWRtimeIdx:   Index of swr timestamps
% trials2rem:   an index of the trials to exclude for various reasons, but
%               mostly due to lack of ripples
%
% written by John Stout

function [SWRevents,SWRtimes,SWRtimeIdx,SWRdurations,trials2rem] = extract_SWR(preSWRlfp,mazeLoc,Int,Timestamps,srate,std_above_mean,InterRippleInterval)

%% create a divisor based on sampling rate

% create a divisor to convert to sec or ms
divisor = srate*(1/1000); % first convert to ms

%% extract sharp wave ripples

% now get data from a specific maze location using the int file
numTrials = size(Int,1);

% initialize variables
trials2rem     = zeros([1 numTrials]); % this will be used later
zSmooth_data   = cell([1 numTrials]);
LFPtimes       = cell([1 numTrials]);
LFPidx         = cell([1 numTrials]);
possible_swrs  = cell([1 numTrials]);
idxRippleTimes = cell([1 numTrials]);
ripDuration    = cell([1 numTrials]);

for triali = 1:numTrials
    
    % zscored, transformed, smoothed data for extracting ripples
    zSmooth_data{triali} = preSWRlfp(Timestamps > Int(triali,mazeLoc(1)) & Timestamps < Int(triali,mazeLoc(2)));
    
    % timestmaps for extracting ripple
    LFPtimes{triali}     = Timestamps(Timestamps > Int(triali,mazeLoc(1)) & Timestamps < Int(triali,mazeLoc(2)));
    
    % index of lfp timestamps for extracting ripple
    LFPidx{triali}       = find(Timestamps > Int(triali,mazeLoc(1)) & Timestamps < Int(triali,mazeLoc(2)));

    % Buzsakis method from the fernandez ruiz science paper on long
    % duration ripples found ripples > 4std and ended the ripple time when
    % it dipped below 1std. Currently, We track when the ripple starts at
    % std_above_mean and its over after it dips below. But this may be why
    % the time durations are not that long.
    idxAbove = [];
    idxAbove = find(zSmooth_data{triali} >= std_above_mean);
    
    % define std_above_mean start time
    idxDiff = []; idxChangeDiff = []; idxStart = [];
    idxDiff       = diff(idxAbove);
    idxChangeDiff = [1 find(idxDiff ~= 1)+1];
    idxStart      = idxAbove(idxChangeDiff);
    
    % get end of ripple event (dips below 1)
    idxEnd = [];
    for i = 1:length(idxStart)
        restOfData  = []; idxBelowAll = []; idxBelow = [];
        restOfData  = zSmooth_data{triali}(idxStart(i):length(zSmooth_data{triali}));
        idxBelowAll = find(restOfData < 1);
        idxBelow    = idxBelowAll(1);
        idxEnd(i)   = idxStart(i)+(idxBelow-2);
    end
    
    % possible ripples
    idxRippleTimes{triali}(:,1) = idxStart;
    idxRippleTimes{triali}(:,2) = idxEnd;
    
    % sanity check - make sure that startPos and endPos are above set
    % std_above_mean
    swr_stdevs = [4 1];
    check1 = []; check2 = [];
    check1 = find(zSmooth_data{triali}(idxRippleTimes{triali}(:,1)) < swr_stdevs(1));
    check2 = find(zSmooth_data{triali}(idxRippleTimes{triali}(:,1)) < swr_stdevs(2));

    % if either are not empty, something is wrong
    if isempty(check1)==0 || isempty(check2)==0
        disp('Fatal error in extracting SWRs. Some were below set threshold')
        return
    end

    % find any instances where the potential ripple does not meet the
    % duration requirements and exlude the potential ripple
    ripDuration{triali} = idxRippleTimes{triali}(:,2) -idxRippleTimes{triali}(:,1);

    % exlude events that lasted less than 15ms
    notLongEnough = [];
    notLongEnough = find(ripDuration{triali} < 15*divisor);

    % remove
    idxRippleTimes{triali}(notLongEnough,:)=[];
    ripDuration{triali}(notLongEnough,:)=[];
 
end

% extract lfp data surrounding the defined ripple events
% ISSUE: sometimes the swr_events that are suppose to be above 3stds,
% we're getting less than 3
% inialize
numRipples      = cell([1 numTrials]);
swr_events      = cell([1 numTrials]);
swr_event_index = cell([1 numTrials]);
swr_timestamp   = cell([1 numTrials]);

for triali = 1:numTrials
    
    % find lfp data for each ripple
    numRipples{triali} = size(idxRippleTimes{triali},1);
    
    % loop across each ripple within each trial
    for j = 1:numRipples{triali}
        % get zscored smoothed/transformed data from ripple onset to ripple
        % offset
        swr_events{triali}{j}      = zSmooth_data{triali}(idxRippleTimes{triali}(j,1):idxRippleTimes{triali}(j,2));
        % index of ripple onset to offset
        swr_event_index{triali}{j} = LFPidx{triali}(idxRippleTimes{triali}(j,1):idxRippleTimes{triali}(j,2));
        % get timestamps within the events
        swr_timestamp{triali}{j}   = LFPtimes{triali}(idxRippleTimes{triali}(j,1):idxRippleTimes{triali}(j,2));
    end
end

% sanity check 2. We should be able to index back to the z-scored data, and
% that data should be the exact same size and be identical in value. If so,
% we can use swr_event_index to index any lfp or timestamp from the OG
% data.
arraysWithData = find((cellfun(@isempty,swr_event_index))==0);

% first, if there are no trials with swrs, break out of the function
if isempty(arraysWithData) == 1
    SWRtimes     = [];
    SWRtimeIdx   = [];
    SWRevents    = [];
    SWRdurations = [];
    trials2rem   = [];
    return
end

% next, perform sanity checks to ensure the indexing works
check3 = preSWRlfp(swr_event_index{arraysWithData(1)}{1});
check4 = swr_events{arraysWithData(1)}{1};
diffChecks = check4-check3; % this entire vector should be zero
if isempty(find(diffChecks ~= 0))==0 % if this is not empty, it means that our swr index does not index back to lfp and timestamps
    disp('Error - cannot use swr_event_index to index back to lfp and timestamps full vectors')
end

% sanity check 3 - make sure there are no instances where std is less than
% what the user set it as
for triali = 1:numTrials
    for swri = 1:length(swr_events{triali})
        if isempty(find(swr_events{triali}{swri} < std_above_mean))==0
            disp('*BUG ALERT* - swr event dipped below defined threshold')
        end
    end
end

% don't include swr events if two events are less than 1 sec apart (Jadhav
% et al., 2016). This is mostly for looking at single unit data around the
% ripple events
if InterRippleInterval > 0
   for triali = 1:numTrials
       
        % get number of swr events
        swrCount = length(swr_events{triali});
        
        % only do whats below if you have more than 1 swr event
        if swrCount > 1
            
            % defined for while loop
            next = 0; 

            % interface with user in case the code gets stuck
            disp(['Attempting to remove events that occur within ',num2str(InterRippleInterval),' sec on trial ',num2str(triali)]);
            
            % only run if there are actual events
            while next == 0
                % loop across events (minus 1 bc we're going to take event
                % i+1)
                if swrCount > 1
                    for i = 1:swrCount-1

                        % find cases where swrs are < 1 sec apart
                        timeOffset = (swr_timestamp{triali}{i+1}(1)-swr_timestamp{triali}{i}(1))/1e6;

                        % Only remove data if time offset < defined window, the
                        % time offset is positive, and if the loop does not
                        % equal the total swr count (this gets things stuck).
                        if timeOffset < InterRippleInterval && timeOffset > 0 && i ~= swrCount

                            disp('Removing swr event...')

                            % remove data
                            swr_events{triali}(i+1)      = []; % remove data
                            swr_timestamp{triali}(i+1)   = [];
                            swr_event_index{triali}(i+1) = []; 

                            % redefine swrCount
                            swrCount = length(swr_events{triali});

                            % break out of for loop after redefining swrCount,
                            % then the for loop redefines swrCount with the
                            % updated data. This is complicated bc the loop is
                            % changing inside the loop.
                            break

                        elseif timeOffset < 0
                            disp('Error with time indexing')
                            break

                        end

                        % break out of while loop
                        if i == swrCount-1
                            disp('Removal completed')
                            next = 1;
                        end
                    end
                % if there is only 1 event, exit the while loop, go to the
                % next trial.
                elseif swrCount == 1
                    next = 1;
                end
            end
        end
    end
end

% sanity check 4 - another check on duration
%"if the value of (length(swr_events{x})) is <30 then =[]"
SWRlens     = cell([1 numTrials]);
SWRtooshort = cell([1 numTrials]);
for triali = 1:numTrials
    
    try
        SWRlens{triali}     = cellfun(@length,swr_events{triali});
        SWRtooshort{triali} = find(SWRlens{triali} < 15*divisor);

        % remove cases of less than 30 samples (15 ms)
        swr_events{triali}(SWRtooshort{triali})      = [];
        swr_event_index{triali}(SWRtooshort{triali}) = [];
        swr_timestamp{triali}(SWRtooshort{triali})   = []; 
        
    catch
        SWRlens{triali}     = [];
        SWRtooshort{triali} = [];        
    end
    
end

%% generate outputs

% this may be redundant, can consolidate later
%SWRcount     = length(swr_event_index);
SWRtimes     = swr_timestamp;
SWRtimeIdx   = swr_event_index;
SWRevents    = swr_events;

% get durations
for triali = 1:numTrials
    try
        SWRdurations{triali} = cellfun(@length,swr_timestamp{triali})./divisor; % divide by divisor for ms (N samples * (1 ms / M samples ))
    catch
        SWRdurations{triali} = [];
    end
end

% spit out the trials 2 remove
trials2rem = find(cellfun('isempty',swr_events)==1);

end