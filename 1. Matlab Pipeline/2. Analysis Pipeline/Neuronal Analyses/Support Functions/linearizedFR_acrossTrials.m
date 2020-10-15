%% linearizedFR_acrossTrials
% this function gets firing rate grouped by bin. It does so by finding
% timestamps that correspond to each vt timestamp. Then using linear
% position (1:1 correspondent to timestamps), we group the spikes. Per each
% bin, we divide the sum of spikes within the bin by the total time spent
% in the bin. Sometimes, NaNs will occur. This happens if the binning
% process didn't detect a specific bin.
%
% this is different from linearizedFR because it loops across all trials
% included in the function arguments. You don't need to include all trials,
% just whatever ones you want linear rates for
%
% -- INPUTS -- %
% some are cell arrays where each array is a trial
% spks: spike times for entire session
% times: a cell array of timestamps (must be in same unit as spks)
% linearPosition: a cell array linear position for the time epoch of interest
% vt_srate: video tracking sampling rate
% resolution_pos: resolution for firing rate smoothing (for linearizing
%                   position, try 2 for 2 cm)
%
% -- OUTPUTS -- %
% all are cell arrays where each array is a trial
% smoothFR: smoothed firing rate across linear position bins
% FR: raw firing rates per bin
% numSpks: number of spikes per bin
% sumTime: amount of time per bin
% instSpk: spikes across time
% instTime: time

function [smoothFR,FR,numSpks,sumTime,instSpk,instTime] = linearizedFR_acrossTrials(spks_session,times,linearPosition,total_dist,resolution_pos)

    % define numTrials
    numTrials = length(times);
    
    % initialize certain variables
    numSpks  = cell([1 numTrials]);
    sumTime  = cell([1 numTrials]);
    FR       = cell([1 numTrials]);
    smoothFR = cell([1 numTrials]);
    instTime = cell([1 numTrials]);
    instSpk  = cell([1 numTrials]);
        
    % get data per trial
    for triali = 1:numTrials
        
        % ensure you are only working with spks within the given time window
        spks_trial = [];
        spks_trial = spks_session(spks_session >= times{triali}(1) & spks_session <= times{triali}(end));

        % find nearest points
        spkSearch = [];
        spkSearch = dsearchn(times{triali}',spks_trial);
        
        % make time vector - instantaneous time intervals
        instTime{triali} = gradient(times{triali}/1e6); % this is more exact %repmat(1/vt_srate,size(times)); % seconds sampling rate

        % shape of timestamp data - this will be instantaneous spike
        instSpk{triali} = zeros(size(times{triali}));

        % replace and create boolean spk data - this is a for loop to account for
        % instances where a spk occured in the same timewindow multiple times
        for i = 1:length(spkSearch)
            instSpk{triali}(spkSearch(i)) = instSpk{triali}(spkSearch(i))+1;
        end

        % now bin the spikes according to linear position 
        %total_dist = max(linearPosition); % total distance the rat ran
        binSpks = cell([1 total_dist]); binTime = cell([1 total_dist]); % initialize
        for i = 1:total_dist % loop across the number of bins
            binSpks{i} = instSpk{triali}(find(linearPosition{triali} == i));
            binTime{i} = instTime{triali}(find(linearPosition{triali} == i));
        end

        % calculate firing rate per bin
        numSpks{triali} = cellfun(@sum,binSpks);
        sumTime{triali} = cellfun(@sum,binTime);

        % firing rate (spks/sec) - this is instantaneous firing rate
        FR{triali} = numSpks{triali}./sumTime{triali}; 
        
        % nans should be 0
        FR{triali}(find(isnan(FR{triali})==1)) = 0;

        % smooth firing rate
        pos_smooth = resolution_pos;
        smoothFR{triali} = smoothdata(FR{triali},'gaussian',pos_smooth);    
    end
end