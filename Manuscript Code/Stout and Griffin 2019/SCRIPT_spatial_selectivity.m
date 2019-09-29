%% spatial specificity = the proportion of firing rate bins greater than 25% of the peak firing rate

% Define some variables
clear
    % set data folder
    %Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';
%datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Thanos 12-11-18';
datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Meusli 6-14-18';
cd(datafolder);
datafolder = pwd;
cd(datafolder);

cell       = 2;
%datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Capn_Session 12';
%datafolder = 'X:\01.Experiments\Completed Studies\DualTask_CDAlternation_HippocampusRecording\0902\0902-03';
% designate a folder for a session
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-11-18';   
    %datafolder = 'X:\01.Experiments\Completed Studies\CondDisc\0700\0700-04';
    %datafolder = pwd;
    

    
    % load video tracking and trial-tracking data
    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
    load(strcat(datafolder,'\VT1.mat'));
    [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);
    
    % convert the position data to cm
    ExtractedX = round(ExtractedX./2.09);
    ExtractedY = round(ExtractedY./2.04);

    % load in5
    load(strcat(datafolder,'\Int_noBowl.mat'));
    TimeStamps = TimeStamps_VT;

    % create a variable containing all clusters
    cd(datafolder);
    clusters = dir('TT*.txt');

    % use this to index spk locations
    maze_times = find(TimeStamps>Int(1,1)&TimeStamps<Int(end,end));
    spk        = textread(clusters(cell).name);

    % index spikes based on timestamps and index x y values
    spk     = spk';

    % define variables
    % ruler was placed on the surface of maze to take measurements. The
    % length of room was 108in while the height was 91 inch. This comes out
    % to approximately 274cm and 231 cm respectively. Taking the average
    % and rounding should give me how many recording cm I had. Then I
    % divided this by 2 so that each pixel would be worth 2 cm. This value
    % was then rounded
    % define variables
    %bin   = round(round((274+231)/2)/2);
    
    % make extractedX and Y equal to half the value so that when binning,
    % each bin accounts for 2cm instead of 1cm
    ExtractedX_weighted = round(ExtractedX./2);
    ExtractedY_weighted = round(ExtractedY./2);
    
    % use the cm converted variables to determine the max X and Y data
    % points. Using the given points then normalizes the matrix to cm. Next
    % to make each bin account for 2cm each, divide the bin values by 2
    %bin = [round((round(max(ExtractedX)))/2) round((round(max(ExtractedY)))/2)];
    bin = [max(ExtractedX_weighted) max(ExtractedY_weighted)];
    %bin = [max(ExtractedX) max(ExtractedY)];
    %bin   = 200;
    %sigma = bin/2;
    %sigma = bin*2; % 4cm sigma
    sigma = 2; % sigma 2 corresponds to 8cm, sigma 4 corresponds to sd of 16cm
    plot  = 0;

% Grab X coordinates, Y coordinates, and spikes that occurred during maze traversals
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
%[binned_pos,C] = hist3(X_new,[bin bin]);
[binned_pos,C] = hist3(X_new,[bin(2) bin(1)]);

% Return bin centers for X and Y coordinates so that the same centers can
% be used when indexing spikes
binned_pos = hist3(X_new,'Ctrs',C);

% Divide position counts by 30 (Neuralynx position data sampling rate) to
% get occupancy (seconds) per bin
binned_pos = binned_pos/30;

spk_new = spk_new';

% for each data point in spk_new, calculate the difference - find the min
% value
%{
tic;
for i = 1:length(spk_new);
    var = [];
    for ii = 1:length(ts_new);
        var(ii) = abs(spk_new(i)-ts_new(ii));
    end
    [~,closest_pnt(i)] = (min(var));
end
disp('your method')
toc;
%}
%tic;
% Create matrix of X and Y coordinates for each spike timestamp
for spikei = 1:length(spk_new)
    spk_ts = dsearchn(ts_new',spk_new(spikei,1));
    spk_x(spikei,1) = X_new(spk_ts,1);
    spk_x(spikei,2) = X_new(spk_ts,2);
    %G = ['finished assigning a positional value for spike ',num2str(spikei)];
    %disp(G)
end
%disp('dsearchn')
%toc;

% Bin spike position data based on same centers for position data
binned_spike = hist3(spk_x,'Ctrs',C);

% remove binned_spikes that occured beyond x of 115 and y of

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

hFig = figure('color',[1 1 1]);
    %subplot 121
    %pcolor([filtered_map nan(nr,1); nan(1,nc+1)]);
    pcolor(filtered_map);
    shading flat;
    %set(gca, 'ydir', 'reverse');
    colormap(jet)
    box off
    set(gca,'TickDir','out')
    xlabel('X-Coordinate')
    ylabel('Y-Coordinate')
    colorbar
    color = get(hFig,'Color');
    set(gca,'XColor',color,'YColor',color,'TickDir','out')

% find data points that were on the maze
spk_var = [];
spk_var = filtered_map(~isnan(filtered_map));
%spk_var = rate_map_new(~isnan(rate_map_new));

%% spatial specificity = the proportion of firing rate bins greater than 25% of the peak firing rate
% check to make sure spikes are in fact binned - although I see they are
% just double check
peak_rate    = max(max(spk_var));
threshold    = peak_rate*.25;
above_thresh = find(filtered_map>threshold);
% spatial specificity
spatial_specificity = (length(above_thresh)/length(spk_var));

subplot 122
bar(spatial_specificity)
ylabel('spatial specificity')
ylim([0 1])
xlabel('cell number')
%title('1 - (spatial specificity)')
txt = num2str(peak_rate);
X2 = ['peak rate = ',txt];
text(.75,spatial_specificity+.05, X2)
txt2 = num2str(spatial_specificity);
Y2 = ['spatial coverage = ',txt2];
text(.75,spatial_specificity+1.5, Y2)
box off

% second fig
hFig = figure('color',[1 1 1]);
    %subplot 121
    %pcolor([filtered_map nan(nr,1); nan(1,nc+1)]);
    pcolor(filtered_map);
    shading flat;
    %set(gca, 'ydir', 'reverse');
    colormap(jet)
    ylimit = ylim;
    ylim([ylimit(1)-21 ylimit(2)+21]);
    xlimit = xlim;
    xlim([xlimit(1)-21 xlimit(2)+21]);  
    box off
    set(gca,'TickDir','out')
    xlabel('X-Coordinate')
    ylabel('Y-Coordinate')
    colorbar
    color = get(hFig,'Color');
    set(gca,'XColor',color,'YColor',color,'TickDir','out')
    hold on;
    txt2 = num2str(spatial_specificity);
    Y3 = ['spatial coverage = ',txt2];
    text(ylimit(1)-21,ylimit(1)-21, Y3)
    hold on
    C = [];
    C = strsplit(datafolder,'\');
    X3 = [C{end},' ', num2str(clusters(cell).name)];
    text(median(xlim)-41,ylimit(2)+21,X3);
    
    cd('X:\07. Manuscripts\In preparation\Stout - JNeuro\Data\Single unit preferences')