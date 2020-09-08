% script for linearizing position getting neuronal data
clear; clc

% inputs
datafolder   = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-11-18'; 
int_name     = 'Int_file.mat';
vt_name      = 'VT1.mat';
missing_data = 'exclude';
measurements.stem     = 137; % in cm
measurements.goalArm  = 50;
measurements.goalZone = 37;
%measurements.retArm   = 130;

% get linear skeleton
Startup_linearSkeleton % add paths
[data] = get_linearSkeleton(datafolder,int_name,vt_name,missing_data,measurements);
idealTraj = data.idealTraj;
rmPaths_linearSkeleton % remove paths

% get linear position
mazePos = [1 7];
[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data,mazePos);

% load in int and position data

% focus on one trajectory for now
linPosBins = linearPosition.left;

% get int and vt data
load(int_name)

% plot to show what a 'linear skeleton' is
figure('color','w');
plot(data.pos(1,:),data.pos(2,:),'Color',[.8 .8 .8]);
hold on;
p1 = plot(idealTraj.idealL(1,:),idealTraj.idealL(2,:),'m','LineWidth',0.2);
p1.Marker = 'o';
p1.LineStyle = 'none';
p2 = plot(idealTraj.idealR(1,:),idealTraj.idealR(2,:),'b','LineWidth',0.2);
p2.Marker = 'o';
p2.LineStyle = 'none';

% separate left/right trials
Int_left  = Int(Int(:,3)==1,:);
Int_right = Int(Int(:,3)==0,:);

% load data
[ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% get data
for triali = 1:length(linPosBins)
    X{triali}  = ExtractedX(TimeStamps >= Int_left(triali,1) & TimeStamps <= Int_left(triali,8));
    Y{triali}  = ExtractedY(TimeStamps >= Int_left(triali,1) & TimeStamps <= Int_left(triali,8));
    TS{triali} = TimeStamps(TimeStamps >= Int_left(triali,1) & TimeStamps <= Int_left(triali,8));
end
%%
%get spike data
cd(datafolder);

% load in our clusters
clusters = dir('TT*.txt');

% a way to define which cluster to look at
ci = 1;

% spike time stamps
spikeTimes = textread(clusters(ci).name);

% isolate the name of the cluster - unnecessary line
cluster = clusters(ci).name(1:end-4);

% initialize some variables
binSpks = []; binTime = []; numSpks =[]; sumTime = []; FR = []; FRmat = [];
normFR = []; smoothFR = [];

% calculate instantaneous firing rate
for triali = 1:length(linPosBins)

    spks = [];
    spks = spikeTimes(spikeTimes >= TS{triali}(1) & spikeTimes <= TS{triali}(end));

    % shape of timestamp data
    spkForm = [];
    spkForm = zeros(size(TS{triali}));

    % find nearest points
    spkSearch = [];
    spkSearch = dsearchn(TS{triali}',spks);

    % replace and create boolean spk data - but what if the spike occured
    % more than one time, per timestamp - create rate map
    for i = 1:length(spkSearch)
        %spkForm();
    end
    
    [uniqueElements, ~, k] = unique(spkSearch);
    indexToDupes = find(not(ismember(1:numel(spkSearch),k)))
     
    spkForm(spkSearch) = 1;
    %spkForm(isnan(spkForm)==1)=0;

    % make time vector
    timeForm = [];
    timeForm = repmat(1/30,size(TS{triali})); % seconds sampling rate

    % 30 samples per sec means i can divide each indiivudal point by 30.
    %clear binSpks binTime
    for i = 1:max(linPosBins{triali}) % loop across the number of bins
        binSpks{triali}{i} = spkForm(linPosBins{triali} == i);
        binTime{triali}{i} = timeForm(linPosBins{triali} == i);
    end

    % calculate firing rate per bin
    numSpks{triali} = cellfun(@sum,binSpks{triali});
    sumTime{triali} = cellfun(@sum,binTime{triali});

    % firing rate (spks/sec) - this is instantaneous firing rate
    FR{triali} = numSpks{triali}./sumTime{triali};
    
    % remove nans - why do we get them?
    %FR{triali} 
end

% sanity check
cellSizes = cellfun(@length,numSpks);
check1 = unique(cellSizes);

if numel(check1) > 1
    disp('Error with number of bins')
end

%{
%Poissian prob of spike locations
 - we need to pick a time interval (shin uses 500ms)
formula: ((l^k)*(e^-k))/k!
k = # of spikes at location in test data
l(lambda) = for each location, avg firing rate * time interval

example: cell a, @ location 5cm, has avg firing rate of 5spikes/sec
    in data to be decoded, a fires 12 spikes @ location 5cm over 2 secs
    
    l = 5spk/sec * 2 sec = 10spk
    k = 12spk

    = ((10spk)^12spk)(e^-(10spk))/(12spk!)
    = probability of 12 spikes = 0.0948

%}

%find avg firing rate across trials for each position

%%

% Ignore me (Allison is learning matlab)
%{ 
fakeFR = {{1 2 3},{4 5 6},{7 8 9},{10 11 12}}; %4 trials, each trial has 3 posns

fakeFRavg = [];
for posni = 1:3 % 1:length(linPosBins) for 1-18
    fakeFR_pos_sum = 0;
   for triali = 1:4
     fakeFR_pos_sum = fakeFR_pos_sum + (fakeFR{1,triali}{1,posni});
     fakeFRavg{1,posni}= fakeFR_pos_sum/4;
     %disp(fakeFR{1,triali}{1,posni})
     %disp(fakeFR{1,triali}{1,posni});
   end
end
%} 

FRavg = [];
for posni = 1:300 %change to 1:length(FR)
    FR_pos_sum = 0;
   for triali = 1:18 %change to 1:length(linPosBins)
     FR_pos_sum = FR_pos_sum + (FR{1,triali}{1,posni});
     FRavg{1,posni}= FR_pos_sum/18; % /(1:length(linPosBins));
   end
end


%Poisson distribution (l^k)*(e^-k))/k!

%%
%X is the set of all linear positions on the track for different trajectory types
X_lin = linearPosition.left{1};

%500ms window - we want to bin the data into 500ms windows (10ms for swr
%events - future thing).
time_window = (Int_left(1,5) + (0.5*1e6));








%numLocations = numel(spikes);
%prob_spks_given_location = numSpks{1}./numLocations;

% important for later
%{
% concatenate and smooth data
FRmat = vertcat(FR{:});
FRmat(find(isnan(FRmat)==1))=0;
% smooth
VidSrate = 30;
gauss_width = 60; 
gauss_timeWidth = gauss_width*(1/VidSrate); % this is in seconds
n = -(gauss_width-1)/2:(gauss_width-1)/2;
alpha       = 4; % std = (N)/(alpha*2) -> https://www.mathworks.com/help/signal/ref/gausswin.html
w           = gausswin(gauss_width,alpha);
stdev = (gauss_width-1)/(2*alpha);
y = exp(-1/2*(n/stdev).^2);

% convolve data with gaussian - remove a certain path to avoid mixing up
% functions
clear smoothFR normFR
for i = 1:length(FR)
    % smooth data
    smoothFR(i,:) = conv(FRmat(i,:),w,'same');
    % normalize firing
    normFR(i,:) = normalize(smoothFR(i,:),'range');
end

% store data
FRdata.normFR{nn-2}{ci}       = normFR;
FRdata.smoothFR{nn-2}{ci}     = smoothFR;
FRdata.numSpikes{nn-2}{ci}    = numSpks;
FRdata.FR{nn-2}{ci}           = FRmat;
%}