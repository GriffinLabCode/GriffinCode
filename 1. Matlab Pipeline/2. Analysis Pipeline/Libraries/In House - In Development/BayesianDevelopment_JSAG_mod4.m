% script for linearizing position getting neuronal data
clear; clc

% inputs
datafolder   = 'X:\01.Experiments\RERh Inactivation Recording\Usher\Muscimol\Baseline';
int_name     = 'Int_VTE_JS.mat'; % 'Int2_JS'; % 'Int_file.mat';
vt_name      = 'VT1.mat';
missing_data = 'interp';
vt_srate     = 30; % 30 samples/sec
clear measurements
measurements.stem     = 112; % in cm was 137
measurements.goalArm  = 56; % was 50
%measurements.goalZone = 29; % was 37
%measurements.retArm   = 130;

% get linear skeleton
Startup_linearSkeleton % add paths
[data] = get_linearSkeleton(datafolder,int_name,vt_name,missing_data,measurements);
idealTraj = data.idealTraj;
rmPaths_linearSkeleton % remove paths

%% get linear position
load(int_name);

mazePos = [1 2]; % was [1 2]

% load position data
[ExtractedX, ExtractedY, TimeStamps_VT] = getVTdata(datafolder,missing_data,vt_name);

stemOrientation = 'x';

% define start position for stem
numTrials = size(Int,1);
if contains(stemOrientation,'x') | contains(stemOrientation,'X')
    for triali = 1:numTrials
        startPos(triali) = ExtractedX(find(Int(triali,1) == TimeStamps_VT));
    end
elseif contains(stemOrientation,'y') | contains(stemOrientation,'Y')
    for triali = 1:numTrials
        startPos(triali) = ExtractedY(find(Int(triali,1) == TimeStamps_VT));
    end   
end
startStemPos = min(startPos); % in pixels

%[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data,mazePos);
clear linearPosition position
[linearPosition,position] = get_linearPosition(datafolder,idealTraj,Int,ExtractedX,ExtractedY,TimeStamps_VT,mazePos,stemOrientation,startStemPos);

%% load in int and position data

% focus on one trajectory for now
linearPosition_var = linearPosition.left;

% -- plot to show what a 'linear skeleton' is -- %
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

% define int var for this script
Int_var = Int_left;

%% get spike data
cd(datafolder);

% load in our clusters
clusters = dir('TT*.txt');

% define a variable for gaussian smoothing. This tells the functions how
% many cm (or time points depending on the function) to smooth over
resolution_time = 1; % time of smoothing
resolution_pos  = 6; % cm smoothing

% redefine numTrials
numTrials = length(linearPosition_var);

% get linearized fr for all clusters
smoothFR = []; instFR = []; numSpks = []; sumTime = []; instSpk = []; instTime = [];
for ci = 1:length(clusters)
    
    % spike time stamps
    spikeTimes = textread(clusters(ci).name);
    
    % cell array of spiking data
    spikeCell{ci} = spikeTimes;

    for triali = 1:numTrials
        
        % get spiketimes
        spks = [];
        spks = spikeTimes(spikeTimes >= position.TS_left{triali}(1) & spikeTimes <= position.TS_left{triali}(end));       
        
        % how much time in consideration?
        totalTime = (position.TS_left{triali}(end)-position.TS_left{triali}(1))/1e6;
        
        % get neuronal activity per bin, across time (not avged within bin)
        [smoothFR_time{ci}{triali},~,instSpk{ci}{triali},...
            ~,instSpk_time{ci}{triali}] = ...
            inst_neuronal_activity(spks,position.TS_left{triali},vt_srate,totalTime,resolution_time);        

        % get neuronal activity linearized (avg activity per bin)
        [smoothFR_pos{ci}{triali},~,numSpks_pos{ci}{triali},sumTime_pos{ci}{triali},...
            ~,instTime{triali}] = linearizedFR(spks,position.TS_left{triali},linearPosition.left{triali},vt_srate,resolution_pos);
                
        % replace nans with zero
        smoothFR_time{ci}{triali}(isnan(smoothFR_time{ci}{triali})==1)=0;
        instSpk{ci}{triali}(isnan(instSpk{ci}{triali})==1)=0;
        smoothFR_pos{ci}{triali}(isnan(smoothFR_pos{ci}{triali})==1)=0;
        numSpks_pos{ci}{triali}(isnan(numSpks_pos{ci}{triali})==1)=0;        
    end
end

%% create rate maps
% since the bayesian decoder should be trained on a trial-by-trial basis,
% we'll make a linearized rate map for each trial
ratesCat_time = vertcat(smoothFR_time{:});
ratesCat_pos  = vertcat(smoothFR_pos{:});
spksCat_time  = vertcat(instSpk{:});

% get number of neurons
numNeurons = length(clusters);

for i = 1:numTrials
    rate_maps_time{i} = vertcat(ratesCat_time{1:numNeurons,i});
    rate_maps_pos{i}  = vertcat(ratesCat_pos{1:numNeurons,i});
    spks_time{i}      = vertcat(spksCat_time{1:numNeurons,i});
    ts_sec{i}         = position.TS_left{i}/1e6;
end

%% figure to make sense of some stuff
% plot to show difference between rate_maps_time and rate_maps_pos. Note
% that we're using the a single trial '{trial}' and the first neuron across linear
% bins '(1,:)'
trial = 2; % define which trial to look at
figure('color','w'); 
subplot 311;
    plot(rate_maps_pos{trial}(1,:),'r','LineWidth',2); axis tight; box off;
    ylabel('Smoothed FR'); xlabel('Linear Position (cm sized bins)');
    title('Firing Rates grouped by position')
subplot 312;
    timingVar = linspace(0,size(rate_maps_time{trial},2)/vt_srate,size(rate_maps_time{trial},2));
    plot(timingVar*1000,rate_maps_time{trial}(1,:),'r','LineWidth',2); axis tight; box off;
    ylabel('Smoothed FR'); xlabel('Time (ms)');
    title('Firing Rates grouped by time')
subplot 313;
    plot(timingVar*1000,linearPosition.left{trial},'k','LineWidth',2);
    ylabel('Linear Position (cm)'); xlabel('Time (ms)'); axis tight; box off;
    title('Time informs us on linear position, and linear position informs us on time')

%% one way to view "rate maps"

% -- lets define our expected FR per bin - this is where we apply the poisson cdf -- %

% get avg fr - this is for position
rateMap_3Dpos  = cat(3,rate_maps_pos{:});
rateMap_avgPos = mean(rateMap_3Dpos,3); % avg in the third dimension (trials)
rateMap_norm   = (normalize(rateMap_avgPos','range'))'; % normalize across linear bins - purely for visualizing

% make figure
figure('color','w'); imagesc(rateMap_norm); ax = gca; ax.YTick = [1:numNeurons]; 
xlabel(['Linearized Pos (cm): Int columns ',num2str(mazePos(1)),' through ',num2str(mazePos(2))]); 
ylabel('Neuron Number'); shading interp; c = colorbar;
ylabel(c,'Normalized Smoothed Firing Rate');

figure('color','w');
jetOn = 1; plot_fig = 1;
[x_sort,idxsort] = SortedRateMap(rateMap_norm,rateMap_norm,plot_fig,jetOn);

%% getting a ton of zeros - somethings not right
% poisspdf(x,lambda) tells you prob of observing each value in x, given
% lambda. So we should be able to do poisspdf(rate_map,spikes) at each time
% point, to find the probability of observing each value in rate_map, given
% spikes
% 
% prob(x|lambda) = ((lambda^x)*e^-lambda)/x!
% prob(spikes|position), where spikes are x and lamda is position. Except
% in our case, its the rate map position converted to spikes. This should
% be so we're drawing from a similar distribution (ie not trying to draw
% spikes from rates, but instead spikes from spikes)

% define tau and get the number of samples that is equivalent to it
tau = 0.5; %s
numSamplesInTau = tau*vt_srate; %*(1/1000); % Nms * 30 samples/sec * (1sec/1000ms) = M samples

numTrials = length(rate_maps_pos);
% use poisspdf - if we set lambda to spikes and x to position, we can use
posterior = cell([1 numTrials]);
for triali = 1:numTrials

    % -- get training data -- %
    
    spikes_temp = spks_time{triali};
    numElements = length(spikes_temp); %272
    loopingIdx  = 1:numSamplesInTau:numElements;
    
    for neuri=1:numNeurons % loop across each neuron
        for loopi = 1:numel(loopingIdx)-1 % loop across each tau window

            % this variable is x in the general equation
            spikes{triali}(neuri,loopi) = sum(spikes_temp(neuri,loopingIdx(loopi):loopingIdx(loopi+1)-1));
            
            % get linear position grouped by tau. This requires averageing
            % and rounding for an integer
            actual_pos{triali}(loopi) = round(mean(linearPosition.left{triali}(loopingIdx(loopi):loopingIdx(loopi+1)-1)));
            
        end
    end    
    
    % the rest of the trials were used to estimate the spatial maps
    rate_maps_train = [];
    rate_maps_train = rate_maps_pos; % temporary
    rate_maps_train(triali)=[]; % remove one trial (this changes per value in for loop)
    
    % training data was assumed to be the average across the rate maps
    training_data = mean(cat(3, rate_maps_train{:}),3);

    % -- testing data -- %
    
    % testing data is spikes for the trial that we removed in the training
    % data. Recall that spikes is the number of spikes of the ith cell in a
    % given time window
    testing_data = spikes{triali};
    
    % -- now get the posterior probability using the Shin equation -- %
    
    % posterior probability matrix should be a time x position matrix
    timeLength = size(testing_data,2);
    posterior_per_cell = cell([1 numNeurons]); % this gets redefined each loop (memory-less)
    for neuri = 1:numNeurons
        for timei = 1:timeLength
            % lambda should be testing data spikes
            lambda = spikes{triali}(:,timei);
            posterior_per_cell{neuri}(timei,:) = poisspdf(round(training_data(neuri,:)),lambda(neuri));
        end
    end
    
    % multiple across neurons and incorporate the 
    posterior{triali} = prod(cat(3, posterior_per_cell{:}),3);
    
    % normalized by C
    posterior{triali} = (normalize(posterior{triali}','range'))';
    
    % per each time point, find the maximum probability
    [max_prob{triali}, decoded_pos{triali}] = max(posterior{triali}');
    
    % define decoding error. I made this up using shins stuff. They used
    % the linear distance between actual position and decoded position.
    % What we have here is decoded position - actual position normalized by
    % the sum to force the values between -1 to 1. Then to get one value,
    % it is summated across times
    %decoding_error(triali) = norm(decoded_pos{triali} - actual_pos{triali});
    decoding_error(triali) = mean(abs(decoded_pos{triali} - actual_pos{triali}));
    
end

%% plot - incorporate updates to this
trial = 7;
figure('color','w'); 
imagesc(posterior{trial}');
colormap hot;
colorbar();
set(gca,'YDir','normal');
hold on;
plot(actual_pos{trial}, 'b','LineWidth', 2,'LineStyle','--');
xlabel('time'); ylabel('position');
plot(decoded_pos{trial}, 'g', 'LineWidth',0.1);
