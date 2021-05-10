%% R21 delays
% -- INPUTS -- %
% LFP1name
% LFP2name
% delay_length
% amountOfData

function [coh,coh_met,timings,data_out,times_out] = coherence_detection(LFP1name,LFP2name,coherence_threshold,threshold_type,params,tStart,doorFuns,s)

% initialize some variables
timeStamps = []; timeConv  = [];
coh_met    = []; coh_store = [];
dur_met    = []; dur_sum   = []; 
coh_temp   = []; 

% VERY IMPORTANT
coh = []; timings = []; timeStamps = []; data_out = []; times_out = [];

% total delay
total_elapsed = 40;

% define srate
srate = params.Fs;

% make this into a while loop that is dependent on elapsed time and whether
% the door has been open - elapsed time = toc(tStart)
openDoor = 0; % default

if contains(threshold_type,'HIGH')
    
    while (toc(tStart) < total_elapsed) && openDoor == 0

        % if a total of 45 seconds have passed, open up doors
        if toc(tStart) > total_elapsed && openDoor == 0
            writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen])
            coh_met  = 0;
            openDoor = 1;
        end

        % sometimes, we error out (a sampling issue on neuralynx's end)
        attempt = 0;
        while attempt == 0
            try
                
                % clear stream   
                clearStream(LFP1name,LFP2name);

                % pause 0.5 sec
                pause(0.5);

                % pull data
                [~, dataArray, timeStampArray, ~, ~, ...
                numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

                attempt = 1;
            catch
            end
        end
        
        % detrend data - did not clean to improve processing speed
        data_det = [];
        data_det(1,:) = locdetrend(dataArray(1,:),params.Fs); 
        data_det(2,:) = locdetrend(dataArray(2,:),params.Fs); 
        
        % store data for later
        data_out  = [data_out data_det];
        times_out = [times_out timeStampArray];
        
        % calculate coherence - chronux toolbox is way faster. Like sub 0.01
        % seconds sometimes, while wcoherence is around 0.05 sec.
        %[coh(i+1),phase,~,~,~,freq] = coherencyc(dataArray(1,:),dataArray(2,:),params);
        coh_temp = [];
        coh_temp = coherencyc(data_det(1,:),data_det(2,:),params);    
        coh      = [coh nanmean(coh_temp)];
        %disp(['Coherence detected at ' num2str(num2str(nanmean(coh_temp)))]);

        % amount of data in consideration
        timings = [timings length(dataArray)/srate];

        % store timestamp array to check later
        timeStamps = [timeStamps size(timeStampArray,2)]; % size(x,2) bc we want columns (tells you how many samples occured per sample)

        % convert time
        %timeConv = [timeCov timeStamps*.5];

        % first, if coherence magnitude is met, do whats below
        if isempty(find(coh > coherence_threshold))==0 % < bc this is low coh

            %disp('High Coherence Threshold Met')

            % open the door
            writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen]);
            coh_met  = 1;
            openDoor = 1;

            % if your timer has elapsed > some preset time, open the startbox door
            if toc(tStart) > total_elapsed && openDoor == 0
                writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen])
                coh_met  = 0;
                openDoor = 1;            
            end

        % otherwise, erase these variables, resetting the coherence
        % magnitude and duration counters
        else

            % if your timer has elapsed > some preset time, open the startbox door
            if toc(tStart) > total_elapsed && openDoor == 0
                writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen])
                coh_met  = 0;                
                openDoor = 1;            
            end

        end

    end
elseif contains(threshold_type,'LOW')
    while (toc(tStart) < total_elapsed) && openDoor == 0

        % if a total of 45 seconds have passed, open up doors
        if toc(tStart) > total_elapsed && openDoor == 0
            writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen])
            coh_met  = 0;            
            openDoor = 1;
        end

        % sometimes, we error out (a sampling issue on neuralynx's end)
        attempt = 0;
        while attempt == 0
            try
                % clear stream   
                clearStream(LFP1name,LFP2name);

                % pause 0.5 sec
                pause(0.5);

                % pull data
                [~, dataArray, timeStampArray, ~, ~, ...
                numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

                attempt = 1;
            catch
            end
        end
        
        % clean data
        data_det = [];
        data_det(1,:) = locdetrend(dataArray(1,:),params.Fs); 
        data_det(2,:) = locdetrend(dataArray(2,:),params.Fs); 
        
        % store data for later
        data_out  = [data_out data_det];
        times_out = [times_out timeStampArray];

        % calculate coherence - chronux toolbox is way faster. Like sub 0.01
        % seconds sometimes, while wcoherence is around 0.05 sec.
        %[coh(i+1),phase,~,~,~,freq] = coherencyc(dataArray(1,:),dataArray(2,:),params);
        coh_temp = [];
        coh_temp = coherencyc(data_det(1,:),data_det(2,:),params);    
        coh      = [coh nanmean(coh_temp)];
        %disp(['Coherence detected at ' num2str(nanmean(coh_temp))]);

        % amount of data in consideration
        timings = [timings length(dataArray)/srate];

        % store timestamp array to check later
        timeStamps = [timeStamps size(timeStampArray,2)]; % size(x,2) bc we want columns (tells you how many samples occured per sample)

        % convert time
        %timeConv = [timeCov timeStamps*.5];

        % first, if coherence magnitude is met, do whats below
        if isempty(find(coh < coherence_threshold))==0 % < bc this is low coh

            %disp('Low Coherence Threshold Met')

            % open the door
            writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen]);
            coh_met  = 1;            
            openDoor = 1;

            % if your timer has elapsed > some preset time, open the startbox door
            if toc(tStart) > total_elapsed && openDoor == 0
                writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen])
                coh_met  = 0;                
                openDoor = 1;
            end

        % otherwise, erase these variables, resetting the coherence
        % magnitude and duration counters
        else

            % if your timer has elapsed > some preset time, open the startbox door
            if toc(tStart) > total_elapsed && openDoor == 0
                writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen])
                coh_met  = 0;                
                openDoor = 1;                
            end

        end

    end
else
    error('Something is wrong...')
end
% if while loop breaks out before opening the door, just open
writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen])
if openDoor == 0
    coh_met  = 0;
end





