%% R21 delays
% -- INPUTS -- %
% LFP1name
% LFP2name
% delay_length
% amountOfData

function [coh,timeConv] = coherence_detection(LFP1name,LFP2name,coherence_threshold,looper,amountOfData,s,doorFuns,params,srate,tStart)

% initialize some variables
timeStamps = []; timeConv  = [];
coh_met    = []; coh_store = [];
dur_met    = []; dur_sum   = []; 
coh_temp   = []; coh = [];
openDoor = 0; % predefine to 0

% make this into a while loop that is dependent on elapsed time and whether
% the door has been open - elapsed time = toc(tStart)
openDoor = 0; % default
while (toc(tStart) < 35) && openDoor == 0
    
    % if a total of 45 seconds have passed, open up doors
    if toc(tStart) > 35 && openDoor == 0
        writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen])
        openDoor = 1;
    end

    % clear stream   
    clearStream(LFP1name,LFP2name);
    
    % pause 0.5 sec
    pause(0.5);
    
    % pull data
    [~, dataArray_new, timeStampArray, ~, ~, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

    % clean data
    data_clean = locdetrend(dataArray_new,params.Fs)

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
    if coh(i) < coherence_threshold % < bc this is low coh
        disp('Coherence threshold 1 met')

        % store data
        coh_met   = coh(i);
        coh_store = [coh_store,coh_met];

        % calculate, sum durations
        dur_met = timeConv(i);
        dur_sum = sum([dur_sum,dur_met]);  
        
        % open the door
        writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen]);

        % if your timer has elapsed > some preset time, open the startbox door
        if toc(tStart) > 10 & openDoor == 0
            writeline(s,doorFuns.centralOpen)
        end

    % otherwise, erase these variables, resetting the coherence
    % magnitude and duration counters
    else
        % if threshold is not met, reset the variable
        coh_met   = [];
        coh_store = [];
        dur_met   = [];
        dur_sum   = [];

        % if your timer has elapsed > some preset time, open the startbox door
        if toc(tStart) > 10 & openDoor == 0
            writeline(s,doorFuns.centralOpen)
        end

    end

    % if your threshold is met, break out, and start the next trial
    disp(['End of loop # ',num2str(i),'/',num2str(looper)])

end