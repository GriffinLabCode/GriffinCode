%% unitEntrainment
%
% -- INPUTS -- %
% spikeIdx: index of spike timestamps, this must be in reference to your
%           LFP
% lfp: lfp data of interest
% lowpass: low pass filter
% highpass: high pass filter
% srate: sampling rate
% phaseMethod: enter 'interp' if you want to interpolate phase, otherwise
%               its hilbert
% filterThetaDelta: y = theta delta ratio
% filterArtifact: y = identify large anomalies
% remData: index of signals that the user wants to exclude 
%
% -- OUTPUTS -- %
% spkPhase: spike-phase values
% spkRadian: spike-radian values
% rayleighsP: p-statistic for raleighs test of non-uniformity
% rayleighsZ: z-stat for rayleighs test of non uniformity
% bsMrl: boostrapped mrl value
% n: binned phase counts
% xout: binned phase values

function [spkPhase,spkRadian,rayleighsP,rayleighsZ,bsMrl,phaseCounts,phaseVal] = unitEntrainment(spikeIdx,lfp,lowpass,highpass,srate,phaseMethod,filterThetaDelta,filterArtifact,remData)

            % filter LFP
            lfp = change_row_to_column(double(lfp)); % reorient
            lfpFilt  = skaggs_filter_var(lfp,lowpass,highpass,srate);
            
            % calculating hilberts phase
            if contains(phaseMethod,'interp') 
                disp('Interpolating theta phase')
                phase = phase_freq_detect(lfpFilt, lowpass, highpass, srate, 0);            
                phaseRad = phase*(pi/180); 
            else
                disp('Hilbert phase')
                [phase,phaseRad] = hilbertPhase(lfpFilt);
            end 
            
            % potential filter for theta:delta violations
            if ~exist('filterThetaDelta')
                filterThetaDelta = 'n';
            else
                if isempty(filterThetaDelta)
                    filterThetaDelta = 'n';
                end
                if contains(filterThetaDelta,[{'y'} {'Y'}])
                    disp('Filtering out signals if theta:delta ratio criterion not met');

                    % theta:delta ratio
                    [~, ~, ratio_ind, sws_ratio] = get_thetaOnly(lfp, srate);

                    % filter out LFP data that do not meet theta:delta
                    % criterion
                    % this code below might not work
                    phase(sws_ratio)=NaN;
                    phaseRad(sws_ratio)=NaN;
                end
            end
            
            % potential filter for artifacts
            if ~exist('filterArtifact')
                filterArtifact = 'n';
            else
                if isempty(filterArtifact)
                    filterArtifact = 'n';
                end
                if contains(filterArtifact,[{'y'} {'Y'}])
                    lfpNaNidx = filtLFPartifact(lfp,srate);
                    % add the artifactual data into the phase
                    phase(lfpNaNidx)=NaN;
                    phaseRad(lfpNaNidx)=NaN; 
                end
            end
            
            % check if this variable exists
            if ~exist('remData')
                remData = [];
            end
            % account for data to remove
            phase(remData)=NaN;
            phaseRad(remData)=NaN;

            % get spike phases
            spkPhase   = phase(spikeIdx);
            spkRadian  = phaseRad(spikeIdx);            
            
            % remove nan
            nanRem = []; nanRem = find(isnan(spkPhase));
            spkPhase(nanRem)=[];
            spkRadian(nanRem)=[];
            spikeIdx(nanRem)=[];
            
            if numel(spikeIdx) > 50
                disp([num2str(numel(spikeIdx)),' spikes']);
                % bootstrapped mrl
                rng('default'); % for replication
                permnum = 1000; % number of permutations
                for i = 1:permnum 
                    % working with same units and same
                    % distribution/pattern
                    randIdx = randsample(1:numel(spikeIdx),50);
                    mrl_sub(i) = circ_r(spkRadian(randIdx));  
                end     

                % entrainment statistics
                bsMrl = mean(mrl_sub);
                mrl   = circ_r(spkRadian); 
                [rayleighsP, rayleighsZ] = circ_rtest(spkRadian);
                [phaseCounts, phaseVal] = hist(spkPhase,[0:30:360]);  
            else
                mrl_sub = []; bsMrl = []; mrl = []; rayleighsP = [];
                rayleighsZ = []; phaseCounts = []; phaseVal = [];
            end
            