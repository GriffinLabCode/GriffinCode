%% R21 delays
% -- INPUTS -- %
% LFP1name
% LFP2name
% delay_length
% amountOfData

function [coh,timeConv] = lowCoherenceShortDuration(varargin)

% delay
disp(['Brief pause for ',num2str(delay_length),' secs'])
pause(delay_length);

% for loop start
coh_temp = [];
coh = [];
for i = 1:looper

    % first get a chunk of data the run a moving window on
    if i == 1

        % clear the stream
        clearStream(LFP1name,LFP2name);

        % get data
        pause(2); % grab one sec of data if this is the first loop
        try
            [succeeded, dataArray, timeStampArray, channelNumberArray, samplingFreqArray, ...
            numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  
        catch
        end  

        % calculate og coherence
        coh_temp = [];
        coh_temp = coherencyc(dataArray(1,:),dataArray(2,:),params);
        coh(i)   = nanmean(coh_temp);

    end

    % pause, then get data        
    pause(amountOfData);
    [~, dataArray_new, timeStampArray, ~, ~, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

    % define number of samples for continuous updating
    numSamples2use = [];
    numSamples2use = size(dataArray_new,2);

    % remove number of samples from the start of signal
    dataArray(:,1:numSamples2use)=[];

    % add data to end of dataArray creating a moving window on real-time
    % data
    dataArray = horzcat(dataArray,dataArray_new);

    % calculate coherence - chronux toolbox is way faster. Like sub 0.01
    % seconds sometimes, while wcoherence is around 0.05 sec.
    %[coh(i+1),phase,~,~,~,freq] = coherencyc(dataArray(1,:),dataArray(2,:),params);
    coh_temp = [];
    coh_temp = coherencyc(dataArray(1,:),dataArray(2,:),params);
    coh(i)   = nanmean(coh_temp);

    % amount of data in consideration
    timings(i) = length(dataArray)/srate;

    % store timestamp array to check later
    timeStamps(i) = size(timeStampArray,2); % size(x,2) bc we want columns (tells you how many samples occured per sample)

    % convert time
    timeConv(i) = timeStamps(i)*amountOfData;

    % first, if coherence magnitude is met, do whats below
    if coh(i) <= threshold.low_coherence_magnitude % < bc this is low coh
        disp('Coherence threshold 1 met')

        % store data
        coh_met   = coh(i);
        coh_store = [coh_store,coh_met];

        % calculate, sum durations
        dur_met = timeConv(i);
        dur_sum = sum([dur_sum,dur_met]);  

        % break out of the coherence detect threshold if thresholds
        % are met
        if dur_sum >= threshold.short_duration
            disp(['YES: Coherence sustained for ',num2str(dur_sum) ' seconds'])
            break
        else
            disp(['NO: Coherence sustained for ',num2str(dur_sum) ' seconds'])
        end

    % otherwise, erase these variables, resetting the coherence
    % magnitude and duration counters
    else
        % if threshold is not met, reset the variable
        coh_met   = [];
        coh_store = [];
        dur_met   = [];
        dur_sum   = [];
    end

    % if your threshold is met, break out, and start the next trial
    disp(['End of loop # ',num2str(i),'/',num2str(looper)])

end