%% Coherence in moving window
% --> See SCRIPT_coherenceSpikes from Libraries > Example code usage
%
% this code searches for high and low coherence states, then saves spike
% data stored from a raw variable. Three variables are used. The raw data
% variable containing boolean spikes and two variables created: dataHigh
% and dataLow. These start as identical to the data variable, but we erase
% all** spikes. Then in a for loop, we search for spikes belonging to high
% or low coherence states, and if detected, they are stored in the dataHigh
% and dataLow variable. This ensures that the only spikes present in these
% variables belong to high and low coherence states.
%
% If you have a matrix of signal data and want to extract spikes from high
% and low coherence events, and you have an idea for thresholds, then run
% this code with no optional inputs. 
%
% If you want to do everything described above, but would want to exclude
% instances where delta power > theta power, include delta threshold.
%
% if you want to do everything described above, but would want to exclude
% potential signal artifacts (this procedure doesn't always work), then
% include an artifactMean and artifactSTD

% -- INPUTS -- %
% data: matrix of LFP data (signal on rows, samples on columns)
% cohInd: you must specify which two signals to compare. For example:
%               indicator = [1 2] means to compare signals 1 and 2 (find
%               high and low coh epochs from signals 1 and 2). The output
%               will be coh events for all of your data
% signalInd: You must specify which signals are LFP and which signals are
%               binary spike data
% srate: sampling rate (e.g. 2000)
% spkIdx: Index pointing to which rows are boolean spike data
% thresholds: [h L] where h = high coh value and L = low coh value
% plotFig: 'y' to plot figure
%
% --- OPTIONAL INPUTS --- %
% deltaThresh: 'y' if you want to require that theta > delta
% artifactMean: array of mean values used to exclude signals (same size as
%                   signalInd)
% artifactSTD: array of standard deviations to use to exclude signals (same
%                   size as signalInd)
% ----> signal exclusion: z-score transforms signal against the mean and
%           STD and removes if > 4std from the mean
% 
% --- OUTPUTS --- %
% *** VERY IMPORTANT ***
% the outputs displayed here reflect raw inputs. The input data gets
% detrended in a moving window to calculate coherence, but the raw data is
% sent as the output.
%
% dataHigh: matrix of input data containing spikes only belonging to high
%               coh events
% dataLow: matrix of input data containing spikes only belonging to low
%               coh events
%
% written by John Stout
    
function [dataHigh,dataLow,C] = getCoherenceSpikes(data,cohInd,signalInd,cohThresholds,srate,spkIdx,plotfig,deltaThresh,artifactMean,artifactSTD)
disp('If you notice signal artifacts in your data, consider ztransforming and removing high coh epochs if extreme voltages are observed or if delta coh > theta coh')

if exist('deltaThresh')==0
    deltaThresh = 'n';
end
if exist('plotFig')==0
    plotFig = 'n';
end
if exist('artifactMean')==0 || exist('artifactSTD')==0
    artifactEx = 'n';
else
    artifactEx = 'y';
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
dataAll = cell([1 nw]); 

% assign dataHigh and dataLow to data
dataHigh = data; dataLow = data;
% get rid of all spikes from dataHigh and dataLow
dataHigh(:,spkIdx)=zeros([size(dataHigh(:,spkIdx))]);
dataLow(:,spkIdx)=zeros([size(dataLow(:,spkIdx))]);

% loop over data in moving window
for n=1:nw
    
    % get data
    indx       = winstart(n):winstart(n)+Nwin-1;
    datawin    = data(indx,:);
    datawin_og = data(indx,:); % non detrended signal
    
    % detrend signals indicated
    datawin(:,signalInd) = detrend(datawin(:,signalInd),3);

    % compute avg theta coherence
    ctheta = mean(mscohere(datawin(:,cohInd(1)),datawin(:,cohInd(2)),[],[],f,srate));  
    %cdelta = mean(mscohere(datawin(:,cohInd(1)),datawin(:,cohInd(2)),[],[],[1:.5:4],srate));
    
    % identify whether c belongs to high, low, or na
    if contains(deltaThresh,'y')
        cdelta = mean(mscohere(datawin(:,cohInd(1)),datawin(:,cohInd(2)),[],[],[1:.5:4],srate));
        if ctheta > cohThresholds(1) && ctheta > cdelta % this should be high
            % if high coherence is detected, replace with spikes from 
            % original variable
            dataHigh(indx,spkIdx) = data(indx,spkIdx);
        elseif ctheta < cohThresholds(2) && ctheta > cdelta
            dataLow(indx,spkIdx) = data(indx,spkIdx);
        else
        end        
    else
        % if threshold is surpassed, replace the spike data with the
        % original spike data!
        if ctheta > cohThresholds(1) % this should be high
            %pause;
            dataHigh(indx,spkIdx) = data(indx,spkIdx);
        elseif ctheta < cohThresholds(2)
            %pause;
            dataLow(indx,spkIdx) = data(indx,spkIdx);
        else
        end
    end
        
    % exclude "artifact" signals
    if contains(artifactEx,'y')
        zSig = [];
        
        % z transform signal data (sig1 = PFC)
        zSig(1,:) = (datawin(:,signalInd(1))-artifactMean(1))/artifactSTD(1);
        zSig(2,:) = (datawin(:,signalInd(2))-artifactMean(2))/artifactSTD(2);    
        
        % find artifacts
        idxArtifact = find(zSig(1,:) > 4 | zSig(1,:) < -4 | zSig(2,:) > 4 | zSig(2,:) < -4);
        percSat = numel(idxArtifact)/numel(zSig);
        if percSat > 1
            % if artifacts, set spike data to zero
            dataHigh(indx,spkIdx) = zeros([size(dataHigh(indx,spkIdx))]);
            dataLow(indx,spkIdx)  = zeros([size(dataLow(indx,spkIdx))]);
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

% last step is to ensure that there are no spikes belonging to both high
% and low coherence states. This happens because the tail end of a low
% coherence state could transition to a high coherence state in a future
% moving window

% since these data are the same, the only difference is where the spikes
% are located, we can use simple procedures to identify spike overlap
for i = spkIdx
    % find spikes per unit (i)
    spkHigh = find(dataHigh(:,i));
    spkLow  = find(dataLow(:,i));
    for ii = 1:length(spkHigh)
        % if there is overlap between two spikes, remove that index from
        % both arrays
        if isempty(find(spkLow == spkHigh(ii)))==0
            dataHigh(spkHigh(ii),i)=0;
            dataLow (spkHigh(ii),i)=0;
        end
    end
    % this might be unnecessary, but lets just be safe and do a pass over
    % the other variable
    for ii = 1:length(spkLow)
        % if there is overlap between two spikes, remove that index from
        % both arrays
        if isempty(find(spkHigh == spkLow(ii)))==0
            dataHigh(spkHigh(ii),i)=0;
            dataLow (spkHigh(ii),i)=0;
        end
    end    
end

                