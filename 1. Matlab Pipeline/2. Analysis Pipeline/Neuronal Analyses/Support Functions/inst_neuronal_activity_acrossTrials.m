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
% times{triali}tamps variable to direct the spks variable. Its a more generalizable
% function
%
% -- INPUTS -- %
% spks: spike times{triali} of a given trial or time of interest. This can be the
%       entire sessions worth of data, or not. It will only examine data
%       within the 'times{triali}' variables window
% times: times{triali}tamps in cell arrays for each trial
% vt_srate: video tracking sampling rate
% totalTime: total time of the epoch of interest - this is not required,
%               but if left undefined, it is assumed that times{triali} is not
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

function [smoothFR,instFR,instSpk,instTime,instSpk_time,meanFR] = inst_neuronal_activity_acrossTrials(spks_session,times,vt_srate,totalTime,resolution_time)

    % define numTrials
    numTrials = length(times{triali});
    
    % initialize certain variables
    smoothFR     = cell([1 numTrials]);
    instFR       = cell([1 numTrials]);
    instSpk      = cell([1 numTrials]);
    instTime     = cell([1 numTrials]);
    instSpk_time = cell([1 numTrials]);
    meanFR       = cell([1 numTrials]);
        
    % get data per trial
    for triali = 1:numTrials

        % get trial based spiking
        spks = spks_session(spks_session >= times{triali}(1) & spks_session <= times{triali}(end));

        % find nearest points
        spkSearch = [];
        spkSearch = dsearchn(times{triali}',spks);

        % shape of times{triali}tamp data - this will be instantaneous spike
        instSpk{triali} = zeros(size(times{triali}));

        % replace and create boolean spk data - this is a for loop to account for
        % instances where a spk occured in the same timewindow multiple times{triali}
        for i = 1:length(spkSearch)
            instSpk{triali}(spkSearch(i)) = instSpk{triali}(spkSearch(i))+1;
        end

        % get index and time
        instSpk_idx  = find(instSpk ~= 0); % all cases of spks

        % define totalTime if non existent
        if exist('totalTime') == 0 || isempty(totalTime) == 1
            totalTime = (times{triali}(end)-times{triali}(1))/1e6;
        end

        % find how much time in consideration
        timingVar    = linspace(0,totalTime,numel(times{triali}));    
        instSpk_time{triali} = timingVar(instSpk_idx); % use this to plot spks across time

        % make time vector - instantaneous time intervals
        instTime{triali} = repmat(1/vt_srate,size(times{triali})); % seconds sampling rate

        % get instantaneous firing rate - this doesn't really make sense unless you
        % collapse across specific bins
        instFR{triali} = instSpk{triali}./instTime{triali};
        
        % remove nans
        instFR{triali}(find(isnan(instFR{triali})==1)) = 0;

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
            time_interval    = round(resolution_time/(1/vt_srate));
            smoothFR{triali} = smoothdata(instFR,'gaussian',time_interval);   
        else
            smoothFR{triali} = instFR;
        end  

        % calculate non instant mean fr
        meanFR{triali} = sum(instSpk)/totalTime;

    end
end