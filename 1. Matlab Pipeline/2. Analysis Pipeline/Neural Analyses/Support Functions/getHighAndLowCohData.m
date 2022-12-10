%% Coherence in moving window
% this code computes coherence over a moving window. This code uses
% mscohere, and detrends the data by removing 3rd degree polynomials using
% the moving window as the segment to detrend over. 
%
% this code also accounts for artifacts in the data, removing them
%
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
% 
% --- OUTPUTS --- %
% datahigh: cell array containing signal data during high coherence events
% datalow: cell array containing signal data during low coh events
% dataex: cell array containing remaining signal data
% C: Avg theta coherence over time
% t: time variable (plot(t,C) or stem(t,C))
%
% written by John Stout
    
function [datahigh,datalow,dataex,C,t] = getHighAndLowCohData(data,cohInd,signalInd,CohThresholds,srate,plotfig)
warning('This function only works if your data variable has samples (voltages) on rows, and observations on columns')

% preparatory steps
movingwin = [1.25 0.25];
f = [6:.5:11];
Fs = srate;
Nwin=round(Fs*movingwin(1)); % number of samples in window
Nstep=round(movingwin(2)*Fs); % number of samples to step through
[N,Ch]=check_consistency(data1,data2);
winstart=1:Nstep:N-Nwin+1;
nw=length(winstart);

C = [];
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
    if ctheta > CohThresholds(1) % this should be high
        datahigh{n} = datawin';
    elseif ctheta < threshold(2)
        datalow{n} = datawin';
    else
        dataex{n} = datawin';
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
    line([xlimits(1) xlimits(2)],[CohThresholds(1) CohThresholds(1)],'color','b','LineStyle','--')
    line([xlimits(1) xlimits(2)],[CohThresholds(2) CohThresholds(2)],'color','r','LineStyle','--')
    title('Epoched coherence. Lines denote high/low coh threshold')
end
