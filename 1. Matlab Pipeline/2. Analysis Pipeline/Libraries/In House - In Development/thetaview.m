%% This is a function made to verify correct hippocampal CSC using mspectrumc plot and look for theta bump 

   %Specifics- often times when working with unfamiliar sets of data
   %several CSCs are within the datafolder and what file corresponds to
   %which region is unlabeled. Using mtspectrumc a user could visually
   %confirm CSC files as Hippocampus vs medial Prefrontal Cortex etc...
%% INPUTS//OUTPUTS

%--INPUTS--
% lfp:            vector of raw lfp values
% Int:            Int file with all trials that you are interested in
%                 looking at.
% Timestamps:     Vector of timestamps


%--OUTPUTS--
%powmean: mean values of power matrix
%SEMpowmean: standard error from mean for matrix mean values 
%powmeancorrected: log corrected mean values of power matrix
%SEMpowmeancorrected: log corrected standard error from the mean for matrix
%                     mean values 
%srate:samples/second
%params: parameters for chronux spectrogram

function [LFP_stem,csc_srate,csc_params,csc_powmean,csc_SEMpowmean,csc_powmeancorrected,csc_SEMpowmeancorrected] = thetaview(Int,Timestamps,lfp,params,view_auto)

% redefine variable for stem
mazePos_stem = [1 5];

numTrials = size(Int,1); % define number of trials
clear X Y TS LFPtimes LFP
for triali = 1:numTrials
    LFPtimes_stem{triali} = Timestamps(Timestamps > Int(triali,mazePos_stem(1)) & Timestamps < Int(triali,mazePos_stem(2)));
    LFP_stem{triali}      = lfp(Timestamps > Int(triali,mazePos_stem(1)) & Timestamps < Int(triali,mazePos_stem(2)));
end

% get power
pow_lfpstem = cell([1 numTrials]); freq_lfpstem = cell([1 numTrials]);
for triali = 1:numTrials
    [pow_LFP_stem{triali},freq_LFP_stem{triali}]=mtspectrumc(LFP_stem{triali},params);
end
    %S = Power
    %f = Frequency 

% change the frequency resolution to match the smallest frequency
% resolution
freqLengths   = cellfun(@length,freq_LFP_stem);
minLen        = min(freqLengths);
selectedIdx   = find(freqLengths == minLen);
selectedFreq  = freq_LFP_stem{selectedIdx(1)};
trials2change = find(freqLengths ~= minLen);

for changei = trials2change
    DwnSamp_idx{changei} = dsearchn(freq_LFP_stem{changei}', selectedFreq');%why ' here?
end

for changei = trials2change
    freq_LFP_stem{changei} = freq_LFP_stem{changei}(DwnSamp_idx{changei});
    pow_LFP_stem{changei} = pow_LFP_stem{changei}(DwnSamp_idx{changei});
end

SizeCheckpow = cellfun(@length,pow_LFP_stem);
SizeCheckpow = unique(SizeCheckpow);

if numel(SizeCheckpow) == 1
    disp 'Down-Sample Success'
else
    disp 'Down-Sample Failure'
end
    
%% I want the mean(for freq and pow) of all trials
powmatrix  = horzcat(pow_LFP_stem{:}); %why do i need this to be a matrix?
powmatrix  = (powmatrix');
powmean    = mean(powmatrix);
SEMpowmean = stderr(powmatrix); %std(powmatrix)./(sqrt(numTrials));

%% Log correction
logcorrectpow       = 10*log10(powmatrix);
powmeancorrected    = mean(logcorrectpow);
SEMpowmeancorrected = stderr(logcorrectpow); %std(powmeancorrected)./(sqrt(numTrials));

%% VISUALIZATION
if view_auto == 1 
%Plot
    x_label_CSC = freq_LFP_stem{1}; 

    figure('color','w');
        subplot 211
        shadedErrorBar(x_label_CSC,powmean,SEMpowmean,'b',1);
        xlabel('Frequency(Hz)')
        ylabel('Avg. Power')
        xlim([0 50])
        box off;
    subplot 212
        shadedErrorBar(x_label_CSC,powmeancorrected,SEMpowmeancorrected,'r',1)
        xlabel('Frequency')
        ylabel('Power (log transformed)')
        xlim([0 50])
        box off
end

end         
