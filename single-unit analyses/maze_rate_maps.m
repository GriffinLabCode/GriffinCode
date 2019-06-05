%% Rate map script
% This script was written by Henry and modified by John

%close all
%clear

%% Define some variables
clearvars -except datafolder
    % set data folder
    %Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';

    % designate a folder for a session
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-11-18';   
    %datafolder = 'X:\01.Experiments\Completed Studies\CondDisc\0700\0700-04';
    datafolder = pwd;
    
    cell       = 1;
    
    % load video tracking and trial-tracking data
    cd('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
    load(strcat(datafolder,'\VT1.mat'));
    [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);

    % load int
    load(strcat(datafolder,'\Int_file.mat'));
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
    bin   = 200;
    sigma = 5;
    plot  = 0;

%% Grab X coordinates, Y coordinates, and spikes that occurred during maze traversals

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

% Put X and Y coordinates into one matrix
X_new(2,:) = Y_new;
X_new = X_new';

% Bin X and Y coordinates, and collect position counts (C) in each bin
[binned_pos,C] = hist3(X_new,[bin bin]);

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
tic;
% Create matrix of X and Y coordinates for each spike timestamp
for spikei = 1:length(spk_new)
    spk_ts = dsearchn(ts_new',spk_new(spikei,1));
    spk_x(spikei,1) = X_new(spk_ts,1);
    spk_x(spikei,2) = X_new(spk_ts,2);
    G = ['finished assigning a positional value for spike ',num2str(spikei)];
    disp(G)
end
disp('dsearchn')
toc;

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
hFig = figure();
pcolor([filtered_map nan(nr,1); nan(1,nc+1)]);
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
end


