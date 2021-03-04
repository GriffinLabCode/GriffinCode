%% R21 delays
% -- INPUTS -- %
% LFP1name
% LFP2name
% delay_length
% amountOfData

    % first, if coherence magnitude is met, do whats below
    if coh(i) >= threshold.high_coherence_magnitude % this is set to >= because the looper is super specific (0.25 increment), so the values are continuously sampled, but discretely. Therefore, to improve detection, set to >=
        disp('Coherence threshold 1 met')

        % store data
        coh_met   = coh(i);
        coh_store = [coh_store,coh_met];

        % calculate, sum durations
        dur_met = timeConv(i);
        dur_sum = sum([dur_sum,dur_met]);  

        % break out of the coherence detect threshold if thresholds
        % are met
        if dur_sum >= threshold.high_coherence_duration
            disp(['YES: Coherence sustained for ',num2str(dur_sum) ' seconds'])

            % make a variable telling you if thresholds were met
            thresholdsMet = 1;
            
            % open doors
            writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen]);

            % break out of loop
            break
            
        else
            % make a variable telling you if thresholds were met
            thresholdsMet = 0;

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

        % make a variable telling you if thresholds were met
        thresholdsMet = 0;         
    end

    % if your threshold is met, break out, and start the next trial
    disp(['End of loop # ',num2str(i),'/',num2str(looper)])
