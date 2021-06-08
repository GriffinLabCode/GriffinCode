%% R21 delays
% -- INPUTS -- %
% LFP1name
% LFP2name
% delay_length
% amountOfData

function [coh,coh_met,timings,data_out,times_out] = coherence_detection(LFP1name,LFP2name,coherence_threshold,threshold_type,params,tStart,doorFuns,s,baselineMean,baselineSTD,total_elapsed)

% ---- %
% hard coded as a life-savor
params.fpass = [4 12];

if isempty(params.Fs)
    error('MUST have a defined sampling rate')
end
% ---- %

% initialize some variables
timeStamps = []; timeConv  = [];
coh_met    = []; coh_store = [];
dur_met    = []; dur_sum   = []; 
coh_temp   = []; 

% VERY IMPORTANT
coh = []; timings = []; timeStamps = []; data_out = []; times_out = [];

% total delay
if exist('total_elapsed')==0
    total_elapsed = 40;
    disp('total delay window defaulted to 40s')
end

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
                % store this for later
                coh = [coh NaN];
            end
        end
        
        % detrend data - did not clean to improve processing speed
        data_det = [];
        data_det(1,:) = locdetrend(dataArray(1,:),params.Fs); 
        data_det(2,:) = locdetrend(dataArray(2,:),params.Fs); 
        
        % store data for later
        data_out  = [data_out data_det];
        times_out = [times_out timeStampArray];
        
        %{
        % test for artifact
        zArtifact = [];
        zArtifact(1,:) = ((data_det(1,:)-baselineMean(1))./baselineSTD(1));
        zArtifact(2,:) = ((data_det(2,:)-baselineMean(2))./baselineSTD(2));
        
        % using a standard deviation threshold of 5 after looking over the
        % data
        noiseThreshold = 4;
        idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
        %}
        
        % detect artifacts
        idxNoise = []; zArtifact = [];
        [idxNoise,zArtifact] = artifactDetect(data_det,baselineMean,baselineSTD);
        
        % calculate coherence based on whether artifacts are present
        if isempty(idxNoise) ~= 1
            coh = [coh NaN]; % add nan to know this was ignored
            continue
            disp('scratch detected - coherence not calculated')
        else     
            % calculate coherence - chronux toolbox is way faster. Like sub 0.01
            % seconds sometimes, while wcoherence is around 0.05 sec.
            %[coh(i+1),phase,~,~,~,freq] = coherencyc(dataArray(1,:),dataArray(2,:),params);
            
            
            coh_temp = [];
            %coh_temp = coherencyc(data_det(1,:),data_det(2,:),params); 
            [coh_temp,~,~,S1,S2,f] = coherencyc(data_det(1,:),data_det(2,:),params); 
            coh = [coh nanmean(coh_temp)]; % add nan to know this was ignored

        end
       
        %{
        
        % -- update 5/14/21 -- %
        % due to the presence of scratching, any instance where power
        % ratios bw 1:9hz and 10:20hz are less than 1.5, the instance is not
        % considered. Moreover, if coherence in the 10:20hz range exceeds
        % 0.8 (based on visualizations), the data is not considered.
        % Moreover, those scratches tnend to have clipping artifacts,
        % therefore, any instance where a clipping artifact exceeds 1% of
        % the signal is excluded
                
        % detect scratch
        [ratioDetect_s1,ratioDetect_s2] = scratchDetect(S1,S2,f);
        
        % detect clippings
        sat1 = detect_clipping(data_det(1,:));
        sat2 = detect_clipping(data_det(2,:));
        
        if ratioDetect_s1 < 1 | ratioDetect_s2 < 1 | sat1 > 1 | sat2 > 2
            coh = [coh NaN]; % add nan to know this was ignored
            continue
            disp('scratch detected - coherence not calculated')
        else
            coh      = [coh nanmean(coh_temp(f > 4 & f < 12))];
            %coh      = [coh nanmean(coh_temp)];
            %disp(['Coherence detected at ' num2str(num2str(nanmean(coh_temp)))]);
        end
        %}
        
        % amount of data in consideration
        timings = [timings length(dataArray)/srate];

        % store timestamp array to check later
        timeStamps = [timeStamps size(timeStampArray,2)]; % size(x,2) bc we want columns (tells you how many samples occured per sample)

        % convert time
        %timeConv = [timeCov timeStamps*.5];

        % first, if coherence magnitude is met, do whats below
        if isempty(find(coh > coherence_threshold))==0 % < bc this is low coh

            %disp('High Coherence Threshold Met')

            % sustained coherence
            if length(coh) > 1
                if isnan(coh(end)) == 0 && isnan(coh(end-1)) == 0
                    if coh(end) > coherence_threshold && coh(end-1) > coherence_threshold
                        % open the door
                        writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen]);
                        coh_met  = 1;
                        openDoor = 1;      
                    end
                end
            end
            
            %{
            % open the door
            writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen]);
            coh_met  = 1;
            openDoor = 1;
            %}
            
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
                coh = [coh NaN];
            end
        end
        
        % clean data
        data_det = [];
        data_det(1,:) = locdetrend(dataArray(1,:),params.Fs); 
        data_det(2,:) = locdetrend(dataArray(2,:),params.Fs); 
        
        % store data for later
        data_out  = [data_out data_det];
        times_out = [times_out timeStampArray];

        %{
        % test for artifact
        zArtifact = [];
        zArtifact(1,:) = ((data_det(1,:)-baselineMean(1))./baselineSTD(1));
        zArtifact(2,:) = ((data_det(2,:)-baselineMean(2))./baselineSTD(2));
        
        % using a standard deviation threshold of 5 after looking over the
        % data
        noiseThreshold = 4;
        idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
        %}
        
        % detect artifacts
        idxNoise = []; zArtifact = [];        
        [idxNoise,zArtifact] = artifactDetect(data_det,baselineMean,baselineSTD);
        
        % calculate coherence based on whether artifacts are present
        if isempty(idxNoise) ~= 1
            coh = [coh NaN]; % add nan to know this was ignored
            continue
            disp('scratch detected - coherence not calculated')
        else     
            % calculate coherence - chronux toolbox is way faster. Like sub 0.01
            % seconds sometimes, while wcoherence is around 0.05 sec.
            %[coh(i+1),phase,~,~,~,freq] = coherencyc(dataArray(1,:),dataArray(2,:),params);
            
            
            coh_temp = [];
            %coh_temp = coherencyc(data_det(1,:),data_det(2,:),params); 
            [coh_temp,~,~,S1,S2,f] = coherencyc(data_det(1,:),data_det(2,:),params); 
            coh = [coh nanmean(coh_temp)]; % add nan to know this was ignored

        end
        
        % amount of data in consideration
        timings = [timings length(dataArray)/srate];

        % store timestamp array to check later
        timeStamps = [timeStamps size(timeStampArray,2)]; % size(x,2) bc we want columns (tells you how many samples occured per sample)

        % convert time
        %timeConv = [timeCov timeStamps*.5];

        % first, if coherence magnitude is met, do whats below
        if isempty(find(coh < coherence_threshold))==0 % < bc this is low coh

            %disp('Low Coherence Threshold Met')

            % sustained coherence\
            if length(coh) > 1
                if isnan(coh(end)) == 0 && isnan(coh(end-1)) == 0 % if both coh of interest are real
                    if coh(end) < coherence_threshold && coh(end-1) < coherence_threshold
                        % open the door
                        writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen]);
                        coh_met  = 1;
                        openDoor = 1;      
                    end
                end
            end         
            %{
            % open the door
            writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen]);
            coh_met  = 1;            
            openDoor = 1;
            %}
            
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





