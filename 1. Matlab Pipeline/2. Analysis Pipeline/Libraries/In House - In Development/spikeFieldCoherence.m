%% trying to get spike field coherence to work
clear; clc
datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Usher\Saline\Baseline';
[x,y,t] = getVTdata(datafolder,'interp','VT1.mat');

% get lfp and spike data
spikeData = get_spkTimes(datafolder,'TT6_SS_04');
[lfp,lfpTimes] = getLFPdata(datafolder,'HPC');

%
params = getCustomParams;
params.fpass = [0 100];
params.tapers = [10 19];
params.err = [1 .05];

% spike field
data1 = lfp';
data2 = spikeData{1}(1:50);
[C,phi,S12,S1,S2,f]=coherencycpt(data1,data2,params);








