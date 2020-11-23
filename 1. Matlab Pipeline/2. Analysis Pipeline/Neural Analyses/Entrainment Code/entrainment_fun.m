%% entrainment
% this code was adapted from henry hallocks entrainment code. I
% incorporated a down-sampling procedure and changed some minor things to
% improve analysis time. I chose to down-sample after filtering to prevent
% aliasing problems. The idea to down-sample came from jadhav et al., 2016
% ('coordinated excitation and inhibition...'). This greatly improves
% processing times.
%
% The shuffling results should be interpreted with caution.
%
% rewritten and modified by John Stout - large chunks taken from Henry
% Hallock. Phase interpolation function received from Mark Brandon
%
% ~~ INPUTS ~~ 
% LFP: LFP data concatenated across trials
% spikes: spike timestamps concatenated across trials
% signalTimes: timestamps concatenated across trials
% phase_bandpass: a 1x2 vector [4 12] is an example for extracting theta
% srate: sampling rate
% downSample: 1 or 0, if 1, data is downsampled to 125Hz after filtering  
% shuffle: do you want to shuffle your phase values? This could be used to
%           create a null distribution
% spkCount: number of spikes required to run analysis
%
% ~~ OUTPUTS ~~
% mrl: mrl calculated before subsampling
% mrl_subbed: averaged mrl subsampled to 50 spikes
% p value obtained to represent significant modulation
%
%
function [mrl,mrl_subbed,p,spkPhaseRad,spkPhaseDeg,z] = entrainment_fun(LFP,spikes,signalTimes,phase_bandpass,srate,downSample,shuffle,thetaDelta_threshold)

% Filter phase signal
[signal_filtered] = skaggs_filter_var(LFP,phase_bandpass(:,1),phase_bandpass(:,2),srate);

if downSample == 1
    
    % downsample data - Jadhav et al., 2016  
    target_downSample = 125;
    div = find_downsample_rate(srate,target_downSample);

    % provide new srate
    srateNew = length(1:div:srate);
    srate    = [];
    srate    = srateNew;

    % downsample data after filtering example - https://dsp.stackexchange.com/questions/36399/which-order-to-perform-downsampling-and-filtering
    times_use = signalTimes(1:div:end);
    lfp_use   = signal_filtered(1:div:end);
    
else
    
    times_use = signalTimes;
    lfp_use   = signal_filtered;
    
end

% Extract phase information from filtered signal
Phase        = phase_freq_detect(lfp_use, times_use, 6, 10, srate); 
PhaseRadians = Phase*(pi/180); 

% only include epochs when theta:delta ratio is 4:1
[thetaDeltaRatio,~,lfp_highTheta] = Theta_Delta_Ratio(LFP,[5 9],[0 4],srate);
TD_idx = find(thetaDeltaRatio >= thetaDelta_threshold);

if shuffle == 0
    
    % Assign a phase value to each spike
    numSpikes = length(spikes);
    for j = 1:numSpikes
        spk_ind(j)       = dsearchn(times_use',spikes(j)');
        spkPhaseRad(j,:) = PhaseRadians(spk_ind(j),:);
        spkPhaseDeg(j,:) = Phase(spk_ind(j),:);   
    end
    
    % only include if theta:delta > 4
    phaseIdx    = intersect(spk_ind,TD_idx);
    Phase_TD    = Phase(phaseIdx); 
    PhaseRad_TD = PhaseRadians(phaseIdx);

    % Get rid of spikes that could not be assigned a phase value due to low
    % amplitude oscillations
    PhaseRad_TD(isnan(PhaseRad_TD)) = [];
    Phase_TD(isnan(Phase_TD)) = [];

    % Create sub-sampled MRL value from bootstrapped spike-phase distribution
    permnum = 1000;
    for i = 1:permnum  
        random_spikes = randsample(PhaseRad_TD,20);
        mrl_sub(i)    = circ_r(random_spikes);      
    end

    % Calculate MRL, Rayleigh's z-statistic, and p-value based on null
    % hypothesis of uniform spike-phase distribution
    mrl_subbed  = mean(mrl_sub,2);
    mrl         = circ_r(PhaseRad_TD); 
    [p, z]      = circ_rtest(PhaseRad_TD); 
    %[n, xout] = hist(spkPhaseDeg,[0:30:360]); 

elseif shuffle == 1
    
    for shuffi = 1:1000
        Phase        = randsample(Phase,numel(Phase));
        PhaseRadians = randsample(Phase,numel(PhaseRadians));
    
        % Assign a phase value to each spike
        numSpikes = length(spikes);
        for j = 1:numSpikes
            spk_ind = dsearchn(times_use',spikes(j)');
            spkPhaseRad(j,:) = PhaseRadians(spk_ind,:);
            spkPhaseDeg(j,:) = Phase(spk_ind,:);   
        end

        % Get rid of spikes that could not be assigned a phase value due to low
        % amplitude oscillations
        spkPhaseRad(isnan(spkPhaseRad)) = [];
        spkPhaseDeg(isnan(spkPhaseDeg)) = [];

        % get the number of included spikes
        includedSpikeCount = length(spkPhaseRad);

        if includedSpikeCount >= spkCount
            % Create sub-sampled MRL value from bootstrapped spike-phase distribution
            permnum = 1000;
            for i = 1:permnum  
                random_spikes = randsample(spkPhaseRad,spkCount);
                mrl_sub{shuffi}(i)    = circ_r(random_spikes);      
            end

            % Calculate MRL, Rayleigh's z-statistic, and p-value based on null
            % hypothesis of uniform spike-phase distribution
            mrl_subbed(shuffi)     = mean(mrl_sub{shuffi},2);
            mrl(shuffi)            = circ_r(spkPhaseRad); 
            [p(shuffi), z(shuffi)] = circ_rtest(spkPhaseRad); 
            %[n, xout] = hist(spkPhaseDeg,[0:30:360]); 

            % get averages of shuffled data
            mrl_subbed = mean(mrl_subbed);
            mrl        = mean(mrl);
            z          = mean(z);
        else
            mrl_subbed  = NaN;
            mrl         = NaN;
            p           = NaN;
            spkPhaseRad = NaN;
            spkPhaseDeg = NaN;
            z           = NaN;      
        end  
    end    
end

end
         


