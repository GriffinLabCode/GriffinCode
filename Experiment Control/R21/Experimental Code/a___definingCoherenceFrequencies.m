%% STEP 2)

%%
clear;

prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
confirm  = input(prompt,'s');

if ~contains(confirm,[{'y'} {'Y'}])
    error('This code does not match the target rat')
end

%% load rat specific data
threshold.coh_duration = 0.5;

disp(['Getting baseline data for ' targetRat])

% interface with user
prompt   = 'Enter LFP1 name (HPC) ';
LFP1name = input(prompt,'s');
prompt   = 'Enter LFP2 name (PFC) ';
LFP2name = input(prompt,'s'); 

% interface with cheetah setup
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);    

if srate > 2035 || srate < 2000
    error('Sampling rate is not correct')
end

% location of data
dataStored = ['C:\Users\jstout\Desktop\Data 2 Move\',targetRat,'\step1-definingCoherence'];
mkdir(dataStored) % make folder
cd(dataStored)

%% run code
% initialize
coh      = [];
detected = [];
xVar     = [];

% use tic toc to store timing for yoked control
tStart = [];
tStart = tic;

next = 0;
while next == 0
attempt = 0;
while attempt == 0
    try

        % clear stream   
        clearStream(LFP1name,LFP2name);

        % pause 0.5 sec
        pause(0.5);

        % pull data
        [~, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

        attempt = 1;
    catch
        coh = [coh NaN];
    end
end

%{
% filtering and detrending takes too long. 
coherence isn't below .
% notch filter
filtLFP = [];
filtLFP(1,:) = notchfilt(dataArray(1,:),srate);
filtLFP(2,:) = notchfilt(dataArray(2,:),srate);

% detrend
data_det = [];
data_det(1,:) = detrend(filtLFP(1,:)); 
data_det(2,:) = detrend(filtLFP(2,:)); 
%disp('Real-time data detrended...')
%}

% test for artifact
zArtifact = [];
zArtifact(1,:) = ((dataArray(1,:)-baselineMean(1))./baselineSTD(1));
zArtifact(2,:) = ((dataArray(2,:)-baselineMean(2))./baselineSTD(2));

noiseThreshold = 4;
idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
if isempty(idxNoise) ~= 1
    detect_temp = [];
    detect_temp = 1;
    detected = [detected detect_temp]; % add nan to know this was ignored
    disp('Artifact Detected - coherence not calculated')
    %{
    figure(2); 
    subplot 211;
    plot(zArtifact(1,:));
    subplot 212;
    plot(zArtifact(2,:));
    pause;
    close;
    %}
else   
    % frequencies
    fpass = [4:12];
    window = []; noverlap = [];
    % initialize
    coh_temp = [];
    % coherence
    [coh_temp,fcoh] = mscohere(data_det(1,:),data_det(2,:),window,noverlap,fpass,srate);
    % store
    coh  = [coh;coh_temp]; % add nan to know this was ignored 
    %xVar = [xVar i];
    disp('Artifact not detected - coherence calculated')
    detect_temp = [];
    detect_temp = 0;
    detected    = [detected detect_temp]; % add nan to know this was ignored
    
%{
    fig = figure(1); hold on; box off
    fig.Color = 'w';
    subplot 311;  plot(dataArray(1,:),'b'); title('HPC')
    subplot 312;  plot(dataArray(2,:),'r'); title('PFC')
    subplot 313;
    stem(coh,'k','LineWidth',2)
    ylim([0 1]);
    %xlim([0 1])
    xlimits = xlim;
    l = line([xlimits(1) xlimits(2)],[.7 .7]);
    l.Color = [0 .5 0];
    l.LineStyle = '--';
    l.LineWidth = 1; 
    l2 = line([xlimits(1) xlimits(2)],[.3 .3]);
    l2.Color = 'r';
    l2.LineStyle = '--';
    l2.LineWidth = 1; 
    ylabel('Coherence')
    xlabel('Interval (0.5 sec)')
    pause();
    disp('Press Any Key To Continue')
    %}
end
    
disp([num2str(5-toc(tStart)/60) ' minutes remaining'])


if toc(tStart)/60 > 5
    next = 1;
    disp('THE END...')
    
end
    
end



figure('color','w')
h1 = histogram(coh)
h1.FaceColor = [.6 .6 .6]
box off
ylabel('Frequency')
xlabel('Coherence Magnitude')
high = prctile(coh,75);
low  = prctile(coh,25);
ylimits = ylim;
xlimits = xlim;
l1 = line([high high], [ylimits(1) ylimits(2)]);
l1.Color = 'b'
l1.LineWidth = 2;
l1.LineStyle = '--'
l2 = line([low low], [ylimits(1) ylimits(2)]);
l2.Color = 'r'
l2.LineWidth = 2;
l2.LineStyle = '--'

%% saving data
% cd to rat specific folder and save your data
cd(dataStored)
%save(['CoherenceDistribution2' targetRat])
save(['CoherenceDistribution' targetRat])

%% find number repeats of > .7 and < .3 plot distributions - each repeat
% reflects a 0.5 sec interval of data

%{
clear;
threshold_hist_max = 0.7;
threshold_hist_min = 0.3;

coh_sustained=[];

%0.5sec
c05 = length(coh(coh>threshold_hist_max));
nc05 = length(coh(coh<threshold_hist_min));
coh_sustained(1)=c05;
ncoh_sustained(1)=nc05;

%1sec thru 5sec - coherence
for i=1:length(coh)
    %1s
    if coh(i)>threshold_hist_max && coh(i+1)>threshold_hist_max
        c1(i) = coh(i);
    else
        c1(i) = NaN;
    end

    %1.5s 
    if coh(i)>threshold_hist_max && coh(i+1)>threshold_hist_max && coh(i+2)>threshold_hist_max
        c15(i) = coh(i);
    else
        c15(i) = NaN;
    end
    
    %2s 
    if coh(i)>threshold_hist_max && coh(i+1)>threshold_hist_max && coh(i+2)>threshold_hist_max ...
            && coh(i+3)>threshold_hist_max
        c2(i) = coh(i);
    else
        c2(i) = NaN;
    end

    %2.5s
    if coh(i)>threshold_hist_max && coh(i+1)>threshold_hist_max && coh(i+2)>threshold_hist_max ...
            && coh(i+3)>threshold_hist_max && coh(i+4)>threshold_hist_max
        c25(i) = coh(i);
    else
        c25(i) = NaN;
    end

    %3s
    if coh(i)>threshold_hist_max && coh(i+1)>threshold_hist_max && coh(i+2)>threshold_hist_max ...
            && coh(i+3)>threshold_hist_max && coh(i+4)>threshold_hist_max && coh(i+5)>threshold_hist_max
        c3(i) = coh(i);
    else
        c3(i) = NaN;
    end
    
    %3.5s
    if coh(i)>threshold_hist_max && coh(i+1)>threshold_hist_max && coh(i+2)>threshold_hist_max ...
            && coh(i+3)>threshold_hist_max && coh(i+4)>threshold_hist_max && coh(i+5)>threshold_hist_max ...
            && coh(i+6)>threshold_hist_max
        c35(i) = coh(i);
    else
        c35(i) = NaN;
    end
    
    %4s
    if coh(i)>threshold_hist_max && coh(i+1)>threshold_hist_max && coh(i+2)>threshold_hist_max ...
            && coh(i+3)>threshold_hist_max && coh(i+4)>threshold_hist_max && coh(i+5)>threshold_hist_max ...
            && coh(i+6)>threshold_hist_max && coh(i+7)>threshold_hist_max 

        c4(i) = coh(i);
        
    else
        c4(i) = NaN;
    end
    
    %4.5s
    if coh(i)>threshold_hist_max && coh(i+1)>threshold_hist_max && coh(i+2)>threshold_hist_max ...
        && coh(i+3)>threshold_hist_max && coh(i+4)>threshold_hist_max && coh(i+5)>threshold_hist_max ...
        && coh(i+6)>threshold_hist_max && coh(i+7)>threshold_hist_max && coh(i+8)>threshold_hist_max 

        c45(i) = coh(i);
    else
        c45(i) = NaN;
    end
    
    %5s
    if coh(i)>threshold_hist_max && coh(i+1)>threshold_hist_max && coh(i+2)>threshold_hist_max ...
        && coh(i+3)>threshold_hist_max && coh(i+4)>threshold_hist_max && coh(i+5)>threshold_hist_max ...
        && coh(i+6)>threshold_hist_max && coh(i+7)>threshold_hist_max && coh(i+8)>threshold_hist_max ...
        && coh(i+9)>threshold_hist_max 

        c5(i) = coh(i);
        
    else
        c5(i) = NaN;
    end
    
end

%1sec thru 5sec - noncoherence
for i=1:length(coh)
    %1s
    if coh(i)<threshold_hist_min && coh(i+1)<threshold_hist_min 
        nc1(i) = coh(i);
    else
        nc1(i)=NaN;
    end
    

    %1.5s 
    if coh(i)<threshold_hist_min && coh(i+1)<threshold_hist_min && coh(i+2)<threshold_hist_min ...
        nc15(i) = coh(i);
    else
        nc15(i)=NaN;
    end
    
    
    %2s 
    if coh(i)<threshold_hist_min && coh(i+1)<threshold_hist_min && coh(i+2)<threshold_hist_min ...
        && coh(i+3)
    
        nc2(i) = coh(i);
    else
        nc2(i)=NaN;
    end
    

    %2.5s
    if coh(i)<threshold_hist_min && coh(i+1)<threshold_hist_min && coh(i+2)<threshold_hist_min ...
        && coh(i+3)<threshold_hist_min && coh(i+4)<threshold_hist_min 
    
        nc25(i) = coh(i);
    else
        nc25(i)=NaN;
    end
    

    %3s
    if coh(i)<threshold_hist_min && coh(i+1)<threshold_hist_min && coh(i+2)<threshold_hist_min ...
        && coh(i+3)<threshold_hist_min && coh(i+4)<threshold_hist_min && coh(i+5)<threshold_hist_min
       
        nc3(i) = coh(i);
    else
        nc3(i)=NaN;
    end
    
    
    %3.5s
    if coh(i)<threshold_hist_min && coh(i+1)<threshold_hist_min && coh(i+2)<threshold_hist_min ...
        && coh(i+3)<threshold_hist_min && coh(i+4)<threshold_hist_min && coh(i+5)<threshold_hist_min ...
        && coh(i+6)<threshold_hist_min
    
        nc35(i) = coh(i);
    else
        nc35(i)=NaN;
    end
    
    
    %4s
    if coh(i)<threshold_hist_min && coh(i+1)<threshold_hist_min && coh(i+2)<threshold_hist_min ...
        && coh(i+3)<threshold_hist_min && coh(i+4)<threshold_hist_min && coh(i+5)<threshold_hist_min ...
        && coh(i+6)<threshold_hist_min && coh(i+7)<threshold_hist_min

        nc4(i) = coh(i);
    else
        nc4(i)=NaN;
    end
    
    %4.5s
    if coh(i)<threshold_hist_min && coh(i+1)<threshold_hist_min && coh(i+2)<threshold_hist_min ...
        && coh(i+3)<threshold_hist_min && coh(i+4)<threshold_hist_min && coh(i+5)<threshold_hist_min ...
        && coh(i+6)<threshold_hist_min && coh(i+7)<threshold_hist_min && coh(i+8)<threshold_hist_min

        nc45(i) = coh(i);
    else
        nc45(i)=NaN;
    end
    
    %5s
    if coh(i)<threshold_hist_min && coh(i+1)<threshold_hist_min && coh(i+2)<threshold_hist_min ...
        && coh(i+3)<threshold_hist_min && coh(i+4)<threshold_hist_min && coh(i+5)<threshold_hist_min ...
        && coh(i+6)<threshold_hist_min && coh(i+7)<threshold_hist_min && coh(i+8)<threshold_hist_min ...
        && coh(i+9)<threshold_hist_min 

        nc5(i) = coh(i);
    else
        nc5(i)=NaN;
    end
    
end

coh_sustained(2)=numel(c1(~isnan(c1)));
coh_sustained(3)=numel(c1(~isnan(c15)));
coh_sustained(4)=numel(c1(~isnan(c2)));
coh_sustained(5)=numel(c1(~isnan(c25)));
coh_sustained(6)=numel(c1(~isnan(c3)));
coh_sustained(7)=numel(c1(~isnan(c35)));
coh_sustained(8)=numel(c1(~isnan(c4)));
coh_sustained(9)=numel(c1(~isnan(c45)));
coh_sustained(10)=numel(c1(~isnan(c5)));

ncoh_sustained(2)=numel(c1(~isnan(nc1)));
ncoh_sustained(3)=numel(c1(~isnan(nc15)));
ncoh_sustained(4)=numel(c1(~isnan(nc2)));
ncoh_sustained(5)=numel(c1(~isnan(nc25)));
ncoh_sustained(6)=numel(c1(~isnan(nc3)));
ncoh_sustained(7)=numel(c1(~isnan(nc35)));
ncoh_sustained(8)=numel(c1(~isnan(nc4)));
ncoh_sustained(9)=numel(c1(~isnan(nc45)));
ncoh_sustained(10)=numel(c1(~isnan(nc5)));

numX=numel(coh_sustained)/2;
x=0.5:0.5:numX;
allIt = sum(coh_sustained);
figure('color','w'); box off
%histogram(coh_sustained,6)
bar(x,coh_sustained./allIt)
ylabel('Frequency')
xlabel('Coherence sustained for (secs)')

figure('color','w'); 
allIt = sum(coh_sustained);
bar(x,ncoh_sustained./allIt)
ylabel('Frequency')
xlabel('Low Cohence sustained for (secs)')
%}
% -- checks out -- %
idxHigh = coh > high;
idxLow  = coh < low;

% half sec
high05 = numel(find(idxHigh == 1));
low05 = numel(find(idxLow == 1));

% get one sec - fix low coh
idxHigh = double(idxHigh);
idxLow  = double(idxLow);
idxHigh(idxHigh == 0) = NaN; % al 0 to nan
idxHigh = diff(idxHigh); % nan-0 = nan 1-nan = nan 0-1 = nan 1-1 = 0 all 1s are repeats, so now all 0s reflect repeats
idxLow(idxLow == 0) = NaN; % al 0 to nan
idxLow = diff(idxLow); % nan-0 = nan 1-nan = nan 0-1 = nan 1-1 = 0 all 1s are repeats, so now all 0s reflect repeats

idxHigh(idxHigh == 0) = 1;
idxLow(idxLow == 0) = 1;
high1 = numel(find(idxHigh == 1));
low1  = numel(find(idxLow == 1));

% 1.5 sec
idxHigh(isnan(idxHigh))=0;
idxLow(isnan(idxLow))=0;

idxHigh = double(idxHigh);
idxLow  = double(idxLow);
idxHigh(idxHigh == 0) = NaN; % al 0 to nan
idxHigh = diff(idxHigh); % nan-0 = nan 1-nan = nan 0-1 = nan 1-1 = 0 all 1s are repeats, so now all 0s reflect repeats
idxLow(idxLow == 0) = NaN; % al 0 to nan
idxLow = diff(idxLow); % nan-0 = nan 1-nan = nan 0-1 = nan 1-1 = 0 all 1s are repeats, so now all 0s reflect repeats

idxHigh(idxHigh == 0) = 1;
idxLow(idxLow == 0) = 1;
high15 = numel(find(idxHigh == 1));
low15  = numel(find(idxLow == 1));

coh_high = [high05 high1 high15]
coh_low  = [low05 low1 low15]

allIt = length(coh);
figure('color','w');
x = 0.5:0.5:1.5
%histogram(coh_sustained,6)
bar(x,coh_high./sum(coh_high))
ylabel('Prop. of high events')
xlabel('High coherence sustained for (secs)')
box off
ylim([0 1])

figure('color','w');
x = 0.5:0.5:1.5
%histogram(coh_sustained,6)
bar(x,coh_low./sum(coh_low))
ylabel('Prop. of low events')
xlabel('Low coherence sustained for (secs)')
box off
ylim([0 1])
