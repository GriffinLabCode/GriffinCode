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
% written by Henry Hallock (some rate-map portions) and John Stout (spatial
% specificty portion, conversions, some rate-map portions)

 
function [spatial_coverage,peak_rate] = spatial_coverage_score(datafolder,Int,ExtractedX,ExtractedY,TimeStamps,maze_times,spk,clusters)   

    % index spikes based on timestamps and index x y values
    spk     = spk';

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

%% control for peak-rates influence on spatial-coverage
%{
for i = 1:size(Int,1)
    X = ExtractedX(find(TimeStamps>Int(i,1) & TimeStamps<Int(i,8)));
    Y = ExtractedY(find(TimeStamps>Int(i,1) & TimeStamps<Int(i,8)));
    ts = TimeStamps(find(TimeStamps>Int(i,1) & TimeStamps<Int(i,8)));
    spk_new = (spk(find(spk>Int(i,1) & spk<Int(i,8))))';
    spk_idx = (find(spk>Int(i,1) & spk<Int(i,8)));

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

    if isempty(spk_x)==0
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
        for ii = 1:size(filtered_map,1);
            for k = 1:size(filtered_map,2);
                if isnan(rate_map_raw(ii,k))
                    filtered_map(ii,k) = NaN;
                end
            end
        end

        [nr,nc] = size(filtered_map);

        rate_map_new = rate_map;
        for iii = 1:size(rate_map_new,1);
            for k = 1:size(rate_map_new,2);
                if isnan(rate_map_raw(iii,k))
                    rate_map_new(iii,k) = NaN;
                end
            end
        end

        % find data points that were on the maze
        spk_var = [];
        spk_var = filtered_map(~isnan(filtered_map));
        %spk_var = rate_map_new(~isnan(rate_map_new));
        
        % find the peak rate across all trials
        peak_rate(i) = max(spk_var);

        % clear stuff
        clearvars -except peak_rate clusters TimeStamps ExtractedX ExtractedY ...
            ExtractedX_weighted ExtractedY_weighted spk datafolder Int cell bin sigma ...
            X_weighted Y_weighted trials        
    else
        spk_var = NaN;
        peak_rate(i) = NaN;
        clearvars -except peak_rate clusters TimeStamps ExtractedX ExtractedY ...
            ExtractedX_weighted ExtractedY_weighted spk datafolder Int cell bin sigma ...
            X_weighted Y_weighted trials          
    end   
end  
peakrate_sample = peak_rate(1:2:length(peak_rate));
peakrate_choice = peak_rate(2:2:length(peak_rate));

peakrate_sample(isnan(peakrate_sample))=[];
peakrate_choice(isnan(peakrate_choice))=[];

meanpeak_sample = mean(peakrate_sample);
meanpeak_choice = mean(peakrate_choice);

% find averaged peak and threshold for spatial coverage
peak_rate(isnan(peak_rate))=[];
mean_peak = mean(peak_rate);   
threshold = mean_peak*.25;

clearvars -except mean_peak threshold clusters TimeStamps ExtractedX ExtractedY ...
    ExtractedX_weighted ExtractedY_weighted spk datafolder Int cell bin sigma ...
    X_weighted Y_weighted trials peakrate_sample meanpeak_sample meanpeak_choice   
 %}  
%% all trials
    for i = 1:length(trials)
        cell_X{i} = ExtractedX(find(TimeStamps>Int(trials(i),1) & TimeStamps<Int(trials(i),8)));
        cell_Y{i} = ExtractedY(find(TimeStamps>Int(trials(i),1) & TimeStamps<Int(trials(i),8)));
        cell_T{i} = TimeStamps(find(TimeStamps>Int(trials(i),1) & TimeStamps<Int(trials(i),8)));
        cell_S{i} = spk(find(spk>Int(trials(i),1) & spk<Int(trials(i),8)));
        cell_Sind{i} = (find(spk>Int(trials(i),1) & spk<Int(trials(i),8)));
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
 
    % find data points that were on the maze
    spk_var = [];
    spk_var = filtered_map(~isnan(filtered_map));
    %spk_var = rate_map_new(~isnan(rate_map_new));

    % spatial specificity = the proportion of firing rate bins greater than 25% of the peak firing rate
    % check to make sure spikes are in fact binned - although I see they are
    % just double check
    peak_rate        = max(max(spk_var));
    threshold        = peak_rate*.25;
    above_thresh     = find(filtered_map>threshold);
    % spatial specificity
    spatial_coverage = (length(above_thresh)/length(spk_var));

end