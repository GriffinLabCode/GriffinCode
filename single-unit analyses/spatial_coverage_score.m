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
% written by Henry Hallock (rate-map portion) and John Stout (spatial
% specificty portion and subsampling)

 
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
    
    % define variables
    bin = [max(ExtractedX_weighted) max(ExtractedY_weighted)];
    sigma = 2; % a sigma of 2 corresponds to 8cm smoothing
    %sigma = bin/2; % 4cm sigma
    plot  = 0;

    % get number of trials
    ntrials = size(Int,1);

    % gives TS of:
    start = Int(1,1);
    finish = Int(ntrials,8);

    % gives cell # of TS-start/finish in TS variable
    % start TS and start cell # should be compatible
    start_ind = dsearchn(TimeStamps',start);
    finish_ind = dsearchn(TimeStamps',finish);

    % gives x/y coordinates contained within start/finish ind
    X_new = ExtractedY(1,start_ind:finish_ind);
    Y_new = ExtractedX(1,start_ind:finish_ind);

    % gives TS contained within start/finish ind
    % should be ame length as x/y data calculated above
    ts_new = TimeStamps(1,start_ind:finish_ind);

    % find cells that contain spikes in spk variable
    % extract spike TS
    spk_ind = find(spk>start & spk<finish);
    spk_new = spk(spk_ind);

    % subsample out delays to match the number of ITIs
    try
        idx_bad = find(Int(:,9)==1);
        num_bad = length(idx_bad);
        sample_trials = 1:2:size(Int,1);
        delay_subbed = randsample(sample_trials,num_bad);
        Int(delay_subbed,9)=1;

        % remove spks during unwinding times
        for triali = 1:length(idx_bad)
            if idx_bad(triali) == size(Int,1); 
                continue
            else
                spks_unwind{triali} = find(spk_new>=Int(idx_bad(triali),8) ...
                    & spk_new<=Int(idx_bad(triali)+1,1));
            end
        end
        spks_elim = horzcat(spks_unwind{:});    
        spk_new(spks_elim)=[];
    catch
        if isempty(idx_bad) == 1
           disp('no unwinding trials')
        else
           disp('error - may not have a corrected Int file')
        end
    end
    
    % Put X and Y coordinates into one matrix
    X_new(2,:) = Y_new;
    X_new = X_new';

    % Bin X and Y coordinates, and collect position counts (C) in each bin
    [binned_pos,C] = hist3(X_new,[bin(2) bin(1)]);

    % Return bin centers for X and Y coordinates so that the same centers can
    % be used when indexing spikes
    binned_pos = hist3(X_new,'Ctrs',C);

    % Divide position counts by 30 (Neuralynx position data sampling rate) to
    % get occupancy (seconds) per bin
    binned_pos = binned_pos/30;

    % invert
    spk_new = spk_new';

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
    rate_map_raw  = rate_map;

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

    % find data points that were on the maze
    spk_var = [];
    spk_var = filtered_map(~isnan(filtered_map));

    %% spatial specificity = the proportion of firing rate bins greater than 25% of the peak firing rate
    % check to make sure spikes are in fact binned - although I see they are
    % just double check
    peak_rate    = max(max(spk_var));
    threshold    = peak_rate*.25;
    above_thresh = find(filtered_map>threshold);
    
    % spatial specificity
    spatial_coverage = (length(above_thresh)/length(spk_var));

end