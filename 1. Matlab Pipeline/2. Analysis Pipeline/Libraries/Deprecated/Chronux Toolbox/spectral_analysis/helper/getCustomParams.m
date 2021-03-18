%% custom parameters
%
% JS custom parameters

function [params] = getCustomParams()

params.tapers    = [3 5];
params.trialave  = 0;
params.err       = [2 .05];
params.pad       = 0;
params.fpass     = [0 100]; % [1 100]
params.movingwin = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
params.Fs        = []; %data1.SampleFrequencies(1);
params.cleanFreq = [58 62];

disp('Remember to define params.Fs as your sampling rate')


