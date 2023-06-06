%% unitEntrainment
%
% -- INPUTS -- %
% spikeIdx: index of spike timestamps, this must be in reference to your
%           LFP
% lfp: lfp data of interest
% lowpass: low pass filter
% highpass: high pass filter
% srate: sampling rate
%
% -- OUTPUTS

function [spkPhase,spkRadian,rayleighsP,rayleighsZ,bsMrl,n,xout] = unitEntrainment(spikeIdx,lfp,lowpass,highpass,srate)

            % filter LFP
            lfp = change_row_to_column(double(lfp)); % reorient
            lfpFilt  = skaggs_filter_var(lfp,lowpass,highpass,srate);
            
            % calculating hilberts phase
            [phase,phaseRad] = hilbertPhase(lfpFilt);

            % get spike phases
            spkPhase   = phase(spikeIdx);
            spkRadian  = phaseRad(spikeIdx);
            
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
            [n, xout] = hist(spkPhase,[0:30:360]);             
            