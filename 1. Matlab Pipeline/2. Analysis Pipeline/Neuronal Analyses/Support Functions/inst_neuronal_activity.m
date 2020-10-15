%% instantaneous neuronal activity
% this function gets instantaneous firing rates and spikes across time.
% This is useful in two common scenarios: 1) you want to examine neuronal
% activity on a trial-by-trial basis across time. And 2) you want to
% examine neuronal activity across linearized position bins, organized by
% time.
%
% Furthermore, this function is powerful as it provides a different way to
% assess average firing rates. Eventually, other ways of getting mean fr
% will be depricated and this function will take its place as it requires a
% timestamps variable to direct the spks variable. Its a more generalizable
% function
%
% -- INPUTS -- %
% spks: spike times of a given trial or time of interest. This can be the
%       entire sessions worth of data, or not. It will only examine data
%       within the 'times' variables window
% times: timestamps of a given trial or time of interest - make sure the
%           spks and times variables are in the same unit of time (ie
%           seconds or standard neuralynx time)
% vt_srate: video tracking sampling rate
% totalTime: total time of the epoch of interest - this is not required,
%               but if left undefined, it is assumed that times is not
%               converted to sec
% resolution_time: resolution of time for smoothing (try 1, for 1 second)
%
% -- OUTPUTS -- %
% instFR: instantaneous firing rate
% instSpk: instantaneous spiking
% instTime: time interval for sampling rate
% instSpk_time: time (in seconds) of when the spks occurred
% meanFR: not instantaneous. But the average rate over the window of
%           interest
%
% written by John Stout

function [smoothFR,instFR,instSpk,instTime,instSpk_time,meanFR] = inst_neuronal_activity(spks,times,vt_srate,totalTime,resolution_time)

    % ensure you are only working with spks within the given time window
    spks_old = spks; spks = [];
    spks = spks_old(spks_old >= times(1) & spks_old <= times(end));

    % find nearest points
    spkSearch = [];
    spkSearch = dsearchn(times',spks);

    % shape of timestamp data - this will be instantaneous spike
    instSpk = [];
    instSpk = zeros(size(times));

    % replace and create boolean spk data - this is a for loop to account for
    % instances where a spk occured in the same timewindow multiple times
    for i = 1:length(spkSearch)
        instSpk(spkSearch(i)) = instSpk(spkSearch(i))+1;
    end

    % get index and time
    instSpk_idx  = find(instSpk ~= 0); % all cases of spks
    
    % define totalTime if non existent
    if exist('totalTime') == 0 || isempty(totalTime) == 1
        totalTime = (times(end)-times(1))/1e6;
    end
    
    % find how much time in consideration
    timingVar    = linspace(0,totalTime,numel(times));    
    instSpk_time = timingVar(instSpk_idx); % use this to plot spks across time

    % make time vector - instantaneous time intervals
    instTime = [];
    instTime = repmat(1/vt_srate,size(times)); % seconds sampling rate

    % get instantaneous firing rate - this doesn't really make sense unless you
    % collapse across specific bins
    instFR = instSpk./instTime;

    % remove nans
    instFR(find(isnan(instFR)==1)) = 0;    

    % if you want, you can derive linearized FR using the instantaneous
    % firing rate
    %{
    % derive the position rate map
    numLinearBins = max(linearPosition);
    for bini = 1:numLinearBins

        groupIdx = []; % initialize
        groupIdx = linearPosition == bini; % create grouping variable

        % group and average
        linearFR(bini) = nanmean(instFR(groupIdx));
    end 
    smoothLinFR = smoothdata(linearFR,'gaussian',6);
    %}
    
    % define smooth resolution
    if resolution_time > 0
        time_interval   = round(resolution_time/(1/vt_srate));
        smoothFR        = smoothdata(instFR,'gaussian',time_interval);   
    else
        smoothFR = instFR;
    end  
    
    % calculate non instant mean fr
    meanFR = sum(instSpk)/totalTime;
    
end