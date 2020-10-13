%% sharp wave ripple PETH
% peri-stimulus time histogram surrounding a sharp wave ripple event
%
% -- INPUTS -- %
% spikeTimes: vector of spike times
% timesAround: vector containing timing around ripple ( = [0.5*1e6, 0.5*1e6] ) 
%               for half second before and after)
% SWRtimes: cell array of sharp wave ripple times
% plotFig: 1 for plotting
%
% things to add: remove spikes that fire < 50 spikes surrounding ripple
%
% -- OUTPUTS -- %
% FR: firing rate
% n: matrix of spikes as boolean
% excludeCell: variable indicate exclusion criteria (1 == exclude, 0 ==
%               include). This is set to 1 if there are less than 50 spikes
%               surrounding a ripple
%
% this code was adapted from Henry Hallock

function [FR,n,excludeCell] = PETH_SWR(spikeTimes,SWRtimes,timesAround,plotFig)

% get time around ripples
nRipples = length(SWRtimes);
spkMS    = spikeTimes/1e6; % maybe this should b spike per ms (1e3)

for i = 1:nRipples
    beforeRipple(i,:) = SWRtimes{i}(1)/1e6-timesAround(1)/1e6;
    afterRipple(i,:)  = SWRtimes{i}(1)/1e6+timesAround(2)/1e6;
    rippleStart(i,:)  = SWRtimes{i}(1)/1e6; 
end

bin          = 10; % ms bins, for binning purposes
timeLength   = (timesAround(1)+timesAround(2))/1e6; % converted to ms
edges = (-(timeLength/2):bin:timeLength/2);

if plotFig == 1; figure('color','w'); end
clear n
for i = 1:nRipples
    s = spkMS(spkMS > beforeRipple(i) & spkMS<afterRipple(i));
    ev = rippleStart(i);
    s0 = s - ev; % spike times centered around ripple start
    s0 = s0/1e3; % spikes converted to ms
    n(:,i) = histc(s0,edges);
    if plotFig == 1
        if isempty(s) == 0,subplot(211),plot(s0,i,'k.'), end
        axis([-(timeLength/2) timeLength/2 0 nRipples])
        hold on
    end
end
if plotFig == 1
    ylimits = ylim;
    line1 = line([0 0],ylimits);
    line1.LineStyle = '--';
    line1.LineWidth = 1;
    line1.Color     = 'b';
    set(gca,'XTick',[]);
    ylabel('Ripple')
end

% Get firing rate by dividing number of spikes in each bin by bin size
%FR = sum(n,2)./bin; % summing spikes first to account for all the zeros - kinda weird, check with Jadhav
FR   = n./bin;
nAvg = mean(FR,2);
Std  = std(FR,0,2); 
SEM  = Std/sqrt(nRipples-1); 

% Create Gaussian filter for rate plot smoothing
VidSrate    = 30;

% smooth data
FRsmooth = smoothdata(nAvg,'gaussian',VidSrate);

if plotFig == 1
    subplot(212)
    %varargout = shadedErrorBar(linspace(-(rippleLength),0,size(edges,2)),nAvg_Smooth(halfWidth:end-halfWidth+difference)',SEM_Smooth(halfWidth:end-halfWidth+difference),'k',1);
    timingInt = timesAround(1)/1000;
    timing = linspace(-timingInt,timingInt,size(edges,2));
    plot(timing,FRsmooth,'k','LineWidth',2)
    axis tight
    ylabel('Firing Rate (Hz)')
    xlabel('Time (ms)')
    ylimits = ylim;
    line1 = line([0 0],ylimits);
    line1.LineStyle = '--';
    line1.LineWidth = 1;
    line1.Color     = 'b';
end

% Perform Poisson regression between time and firing rate
%{
nAvg(end,:) = [];
x = linspace(1,timeLength,timeLength/bin);
x = x';
[b, dev, stats] = glmfit(x,nAvg,'poisson');
p = stats.p(2,1);
b = stats.beta(2,1);
%}

% define exclusion variable
if length(find(n == 1)) < 50
    excludeCell = 1; % exclude if less than 50 spikes around ripple
else
    excludeCell = 0; % include if greater than or = to 50 spikes around ripple
end

% shuffle columns of the variable n create 5000 seperate shuffles
% create a 3D array - EW
for i = 1:5000
    shuffle_n(:,:,i) = n(randperm(size(n, 1)),:);
end
% now calculate shuffled firing rate for each shuffle
FRshuffle = shuffle_n./bin;
% get vector average for each shuffle, then average across shuffles.
%shuffAvg = mean(FRshuffle,2);
shuffAvg = mean(mean(FRshuffle,3),2);
shuffAvg_smooth = smoothdata(shuffAvg,'gaussian',VidSrate);

if plotFig == 1
    hold on;
    plot(timing,shuffAvg_smooth,'r','LineWidth',2)
end

% define new variable
%FRsmooth = nAvg_Smooth(halfWidth:end-halfWidth+difference)';

% then average the shuffled firing rates

% Find the sqr diff between the averaged 3d array and the og
%sqrdiff_n = (n - avg_shuffle).^2;

end


