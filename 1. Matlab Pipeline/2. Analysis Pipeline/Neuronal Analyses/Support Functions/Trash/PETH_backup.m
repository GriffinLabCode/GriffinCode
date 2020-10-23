%% PETH
% peri-event time histogram
%
% IMPORTANT: This code assumes neurlynx time scale. So if you're working
%               with seconds, convert them by N*1e6;
%
% -- INPUTS -- %
% spikeTimes: vector of spike times
% eventTimes: vector of timestamps that correspond to the start of the
%               event that you are interested in. Say, you were interested
%               in examining 10 sec before and after the middle of startbox
%               occupancy. This variable would have the middle timestamp of
%               each startbox occupancy for each trial. Or, if you were
%               interested in unit activity around an swr event, each
%               element in this vector would be the onset of the swr event
% timesAround: times around the eventTimes. Say you wanted 1 sec before the
%               eventTime, and 2 sec after. timesAround = [1*1e6 2*1e6].
%               Note that I converted to neuralynx timing. If your other
%               arguments are in seconds, than this should be [1 2].
%
% timeRes: time resolution; if you are looking at 1 second before 
%               1 second after your event, you need to decide how you want
%               to bin your spike data. Do you want 100 ms bins? 50ms bins?
%               1sec bins? 1ms bins? if you type timeRes = 100, your data
%               will scale by 100 between bins. If you select 50, your data
%               will scale by 50 per bin. 20 seems to be good for swr
%               events
%
% timeScale: 'ms' or 'sec'
%
% plotFig: whether or not to plot the fig. Can be '1', 'y', 'Y', or empty.
%           If anything else, it will not plot
%
% -- OUTPUTS -- %
%
% Parts of this code were found in Henry Hallocks folder. SWR and shuffle
% data was added by John Stout. Variables were renamed and function
% arguments and outputs changed by John Stout.
%
% This code is incomplete and should undergo one more round of checking as
% of 10/21/2020

function [FRsmooth,nAvg,FR,n,stats,shuffAvg_smooth,shuffAvg,shuffle_n] = PETH(spikeTimes,eventTimes,timesAround,timeRes,timeScale,plotFig,swrMod_test)

% initialize outputs
FRsmooth = []; nAvg = []; FR = []; n = []; stats = []; shuffAvg_smooth = [];
shuffAvg = []; shuffle_n = [];

% get time around events
nEvents = length(eventTimes);
for i = 1:nEvents
    beforeEvent(i,:) = eventTimes(i)-timesAround(1);
    afterEvent(i,:)  = eventTimes(i)+timesAround(2);
    eventStart(i,:)  = eventTimes(i); 
end

% concatenate event boundaries
eventBoundaries = horzcat(beforeEvent,afterEvent);

% for ms
if isempty('timeRes') & (contains(swrMod_test,[{'y'},{'Y'}]) | swrMod_test == 1)
    % default
    timeRes = 20; % ms bins, for binning purposes
end

% decide your timescale
if contains(timeScale,[{'ms'},{'millisec'}])
    timeLength = (timesAround(1)+timesAround(2))/1e3; % converted to ms
elseif contains(timeScale,[{'sec'},{'second'}])
    timeLength = (timesAround(1)+timesAround(2)); % converted to ms
end

% define your edges, this is the how data is going to be grouped
edges = (-(timeLength/2):timeRes:timeLength/2);

if plotFig == 1 | contains(plotFig,[{'y'},{'Y'}]); figure('color','w'); end
clear n
for i = 1:nEvents
    s  = spikeTimes(spikeTimes > beforeEvent(i) & spikeTimes<afterEvent(i));
    ev = eventStart(i);
    s0 = s - ev; % spike times centered around event start
    s0 = s0/1e3; % spikes converted to ms
    n(:,i) = histc(s0,edges);
    if plotFig == 1 | contains(plotFig,[{'y'},{'Y'}]);
        if isempty(s) == 0,subplot(211),plot(s0,i,'k.'), end
        axis([-(timeLength/2) timeLength/2 0 nEvents])
        hold on
    end
end
if plotFig == 1 | contains(plotFig,[{'y'},{'Y'}]);
    ylimits = ylim;
    line1 = line([0 0],ylimits);
    line1.LineStyle = '--';
    line1.LineWidth = 1;
    line1.Color     = 'b';
    set(gca,'XTick',[]);
    ylabel('Event #')
end

% Get firing rate by dividing number of spikes in each bin by bin size
%FR = sum(n,2)./timeRes; % summing spikes first to account for all the zeros - kinda weird, check with Jadhav
FR   = n./timeRes;
nAvg = mean(FR,2)';
Std  = std(FR,0,2)'; 
SEM  = stderr(FR'); 

% smooth data
smoothFact = round(length(nAvg)/10)*2;
FRsmooth = smoothdata(nAvg,'gaussian',smoothFact);
SEMsmooth = smoothdata(SEM,'gaussian',smoothFact);

if plotFig == 1 | contains(plotFig,[{'y'},{'Y'}]);
    subplot(212)
    %varargout = shadedErrorBar(linspace(-(rippleLength),0,size(edges,2)),nAvg_Smooth(halfWidth:end-halfWidth+difference)',SEM_Smooth(halfWidth:end-halfWidth+difference),'k',1);
    timingInt = timesAround(1)/1000;
    timing = linspace(-timingInt,timingInt,size(edges,2));
    plot(timing,FRsmooth,'k','LineWidth',2)
    %varargout = shadedErrorBar(timing,FRsmooth,SEMsmooth,'k',1);
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
x = linspace(1,timeLength,length(edges));
x = x';
[b, dev, stats_out] = glmfit(x,nAvg,'poisson');
stats.p_timeXfr_poissonReg = stats_out.p(2,1);
stats.b_timeXfr_poissonReg = stats_out.beta(2,1);

% shuffle columns of the variable n create 5000 seperate shuffles
% create a 3D array - EW
for i = 1:5000
    shuffle_n(:,:,i) = n(randperm(size(n, 1)),:);
end
% now calculate shuffled firing rate for each shuffle
FRshuffle = shuffle_n./timeRes; % get rate for every shuffle
%FRshuffle = sum(shuffle_n,3)./bin; % get FR for each shuffle
%FRshuffle = reshape(FRshuffle,[size(FRshuffle,1) size(FRshuffle,3)]); % change shape
% get vector average for each shuffle, then average across shuffles.

shuffAvg = mean(FRshuffle,3);     % avg across shuffles
shuffEventAvg = mean(shuffAvg,2); % average across events
shuffEventSEM = stderr(shuffAvg')';    % sem across event shuffles
shuffAvg_smooth = smoothdata(shuffEventAvg,'gaussian',smoothFact);

if plotFig == 1 | contains(plotFig,[{'y'},{'Y'}]);
    hold on;
    plot(timing,shuffAvg_smooth,'r','LineWidth',2)
end

%% significance testing

% Find the sqr diff between FR and shuffled data
stats.sqrdiff = (FRsmooth - shuffAvg_smooth').^2;
%[stats.p_trueXshuff,h,stats.stat_trueXshuff] = ranksum(FRsmooth,shuffAvg_smooth');

if swrMod_test == 1 | contains(swrMod_test,[{'y'},{'Y'}])

    % Jadhav does something a little different, but I prefer using the 
    % shuffled data as a normal distribution (which it tends to make), then
    % using a z-test to see if the average firing rate from 0-200ms post
    % ripple comes from the distribution of shuffled firing rates.
    
    % get pre/post event data
    preEventIdx  = find(edges == -500):find(edges == -100);
    postEventIdx = find(edges == 0):find(edges == 200);    
    
    % get data
    preFR  = FRsmooth(preEventIdx);
    postFR = FRsmooth(postEventIdx);    
    
    % get shuffled average frs
    shuffAvg_swr   = mean(FRshuffle,2); % get average for each shuffle
    postShuff_temp = shuffAvg_swr(postEventIdx,:,:);
    postShuff      = reshape(postShuff_temp,[size(postShuff_temp,1) size(postShuff_temp,3)]);
    
    % get average of postFR and postShuffle
    postFR_mean    = mean(postFR);
    postShuff_mean = mean(postShuff,1);

    if plotFig == 1 | contains(plotFig,[{'y'},{'Y'}])
        % what if i do a ztest?
        figure('color','w')
        histogram(postShuff_mean,10)
        ylimits = ylim;
        l1 = line([postFR_mean postFR_mean],[ylimits(1) ylimits(2)]);
        l1.Color = 'r';
        l1.LineWidth = 2;
    end

    % perform z-test
    m = mean(postShuff_mean);
    sigma = std(postShuff_mean);
    [h,stats.swrMod_zTest_p] = ztest(postFR_mean,m,sigma);
    
    
    % tang paper
    baselineResp = 
    
    
    % I think Jadhav uses a difference score to determine if the unit
    % increases or decreases after the ripple
    stats.diff_preXpost = mean(preFR)-mean(postFR);
    stats.preXpostSWR_mod_ranksum = ranksum(preFR,postFR);

    if plotFig == 1 | contains(plotFig,[{'y'},{'Y'}]);
        figure('color','w')
        x = [ones(size(postFR))'; 2*ones(size(postShuff_mean))'];
        y = [postFR'; postShuff_mean'];
        b = boxplot(y,x);
        box off
        ax = gca;
        ax.XTickLabel = [{'Post-event'},{'Shuffled data'}];
        ylabel('Firing Rate (Hz)')        
        
        figure('color','w')
        x = [ones(size(preFR))'; 2*ones(size(postFR))'];
        y = [preFR'; postFR'];
        b = boxplot(y,x);
        box off
        ax = gca;
        ax.XTickLabel = [{'Pre-event'},{'Post-event'}];
        ylabel('Firing Rate (Hz)')
    end
    
    % baseline response is the mean of all shuffled responses
    baseline_resp = mean(postShuff,2);
    
    % compare the response in a 0-200ms window after swr onset (swr
    % response) to the baseline
    swr_response = postFR';
    
    % mean squared response between swr and baseline. They refer to mean
    % squared difference. Following logically, this is mean squared error
    mse_swr_baseline = immse(swr_response,baseline_resp); % mean((swr_response-baseline_resp).^2)
    
    % mse of shuffled response to baseline
    for i = 1:size(postShuff,2)
        mse_shuff_baseline(i) = immse(postShuff(:,i),baseline_resp);
    end
    
    % a neuron was considered swr modulated when the mean squared
    % difference of its actual swr response from the baseline was >95% of
    % the mean squared difference of its shuffled response from the
    % baseline (ie p<0.05) - Tang et al., 2017 JNeuro
    figure('color','w'); hold on;
    histogram(mse_shuff_baseline)
    ylimits = ylim;
    l = line([mse_swr_baseline mse_swr_baseline],[ylimits(1) ylimits(2)]);
    l.Color = 'r';
    l.LineWidth = 2;
    xlabel('MSE')
    ylabel('Iteration')
    legend('BASEr - Shuf', 'SWRr - BASEr')
    
    % > 95% of a two tailed distribution?
    Y = prctile(mse_shuff_baseline,[5 95]);
    
    if mse_swr_baseline < Y(1) | mse_swr_baseline > Y(2)
        stat.swr_mod = 'y';
    else
        stat.swr_mod = 'n';
    end
    
end

end


