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

function [SWRevents,SWRtimes,SWRtimeIdx,SWRdurations,trials2rem] = extract_SWR_simple(lfp,mazeLoc,Int,Timestamps,srate,phase_bandpass,std_above_mean,gauss,InterRippleInterval,plotFig)

%% create a divisor based on sampling rate

% create a divisor to convert to sec or ms
divisor = srate*(1/1000); % first convert to ms

%% extract sharp wave ripples

% z-score data so that elements reflect sd from the mean
zSmoothedAll = zscore(lfp);

% use RunLength function. Possible_swrs indicates the start and end of 
% periods where the std is greater than the user define threshold.
[~, ~, possible_swrs] = RunLength(zSmooth_data >= std_above_mean);

% if the possible_swrs{triali} cell is empty, and its the first loop,
% you may get an error. so we add an if statement
if isempty(possible_swrs{triali})==1 % if there WERE ripples, do the following...
    trials2rem(triali) = 1;
    continue
end

% sometimes, the first value may not reach threshold. Therefore account
% for those instances.
if zSmooth_data{triali}(possible_swrs{triali}(1)) < std_above_mean
    possible_swrs{triali}(1) = []; % for some reason this is "1" despite it not being important
end

% if this array is now empty, skip
if isempty(possible_swrs{triali})==1
    trials2rem(triali) = 1;
    continue
end

% sometimes, the final value will reach threshold with no end point in
% sight, we need to erase these cases. Note that
% possible_swrs{triali}(end) SHOULD NOT be > std_above_mean. In fact
% possible_swrs{triali}(end), and possible_swrs{triali}(2:2:length(possible_swrs{triali}))
% should not reach threshold. The index accounts for the onset of the
% ripple to one element beyond the end of the ripple. Therefore, 
% possible_swrs{triali}(end-1) should ALWAYS reach threshold. The same
% is true for
% possible_swrs{triali}(2:2:length(possible_swrs{triali}))-1. The '-1'
% allows us to get the potential SWR offset.
if zSmooth_data{triali}(possible_swrs{triali}(end)) > std_above_mean && zSmooth_data{triali}(possible_swrs{triali}(end-1)) < std_above_mean
    possible_swrs{triali}(end) = []; % for some reason this is "1" despite it not being important
end    

% get start of potential ripples
startPos = [];
startPos = possible_swrs{triali}(1:2:length(possible_swrs{triali}));

% get end of potential ripple. % must subtract 1, the possible_swrs var 
% indicates the start of swr and 1 after the end of swr
endPos = [];
endPos = possible_swrs{triali}(2:2:length(possible_swrs{triali}))-1; 

% sanity check - make sure that startPos and endPos are above set
% std_above_mean
check1 = []; check2 = [];
check1 = find(zSmooth_data{triali}(startPos) < std_above_mean);
check2 = find(zSmooth_data{triali}(endPos) < std_above_mean);

% if either are not empty, something is wrong
if isempty(check1)==0 || isempty(check2)==0
    disp('Fatal error in extracting SWRs. Some were below set threshold')
    return
end

% concatenate data
idxRippleTimes{triali} = horzcat(startPos',endPos');

% find any instances where the potential ripple does not meet the
% duration requirements and exlude the potential ripple
ripDuration{triali} = idxRippleTimes{triali}(:,2) - idxRippleTimes{triali}(:,1);

% exlude events that lasted less than 15ms
notLongEnough = [];
notLongEnough = find(ripDuration{triali} < 15*divisor);

% remove
idxRippleTimes{triali}(notLongEnough,:)=[];
ripDuration{triali}(notLongEnough,:)=[];

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
check3 = zSmoothedAll(swr_event_index{1}{1});
check4 = swr_events{1}{1};
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
        swrCount = length(swr_events{triali});
        next = 0; % defined for while loop
        while next == 0
            for i = 1:swrCount-1

                % find cases where swrs are < 1 sec apart
                timeOffset = (swr_timestamp{triali}{i+1}(1)-swr_timestamp{triali}{i}(1))/1e6;

                % remove those instances when you find them
                if timeOffset < InterRippleInterval && timeOffset > 0

                    % remove data
                    swr_events{triali}(i+1)      = []; % remove data
                    swr_timestamp{triali}(i+1)   = [];
                    swr_event_index{triali}(i+1) = []; 

                    % redefine swrCount
                    swrCount = length(swr_events{triali});

                    % must break out of for loop, then redefine loop
                    break

                end

                % time offset should never be a negative integer. If it is, something
                % is wrong.
                if timeOffset < 0
                    disp('Error with time indexing')
                    break
                end 

                if i == swrCount-1
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