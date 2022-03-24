%% moving window method
% compute mscohere
% determine phase lag
%{
    [Pxy,F] = cpsd(x,y,hamming(100),80,100,Fs);
    Pxy(Cxy < 0.2) = 0;
    plot(F,angle(Pxy)/pi)
%}

%% preperatory steps

% only perform what's below if you need to
if exist('targetRat')==0
    clear; clc; close all;
    
    % get directory that houses this code
    codeDir = getCurrentPath();
    addpath(codeDir)

    prompt = ['What is your rats name? '];
    targetRat = input(prompt,'s');

    prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
    confirm  = input(prompt,'s');

    if ~contains(confirm,[{'y'} {'Y'}])
        error('This code does not match the target rat')
    end

    disp(['Getting baseline data for ' targetRat])
    cd(['C:\Users\jstout\Desktop\Data 2 Move\',targetRat,'\step1-definingBaseline']);
    load('step1_baselineData')

    % interface with cheetah setup
    threshold.coh_duration = 0.5;
    [srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);    

    if srate > 2035 || srate < 2000
        error('Sampling rate is not correct')
    end
end

%% set these parameters to test
% this test's what lfp-extraction intervals are required by having the user
% manually adjust the extraction interval to test for failure rates
test_interval_requirement = 1; 
    plot_interval_requirements = 0; % this can only be set to 1 if above is 0 as it plots results of the user manually manipulating the extraction intervals
    
%% test method parameters
% step 1 --
if test_interval_requirement == 1
    
    prompt    = ['Enter a pause time (e.g. 0.1 for 0.1 seconds) '];
    pauseTime = str2num(input(prompt,'s'));    
    
    % 1) does it take progressively longer to extract data without clearing the
    % stream? 2) are there any failures? If so, how many?

    % this makes it so you can update pauseTime intervals
    if exist('saveInt_lfp1')==0 || exist('saveInt_lfp2')==0
        saveInt_lfp1 = []; saveInt_lfp2 = []; pauseTimeInt = [];
    end

    % clear stream   
    clearStream(LFP1name,LFP2name);

    success_lfp1 = []; success_lfp2 = []; time2extract = [];
    for i = 1:50

        tic;
        pause(pauseTime)
        try
            dataArray = []; timeStampArray = [];

            % pull data
            [succeeded, dataArray, timeStampArray, ~, ~, ...
            numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

            % using the success variable, we will directly test for failure
            % rate
            % 0 means the function failed
            success_lfp1(i) = succeeded(1);
            success_lfp2(i) = succeeded(2);        
        catch
            % NaN means something above failed
            success_lfp1(i) = NaN;
            success_lfp2(i) = NaN; 
        end
        % using the time2extract, we will directly test if it takes
        % progressively longer to pull in data as it accumulates
        time2extract(i) = toc;

        disp(['Iteration ',num2str(i)])
    end

    % make a scatter plot of successes - its a binary variable
    figure('color','w')
    subplot 211; hold on;
        scatter(1:length(success_lfp1),success_lfp1,'b','LineWidth',5);
        scatter(1:length(success_lfp2),success_lfp2,'r','Filled');  
        legend('LFP1','LFP2')
        ylabel('Success = 1, Failure = 0')
        xlabel([num2str(pauseTime) ' sec. intervals'])
        ylim([0 1])
        title('Acquiring real-time LFP data')
    subplot 212; hold on;
        pFail_lfp1 = numel(find(success_lfp1==0 | isnan(success_lfp1)==1))/length(success_lfp1);
        pFail_lfp2 = numel(find(success_lfp2==0 | isnan(success_lfp2)==1))/length(success_lfp2);
        b = bar(1,pFail_lfp1,'FaceColor','b');
        bar(2,pFail_lfp2,'FaceColor','r');
        ylim([0 1])
        ylabel('Probability of acquisition failure')
        legend('LFP1','LFP2')

    % cache data
    saveInt_lfp1 = [saveInt_lfp1 pFail_lfp1];
    saveInt_lfp2 = [saveInt_lfp2 pFail_lfp1];
    pauseTimeInt = [pauseTimeInt pauseTime];
    
    %save('data_acquisition_requirements')
end

if plot_interval_requirements == 1 && test_interval_requirement == 0
    load('data_acquisition_requirements');
    
    figure('color','w'); hold on;
    scatter(pauseTimeInt,saveInt_lfp1,'b','LineWidth',5);
    scatter(pauseTimeInt,saveInt_lfp2,'r','Filled');
    ylabel('probability of acquisition failure')
    xlabel('LFP acquisition interval (in sec.)')
    legend('LFP1','LFP2')
    title('Simultaneous extraction of two LFP across varying intervals')
end

%% But how long does it take to extract LFP data?
% step 2 ---
% using 0.25 sec intervals based on the data above, test how long it takes
% to extract LFP

% clear stream   
clearStream(LFP1name,LFP2name);
pauseTime = 0.25;
success_lfp1 = []; success_lfp2 = []; time2extract = [];
for i = 1:1000

    tic;
    pause(pauseTime)
    try
        dataArray = []; timeStampArray = [];

        % pull data
        [succeeded, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

        % using the success variable, we will directly test for failure
        % rate
        % 0 means the function failed
        success_lfp1(i) = succeeded(1);
        success_lfp2(i) = succeeded(2);        
    catch
        % NaN means something above failed
        success_lfp1(i) = NaN;
        success_lfp2(i) = NaN; 
    end
    % using the time2extract, we will directly test if it takes
    % progressively longer to pull in data as it accumulates
    time2extract(i) = toc;

    disp(['Iteration ',num2str(i)])
end

figure('color','w')
histogram(time2extract,'FaceColor','k')
ylabel('Iteration')
xlabel('Time (sec)')
box off

figure('color','w'); hold on;
pFail_lfp1 = numel(find(success_lfp1==0 | isnan(success_lfp1)==1))/length(success_lfp1);
pFail_lfp2 = numel(find(success_lfp2==0 | isnan(success_lfp2)==1))/length(success_lfp2);
b = bar(1,pFail_lfp1,'FaceColor','b');
bar(2,pFail_lfp2,'FaceColor','r');
ylim([0 1])
ylabel('Probability of acquisition failure (1000it)')
legend('LFP1','LFP2')
        
%% Extraction and coherence failures
% The analyses above indicate that 0.25 second intervals works with no failures
% I will use these results to perform a moving window approach
% morevoer, after 1000 iterations, we still retained a 0% failure 

% step 3 --

% test whether the amount of time in consideration matters for coherence

if test_timeONcoherence == 1
    close all
    
    prompt    = ['Enter a pause time (>=0.25) '];
    pauseTime = str2num(input(prompt,'s'));    
    
    % 1) does it take progressively longer to extract data without clearing the
    % stream? 2) are there any failures? If so, how many?

    % this makes it so you can update pauseTime intervals
    if exist('thetaPeak')==0 || exist('cohMag')==0
        thetaPeak = []; cohMag = []; pauseDur = [];
    end

    % moving window method parameters
    %pauseTime = 0.25; % seconds
    windowLength = 2; % seconds
    windowStep = (srate*pauseTime)+12; % 12 samples over almost always

    % clear stream   
    clearStream(LFP1name,LFP2name);
    success_lfp1 = []; success_lfp2 = []; time2extract = [];
    time2extract = [];
    data2use     = [];
    coh          = [];

    % define fpass
    fpass = [1:20];

    clearStream(LFP1name,LFP2name);
    success_lfp1 = []; success_lfp2 = []; time2extract = [];

    for i = 1:50

        tic;
        pause(pauseTime)
        try
            dataArray = []; timeStampArray = [];

            % pull data
            [succeeded, coh, f] = NlxComputeCoherence(LFP1name, LFP2name, fpass);  

            % store coherence data, f is always the same
            coh_store{i} = coh;

            % using the success variable, we will directly test for failure
            % rate
            % 0 means the function failed
            success_lfp1(i) = succeeded(1);
            success_lfp2(i) = succeeded(2);     

        catch
            % NaN means something above failed
            success_lfp1(i) = NaN;
            success_lfp2(i) = NaN; 
        end
        % using the time2extract, we will directly test if it takes
        % progressively longer to pull in data as it accumulates
        time2extract(i) = toc;

        disp(['Iteration ',num2str(i)])
    end
    cohAll = vertcat(coh_store{:});
    cohAvg = nanmean(cohAll);
    cohSer = stderr(cohAll,1);
    figure('color','w')
    shadedErrorBar(f,cohAvg,cohSer,'k',1)
    xlabel('Frequency')
    ylabel('Coherence')
    title(['Sampled at ',num2str(pauseTime), ' sec'])
    box off
    savefig(['fig_cohXf_at' num2str(pauseTime) 'sec.fig']);
    
    % store time
    pauseDur = [pauseDur pauseTime];

    % average theta
    fTheta = find(f > 4 & f < 12);
    cohMag = [cohMag nanmean(cohAvg(fTheta))];
    
    % peak freq    
    fTheta = find(f < 12);
    [~,fPeak] = max(cohAvg(fTheta));
    thetaPeak = [thetaPeak fPeak];
    
end
figure('color','w')
s = scatter(pauseDur,thetaPeak,'m','Filled','MarkerEdgeColor','k','LineWidth',1);
xlabel('Amount of data (sec)')
ylabel('Theta peak frequency (Hz) of coherence')

figure('color','w')
s = scatter(pauseDur,cohMag,'m','Filled','MarkerEdgeColor','k','LineWidth',1);
xlabel('Amount of data (sec)')
ylabel('Theta magnitude (4-12hz)')


%% Moving window
% cannot treat the data as if its discrete. The analyses above indicate
% that data can be extracted at 250ms resolution with 0 failures, but
% coherence must be performed on at least 1.25seconds of data as it grossly
% overestimates the theta coherence range

% define pauseTime as 250ms and windowDuration as 1.25 seconds
pauseTime      = 0.25;
windowDuration = 1.25;

% Need to approximate idealized window lengths and true window lengths
% clear stream   
clearStream(LFP1name,LFP2name);
pause(windowDuration)
[succeeded, dataArray, timeStampArray, ~, ~, ...
numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% choose numOver - because the code isn't zero lag, there is some timeloss.
% Account for it
windowLength  = srate*windowDuration;    
trueWinLength = length(dataArray);
timeLoss      = trueWinLength-windowLength;
windowStep    = (srate*pauseTime)+timeLoss;

% initialize some variables
success_lfp1 = []; success_lfp2 = []; time2extract = [];
time2extract = [];
data2use     = [];
coh          = [];
dataWin      = [];

% define fpass
fpass = [1:20];

% 1) get 1.25 seconds of data
% pull data
clearStream(LFP1name,LFP2name);
pause(windowDuration)
[succeeded, dataArray, timeStampArray, ~, ~, ...
numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% 2) store the data
% now add and remove data to move the window
dataWin = dataArray;
dataWinOG = dataWin; % store this for trouble shooting

% 3) pull in 0.25 seconds of data
% pull in data at shorter resolution   
pause(pauseTime)
[succeeded, dataArray, timeStampArray, ~, ~, ...
numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% 4) apply it to the initial array, remove what was there
dataWin(:,1:windowStep)=NaN;
dataWin = [dataWin dataArray];

% 5) plot results
figure('color','w'); hold on;
plot(dataWinOG(1,:),'r','LineWidth',2);
plot(dataWin(1,:),'b');
axis tight
legend('Signal og','Signal shifted by 250ms')

%% step 5 - real time moving window

% define pauseTime as 250ms and windowDuration as 1.25 seconds
pauseTime      = 0.25;
windowDuration = 1.25;

% Need to approximate idealized window lengths and true window lengths
% clear stream   
clearStream(LFP1name,LFP2name);
pause(windowDuration)
[succeeded, dataArray, timeStampArray, ~, ~, ...
numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% choose numOver - because the code isn't zero lag, there is some timeloss.
% Account for it
windowLength  = srate*windowDuration;    
trueWinLength = length(dataArray);
timeLoss      = trueWinLength-windowLength;
windowStep    = (srate*pauseTime)+timeLoss;

% initialize some variables
success_lfp1 = []; success_lfp2 = []; time2extract = [];
time2extract = [];
data2use     = [];
coh          = [];
dataWin      = [];

% Need to approximate idealized window lengths and true window lengths
% clear stream   
for i = 1:1000
    
    if i == 1
        clearStream(LFP1name,LFP2name);
        pause(windowDuration)
        [succeeded, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  
   
        % 2) store the data
        % now add and remove data to move the window
        dataWin = dataArray;
        dataWinOG = dataWin; % store this for trouble shooting
    end
    
    % 3) pull in 0.25 seconds of data
    % pull in data at shorter resolution
    pause(pauseTime)
    [succeeded, dataArray, timeStampArray, ~, ~, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

    % 4) apply it to the initial array, remove what was there
    dataWin(:,1:length(dataArray))=[]; % remove 560 samples
    dataWin = [dataWin dataArray]; % add data
    
    % calculate the amount of data actually pulled in
    actualDataDuration(i) = length(dataWin)/srate;
    
    disp(['Iteration ',num2str(i)])
end
figure('color','w')
scatter(1:length(actualDataDuration),actualDataDuration,'k','Filled')
ylabel('Moving window duration (sec)')
xlabel('Moving window iterations')
title('Consistency of moving window method')

%% step 6 -
% real time moving window with coherence detection

% define pauseTime as 250ms and windowDuration as 1.25 seconds
pauseTime      = 0.25;
windowDuration = 1.25;

dataArray = [];
% Need to approximate idealized window lengths and true window lengths
% clear stream   
clearStream(LFP1name,LFP2name);
pause(windowDuration)
[succeeded, dataArray, timeStampArray, ~, ~, ...
numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% choose numOver - because the code isn't zero lag, there is some timeloss.
% Account for it
windowLength  = srate*windowDuration;    
trueWinLength = length(dataArray);
timeLoss      = trueWinLength-windowLength;
windowStep    = (srate*pauseTime)+timeLoss;

% initialize some variables
success_lfp1 = []; success_lfp2 = []; time2extract = [];
time2extract = [];
data2use     = [];
coh          = [];
dataWin      = [];

% prep for coherence
srate = 2000; window = []; noverlap = []; fpass = [1:20];

actualDataDuration = [];
% Need to approximate idealized window lengths and true window lengths
% clear stream   
for i = 1:1000
    
    if i == 1
        clearStream(LFP1name,LFP2name);
        pause(windowDuration)
        [succeeded, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  
   
        % 2) store the data
        % now add and remove data to move the window
        dataWin = dataArray;
        dataWinOG = dataWin; % store this for trouble shooting
    end
    
    % 3) pull in 0.25 seconds of data
    % pull in data at shorter resolution   
    pause(pauseTime)
    tic;
    [succeeded, dataArray, timeStampArray, ~, ~, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

    % 4) apply it to the initial array, remove what was there
    dataWin(:,1:length(dataArray))=[]; % remove 560 samples
    dataWin = [dataWin dataArray]; % add data
    
    % calculate coherence
    [coh{i},f] = mscohere(dataWin(1,:),dataWin(2,:),window,noverlap,fpass,srate);

    % calculate the amount of data actually pulled in
    actualDataDuration(i) = length(dataWin)/srate;
    
    disp(['Iteration ',num2str(i)])
end
figure('color','w')
scatter(1:length(actualDataDuration),actualDataDuration,'k','Filled')
ylabel('Moving window duration (sec)')
xlabel('Moving window iterations')
title('Consistency of moving window method with coherence')

% test for average coherence distribution consistency - should see 8hz for
% 6-10hz
cohAll = []; cohAvg = []; cohSer = [];
cohAll = vertcat(coh{:});
cohAvg = nanmean(cohAll,1);
cohSer = stderr(cohAll,1);

figure('color','w')
shadedErrorBar(f,cohAvg,cohSer,'k',1)
xlabel('Frequency')
ylabel('Coherence')
title(['Moving Window Coherence (1.28sec w/ 250ms moving window) | 1k iterations'])
box off
savefig(['fig_cohXf_at' num2str(mean(actualDataDuration)) 'sec_step6.fig']);
    
% now estimate coherence in the 7-10hz range and test the stability across
% time
for i = 1:length(coh)
    thetaIdx = find(f>6 & f<11); % 7-10hz
    coh_theta(i) = nanmean(coh{i}(thetaIdx));
end
figure('color','w')
histogram(coh_theta)

data{1}    = coh_theta;
xRange     = [0:.05:1];
colors{1}  = 'k';
dataLabels = '21-34';
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);

%% step 7
% how long does it take to compute coherence and then send a command to the
% maze?

% -- maze setup -- %
% check port
if exist("s") == 0
    % connect to the serial port making an object
    s = serialport("COM6",19200);
end

% load in door functions
doorFuns = DoorActions;

% test reward wells
rewFuns = RewardActions;

% get IR information
irBreakNames = irBreakLabels;

% for arduino
if exist("a") == 0
    % connect arduino
    a = arduino('COM5','Uno','Libraries','Adafruit\MotorShieldV2');
end

% digital ports for reverse maze
irArduino.Delay       = 'D8';
irArduino.rGoalArm    = 'D10';
irArduino.lGoalArm    = 'D12';
irArduino.rGoalZone   = 'D7';
irArduino.lGoalZone   = 'D2';
irArduino.choicePoint = 'D6';

% -- real time coherence set up -- %
% real time moving window with coherence detection

% define pauseTime as 250ms and windowDuration as 1.25 seconds
pauseTime      = 0.25;
windowDuration = 1.25;

% Need to approximate idealized window lengths and true window lengths
% clear stream   
clearStream(LFP1name,LFP2name);
pause(windowDuration)
[succeeded, dataArray, timeStampArray, ~, ~, ...
numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% choose numOver - because the code isn't zero lag, there is some timeloss.
% Account for it
windowLength  = srate*windowDuration;    
trueWinLength = length(dataArray);
timeLoss      = trueWinLength-windowLength;
windowStep    = (srate*pauseTime)+timeLoss;

% initialize some variables
success_lfp1 = []; success_lfp2 = []; time2extract = [];
time2extract = [];
data2use     = [];
coh          = [];
dataWin      = [];
cohAvg_data  = [];
coh          = [];

% prep for coherence
srate = 2000; window = []; noverlap = []; 
fpass = [7:10];

actualDataDuration = [];
time2cohAndSend = [];
% Need to approximate idealized window lengths and true window lengths
% clear stream   
for i = 1:1000
    
    if i == 1
        clearStream(LFP1name,LFP2name);
        pause(windowDuration)
        [succeeded, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  
   
        % 2) store the data
        % now add and remove data to move the window
        dataWin = dataArray;
        dataWinOG = dataWin; % store this for trouble shooting
    end
    
    % 3) pull in 0.25 seconds of data
    % pull in data at shorter resolution   
    pause(pauseTime)
    [succeeded, dataArray, timeStampArray, ~, ~, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

    % 4) apply it to the initial array, remove what was there
    dataWin(:,1:length(dataArray))=[]; % remove 560 samples
    dataWin = [dataWin dataArray]; % add data
    
    % calculate coherence
    tic;
    [coh,f] = mscohere(dataWin(1,:),dataWin(2,:),window,noverlap,fpass,srate);
    cohAvg = nanmean(coh);
    
    if cohAvg > 0.6
        writeline(s,doorFuns.centralOpen)
        time2cohAndSend = [time2cohAndSend toc];
    elseif cohAvg < 1.5
        writeline(s,doorFuns.centralClose)
        time2cohAndSend = [time2cohAndSend toc];     
    end
    
    cohAvg_data = [cohAvg_data cohAvg];
        
    % calculate the amount of data actually pulled in
    actualDataDuration(i) = length(dataWin)/srate;
    
    disp(['Iteration ',num2str(i)])
end
figure('color','w')
boxplot(time2cohAndSend)
box off

figure('color','w')
histogram(time2cohAndSend)
box off
xlabel('Time (sec)')
ylabel('Iterations')
title('Calc. coher. and send door command')

figure('color','w')
scatter(1:length(actualDataDuration),actualDataDuration,'k','Filled')
ylabel('Moving window duration (sec)')
xlabel('Moving window iterations')
title('Consistency of moving window method with coherence')

data{1}    = cohAvg_data;
xRange     = [0:.05:1];
colors{1}  = 'k';
dataLabels = '21-12';
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
ylabel('Probability Density Function')
xlabel('Coherence')

%% step 8, estimate the duration of coherence
cohDiff = gradient(cohAvg_data);

figure('color','w')
subplot 211
    stem(cohAvg_data(1:500),'b','LineWidth',1)
    ylim([0 1])
    box off
    ylabel('Coherence')
    xlabel('Moving window iteration')
subplot 212;
    st = stem(cohDiff(1:100),'b','LineWidth',1)
    box off
    ylabel('d(coherence)')
    xlabel('Moving window iteration')
    title('Testing for change')
    
%% test for failures with detrend
% real time moving window with coherence detection

% define pauseTime as 250ms and windowDuration as 1.25 seconds
pauseTime      = 0.25;
windowDuration = 1.25;

% Need to approximate idealized window lengths and true window lengths
% clear stream   
clearStream(LFP1name,LFP2name);
pause(windowDuration)
[succeeded, dataArray, timeStampArray, ~, ~, ...
numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% choose numOver - because the code isn't zero lag, there is some timeloss.
% Account for it
windowLength  = srate*windowDuration;    
trueWinLength = length(dataArray);
timeLoss      = trueWinLength-windowLength;
windowStep    = (srate*pauseTime)+timeLoss;

% initialize some variables
success_lfp1 = []; success_lfp2 = []; time2extract = [];
time2extract = [];
data2use     = [];
coh          = [];
dataWin      = [];

% prep for coherence
srate = 2000; window = []; noverlap = []; fpass = [1:20];

actualDataDuration = [];
% Need to approximate idealized window lengths and true window lengths
% clear stream   
dataStore = cell([1 1000]);
for i = 1:1000
    
    if i == 1
        clearStream(LFP1name,LFP2name);
        pause(windowDuration)
        [succeeded, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  
   
        % 2) store the data
        % now add and remove data to move the window
        dataWin = dataArray;
        dataWinOG = dataWin; % store this for trouble shooting
    end
    
    % 3) pull in 0.25 seconds of data
    % pull in data at shorter resolution   
    pause(pauseTime)
    tic;
    [succeeded, dataArray, timeStampArray, ~, ~, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

    % 4) apply it to the initial array, remove what was there
    dataWin(:,1:length(dataArray))=[]; % remove 560 samples
    dataWin = [dataWin dataArray]; % add data
    
    % store it
    dataStore{i} = dataWin;
    
    % detrend
    dataDet(1,:) = detrend(dataWin(1,:),3);
    dataDet(2,:) = detrend(dataWin(2,:),3);
    
    % calculate coherence
    [coh{i},f] = mscohere(dataDet(1,:),dataDet(2,:),window,noverlap,fpass,srate);

    % calculate the amount of data actually pulled in
    actualDataDuration(i) = length(dataWin)/srate;
    
    outTime(i) = toc;
    disp(['Iteration ',num2str(i)])
end
figure('color','w')
scatter(1:length(actualDataDuration),actualDataDuration,'k','Filled')
ylabel('Moving window duration (sec)')
xlabel('Moving window iterations')
title('Consistency of moving window method with coherence')

% test for average coherence distribution consistency - should see 8hz for
% 6-10hz
cohAll = []; cohAvg = []; cohSer = [];
cohAll = vertcat(coh{:});
cohAvg = nanmean(cohAll,1);
cohSer = stderr(cohAll,1);

figure('color','w')
shadedErrorBar(f,cohAvg,cohSer,'k',1)
xlabel('Frequency')
ylabel('Coherence')
title(['Moving Window Coherence (1.28sec w/ 250ms moving window) | 1k iterations - 21-16'])
box off
savefig(['fig_cohXf_at' num2str(mean(actualDataDuration)) 'sec_wDetrend.fig']);
    
% now estimate coherence in the 7-10hz range and test the stability across
% time
for i = 1:length(coh)
    thetaIdx = find(f>5 & f<10);
    coh_theta(i) = nanmean(coh{i}(thetaIdx));
end
figure('color','w')
stem(coh_theta(1:200),'b','LineWidth',1)

figure('color','w')
histogram(coh_theta)

data{1}    = coh_theta;
xRange     = [0:.05:1];
colors{1}  = 'k';
dataLabels = '21-12';
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);

figure('color','w'); format long
boxplot(outTime,'symbol','')
ylim([0.023 .033])
ylabel('Sec')
title('Time to calculate extract data, detrend, calculate coherence')

%% now add artifact rejection
% define pauseTime as 250ms and windowDuration as 1.25 seconds
pauseTime      = 0.25;
windowDuration = 1.25;

% Need to approximate idealized window lengths and true window lengths
% clear stream   
clearStream(LFP1name,LFP2name);
pause(windowDuration)
[succeeded, dataArray, timeStampArray, ~, ~, ...
numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% choose numOver - because the code isn't zero lag, there is some timeloss.
% Account for it
windowLength  = srate*windowDuration;    
trueWinLength = length(dataArray);
timeLoss      = trueWinLength-windowLength;
windowStep    = (srate*pauseTime)+timeLoss;

% initialize some variables
success_lfp1 = []; success_lfp2 = []; time2extract = [];
time2extract = [];
data2use     = [];
coh          = [];
dataWin      = [];

% prep for coherence
srate = 2000; window = []; noverlap = []; fpass = [1:20];

% define a noise threshold in standard deviations
noiseThreshold = 4;

% define how much noise you're willing to accept
noisePercent = 5; % 5 percent

actualDataDuration = [];
% Need to approximate idealized window lengths and true window lengths
% clear stream   
dataStore = cell([1 1000]);
for i = 1:1000
    
    if i == 1
        clearStream(LFP1name,LFP2name);
        pause(windowDuration)
        [succeeded, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  
   
        % 2) store the data
        % now add and remove data to move the window
        dataWin = dataArray;
        dataWinOG = dataWin; % store this for trouble shooting
    end
    
    % 3) pull in 0.25 seconds of data
    % pull in data at shorter resolution   
    pause(pauseTime)
    tic;
    [succeeded, dataArray, timeStampArray, ~, ~, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

    % 4) apply it to the initial array, remove what was there
    dataWin(:,1:length(dataArray))=[]; % remove 560 samples
    dataWin = [dataWin dataArray]; % add data
    
    % store it
    dataStore{i} = dataWin;
    
    % detrend
    dataDet(1,:) = detrend(dataWin(1,:),3);
    dataDet(2,:) = detrend(dataWin(2,:),3);
    
    % determine if data is noisy
    zArtifact = [];
    zArtifact(1,:) = ((dataArray(1,:)-baselineMean(1))./baselineSTD(1));
    zArtifact(2,:) = ((dataArray(2,:)-baselineMean(2))./baselineSTD(2));

    idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
    percSat = (length(idxNoise)/length(zArtifact))*100;
    if percSat > noisePercent
        artifact(i) = 1;
        disp('Artifact Detected - coherence not calculated')     
    else
        % store data
        artifact(i) = 0;
    end    
    
    % calculate coherence
    [coh{i},f] = mscohere(dataDet(1,:),dataDet(2,:),window,noverlap,fpass,srate);

    % calculate the amount of data actually pulled in
    actualDataDuration(i) = length(dataWin)/srate;
    
    outTime(i) = toc;
    disp(['Iteration ',num2str(i)])
end
figure('color','w')
scatter(1:length(actualDataDuration),actualDataDuration,'k','Filled')
ylabel('Moving window duration (sec)')
xlabel('Moving window iterations')
title('Consistency of moving window method with coherence')

% test for average coherence distribution consistency - should see 8hz for
% 6-10hz
cohAll = []; cohAvg = []; cohSer = [];
cohAll = vertcat(coh{:});
cohAvg = nanmean(cohAll,1);
cohSer = stderr(cohAll,1);

figure('color','w')
shadedErrorBar(f,cohAvg,cohSer,'k',1)
xlabel('Frequency')
ylabel('Coherence')
title(['Moving Window Coherence (1.28sec w/ 250ms moving window) | 1k iterations - 21-16'])
box off
savefig(['fig_cohXf_at' num2str(mean(actualDataDuration)) 'sec_wDetrend.fig']);
    
% now estimate coherence in the 7-10hz range and test the stability across
% time
for i = 1:length(coh)
    thetaIdx = find(f>6 & f<12);
    coh_theta(i) = nanmean(coh{i}(thetaIdx));
end
figure('color','w')
stem(coh_theta(1:200),'b','LineWidth',1)

figure('color','w')
histogram(coh_theta)

data{1}    = coh_theta;
xRange     = [0:.05:1];
colors{1}  = 'k';
dataLabels = '21-12';
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);

figure('color','w'); format long
boxplot(outTime,'symbol','')
ylim([0.023 .033])
ylabel('Sec')
title('Time to: extract, detrend, reject, and coherence')
box off

figure('color','w')
pArtifact = numel(find(artifact == 1))/numel(artifact);
bar(1,pArtifact)
ylim([0 1])
title('probability of an artifact on 21-16')
box off


%% MASTER ROUND TRIP TESTER
clear; clc; close all;

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
confirm  = input(prompt,'s');

if ~contains(confirm,[{'y'} {'Y'}])
    error('This code does not match the target rat')
end

disp(['Getting baseline data for ' targetRat])
cd(['C:\Users\jstout\Desktop\Data 2 Move\',targetRat,'\step1-definingBaseline']);
load('step1_baselineData')

% interface with cheetah setup
threshold.coh_duration = 0.5;
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);    

if srate > 2035 || srate < 2000
    error('Sampling rate is not correct')
end
    
% -- maze setup -- %
% check port
if exist("s") == 0
    % connect to the serial port making an object
    s = serialport("COM6",19200);
end

% load in door functions
doorFuns = DoorActions;

% test reward wells
rewFuns = RewardActions;

% get IR information
irBreakNames = irBreakLabels;

% for arduino
if exist("a") == 0
    % connect arduino
    a = arduino('COM5','Uno','Libraries','Adafruit\MotorShieldV2');
end

% digital ports for reverse maze
irArduino.Delay       = 'D8';
irArduino.rGoalArm    = 'D10';
irArduino.lGoalArm    = 'D12';
irArduino.rGoalZone   = 'D7';
irArduino.lGoalZone   = 'D2';
irArduino.choicePoint = 'D6';

% choose one IR beam, set it up between the central door and make sure it
% works - in this case, I removed the rGoalArm beam, and set it up between
% the central door
%{
for i = 1:10000000
    readDigitalPin(a,irArduino.rGoalArm)
end
%}

% -- real time coherence set up -- %
% real time moving window with coherence detection

% define pauseTime as 250ms and windowDuration as 1.25 seconds
pauseTime      = 0.25;
windowDuration = 1.25;

% Need to approximate idealized window lengths and true window lengths
% clear stream   
clearStream(LFP1name,LFP2name);
pause(windowDuration)
[succeeded, dataArray, timeStampArray, ~, ~, ...
numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% choose numOver - because the code isn't zero lag, there is some timeloss.
% Account for it
windowLength  = srate*windowDuration;    
trueWinLength = length(dataArray);
timeLoss      = trueWinLength-windowLength;
windowStep    = (srate*pauseTime)+timeLoss;

% initialize some variables
success_lfp1 = []; success_lfp2 = []; time2extract = [];
time2extract = [];
data2use     = [];
coh          = [];
dataWin      = [];
cohAvg_data  = [];
coh          = [];

% prep for coherence
srate = 2000; window = []; noverlap = []; 
fpass = [6:10];

actualDataDuration = [];
time2cohAndSend = [];
time2coherence  = [];
% Need to approximate idealized window lengths and true window lengths
% clear stream 
roundTrip = []; time2coherence = []; timeFromCoherence = [];
noiseThreshold = 4; noisePercent = 1;
triggerTic = 2; % hardcode for first run
for i = 1:1000
        
    if i == 1
        clearStream(LFP1name,LFP2name);
        pause(windowDuration)
        [succeeded, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  
   
        % 2) store the data
        % now add and remove data to move the window
        dataWin = dataArray;
        dataWinOG = dataWin; % store this for trouble shooting
    end
    
    % 3) pull in 0.25 seconds of data
    % pull in data at shorter resolution   
    pause(pauseTime)
    tic;
    [succeeded, dataArray, timeStampArray, ~, ~, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

    % 4) apply it to the initial array, remove what was there
    dataWin(:,1:length(dataArray))=[]; % remove 560 samples
    dataWin = [dataWin dataArray]; % add data
    
    % detrend
    dataDet(1,:) = detrend(dataWin(1,:),3);
    dataDet(2,:) = detrend(dataWin(2,:),3);    

    % determine if data is noisy
    zArtifact = [];
    zArtifact(1,:) = ((dataDet(1,:)-baselineMean(1))./baselineSTD(1));
    zArtifact(2,:) = ((dataDet(2,:)-baselineMean(2))./baselineSTD(2));

    idxNoise = find(zArtifact(1,:) > noiseThreshold | zArtifact(1,:) < -1*noiseThreshold | zArtifact(2,:) > noiseThreshold | zArtifact(2,:) < -1*noiseThreshold );
    percSat = (length(idxNoise)/length(zArtifact))*100;
    if percSat > noisePercent
        artifact(i) = 1;
        disp(['Artifact Detected at ' num2str(percSat) '% saturation'])     
    else
        % store data
        artifact(i) = 0;
    end    

    % calculate coherence
    [coh,f] = mscohere(dataWin(1,:),dataWin(2,:),window,noverlap,fpass,srate);
    cohAvg = nanmean(coh);
    cohAvg_data = [cohAvg_data cohAvg];    
    
    % extract -> coherence
    time2coherence = [time2coherence toc];
    
    % calculate the amount of data actually pulled in
    actualDataDuration(i) = length(dataWin)/srate;
    
    disp(['Iteration', num2str(i)])

end

figure('color','w')
histogram(time2coherence)
box off

% Here, we are going to perform an automated procedure to determine the
% exact amount of time required for the door to open
% need to determine the exact time it takes for the door to completely open
format short
roundTrip = [];
pauseDur = 0; fail2detect = [];
for i = 1:1000

    % manipulate duration
    if i > 1
        if fail2detect(i-1) == 1
            pauseDur(i) = pauseDur(i-1)+0.010;
            disp(['Pause duration = ',num2str(pauseDur(i))])
        else
            pauseDur(i) = pauseDur(i-1);
        end
    end   
    writeline(s,doorFuns.centralOpen)        
    pause(pauseDur(i))
    if readDigitalPin(a,irArduino.rGoalArm) == 1 
        % only trigger every 1 sec
        disp('opened')
        % round trip, extract -> door open
        roundTrip = [roundTrip toc(timeStart)];
        % set indicator
        fail2detect(i) = 0;
    else
        fail2detect(i) = 1;
    end    
    writeline(s,doorFuns.centralClose)    
    pause(1);
    
    % once the score is tapered off, end the function
    if pauseDur(i) > 1
        break
    end
    disp(['Iteration ',num2str(i)])
end

figure('color','w')
scatter(1:length(fail2detect),fail2detect)
scatter(pauseDur,fail2detect)

figure('color','w')
histogram(roundTrip)

data{1}    = roundTrip;
xRange     = [0:.05:0.7];
colors{1}  = 'k';
dataLabels = '21-12';
distType   = 'normal';
[y,a] = plotCurves(data,xRange,colors,dataLabels,distType);

figure('color','w'); format long
boxplot(roundTrip,'symbol','')
%ylim([0.023 .033])
ylabel('Sec')
title('Round trip time')
box off

%% the results of these analyses indicate the following:
%{
1) Data must be pulled in at a rate of 250ms. No less, but can always be
more.
2) Data can be successfully pulled in at a rate of ~6ms
3) Coherence should not be calculated on data less than 1.25seconds. If
they do, it should be made aware that it grossly overestimates theta. It's
not clear if theres a point in which this breaks down.
4) 
