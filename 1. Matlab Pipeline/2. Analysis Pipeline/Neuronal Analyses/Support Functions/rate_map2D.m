function [filtered_map, rate_map, binned_pos, binned_spike] = rate_map2D(ExtractedX, ExtractedY, TimeStamps, spk, Int, bin, sigma, plot)
%%

%   This function returns a 2-D occupancy map (seconds), spike map (number
%   of spikes), firing rate map (Hz), and smoothed firing rate map for a
%   given cluster during maze traversals

%   Inputs:
%       ExtractedX = 1 x n coordinates array of X-coordinate values
%       ExtractedY = 1 x n coordinates array of Y-coordinate values
%       TimeStamps = 1 x n timestamps array of position timestamps
%       spk =        n spikes x 1 array of spike timestamp values
%       Int =        n trials x 8 matrix of maze timestamp values
%       bin =        Spatial bin size for 2-D histogram
%       sigma =      Standard deviation for gaussian filter
%       plot =       0 if plot, 1 if no plot

%   Outputs:
%       filtered_map = Smoothed firing rate map
%       rate_map =     Raw firing rate map
%       binned_pos =   Occupancy map
%       binned_spike = Spike map
%    

% Henry Hallock code

%%

% Grab X coordinates, Y coordinates, and spikes that occurred during maze
% traversals
ntrials = size(Int,1);
start = Int(1,1);
finish = Int(ntrials,8);
start_ind = dsearchn(TimeStamps',start);
finish_ind = dsearchn(TimeStamps',finish);
X_new = ExtractedY(1,start_ind:finish_ind);
Y_new = ExtractedX(1,start_ind:finish_ind);
ts_new = TimeStamps(1,start_ind:finish_ind);
spk_ind = find(spk>start & spk<finish);
spk_new = spk(spk_ind);

% Put X and Y coordinates into one matrix
% Bin X and Y coordinates, and collect position counts in each bin
% Return bin centers for X and Y coordinates so that the same centers can
% be used when indexing spikes
% Divide position counts by 30 (Neuralynx position data sampling rate) to
% get occupancy (seconds) per bin
X_new(2,:) = Y_new;
X_new = X_new';
[binned_pos,C] = hist3(X_new,[bin bin]);
binned_pos = hist3(X_new,'Ctrs',C);
binned_pos = binned_pos/30;

% Create matrix of X and Y coordinates for each spike timestamp
for spikei = 1:length(spk_new)
    spk_ts = dsearchn(ts_new',spk_new(spikei,1));
    spk_x(spikei,1) = X_new(spk_ts,1);
    spk_x(spikei,2) = X_new(spk_ts,2);
end

% Bin spike position data based on same centers for position data
binned_spike = hist3(spk_x,'Ctrs',C);

% Divide number of spikes per bin by occupancy per bin to get firing rate
% values
rate_map = binned_spike ./ binned_pos;

% Get rid of spurious rate map data that occurred because of tracking
% errors
rate_map(1,1) = NaN;
rate_map_raw = rate_map;

% Convert NaNs in rate map to zeros for smoothing purposes
rate_map(isnan(rate_map)) = 0;

% Define Gaussian kernel based on given standard deviation value
[X,Y] = meshgrid(round(-bin/2):round(bin/2), round(-bin/2):round(bin/2));
f = exp(-X.^2/(2*sigma^2)-Y.^2/(2*sigma^2));
f = f./sum(f(:));

filtered_map = conv2(rate_map,f,'same');

% Put the NaNs back into the filtered map in areas where there was no
% recorded position data
% Having NaNs instead of zeros allows the rate map background to be white
for i = 1:size(filtered_map,1);
    for k = 1:size(filtered_map,2);
        if isnan(rate_map_raw(i,k))
            filtered_map(i,k) = NaN;
        end
    end
end
            
[nr,nc] = size(filtered_map);

if plot == 0
figure()
pcolor([filtered_map nan(nr,1); nan(1,nc+1)]);
shading flat;
set(gca, 'ydir', 'reverse');
colormap(jet)
box off
set(gca,'TickDir','out')
xlabel('X-Coordinate')
ylabel('Y-Coordinate')
end






        
    







end

