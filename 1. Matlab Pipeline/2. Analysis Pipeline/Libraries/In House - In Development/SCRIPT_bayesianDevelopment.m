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
measurements.retArm   = 130;

% get linear skeleton
[data] = get_linearSkeleton(datafolder,int_name,vt_name,missing_data,measurements);
idealTraj = data.idealTraj;

% get linear position
[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data);

%% load in int and position data

% focus on one trajectory for now
linPosBins = linearPosition.left;

% get int and vt data
load(int_name)
[ExtractedX, ExtractedY, TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% separate left/right trials
Int_left  = Int(Int(:,3)==1,:);
Int_right = Int(Int(:,3)==0,:);

% get data
for triali = 1:length(linPosBins)
    X{triali}  = ExtractedX(TimeStamps >= Int_left(triali,1) & TimeStamps <= Int_left(triali,8));
    Y{triali}  = ExtractedY(TimeStamps >= Int_left(triali,1) & TimeStamps <= Int_left(triali,8));
    TS{triali} = TimeStamps(TimeStamps >= Int_left(triali,1) & TimeStamps <= Int_left(triali,8));
end

%% get spike data
cd(datafolder);
clusters   = dir('TT*.txt');
ci=1;
spikeTimes = textread(clusters(ci).name);
cluster    = clusters(ci).name(1:end-4);

% initialize some variables
binSpks = []; binTime = []; numSpks =[]; sumTime = []; FR = []; FRmat = [];
normFR = []; smoothFR = [];

% calculate instantaneous firing rate
for triali = 1:length(linPosBins)

    spks = [];
    spks = spikeTimes(spikeTimes >= TS{triali}(1) & spikeTimes <= TS{triali}(end));

    % shape of timestamp data
    spkForm = [];
    spkForm = NaN(size(TS{triali}));

    % find nearest points
    spkSearch = [];
    spkSearch = dsearchn(TS{triali}',spks);

    % replace and create boolean spk data
    spkForm(spkSearch) = 1;
    spkForm(isnan(spkForm)==1)=0;

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

    % firing rate (spks/sec)
    FR{triali} = numSpks{triali}./sumTime{triali};
    
end

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
