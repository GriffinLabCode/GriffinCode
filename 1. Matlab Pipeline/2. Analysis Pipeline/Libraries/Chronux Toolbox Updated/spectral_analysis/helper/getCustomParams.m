%% custom parameters
%
% JS custom parameters

function [params] = getCustomParams()

%{
params.tapers    = [3 5];
params.trialave  = 0;
params.err       = [2 .05];
params.pad       = 0;
params.fpass     = [0 100]; % [1 100]
params.movingwin = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
params.Fs        = []; %data1.SampleFrequencies(1);
params.cleanFreq = [58 62];
%}

% use 3 and 5 for tapers - it really seems like the best middle ground
params.tapers = [3 5];
params.pad = 2; % padding helps frequency resolution
params.Fs = [];
params.fpass = [0 100];
params.err = [2 .05];
params.trialave = 0;
%params.cleanFreq = 60;

disp('Remember to define params.Fs as your sampling rate')


