%% SCRIPT

% example run through of getting spike data
clear; clc;
datafolder   = 'X:\01.Experiments\RERh Inactivation Recording\Usher\Muscimol\Baseline';
int_name     = 'Int_VTE_JS.mat'; % 'Int2_JS'; % 'Int_file.mat';
vt_name      = 'VT1.mat';
missing_data = 'interp';
vt_srate     = 30; % 30 samples/sec
tt_name      = 'TT'; % what are the first two letters of your TTs?

% get video tracking data
[x,y,t] = getVTdata(datafolder,missing_data,vt_name);
% figure; plot(x,y)

% load int file
Int = getIntFile(datafolder,int_name);

% you can get spike data like this
[spikeData,spikeTimes] = getSpikeData(datafolder,tt_name);

% however, here, we're going to be generating raster plots
IntLoc     = 5; % define a location defined by timestamps on your int file. For example, Choice point entry
timeAround = [2 2]; % define time around the choice point. This is in seconds
[spk_sec,anchorTimes,clusters] = rasterPrep(datafolder,tt_name,Int,IntLoc,timeAround);

% "spk_sec" are spike data converted to seconds
% "anchorTimes" reflect the timestamps of choice point entry
% "clusters" are the names of the units you recorded/saved

% now we want to get spike data surrounding the choice point, but we also
% want to convert the spike times to "relative seconds" around the choice
% point. For example, we want to know if spike X occured 1 second from
% choice point entry
spkEvents = spk_sec;
[relativeSpikeTimes] = getRelativeSpikeTimes(spkEvents,anchorTimes);
% "relativeSpikeTimes" is the same size and shape as spk_sec. Open and
% compare these variables. Notice that "relativeSpikeTimes" are on a
% smaller scale of seconds, it tells you the exact time the spike happened
% relative to choice point entry. On the other hand, "spk_sec" is just raw
% spiking data converted to seconds.

% plot raster
getSpikeRaster(relativeSpikeTimes,timeAround)

% -- now, lets get the peri-stimulus time histogram data -- %
% this is important for different reasons. While the spike raster and the
% PETH tell you very similar things, the PETH allows us to bin the data in
% a very controlled manner
timeRes = 0.01; % 100ms resolution





