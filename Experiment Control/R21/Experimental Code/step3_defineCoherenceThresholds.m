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
cd(['C:\Users\jstout\Desktop\Data 2 Move\',targetRat,'\step1-definingBaseline']);
load('step1_baselineData')

% interface with cheetah setup
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);    

if srate > 2035 || srate < 2000
    error('Sampling rate is not correct')
end

% location of data
dataStored = ['C:\Users\jstout\Desktop\Data 2 Move\',targetRat,'\step2-definingCoherence'];
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
plotFig = 0;
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

            % if data isn't sampled perfectly, skip
            if length(dataArray) ~= 1024
                attempt = 0;
                coh = [coh NaN];
            else 
                attempt = 1;
            end        
            %attempt = 1;
        catch
            % if data can't be sampled, skip
            coh = [coh NaN];
        end
    end

    % --- if everything above is good, move on! --- %
    
    % detrend
    data_det = [];
    data_det(1,:) = detrend(dataArray(1,:)); 
    data_det(2,:) = detrend(dataArray(2,:)); 
    %disp('Real-time data detrended...')

    % test for artifact by normalizing the data against its baseline
    % distribution metrics
    zArtifact = [];
    zArtifact(1,:) = ((data_det(1,:)-baselineMean(1))./baselineSTD(1));
    zArtifact(2,:) = ((data_det(2,:)-baselineMean(2))./baselineSTD(2));

    % noise = >4std from mean. If the data has >1% saturation, don't
    % include
    noiseThreshold = 4;
    idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
    percSat = (length(idxNoise)/length(zArtifact))*100;
    if percSat > 1
        detect_temp = [];
        detect_temp = 1;
        detected = [detected detect_temp]; % add nan to know this was ignored
        coh  = [coh NaN];
        disp('Artifact Detected - coherence not calculated')
        
        %{
        fig2 = figure(2); fig2.Color = 'w';
        subplot 211;
        title('Artifact data')
        plot(zArtifact(1,:));
        subplot 212;
        plot(zArtifact(2,:));
        %pause;
        %close;
        %}
        
    else   
        % frequencies
        fpass = [6:12];
        window = []; noverlap = [];
        % initialize
        coh_temp = [];
        % coherence
        [coh_temp,fcoh] = mscohere(data_det(1,:),data_det(2,:),window,noverlap,fpass,srate);
        % store
        coh  = [coh nanmean(coh_temp)]; % add nan to know this was ignored 
        %xVar = [xVar i];
        disp('Artifact not detected - coherence calculated')
        detect_temp = [];
        detect_temp = 0;
        detected    = [detected detect_temp]; % add nan to know this was ignored

    
        if plotFig == 1
            fig = figure(1); hold on; box off
            fig.Color = 'w';
            %subplot 311;  plot(dataArray(1,:),'b'); title('HPC')
            %subplot 312;  plot(dataArray(2,:),'r'); title('PFC')
            %subplot 313;
            stem(coh,'k','LineWidth',2)
            ylim([0 1]);
            %xlim([0 1])

            xlimits = xlim;
            %{
            l = line([xlimits(1) xlimits(2)],[.7 .7]);
            l.Color = [0 .5 0];
            l.LineStyle = '--';
            l.LineWidth = 1; 
            l2 = line([xlimits(1) xlimits(2)],[.3 .3]);
            l2.Color = 'r';
            l2.LineStyle = '--';
            l2.LineWidth = 1; 
            %}
            ylabel('Coherence')
            xlabel('Interval (0.5 sec)')
            %pause();
            %disp('Press Any Key To Continue')
        end
    end

    disp([num2str(5-toc(tStart)/60) ' minutes remaining'])


    if toc(tStart)/60 > 5
        next = 1;
        disp('THE END...')

    end
    
end


%% generate distribution of coherence estimates
% define high and low coherence
figure('color','w')
h1 = histogram(coh);
h1.FaceColor = [.6 .6 .6];
box off
ylabel('Frequency')
xlabel('Coherence Magnitude')

% -- high and low coherence -- %
high = prctile(coh,75);
low  = prctile(coh,25);

% figure stuff
ylimits = ylim;
xlimits = xlim;
l1 = line([high high], [ylimits(1) ylimits(2)]);
l1.Color = 'b';
l1.LineWidth = 2;
l1.LineStyle = '--';
l2 = line([low low], [ylimits(1) ylimits(2)]);
l2.Color = 'r';
l2.LineWidth = 2;
l2.LineStyle = '--';

%%
figure;
plot(coh)

%% saving data
dataStored = ['C:\Users\jstout\Desktop\Data 2 Move\',targetRat,'\step3-definingCoherenceThresholds'];
mkdir(dataStored) % make folder
cd(dataStored)

% cd to rat specific folder and save your data
cd(dataStored)
%save(['CoherenceDistribution2' targetRat])
save(['CoherenceDistribution' targetRat])

%% find number repeats of > .7 and < .3 plot distributions - each repeat
% reflects a 0.5 sec interval of data

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
