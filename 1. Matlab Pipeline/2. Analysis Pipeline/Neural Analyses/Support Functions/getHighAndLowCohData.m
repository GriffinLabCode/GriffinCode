%% Coherence in moving window
% this code computes theta coherence over moving windows similar to the BMI
% does in real time.

% -- INPUTS -- %
% data: matrix of LFP data (signal on rows, samples on columns)
% cohInd: you must specify which two signals to compare. For example:
%               indicator = [1 2] means to compare signals 1 and 2 (find
%               high and low coh epochs from signals 1 and 2). The output
%               will be coh events for all of your data
% signalInd: You must specify which signals are LFP and which signals are
%               binary spike data
% srate: sampling rate (e.g. 2000)
% thresholds: [h L] where h = high coh value and L = low coh value
% plotFig: 'y' to plot figure
% deltaThresh: 'y' if you want to require that theta > delta
% 
% --- OUTPUTS --- %
% datahigh: cell array containing signal data during high coherence events
% datalow: cell array containing signal data during low coh events
% dataex: cell array containing remaining signal data
% C: Avg theta coherence over time
% t: time variable (plot(t,C) or stem(t,C))
%
% written by John Stout
    
function [datahigh,datalow,dataex,C,t] = getHighAndLowCohData(data,cohInd,signalInd,cohThresholds,srate,plotfig,deltaThresh)
disp('If you notice signal artifacts in your data, consider ztransforming and removing high coh epochs if extreme voltages are observed or if delta coh > theta coh')

if exist('deltaThresh')==0
    deltaThresh = 'n';
end
if exist('plotFig')==0
    plotFig = 'n';
end
    
% preparatory steps
movingwin = [1.25 0.25];
f = [6:.5:11];
Fs = srate;
Nwin=round(Fs*movingwin(1)); % number of samples in window
Nstep=round(movingwin(2)*Fs); % number of samples to step through
%[N,Ch]=check_consistency(data1,data2);
[row,col] = size(data);
if row < col
    data = data';
    disp('Signal detected on columns. Inverted so signal is on rows')
end
[N,~] = size(data);
winstart=1:Nstep:N-Nwin+1;
nw=length(winstart);

disp(['LFP channels defined in "signalInd" will be detrended'])
C = []; datahigh = cell([1 nw]); datalow = cell([1 nw]); dataex = cell([1 nw]);
for n=1:nw
    
    % get data
    indx    = winstart(n):winstart(n)+Nwin-1;
    datawin = data(indx,:);
    
    % detrend signals indicated
    datawin(:,signalInd) = detrend(datawin(:,signalInd),3);
    
    % compute avg theta coherence
    ctheta = mean(mscohere(datawin(:,cohInd(1)),datawin(:,cohInd(2)),[],[],f,srate));  
    %cdelta = mean(mscohere(datawin(:,cohInd(1)),datawin(:,cohInd(2)),[],[],[1:.5:4],srate));
    
    % identify whether c belongs to high, low, or na
    if contains(deltaThresh,'y')
        cdelta = mean(mscohere(datawin(:,cohInd(1)),datawin(:,cohInd(2)),[],[],[1:.5:4],srate));
        if ctheta > cohThresholds(1) && ctheta > cdelta % this should be high
            datahigh{n} = datawin';
        elseif ctheta < cohThresholds(2) && ctheta > cdelta
            datalow{n} = datawin';
        else
            dataex{n} = datawin';
        end        
    else
        if ctheta > cohThresholds(1) % this should be high
            datahigh{n} = datawin';
        elseif ctheta < cohThresholds(2)
            datalow{n} = datawin';
        else
            dataex{n} = datawin';
        end
    end
    % store coherence
    C(n,:)=ctheta;
    %Cd(n,:)=cdelta;
end

% reorient coherence matrix
C = C';

% generate time
winmid=winstart+round(Nwin/2);
t=winmid/Fs;

if contains(plotfig,[{'y'} {'Y'}])
    figure('color','w')
    stem(t,C,'k');
    ylabel('Theta coherence (6-11Hz)')
    xlabel('Time (sec)')
    axis tight;
    ylim([0 1]);
    xlimits = xlim;
    ylimits = ylim;
    line([xlimits(1) xlimits(2)],[cohThresholds(1) cohThresholds(1)],'color','b','LineStyle','--')
    line([xlimits(1) xlimits(2)],[cohThresholds(2) cohThresholds(2)],'color','r','LineStyle','--')
    title('Epoched coherence. Lines denote high/low coh threshold')
end
