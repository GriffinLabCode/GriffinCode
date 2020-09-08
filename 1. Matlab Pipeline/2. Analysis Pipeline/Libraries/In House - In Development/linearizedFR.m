%% linearizedFR
% this function gets firing rate grouped by bin. It does so by finding
% timestamps that correspond to each vt timestamp. Then using linear
% position (1:1 correspondent to timestamps), we group the spikes. Per each
% bin, we divide the sum of spikes within the bin by the total time spent
% in the bin. Sometimes, NaNs will occur. This happens if the binning
% process didn't detect a specific bin.
%
% -- INPUTS -- %
% spks: spike times
% times: timestamps (must be in same unit as spks)
% linearPosition: linear position for the time epoch of interest
% vt_srate: video tracking sampling rate
% resolution_pos: resolution for firing rate smoothing (for linearizing
%                   position, try 2 for 2 cm)
%
% -- OUTPUTS -- %
% smoothFR: smoothed firing rate across linear position bins
% FR: raw firing rates per bin
% numSpks: number of spikes per bin
% sumTime: amount of time per bin
% instSpk: spikes across time
% instTime: time

function [smoothFR,FR,numSpks,sumTime,instSpk,instTime] = linearizedFR(spks,times,linearPosition,vt_srate,resolution_pos)

    % find nearest points
    spkSearch = [];
    spkSearch = dsearchn(times',spks);

    % make time vector - instantaneous time intervals
    instTime = [];
    instTime = repmat(1/vt_srate,size(times)); % seconds sampling rate
          
    % shape of timestamp data - this will be instantaneous spike
    instSpk = [];
    instSpk = zeros(size(times));

    % replace and create boolean spk data - this is a for loop to account for
    % instances where a spk occured in the same timewindow multiple times
    for i = 1:length(spkSearch)
        instSpk(spkSearch(i)) = instSpk(spkSearch(i))+1;
    end
    
    % now bin the spikes according to linear position 
    for i = 1:max(linearPosition) % loop across the number of bins
        binSpks{i} = instSpk(linearPosition == i);
        binTime{i} = instTime(linearPosition == i);
    end
    
    % calculate firing rate per bin
    numSpks = cellfun(@sum,binSpks);
    sumTime = cellfun(@sum,binTime);

    % firing rate (spks/sec) - this is instantaneous firing rate
    FR = numSpks./sumTime; 
    
    % smooth firing rate
    pos_smooth = resolution_pos;
    smoothFR   = smoothdata(FR,'gaussian',pos_smooth);    
            
end