%% Coherence in moving window
% --> See SCRIPT_coherenceSpikes from Libraries > Example code usage
%
% this code extracts high/low coherence states based on some thresholded
% data and returns matrices with spikes belonging entirely to high
% coherence or low coherence states.
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
% dataMed: matrix of input data containing spikes only belonging to non high
%           nor low coh states
% dataCat: matrix of input data restructured. Note that this will be
%                   slightly shorter than your input data due to moving
%                   window
%
% written by John Stout
    
function [dataHigh,dataLow,dataMed,dataCat] = getCoherenceSpikes(data,cohInd,signalInd,cohThresholds,srate,spkIdx,plotfig,deltaThresh,artifactMean,artifactSTD)
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
        dataAll{n} = datawin_og';
        if ctheta > cohThresholds(1) && ctheta > cdelta % this should be high
            datahigh{n} = datawin';
        elseif ctheta < cohThresholds(2) && ctheta > cdelta
            datalow{n} = datawin';
        else
            dataex{n} = datawin';
        end        
    else
        dataAll{n} = datawin_og';
        if ctheta > cohThresholds(1) % this should be high
            datahigh{n} = datawin';
        elseif ctheta < cohThresholds(2)
            datalow{n} = datawin';
        else
            dataex{n} = datawin';
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
            % shit data goes to the ex var
            dataex{n} = datawin';
            % in case anything was set, remove that data
            datalow{n}  = [];
            datahigh{n} = [];
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

% restructure variables 
for i = 1:length(dataAll)
    if isempty(datahigh{i})==0
        dataAll{2,i}='high';
    elseif isempty(datalow{i})==0
        dataAll{2,i}='low';
    elseif isempty(dataex{i})==0
        dataAll{2,i}='med';
    end
end

% prep some matrices and define the as dataAll, we will then remove spikes
% that do not belong
dataHigh = []; dataLow = []; dataMed = [];
dataHigh = dataAll(1,:); dataLow = dataAll(1,:); dataMed = dataAll(1,:);
for i = 1:length(dataAll)
    % if this is a high coh epoch, remove spikes from dataMed and dataLow
    if contains(dataAll(2,i),'high')
        %disp([num2str(i)])
        %pause;
        % no high spikes in med or low epochs
        %dataMed{i}(spkIdx,:)=zeros([size(dataMed{i}(spkIdx,:))]);
        %dataLow{i}(spkIdx,:)=zeros([size(dataLow{i}(spkIdx,:))]);
        dataMed{i}(:,:)=zeros([size(dataMed{i}(:,:))]);
        dataLow{i}(:,:)=zeros([size(dataLow{i}(:,:))]);
        
        %pause;
    elseif contains(dataAll(2,i),'low')
        % no low spikes in med or high epochs
        %dataMed{i}(spkIdx,:)=zeros([size(dataMed{i}(spkIdx,:))]);
        %dataHigh{i}(spkIdx,:)=zeros([size(dataHigh{i}(spkIdx,:))]);   
        dataMed{i}(:,:)=zeros([size(dataMed{i}(:,:))]);
        dataHigh{i}(:,:)=zeros([size(dataHigh{i}(:,:))]);   
    
    elseif contains(dataAll(2,i),'med')
        % no med spikes in low or high coh epochs
        %dataLow{i}(spkIdx,:)=zeros([size(dataLow{i}(spkIdx,:))]);
        %dataHigh{i}(spkIdx,:)=zeros([size(dataHigh{i}(spkIdx,:))]);         
        dataLow{i}(:,:)=zeros([size(dataLow{i}(:,:))]);
        dataHigh{i}(:,:)=zeros([size(dataHigh{i}(:,:))]);         
    
    end
end
  
% dataAll reflects the raw signal. Note that this will be slightly shorter
% than your input due to moving window
dataCat = horzcat(dataAll{1,:});
[~,idx] = unique(dataCat(4,:));
dataCat = dataCat(:,idx);
 
% do the same for high and low coh events
dataHigh = horzcat(dataHigh{1,:});
dataHigh = dataHigh(:,idx);
dataLow  = horzcat(dataLow{1,:});
dataLow  = dataLow(:,idx);
dataMed  = horzcat(dataMed{1,:});
dataMed  = dataMed(:,idx);

% sanity check - making sure that the signals subtract out to zero across
% all variables so that we know all data is identical
if numel((dataLow(1,:)-dataHigh(1,:))==0) ~= numel((dataLow(1,:)-dataMed(1,:))==0) || numel((dataMed(1,:)-dataCat(1,:))==0) ~= numel((dataLow(1,:)-dataMed(1,:))==0)
   error('array outputs are incorrect')
end

% checks out
%{
    figure('color','w')
    plot(dataCat(1,1:20000),'r','LineWidth',2)
    hold on; plot(data(1:20000,1),'b')

    figure('color','w'); hold on;
    %plot(dataCat(1,1:20000),'r','LineWidth',2)
    plot(dataHigh(1,1:20000),'b','LineWidth',2)
    plot(dataLow(1,1:20000),'r','LineWidth',1.5)
    plot(dataMed(1,1:20000),'k','LineWidth',.5)

%}

    
    
                