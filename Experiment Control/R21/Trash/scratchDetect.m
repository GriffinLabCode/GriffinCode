%% SCRATCH DETECT
% scratching induces artifacts in the LFP that seem to exhibit a 10-20 hz
% range in their influence. Here, we take advantage of the 1/f law, in that
% low freq ranges should have much higher power than high freq. ranges.
% Thus, using a range 0-9hz should be much higher in power (on the order of
% magnitude of 1-2x greater) than 10-20hz power. 
%
% During scratching events, this is not true. 10-20hz power is much
% stronger!
%
% -- INPUTS -- %
% S1: power spectra from example LFP
% S2: power spectra from example LFP 2
% f: shared frequency distribution
% params: Chronux params. Use params = getCustomParams; and define
%           params.Fs
%
% -- OUTPUTS -- %
% lfpRatio1: ratio of good:bad range, where values > 1 indicate that the
%               0-9hz range is greater than equal in size. Values < 1
%               indicate that the 0-9 hz is far less in power than the
%               10-20hz range
% lfpRatio2: same as above for lfp signal 1
% accept: variable that indicates if you should accept or reject this
%           signal.
%
%
% written by John Stout


function [ratioDetect_s1,ratioDetect_s2] = scratchDetect(S1,S2,f)

% you have to use scratch data, hence the use of S1_b and S2_b
scratchRange = [10 20];
normalRange  = [1 9]; % avoiding 0 due to the roundoff effect

% define good and bad ranges
idxBadRange  = find(f > scratchRange(1) & f < scratchRange(2));
idxGoodRange = find(f > normalRange(1) & f < normalRange(2));

% get power for hpc and pfc
s1Bad = nanmean(S1(idxBadRange));
s2Bad = nanmean(S2(idxBadRange));

s1Good = nanmean(S1(idxGoodRange));
s2Good = nanmean(S2(idxGoodRange));

% compute ratio
ratioDetect_s1 = s1Good/s1Bad;
ratioDetect_s2 = s2Good/s2Bad;






