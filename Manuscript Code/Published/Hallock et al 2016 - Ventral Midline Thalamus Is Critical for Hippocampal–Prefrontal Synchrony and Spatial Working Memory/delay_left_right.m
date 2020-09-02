 function [DI,KS,P] = delay_left_right(spk, Int, delay_length, bin)

%   This function calculates firing rates for left turn and right turn
%   trials during start box occupancy. It compares left turn and right turn
%   firing rates by (1) computing a discrimination index between left and
%   right turn firing rates, (2) using a Kolmogorov-Smirnov test for firing
%   rate distributions across temporal bins, and (3) using a Wilcoxon
%   rank-sum test between mean firing rate values for left and right turn
%   trials.

% Input:
%   spk:            n spikes x 1 array of spike timestamp values
%   Int:            n trials x 8 matrix of maze timestamp values
%   delay_length:   Length of delay period (make sure that this value
%                   corresponds to delay length for shortest trial)
%   bin:            Size of time bin

% Output:
%   DI:             Discrimination index
%   KS:             Probability that left and right turn firing rate
%                   distributions originated from the same distribution
%   P:              Probability that left and right turn distributions
%                   centered around median left and right turn firing rate values
%                   originated from the same distribution with a common median firing rate

%%

nTrials=size(Int,1);

% Create an "Int" variable for left turn trials
for i = 2:nTrials
    if Int(i,3) == 0
        IntL(i-1,1:8) = Int(i,1:8);
    else
        IntL(i-1,1:8) = NaN;
    end
end
IntL = IntL(isfinite(IntL(:, 1)), :);

% Create an "Int" variable for right turn trials
for i = 2:nTrials
    if Int(i,3) == 1
        IntR(i-1,1:8) = Int(i,1:8);
    else
        IntR(i-1,1:8) = NaN;
    end
end
IntR = IntR(isfinite(IntR(:, 1)), :);

% Define boundaries for start-box occupancy
ntrialsL = size(IntL,1);
ntrialsR = size(IntR,1);
spksec=spk/1e6;
TrialStartL = (IntL(1:ntrialsL,1)-delay_length*1e6)/1e6;
TrialEndL = IntL(1:ntrialsL,1)/1e6;
TrialStartR = (IntR(1:ntrialsR,1)-delay_length*1e6)/1e6;
TrialEndR = IntR(1:ntrialsR,1)/1e6;
DelayCenterL = (IntL(1:ntrialsL,1)-(delay_length/2)*1e6)/1e6;
DelayCenterR = (IntR(1:ntrialsR,1)-(delay_length/2)*1e6)/1e6;

% Define PETH edges and centers based on temporal bin size
edges = (-(delay_length/2):bin:(delay_length/2));

% Create raster plot for left turn trials
for i = 2:ntrialsL
    s=spksec(find(spksec>TrialStartL(i-1) & spksec<TrialEndL(i-1)));
    ev=DelayCenterL(i-1);
    s0=s-ev; 
    n_left(:,i-1) = histc(s0,edges);
    if isempty(s)==0,subplot(311),plot(s0,i,'bs','MarkerFace','blue','MarkerSize',2), end
    axis([-(delay_length/2) (delay_length/2) 0 ntrialsL+1])
    hold on
end
box off
ylabel('Trial')
set(gca,'XTick',[])

% Create raster plot for right turn trials
for i = 2:ntrialsR
    s=spksec(find(spksec>TrialStartR(i-1) & spksec<TrialEndR(i-1)));
    ev=DelayCenterR(i-1);
    s0=s-ev;
    n_right(:,i-1) = histc(s0,edges);
    if isempty(s)==0,subplot(312),plot(s0,i,'rs','MarkerFace','red','MarkerSize',2), end
    axis([-(delay_length/2) (delay_length/2) 0 ntrialsR+1])
    hold on
end
box off
ylabel('Trial')
set(gca,'XTick',[])

% Calculate mean firing rate by first dividing number of spikes in each
% cell by size of the temporal bin, and then averaging firing rate values
% across trials
FR_left = n_left./bin;
FR_right = n_right./bin;
nAvg_left = mean(FR_left,2);
nAvg_right = mean(FR_right,2);
Std_left = std(FR_left,0,2); 
Std_right = std(FR_right,0,2);
SEM_left = Std_right/sqrt(ntrialsL); 
SEM_right = Std_right/sqrt(ntrialsR);

% Smooth firing rate data with Gaussian filter
windowWidth = int16(10);
halfWidth = windowWidth/2;
gaussFilter = gausswin(10);
gaussFilter = gaussFilter/sum(gaussFilter);

nAvg_Smooth_left = conv(nAvg_left,gaussFilter);
nAvg_Smooth_right = conv(nAvg_right,gaussFilter);
SEM_Smooth_left = conv(SEM_left,gaussFilter);
SEM_Smooth_right = conv(SEM_right,gaussFilter);

% Define sizes of arrays to be plotted
% Length of smoothed rate plot ~= length of raw rate plot because Gaussian
% filter extends edges to avoid blurring
smooth_length = size(nAvg_Smooth_left(halfWidth:end-halfWidth),1);
raw_length = size(nAvg_left,1);
difference = raw_length-smooth_length;

left_max = max(nAvg_Smooth_left+SEM_Smooth_left);
right_max = max(nAvg_Smooth_right+SEM_Smooth_right);

% Plot smoothed firing rates
subplot(313)
varargout1=shadedErrorBar(linspace(-(delay_length),0,size(edges,2)),nAvg_Smooth_left(halfWidth:end-halfWidth+difference)',SEM_Smooth_left(halfWidth:end-halfWidth+difference),'b',1);
hold on
varargout2=shadedErrorBar(linspace(-(delay_length),0,size(edges,2)),nAvg_Smooth_right(halfWidth:end-halfWidth+difference)',SEM_Smooth_right(halfWidth:end-halfWidth+difference),'r',1);
axis tight
ylabel('Firing Rate (Hz)')
xlabel('Time (Seconds)')
legend([varargout1.mainLine,varargout2.mainLine],'Left','Right')
box off

% Define y-axis boundaries
if left_max > right_max
    ylim ([0 left_max+0.5]);
else
    ylim ([0 right_max+0.5]);
end

FR_Right = mean(nAvg_right);
FR_Left = mean(nAvg_left);

% Calculate discrimination index score between left and right turn trials
DI = abs((FR_Left - FR_Right)/(FR_Left + FR_Right));

% Perform Kolmogorov-Smirnov test on left and right turn firing rate
% distributions
[h p] = kstest2(nAvg_right,nAvg_left);
KS = p;

nAvg_LeftTrials = mean(n_left,1);
nAvg_RightTrials = mean(n_right,1);

% Perform Wilcoxon's rank-sum test on averaged left and right turn firing
% rate values
P = ranksum(nAvg_LeftTrials,nAvg_RightTrials);



end

