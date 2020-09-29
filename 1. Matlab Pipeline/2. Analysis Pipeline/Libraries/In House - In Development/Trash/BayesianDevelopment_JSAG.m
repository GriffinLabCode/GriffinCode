% script for linearizing position getting neuronal data
clear; clc

% inputs
datafolder   = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-11-18'; 
int_name     = 'Int_file.mat';
vt_name      = 'VT1.mat';
missing_data = 'exclude';
vt_srate     = 30; % 30 samples/sec
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
mazePos = [1 2]; % was [1 2]
[linearPosition,position] = get_linearPosition(datafolder,idealTraj,int_name,vt_name,missing_data,mazePos);

%% load in int and position data

% load position data
[ExtractedX, ExtractedY, TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% focus on one trajectory for now
linearPosition_var = linearPosition.left;

% get int and vt data
load(int_name)

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

% get data
numTrials = length(linearPosition_var);
for triali = 1:numTrials
    X{triali}  = ExtractedX(TimeStamps >= Int_var(triali,mazePos(1)) & TimeStamps <= Int_var(triali,mazePos(2)));
    Y{triali}  = ExtractedY(TimeStamps >= Int_var(triali,mazePos(1)) & TimeStamps <= Int_var(triali,mazePos(2)));
    TS{triali} = TimeStamps(TimeStamps >= Int_var(triali,mazePos(1)) & TimeStamps <= Int_var(triali,mazePos(2)));
end

%% get spike data
cd(datafolder);

% load in our clusters
clusters = dir('TT*.txt');

% define a variable for gaussian smoothing. This tells the functions how
% many cm (or time points depending on the function) to smooth over
resolution_time = 1; % time of smoothing
resolution_pos  = 6; % cm smoothing

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
        spks = spikeTimes(spikeTimes >= Int_var(triali,mazePos(1)) & spikeTimes <= Int_var(triali,mazePos(2)));       
        
        % how much time in consideration?
        totalTime = (TS{triali}(end)-TS{triali}(1))/1e6;
        
        % get neuronal activity per bin, across time (not avged within bin)
        [smoothFR_time{ci}{triali},~,instSpk{ci}{triali},...
            ~,instSpk_time{ci}{triali}] = ...
            inst_neuronal_activity(spks,TS{triali},vt_srate,totalTime,resolution_time);        

        % get neuronal activity linearized (avg activity per bin)
        [smoothFR_pos{ci}{triali},~,numSpks_pos{ci}{triali},sumTime_pos{ci}{triali},...
            ~,instTime{triali}] = linearizedFR(spks,TS{triali},linearPosition.left{triali},vt_srate,resolution_pos);
                
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
    ts_sec{i}         = TS{i}/1e6;
end

%% figure to make sense of some stuff
% plot to show difference between rate_maps_time and rate_maps_pos. Note
% that we're using the a single trial '{trial}' and the first neuron across linear
% bins '(1,:)'
trial = 1; % define which trial to look at
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

%% JS - 9-24-2020 consolidating and updating
% prob(x|lambda) = ((lambda^x)*e^-lambda)/x!
% prob(spikes|position), where spikes are x and lamda is position. Except
% in our case, its the rate map position converted to spikes. This should
% be so we're drawing from a similar distribution (ie not trying to draw
% spikes from rates, but instead spikes from spikes)

% define tau and get the number of samples that is equivalent to it
tau = 0.5; %s
numSamplesInTau = tau*vt_srate; %*(1/1000); % Nms * 30 samples/sec * (1sec/1000ms) = M samples

% leave 1 out method per trial
for triali = 1:numTrials

    % group neuronal activity based on tau - get data every 15 samples. Now
    % we're interested in time, so we will use instSpk variable, which is
    % spikes across time (see 2nd figure in script)
    spikes_temp = spks_time{triali};
    numElements = length(spikes_temp); %272
    loopingIdx  = 1:numSamplesInTau:numElements;
    for i=1:numNeurons
        for ii = 1:numel(loopingIdx)-1 %1:18
            % need to sum the spikes within the tau window. Note that you have to
            % do this complicated line below because tau may not evenly fit into
            % the length of the data. For example 272 (number
            % of example data points)/ 15 (tau in samples) = 18.13. We need an
            % integer in order to group the data, not a floating point number.

            % this variable is x in the general equation
            spikes(i,ii) = sum(spikes_temp(i,loopingIdx(ii):loopingIdx(ii+1)-1));
        end
    end

    % due to leave 1 out method, remove one rate_maps_pos trial
    rate_maps_train = [];
    rate_maps_train = rate_maps_pos; % temporary
    rate_maps_train(triali)=[];
    
    % now consider lambda. On average, this is what the spiking data looks
    % like. poissonpdf(x,lambda) will tell you the probability of observing x
    % given the lambda rate - this may have to be estimated in a leave-1-out
    % fashion
    lambda = tau*mean(cat(3, rate_maps_pos{:}),3);

    % whats the probability of observing spikes, given position n? This is how
    % you create the matrix!!
    numLinearBins = size(lambda,2);
    for ci = 1:numNeurons % per each neuron
        for n = 1:numLinearBins % per each bin, find the probability of observing spikes
            prob_spikesGivenPos{ci}(:,n) = poisspdf(spikes(ci,:),lambda(ci,n));
        end
    end

    % multiply across neurons
    prob_spikesGivenPos_avg = mean(cat(3, prob_spikesGivenPos{:}),3);

    
    
end

%{
% this is for when we get the posterior
figure(); imagesc(prob_spikesGivenPos_avg');
colormap hot;
colorbar();
set(gca,'YDir','normal');
hold on;
yyaxis right
plot(linearPosition.left{1}, 'b','LineWidth', 2,'LineStyle','--');
xlabel('time'); ylabel('position');
%}

%hold on;
%plot(ind, 'g', 'LineWidth',0.1);

%% bayesian decoding
% these variables are named like those in Shin et al., 2019

%{
% -- start by doing this for one trial and one neuron, 
        then we will do it for all neurons and multiply the products, then
        make for loop to do it across all trials. -- %
%}

% define the trial to look at
trial = 1; 

% the expected FR should be the firing rate expected given that you observe
% the rat in position "x" - since we care about position, using the
% rate_maps_pos variable.
%expectedFRs = rate_maps_pos{trial}(1,:); % 1 trial, 1 neuron

% define tau and get the number of samples that is equivalent to it
tau = 0.5; %s
numSamplesInTau = tau*vt_srate; %*(1/1000); % Nms * 30 samples/sec * (1sec/1000ms) = M samples

% group neuronal activity based on tau - get data every 15 samples. Now
% we're interested in time, so we will use instSpk variable, which is
% spikes across time (see 2nd figure in script)

%spikes per tau for all neurons

spikes_temp = spks_time{trial};
numElements = length(spikes_temp); %272
loopingIdx  = 1:15:numElements;
for i=1:5
    for ii = 1:numel(loopingIdx)-1 %1:18
        % need to sum the spikes within the tau window. Note that you have to
        % do this complicated line below because tau may not evenly fit into
        % the length of the data. For example 272 (number
        % of example data points)/ 15 (tau in samples) = 18.13. We need an
        % integer in order to group the data, not a floating point number.
        spikes(i,ii) = sum(spikes_temp(i,loopingIdx(ii):loopingIdx(ii+1)-1));
    end
end

%spikes is per tau window, but position is not
%this helps to be able to look at each position and not each position*tau
%ex. for each 15 data points, position will be different but spikes will be the
%same
for neuroni = 1:5
    for i=1:(numSamplesInTau*18)
        spike_spread(neuroni,i)=spikes(neuroni,ceil(i/15));
    end
end

%this table is organized:
%for each time point
%1. position
%2. firing rate (by position)
%3. spikes
%allows us to visualize each variable needed to run poisson and easily
%access for the formula
%each cell in spiketimerate{} is a different neuron
spiketimerate={};
for n=1:5
    spiketimerate{n}(1,:)=linearPosition.left{1}(1,:);

    %if I'm in position 1, fill in corresponding rate, etc.
    for i=1:length(rate_maps_time{trial})
        for ii = 1:length(rate_maps_pos{trial})
             if spiketimerate{n}(1,i)==ii
                 spiketimerate{n}(2,i)=rate_maps_pos{1}(n,ii);
             end
        end
    end
end

%just to make it match up, obvi bad code, will fix later (any ideas?)
spike_spread(1,271)=0;
spike_spread(1,272)=0;

%number of spikes to use for each position
for n=1:5
    spiketimerate{n}(3,:)=spike_spread(n,:);
end

%poisson distribution old (ignore me)
%has as many unique values as positions
%{
for n = 1:numNeurons
     for time=1:length(rate_maps_time{trial})
        fr = spiketimerate{n}(2,time);
        spk = spiketimerate{n}(3,time);
        
        pois_num1=(tau*fr)^spk;
        pois_num2 = exp(-1*tau*fr);
        pois_denom = factorial(spk);
        
        poisson(n,time)= (pois_num1*pois_num2)/pois_denom;
     
        %pois(n,time)= (((tau*spiketimerate{n}(2,time))^(spiketimerate{n}(3,time)))*exp(-1*tau*spiketimerate{n}(2,time)))/factorial(spiketimerate{n}(3,time));
    end
end
%}

%cleaned up poisson formula
%poisson_formula(firingrate, spikes, tau);
cd 'X:\03. Lab Procedures and Protocols\MATLABToolbox\Allison';
pf = 'poisson_formula.m';

%poisson distribution old (ignore me)
for n = 1:numNeurons
     for time=1:length(rate_maps_time{trial})
        fr = spiketimerate{n}(2,time);
        spk = spiketimerate{n}(3,time);
        poisson(n,time)= poisson_formula(fr,spk,tau);
     end
end

%make the probability matrix
%for each neuron
%for each timepoint, use spikes from that time point
%test against all possible firing rates from all positions
pois_matrix = {};
for n = 1:numNeurons
for tp = 1:length(rate_maps_time{trial})
    for pt = 1:length(rate_maps_pos{trial})
        % pois_matrix(tp,1)= rate_maps_pos{trial}(1,tp);
        firer = rate_maps_pos{trial}(n,pt);
        spk = spike_spread(n,tp);
        pois_matrix{n}(pt, tp) = poisson_formula(firer,spk,tau);
    end
end
end
%figure(); imagesc(pois_matrix{5});

%multiply across neurons
pois_matrix_tot=pois_matrix{1}.*pois_matrix{2}.*pois_matrix{3}.*pois_matrix{4}.*pois_matrix{5};
%figure(); imagesc(pois_matrix_tot);

%kaefer: for a given window, the likelihoods for all positions were normalized
%by dividing each by the maximum likelihood of that window

%test tau 1 normalizaton
t1n = [];
[t1nc, ind] = max(pois_matrix_tot(:,1:15));
t1n=(pois_matrix_tot(:,1:15))./t1nc;
%figure(); imagesc(t1n);
%colorbar();

pois_matrix_norm = [];
for i=1:272
    [m1,i1]=max(pois_matrix_tot(:,i));
    maxi(i)=m1;
    ind(i)=i1;
end

pois_matrix_norm=pois_matrix_tot./maxi;
figure(); imagesc(pois_matrix_norm);
colormap hot;
colorbar();

set(gca,'YDir','normal');

hold on;
plot(linearPosition.left{1}, 'b','LineWidth', 2);
xlabel('time'); ylabel('position');

hold on;
plot(ind, 'g', 'LineWidth',0.1);

%%
% -- rename to probability of spikes|position so we can easily know -- %
%multiply across neurons
poisson_prod=prod(poisson,1);

figure(); plot(linearPosition.left{1},poisson_prod); xlabel('Linear Position'); ylabel('Probability')

%kaefer
%for each window, given # of spikes, find highest poisson value and
%corresponding position
%i=1:15:272

% -- we need probability estimates for each time point that correspond to
% each position, even if those estimates are zero -- %
varIdx = 1:numSamplesInTau:size(spiketimerate{1},2);
for i = 1:length(varIdx)-1
    [m1,i1] = max(poisson_prod(varIdx(i):varIdx(i+1)-1)); 
    maximum(i)=m1;
    index(i)=i1+varIdx(i)-1;
   
    mostlikely(i)=linearPosition.left{1}(index(i));
end

figure(); 
plot(timingVar*1000,linearPosition.left{trial},'b','LineWidth',2,'LineStyle','--');
hold on;
numMostLikelySamples = floor(timingVar(end)*1000/500) % dynamic var
% need a variable indicating timing steps
msStepStart = ((1:18)*500)-500;
msStepEnd   = (1:18)*500;
% plot
plot(msStepStart,mostlikely,'r','LineWidth',2);
legend('Linear Position','Most Likely Position, given spikes')

%%
%shin - we should use this to corroborate
sumfr = sum(rate_maps_pos{trial});
etosum = exp(-tau*sumfr);
frtospk = fr^spk;

for n = 1:numNeurons
     for time=1:length(rate_maps_time{trial})
        fr = spiketimerate{n}(2,time);
        spk = spiketimerate{n}(3,time);
        
        pois_num1=(tau*fr)^spk;
        pois_num2 = exp(-1*tau*fr);
        pois_denom = factorial(spk);
        
        poisson(n,time)= (pois_num1*pois_num2)/pois_denom;
     
        %pois(n,time)= (((tau*spiketimerate{n}(2,time))^(spiketimerate{n}(3,time)))*exp(-1*tau*spiketimerate{n}(2,time)))/factorial(spiketimerate{n}(3,time));
    end
end


%{
%poisson distribution also incorrect
%{
for neuroni = 1:numNeurons
    for positi = 1:length(rate_maps_pos{trial})
        poisson(neuroni,positi)=(((tau*rate_maps_pos{trial}(neuroni,positi))^spike_spread(neuroni,positi))*exp(-1*tau*rate_maps_pos{trial}(neuroni,positi)))/factorial(spike_spread(neuroni,positi));
    end
end
%}

%multiply across neurons
%poisson_prod=prod(poisson,1);

%kaefer:

%incorrect poisson distribution
%this is WRONG but I'm leaving temporarily in case needed for explanation
%of my thought process
%{
for neuroni = 1:numNeurons
    for positi = 1:length(spikes)
       poisson(neuroni,positi) = (((tau*rate_maps_pos{trial}(neuroni,positi))^spikes(neuroni,positi))*exp(-1*tau*rate_maps_pos{trial}(neuroni,positi)))/(factorial(spikes(neuroni,positi)));
    end
end
%}

%{
%multiply neurons to get one value for each tau?
poisson_prod=prod(poisson,1);

%kaefer 
[~,argmaxx] = max(poisson_prod);
disp(argmaxx);

%shin
for i = 1:length(rate_maps_pos{trial})
    %sum of FRs across neurons for each posn
    sumFR(1,i) = sum(rate_maps_pos{trial}(:,ii));
end
%}
%}
%}


