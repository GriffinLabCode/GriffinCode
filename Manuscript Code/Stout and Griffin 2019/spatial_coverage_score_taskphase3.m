%% spatial specificity 
% this function calculates the spatial specificity using the data from the
% rate map function. This was inspired by Jadhav et al., 2016s spatial
% specificity score
%
% Spatial specificity is calculated by finding 25% of the smoothed
% peak-rate from the rate-map, then dividing the number of instances of
% times where the rate exceeded 25% by the total number of instances of
% firing-rates that were binned on the maze
%
% To control for peak-rates influence on spatial-coverage, this script
% utilized the lower peak-rate between task-phases. This is because
% utilizing the larger peak-rate results in rate-maps that don't visually
% match the score. 
%
% INPUTS
% datafolder
% Int
% ExtractedX, ExtractedY
% TimeStamps
% maze_times
% spk
% clusters
%
% OUTPUTS:
% spatial_specificity: a scalar value between 0 and 1, where values closer
%                      to 0 exhibit stronger specificity
%
% written by Henry Hallock (some pieces of rate-map portion) and 
% John Stout (conversions, some pieces of rate map portion, spatial
% specificty portion)

 
function [coverage_sample,coverage_choice,peak_rate_sample,peak_rate_choice] = spatial_coverage_score_taskphase3(datafolder,Int,ExtractedX,ExtractedY,TimeStamps,spk,clusters)   

    % invert spk variable
    spk = spk';

    % convert the position data to cm
    ExtractedX = round(ExtractedX./2.09);
    ExtractedY = round(ExtractedY./2.04);
    
    % make extractedX and Y equal to half the value so that when binning,
    % each bin accounts for 2cm instead of 1cm
    ExtractedX_weighted = round(ExtractedX./2);
    ExtractedY_weighted = round(ExtractedY./2);
    
%% control for bin size
trials = 1:size(Int,1);
for i = 1:size(Int,1)
   X_weighted_tmp{i} = ExtractedX_weighted(find(TimeStamps>Int(trials(i),1) & TimeStamps<Int(trials(i),8)));
   Y_weighted_tmp{i} = ExtractedY_weighted(find(TimeStamps>Int(trials(i),1) & TimeStamps<Int(trials(i),8)));
end 
   X_weighted = horzcat(X_weighted_tmp{:});
   Y_weighted = horzcat(Y_weighted_tmp{:});

   bin   = [max(X_weighted) max(Y_weighted)];
   sigma = 2; % sigma 2 corresponds to 8cm, sigma 4 corresponds to sd of 
    
%% sample trials
sample_trials = 1:2:size(Int,1);
    for i = 1:length(sample_trials)
        cell_X{i} = ExtractedX(find(TimeStamps>Int(sample_trials(i),1) & TimeStamps<Int(sample_trials(i),8)));
        cell_Y{i} = ExtractedY(find(TimeStamps>Int(sample_trials(i),1) & TimeStamps<Int(sample_trials(i),8)));
        cell_T{i} = TimeStamps(find(TimeStamps>Int(sample_trials(i),1) & TimeStamps<Int(sample_trials(i),8)));
        cell_S{i} = spk(find(spk>Int(sample_trials(i),1) & spk<Int(sample_trials(i),8)));
        cell_Sind{i} = (find(spk>Int(sample_trials(i),1) & spk<Int(sample_trials(i),8)));
    end

    X = horzcat(cell_X{:});
    Y = horzcat(cell_Y{:});
    ts = horzcat(cell_T{:});
    spk_new = (horzcat(cell_S{:}))';
    spk_idx = horzcat(cell_Sind{:});

    % Put X and Y coordinates into one matrix
    X_new = X;
    X_new(2,:) = Y;
    X_new = X_new';

    % Bin X and Y coordinates, and collect position counts (C) in each bin
    %[binned_pos,C] = hist3(X_new,[bin bin]);
    [binned_pos,C] = hist3(X_new,[bin(2) bin(1)]);

    % Return bin centers for X and Y coordinates so that the same centers can
    % be used when indexing spikes
    binned_pos = hist3(X_new,'Ctrs',C);

    % Divide position counts by 30 (Neuralynx position data sampling rate) to
    % get occupancy (seconds) per bin
    binned_pos = (binned_pos/30)';

    % Create matrix of X and Y coordinates for each spike timestamp
    for spikei = 1:length(spk_new)
        spk_ts = dsearchn(ts',spk_new(spikei,1));
        spk_x(spikei,1) = X_new(spk_ts,1);
        spk_x(spikei,2) = X_new(spk_ts,2);
        %G = ['finished assigning a positional value for spike ',num2str(spikei)];
        %disp(G)
    end

    % Bin spike position data based on same centers for position data
    binned_spike = hist3(spk_x,'Ctrs',C);

    % Divide number of spikes per bin by occupancy per bin to get firing rate
    % values
    rate_map = binned_spike' ./ binned_pos;

    % Get rid of spurious rate map data that occurred because of tracking
    % errors
    rate_map(1,1) = NaN;
    rate_map_raw = rate_map;

    % Convert NaNs in rate map to zeros for smoothing purposes
    rate_map(isnan(rate_map)) = 0;

    % Define Gaussian kernel based on given standard deviation value
    [X,Y] = meshgrid(round(-bin(1)/2):round(bin(1)/2), round(-bin(2)/2):round(bin(2)/2));
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

    rate_map_new = rate_map;
    for i = 1:size(rate_map_new,1);
        for k = 1:size(rate_map_new,2);
            if isnan(rate_map_raw(i,k))
                rate_map_new(i,k) = NaN;
            end
        end
    end

    % save variable
    filtered_map_sample = filtered_map;
    
    % find data points that were on the maze
    spk_var = [];
    spk_var_sample = filtered_map(~isnan(filtered_map));
    %spk_var = rate_map_new(~isnan(rate_map_new));

    % spatial specificity = the proportion of firing rate bins greater than 25% of the peak firing rate
    % check to make sure spikes are in fact binned - although I see they are
    % just double check
    peak_rate_sample = max(max(spk_var_sample));
    threshold_sample        = peak_rate_sample*.25;
    %above_thresh_sample     = find(filtered_map>threshold);

%% choice trials
clearvars -except sample_trials coverage_sample peak_rate_sample ...
        filtered_map_sample clusters TimeStamps ExtractedX ExtractedY ...
        ExtractedX_weighted ExtractedY_weighted spk datafolder Int cell bin sigma ...
        X_weighted Y_weighted trials above_thresh_sample spk_var_sample threshold_sample filtered_map_sample
    
choice_trials = 2:2:size(Int,1);
    for i = 1:length(choice_trials)
        cell_X{i} = ExtractedX(find(TimeStamps>Int(choice_trials(i),1) & TimeStamps<Int(choice_trials(i),8)));
        cell_Y{i} = ExtractedY(find(TimeStamps>Int(choice_trials(i),1) & TimeStamps<Int(choice_trials(i),8)));
        cell_T{i} = TimeStamps(find(TimeStamps>Int(choice_trials(i),1) & TimeStamps<Int(choice_trials(i),8)));
        cell_S{i} = spk(find(spk>Int(choice_trials(i),1) & spk<Int(choice_trials(i),8)));
        cell_Sind{i} = (find(spk>Int(choice_trials(i),1) & spk<Int(choice_trials(i),8)));
    end

    X = horzcat(cell_X{:});
    Y = horzcat(cell_Y{:});
    ts = horzcat(cell_T{:});
    spk_new = (horzcat(cell_S{:}))';
    spk_idx = horzcat(cell_Sind{:});
    
    % Put X and Y coordinates into one matrix
    X_new = X;
    X_new(2,:) = Y;
    X_new = X_new';

    % Bin X and Y coordinates, and collect position counts (C) in each bin
    %[binned_pos,C] = hist3(X_new,[bin bin]);
    [binned_pos,C] = hist3(X_new,[bin(2) bin(1)]);

    % Return bin centers for X and Y coordinates so that the same centers can
    % be used when indexing spikes
    binned_pos = hist3(X_new,'Ctrs',C);

    % Divide position counts by 30 (Neuralynx position data sampling rate) to
    % get occupancy (seconds) per bin
    binned_pos = (binned_pos/30)';

    % Create matrix of X and Y coordinates for each spike timestamp
    spk_x = [];
    for spikei = 1:length(spk_new)
        spk_ts = dsearchn(ts',spk_new(spikei,1));
        spk_x(spikei,1) = X_new(spk_ts,1);
        spk_x(spikei,2) = X_new(spk_ts,2);
        %G = ['finished assigning a positional value for spike ',num2str(spikei)];
        %disp(G)
    end

    % Bin spike position data based on same centers for position data
    binned_spike = hist3(spk_x,'Ctrs',C);

    % Divide number of spikes per bin by occupancy per bin to get firing rate
    % values
    rate_map = binned_spike' ./ binned_pos;

    % Get rid of spurious rate map data that occurred because of tracking
    % errors
    rate_map(1,1) = NaN;
    rate_map_raw = rate_map;

    % Convert NaNs in rate map to zeros for smoothing purposes
    rate_map(isnan(rate_map)) = 0;

    % Define Gaussian kernel based on given standard deviation value
    [X,Y] = meshgrid(round(-bin(1)/2):round(bin(1)/2), round(-bin(2)/2):round(bin(2)/2));
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

    rate_map_new = rate_map;
    for i = 1:size(rate_map_new,1);
        for k = 1:size(rate_map_new,2);
            if isnan(rate_map_raw(i,k))
                rate_map_new(i,k) = NaN;
            end
        end
    end

    % save data
    filtered_map_choice = filtered_map;
    
    % find data points that were on the maze
    spk_var = [];
    spk_var_choice = filtered_map(~isnan(filtered_map));
    %spk_var = rate_map_new(~isnan(rate_map_new));

    %% spatial specificity = the proportion of firing rate bins greater than 25% of the peak firing rate
    % check to make sure spikes are in fact binned - although I see they are
    % just double check
    peak_rate_choice    = max(max(spk_var_choice));
    threshold_choice    = peak_rate_choice*.25;
    %above_thresh_choice = find(filtered_map>threshold);
    
    % mean threshold
    %mean_threshold = mean([threshold_choice threshold_sample]);
    
    % go with the lower threshold
    if threshold_choice > threshold_sample
        threshold = threshold_sample;
    elseif threshold_sample > threshold_choice
        threshold = threshold_choice;
    end
    
    % above threshold
    above_thresh_choice = find(filtered_map_choice>threshold);
    above_thresh_sample = find(filtered_map_sample>threshold);
    
    % spatial specificity
    coverage_choice = (length(above_thresh_choice)/length(spk_var_choice));
    coverage_sample = (length(above_thresh_sample)/length(spk_var_sample));
    
    clearvars -except sample_trials coverage_sample peak_rate_sample ...
        filtered_map_sample choice_trials coverage_choice peak_rate_choice ...
        filtered_map_choice clusters TimeStamps ExtractedX ExtractedY ...
        ExtractedX_weighted ExtractedY_weighted spk datafolder Int cell sigma f ...
        threshold_choice threshold_sample threshold
    
end