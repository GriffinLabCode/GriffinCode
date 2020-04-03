function [DI, KS, P, fr_right, fr_left] = stem_left_right(spk, numbins, Int, ExtractedX, TimeStamps, plot)
%%

%   This function calculates firing rates for left turn and right turn
%   trials during stem traversals. It compares left turn and right turn
%   firing rates by (1) computing a discrimination index between left and
%   right turn firing rates, (2) using a Kolmogorov-Smirnov test for firing
%   rate distributions across spatial bins, and (3) using a Wilcoxon
%   rank-sum test between mean firing rate values for left and right turn
%   trials.

% Input:
%   spk:            n spikes x 1 array of spike timestamp values
%   numbins:        Number of stem bins
%   Int:            n trials x 8 matrix of maze timestamp values
%   ExtractedX:     Values for stem entry and stem exit
%   TimeStamps:     Position timestamp data
%   plot:           0 if plot, 1 if no plot

% Output:
%   DI:             Discrimination index
%   KS:             Probability that left and right turn firing rate
%                   distributions originated from the same distribution
%   P:              Probability that left and right turn distributions
%                   centered around median left and right turn firing rate values
%                   originated from the same distribution with a common median firing rate
%   fr_right:       n right turn trials x numbins matrix of firing rate
%                   values for right turn trials (SPSS input for ANOVA or
%                   ANCOVA)
%   fr_left:        n left turn trials x numbins matrix of firing rate
%                   values for left turn trials (SPSS input for ANOVA or ANCOVA) 

%%

% Manually define stem boundaries
xmin = 200;
xmax = 375;
ymax = ;
ymin = ;

bins = linspace(xmin,xmax,numbins+1);
bins = round(bins);

% Populate separate Int variables for left-turn and right-turn trials
for i = 1:size(Int,1)
    if Int(i,3) == 0
        IntL(i,1:8) = Int(i,1:8);
    else
        IntL(i,1:8) = NaN;
    end
end
IntL = IntL(isfinite(IntL(:, 1)), :);

for i = 1:size(Int,1)
    if Int(i,3) == 1
        IntR(i,1:8) = Int(i,1:8);
    else
        IntR(i,1:8) = NaN;
    end
end
IntR = IntR(isfinite(IntR(:, 1)), :);

% Calculate firing rates for each stem bin for left-turn trials
for i = 1:size(IntL,1)
    ts_ind = find(TimeStamps>IntL(i,1) & TimeStamps<IntL(i,5));
    ts_temp = TimeStamps(ts_ind);
    x_temp = ExtractedX(ts_ind);
    x_temp = x_temp';  
    bins = bins';
    k = dsearchn(x_temp,bins);
    bins = bins';
    x_temp = x_temp';
    spk_ts = ts_temp(k);
    for j = 1:length(bins)-1
        numspikes_ind = find(spk>spk_ts(j) & spk<spk_ts(j+1));
        numspikes = length(numspikes_ind);
        time_temp = spk_ts(j+1) - spk_ts(j);
        time_temp = time_temp/1e6;
        fr_temp(j) = numspikes/time_temp;
    end
    fr_left(i,1:size(fr_temp,2)) = fr_temp;
end

% Same as above for right-turn trials
for i = 1:size(IntR,1)
    ts_ind = find(TimeStamps>IntR(i,1) & TimeStamps<IntR(i,5));
    ts_temp = TimeStamps(ts_ind);
    x_temp = ExtractedX(ts_ind);
    x_temp = x_temp';  
    bins = bins';
    k = dsearchn(x_temp,bins);
    bins = bins';
    x_temp = x_temp';
    spk_ts = ts_temp(k);
    for j = 1:length(bins)-1
        numspikes_ind = find(spk>spk_ts(j) & spk<spk_ts(j+1));
        numspikes = length(numspikes_ind);
        time_temp = spk_ts(j+1) - spk_ts(j);
        time_temp = time_temp/1e6;
        fr_temp(j) = numspikes/time_temp;
    end
    fr_right(i,1:size(fr_temp,2)) = fr_temp;
end

% If there were no spikes, firing rate = 0
% Calculate means and standard errors
fr_right(isnan(fr_right)) = 0;
fr_left(isnan(fr_left)) = 0;
fr_left_avg = mean(fr_left,1);
fr_right_avg = mean(fr_right,1);        
std_left = std(fr_left,0,1);
std_right = std(fr_right,0,1);
sem_left = std_left/sqrt(size(IntL,1));
sem_right = std_right/sqrt(size(IntR,1));

% Create Gaussian filter for rate plot smoothing
windowWidth = int16(5);
halfWidth = windowWidth/2;
gaussFilter = gausswin(5);
gaussFilter = gaussFilter/sum(gaussFilter);

smooth_right = conv(fr_right_avg,gaussFilter);
smooth_left = conv(fr_left_avg,gaussFilter);
sem_smooth_right = conv(sem_right,gaussFilter);
sem_smooth_left = conv(sem_left,gaussFilter);

% Define size of smoothed rate plot based on degree of Gaussian blurring
smooth_length = size(smooth_right(1,halfWidth:end-halfWidth));
smooth_length = smooth_length(:,2);
raw_length = size(fr_right,2);
difference = raw_length-smooth_length;

mean_rate_left = mean(fr_left_avg);
mean_rate_right = mean(fr_right_avg);

% Calculate discrimination index score between left-turn and right-turn
% trials
DI = abs(mean_rate_left - mean_rate_right)/(mean_rate_left + mean_rate_right);

% Calculate Kolmogorov-Smirnov test between left-turn and right-turn firing
% rate distributions
[h p] = kstest2(fr_left_avg,fr_right_avg);
KS = p;

avg_left = mean(fr_left,2);
avg_right = mean(fr_right,2);

% Calculate Wilcoxon's rank-sum test between left-turn and right-turn
% bin-averaged firing rates
P = ranksum(avg_left,avg_right);

if plot == 0
figure()
varargout1=shadedErrorBar(bins(:,1:length(bins)-1),smooth_left(1,halfWidth:end-halfWidth+difference),sem_smooth_left(1,halfWidth:end-halfWidth+difference),'b',1);
hold on
varargout2=shadedErrorBar(bins(:,1:length(bins)-1),smooth_right(1,halfWidth:end-halfWidth+difference),sem_smooth_right(1,halfWidth:end-halfWidth+difference),'r',1);
axis tight
ylabel('Firing Rate')
xlabel('Stem Position (X-Coordinate)')
legend([varargout1.mainLine,varargout2.mainLine],'Left','Right')

left_max = max(smooth_left+sem_smooth_left);
right_max = max(smooth_right+sem_smooth_right);

if left_max > right_max
    ylim ([0 left_max+0.5]);
else
    ylim ([0 right_max+0.5]);
end
end




end

