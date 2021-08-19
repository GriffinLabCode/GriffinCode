function [p, b] = PETH_delay(spk, Int, delay_length, bin)
%%

%This function creates a peri-event time histogram, raster plot, and
%average firing rate plot over time for a single unit recorded during delay
%pedestal occupancy. 

%The function also detects changes in firing rate over time ("ramping"
%activity/"decay" activity) by performing a Poisson regression

%Inputs
%   spk = 1 x nSamples array of spike timestamps
%   Int = nTrials x 8 matrix of timestamps values for maze occupancy
%   delay_length = Length of delay period (seconds)
%   bin = Temporal bin size (seconds)
%   plot = 0 if plot, 1 if no plot

%Outputs
%   p = P value for regression coefficient
%   b = Regression coefficient (R)


%%

% Define parameters for start-box occupancy
nTrials=length(Int(:,1));
spksec=spk/1e6;
TrialStart = (Int(2:nTrials,1)-delay_length*1e6)/1e6;
TrialEnd = Int(2:nTrials,1)/1e6;
DelayCenter = (Int(2:nTrials,1)-(delay_length/2)*1e6)/1e6;
intsec = Int/1e6;
ntrials = size(Int,1);

edges = (-(delay_length/2):bin:delay_length/2);

for i = 2:nTrials
    s=spksec(find(spksec>TrialStart(i-1) & spksec<TrialEnd(i-1)));
    ev=DelayCenter(i-1);
    s0=s-ev; 
    n(:,i-1) = histc(s0,edges);
    if isempty(s)==0,subplot(311),plot(s0,i,'k.'), end
    axis([-(delay_length/2) delay_length/2 0 nTrials+1])
    hold on
end

set(gca,'XTick',[]);
ylabel('Trial')

n_allTrials = sum(n,2)*bin; 
max_n_allTrials = max(n_allTrials);
subplot(312), bar(edges,n_allTrials), axis([-(delay_length/2) delay_length/2 0 max_n_allTrials+1])

set(gca,'XTick',[]);
ylabel('Spike Count')


% Get firing rate by dividing number of spikes in each bin by bin size
FR = n./bin;
nAvg = mean(FR,2);
Std = std(FR,0,2); 
SEM = Std/sqrt(nTrials-1); 

% Create Gaussian filter for rate plot smoothing
windowWidth = int16(5);
halfWidth = windowWidth/2;
gaussFilter = gausswin(5);
gaussFilter = gaussFilter/sum(gaussFilter);

nAvg_Smooth = conv(nAvg,gaussFilter);
SEM_Smooth = conv(SEM,gaussFilter);

% Define size of smoothed firing rates to be plotted in accordance with
% Gaussian blurring
smooth_length = size(nAvg_Smooth(halfWidth:end-halfWidth),1);
raw_length = size(nAvg,1);
difference = raw_length-smooth_length;
max_data = max(nAvg_Smooth) + max(SEM_Smooth);
max_graph = max_data + 0.05;

subplot(313)
varargout=shadedErrorBar(linspace(-(delay_length),0,size(edges,2)),nAvg_Smooth(halfWidth:end-halfWidth+difference)',SEM_Smooth(halfWidth:end-halfWidth+difference),'k',1);
axis tight
ylabel('Firing Rate (Hz)')
xlabel('Time (Seconds)')
ylim ([0 max_graph]);


% Perform Poisson regression between time and firing rate
nAvg(end,:) = [];
x = linspace(1,delay_length,delay_length/bin);
x = x';
[b, dev, stats] = glmfit(x,nAvg,'poisson');
p = stats.p(2,1);
b = stats.beta(2,1);


end

