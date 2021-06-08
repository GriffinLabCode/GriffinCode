%% prep 1 - clear history, workspace, get working directory
% _____________________________________________________

% --- MAKE SURE YOU RUN STARTUP_EXPERIMENTCONTROL --- %

%______________________________________________________

%% BUG
% sometimes if the session is not exceeding the time limit of 30 minutes,
% then the code will continue performing trials, but not save the data.
% Cheetah will save the tracking tho

%%


% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

% DA task that incorporates coherence detection
% must have the matlab pipeline Startup run and startup_experimentControl
targetRat = '21-1';

%% confirm this is the correct code
prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
confirm  = input(prompt,'s');

if ~contains(confirm,[{'y'} {'Y'}])
    error('This code does not match the target rat')
end

%% add path to rat place - note that things are blinded, so don't open code
addpath('X:\01.Experiments\R21\Experimenter Blinding - SUHYEONG ONLY')
cd('X:\01.Experiments\R21\Experimenter Blinding - SUHYEONG ONLY');
place2store = getCurrentPath();
addpath(place2store)

%% baseline
try
    % location of data
    dataStored = ['C:\Users\jstout\Desktop\Data 2 Move\' targetRat];
    cd(dataStored)
    % name of rat
    ratID = strsplit(targetRat,'-');
    dataLoad = ['baselineData_', ratID{1},'_',ratID{2}];
    load(dataLoad)
    disp('Loaded baseline data')
catch
    disp('Getting baseline data')
    % this may not have to be run each day
    [baselineMean,baselineSTD] = baselineDetection(LFP1name,LFP2name,srate,10);
    % location of data
    dataStored = ['C:\Users\jstout\Desktop\Data 2 Move\' targetRat];
    cd(dataStored)
    save(dataLoad,'baselineMean','baselineSTD')
end


%% threshold definition
threshLoad = ['CoherenceDistribution',targetRat];
cd(dataStored)
baselineCohData = load(threshLoad,'coh','LFP1name','LFP2name');
threshold.high_coherence_magnitude = prctile(baselineCohData.coh,75);
threshold.low_coherence_magnitude  = prctile(baselineCohData.coh,25);
threshold.coh_duration             = 0.5; % this is not true

%% LFP names

LFP1name = baselineCohData.LFP1name;  % HPC
LFP2name = baselineCohData.LFP2name; % PFC

%% prep 2 - define parameters for the session

% how long should the session be?
session_length = 30; % minutes

delay_length = 30; % seconds
numTrials    = 40;
pellet_count = 1;
timeout_len  = 60*15;

% define a looping time - this is in minutes
amountOfTime = (70/60); %session_length; % 0.84 is 50/60secs, to account for initial pause of 10sec .25; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

% chronux parameters
params = getCustomParams;
params.fpass  = [4 12]; % needs to be 0 20 - note that coherence detection uses 4-12
params.tapers = [3 5]; % bset to [3 5] as default

%% prep 3 - connect with cheetah
% set up function
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);

%% experiment design prep.

% define number of trials
numTrials  = 21;

% randomize trials such that first 12 are high/low and second 12 are yoked
% controls
redo = 1;
while redo == 1
    high  = repmat('H',[(numTrials-1)/4 1]);
    low   = repmat('L',[(numTrials-1)/4 1]);
    both  = [high; low];
    both_shuffled = both;
    for i = 1:1000
        % notice how it rewrites the both_shuffled variable
        both_shuffled = both_shuffled(randperm(numel(both_shuffled)));
    end
    trialType_exp = cellstr(both_shuffled);

    % no more than 3 turns in one direction
    idxH = double(contains(trialType_exp,'H'));
    idxL = double(contains(trialType_exp,'L'));

    for i = 1:length(trialType_exp)-3
        if idxH(i) == 1 && idxH(i+1) == 1 && idxH(i+2) == 1 && idxH(i+3)==1
            redo = 1;
            break        
        elseif idxL(i) == 1 && idxL(i+1) == 1 && idxL(i+2) == 1 && idxL(i+3)==1
            redo = 1;
            break        
        else
            redo = 0;
        end
    end
end

% do the same for control trials
%{
redo = 1;
while redo == 1
    high  = repmat('CH',[(numTrials-1)/4 1]);
    low   = repmat('CL',[(numTrials-1)/4 1]);
    both  = [high; low];
    both_shuffled = both;
    for i = 1:1000
        % notice how it rewrites the both_shuffled variable
        both_shuffled = both_shuffled(randperm(size(both_shuffled,1)),:);
    end
    trialType_con = cellstr(both_shuffled);

    % no more than 3 turns in one direction
    idxH = double(contains(trialType_con,'CH'));
    idxL = double(contains(trialType_con,'CL'));

    for i = 1:length(trialType_con)-3
        if idxH(i) == 1 && idxH(i+1) == 1 && idxH(i+2) == 1 && idxH(i+3)==1
            redo = 1;
            break        
        elseif idxL(i) == 1 && idxL(i+1) == 1 && idxL(i+2) == 1 && idxL(i+3)==1
            redo = 1;
            break        
        else
            redo = 0;
        end
    end
end
%}

% control trials
control  = cellstr(repmat('C',[(numTrials-1)/2 1]));

% define the first 12 as experimental, second 12 as control
trialType = [];
trialType = [trialType_exp;control];

%% auto maze prep.

% -- automaze set up -- %

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
irArduino.Treadmill = 'D9';
irArduino.rGoal     = 'D10';
irArduino.lGoal     = 'D11';

%{
for i = 1:10000000
    readDigitalPin(a,irArduino.lGoal)
end
%}

% get treadmill
[treadFuns,treadSpeed] = TreadMillFuns;

% load treadmill functions and settings
[treadFuns,treadSpeeds] = TreadMillFuns;
targetSpeed = 8;
speedVector = 4:2:targetSpeed;

%% coherence detection prep.

% define sampling rate
params.Fs     = srate;

% define number of samples that correspond to the amount of data in time
numSamples2use = threshold.coh_duration*srate;

% define for loop - 70 total sec
looper = ceil((amountOfTime*60/threshold.coh_duration)); %ceil((amountOfTime*60)/threshold.coh_duration); % N minutes * 60sec/1min * (1 loop is about .250 ms of data)

% define total loop time
total_loop_time = threshold.coh_duration*60; % in seconds

%% clean the stored data just in case IR beams were broken
s.Timeout = 1; % 1 second timeout
next = 0; % set while loop variable
while next == 0
   irTemp = read(s,4,"uint8"); % look for stored data
   if isempty(irTemp) == 1     % if there are no stored ir beam breaks
       next = 1;               % break out of the while loop
       disp('IR record empty - ignore the warning')
   else
       disp('IR record not empty')
       disp(irTemp)
   end
end

% close all maze doors - this gives problems with solenoid box
pause(0.25)
writeline(s,[doorFuns.centralClose doorFuns.sbLeftClose ...
    doorFuns.sbRightClose doorFuns.tLeftClose doorFuns.tRightClose]);

pause(0.25)
writeline(s,[doorFuns.gzLeftClose doorFuns.gzRightClose])

% reward dispensers need about 3 seconds to release pellets
for rewardi = 1:pellet_count
    writeline(s,rewFuns.right)
    pause(4)
    writeline(s,rewFuns.left)
    pause(4)
end

%% treadmill testing

%{
% belt length = 31.25inch = 79.375
beltLength = 79; % cm
numRev = 14; % set to speed of 10
timeRev = 1; % 1 second
convTreadSpeed = beltLength*numRev/timeRev
%}


%% start recording - make a noise when recording begins
[succeeded, reply] = NlxSendCommand('-StartRecording');
load gong.mat;
sound(y);
pause(5)

%% trials
open_t  = [doorFuns.tLeftOpen doorFuns.tRightOpen];
close_t = [doorFuns.tLeftClose doorFuns.tRightClose];
maze_prep = [doorFuns.sbLeftOpen doorFuns.sbRightOpen ...
    doorFuns.tRightClose doorFuns.tLeftClose doorFuns.centralOpen ...
    doorFuns.gzLeftClose doorFuns.gzRightClose];

% mark session start
sStart = [];
sStart = tic;
sessEnd = 0;
while toc(sStart)/60 < session_length || sessEnd == 0
    c = clock;
    session_start = str2num(strcat(num2str(c(4)),num2str(c(5))));
    session_time  = session_start-session_start; % quick definitio of this so it starts the while loop
    for triali = 1:numTrials
        
        % start out with this as a way to make sure you don't exceed 30
        % minutes of the session
        if triali == numTrials || toc(sStart)/60 > session_length
            writeline(s,doorFuns.closeAll)
            sessEnd = 1;            
            break % break out of for loop
        end        

        % set central door timeout value
        s.Timeout = timeout_len; % 5 minutes before matlab stops looking for an IR break    

        % first trial - set up the maze doors appropriately
        pause(0.25);
        writeline(s,maze_prep)
        
        % if not the first trial, track how long the delay was
        if triali > 1 && isempty(tStart)==0
            delay_duration_master(triali) = toc(tStart);
            if contains(trialType(triali),[{'H'} {'L'}])
                delay_duration_manipulate(triali) = delay_duration_master(triali); % a variable used to manipulate the control
            end
        end
        
        % set irTemp to empty matrix
        irTemp = []; 

        % central beam
        % while loop so that we continuously read the IR beam breaks
        next = 0;
        while next == 0
            %irTemp = read(s,4,"uint8");                    % look for IR beam breaks
            if readDigitalPin(a,irArduino.Treadmill) == 0   % if central beam is broken
                % neuralynx timestamp command

                % neuralynx timestamp command
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "choicePoint" 102 2');       

                % close door
                %writeline(s,doorFuns.centralClose) % close the door behind the rat
                next = 1;                          % break out of the loop
            end
        end

        % t-beam
        % check which direction the rat turns at the T-junction
        next = 0;
        while next == 0
            irTemp = [];
            irTemp = read(s,4,"uint8");         
            if irTemp == irBreakNames.sbRight  
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tRightBeam" 222 2');                                    

                % track the trajectory_text
                trajectory_text{triali} = 'R';
                trajectory(triali)      = 0;

                % close opposite door
                writeline(s,[doorFuns.sbRightClose]) 
                pause(.25)
                writeline(s,doorFuns.sbLeftClose);

                if readDigitalPin(a,irArduino.rGoal)==0
                    pause(0.25)
                    writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen]);
                    pause(0.25)
                    writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen]);
                end

                % break while loop
                next = 1;

            elseif irTemp == irBreakNames.sbLeft
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tLeftBeam" 212 2');

                % track the trajectory_text
                trajectory_text{triali} = 'L';
                trajectory(triali)      = 1;            

                % close opposite door
                writeline(s,[doorFuns.sbRightClose]) 
                pause(.25)
                writeline(s,doorFuns.sbLeftClose);

                if readDigitalPin(a,irArduino.lGoal)==0
                    pause(0.25)
                    writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen]);
                    pause(0.25)
                    writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen]);
                end

                % break out of while loop
                next = 1;
            end
        end      
                
        % return arm
        next = 0;
        while next == 0
            irTemp = read(s,4,"uint8");         
            if irTemp == irBreakNames.tRight 
                % send neuralynx command for timestamp
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzRightBeam" 422 2');             

                % close both for audio symmetry
                pause(0.25)
                writeline(s,doorFuns.gzLeftClose)
                pause(0.25)
                writeline(s,doorFuns.gzRightClose)
                
                next = 1;                          
            elseif irTemp == irBreakNames.tLeft
                % send neuralynx command for timestamp
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzLeftBeam" 412 2');

                % close both for audio symmetry
                pause(0.25)
                writeline(s,doorFuns.gzLeftClose)
                pause(0.25)
                writeline(s,doorFuns.gzRightClose)
                pause(0.25)

                next = 1;
            end
        end      

        % startbox
        next = 0;
        while next == 0
            s.Timeout = timeout_len;
            irTemp = read(s,4,"uint8");  
            if irTemp == irBreakNames.central
                next = 1;
            end
        end
        
        next = 0;
        while next == 0
            if readDigitalPin(a,irArduino.Treadmill)==0
                writeline(s,[doorFuns.tLeftClose doorFuns.tRightClose])
                pause(0.25)
                writeline(s,[doorFuns.tLeftClose doorFuns.tRightClose])
                
                % Reward zone and eating
                % send to netcom 
                if triali > 1 && trajectory_text{triali} == 'R' && trajectory_text{triali-1} == 'L'
                    % reward dispensers need about 3 seconds to release pellets
                    for rewardi = 1:pellet_count
                        writeline(s,rewFuns.left)
                        pause(3)
                    end
                elseif triali > 1 && trajectory_text{triali} == 'L' && trajectory_text{triali-1} == 'R'
                    % reward dispensers need about 3 seconds to release pellets
                    for rewardi = 1:pellet_count
                        writeline(s,rewFuns.right)
                        pause(3)
                    end
                end    

                % begin treadmill
                write(maze,treadFuns.start,'uint8');

                % increase tread speed gradually
                for i = speedVector
                    % set treadmill speed
                    write(maze,uint8(speed_cell{i}'),'uint8'); % add a second command in case the machine missed the first one
                end                

                % coherence detection
                total_window = 10; % total amount of time allowed for coherence to be detected
                tStart = [];
                tStart = tic; % required for timing the coherence detection

                % ---- COHERENCE METHODS START HERE ---- %
                if contains(trialType(triali),[{'H'} {'L'}])
                    disp('Estimating Coherence...')                    
                    while (toc(tStart) < total_elapsed) && openDoor == 0

                        % if a total seconds have passed, open up doors
                        if toc(tStart) > total_elapsed && openDoor == 0
                            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
                            coh_met  = 0;
                            openDoor = 1;
                        end

                        % sometimes, we error out (a sampling issue on neuralynx's end)
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
                                % store this for later
                                coh = [coh NaN];
                            end
                        end

                        % detrend data - did not clean to improve processing speed
                        data_det = [];
                        data_det(1,:) = locdetrend(dataArray(1,:),params.Fs); 
                        data_det(2,:) = locdetrend(dataArray(2,:),params.Fs); 

                        % store data for later
                        data_out  = [data_out data_det];
                        times_out = [times_out timeStampArray];

                        % detect artifacts
                        idxNoise = []; zArtifact = [];
                        [idxNoise,zArtifact] = artifactDetect(data_det,baselineMean,baselineSTD);

                        % calculate coherence based on whether artifacts are present
                        if isempty(idxNoise) ~= 1
                            coh = [coh NaN]; % add nan to know this was ignored
                            continue
                            disp('scratch detected - coherence not calculated')
                        else     
                            coh_temp = [];
                            %coh_temp = coherencyc(data_det(1,:),data_det(2,:),params); 
                            [coh_temp,~,~,S1,S2,f] = coherencyc(data_det(1,:),data_det(2,:),params); 
                            coh = [coh nanmean(coh_temp)]; % add nan to know this was ignored

                        end

                        % amount of data in consideration
                        timings = [timings length(dataArray)/srate];

                        % store timestamp array to check later
                        timeStamps = [timeStamps size(timeStampArray,2)]; % size(x,2) bc we want columns (tells you how many samples occured per sample)

                        % convert time
                        %timeConv = [timeCov timeStamps*.5];

                        % first, if coherence magnitude is met, do whats below
                        if contains(threshold_type,'HIGH')
                            if isempty(find(coh > coherence_threshold))==0 % < bc this is low coh

                                %disp('High Coherence Threshold Met')

                                % sustained coherence
                                if length(coh) > 1
                                    if isnan(coh(end)) == 0 && isnan(coh(end-1)) == 0
                                        if coh(end) > coherence_threshold && coh(end-1) > coherence_threshold
                                            % open the door
                                            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);
                                            coh_met  = 1;
                                            openDoor = 1;      
                                        end
                                    end
                                end

                                % if your timer has elapsed > some preset time, open the startbox door
                                if toc(tStart) > total_elapsed && openDoor == 0
                                    writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
                                    coh_met  = 0;
                                    openDoor = 1;            
                                end

                            % otherwise, erase these variables, resetting the coherence
                            % magnitude and duration counters
                            else

                                % if your timer has elapsed > some preset time, open the startbox door
                                if toc(tStart) > total_elapsed && openDoor == 0
                                    writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
                                    coh_met  = 0;                
                                    openDoor = 1;            
                                end

                            end
                        elseif contains(threshold_type,'LOW')
                            % first, if coherence magnitude is met, do whats below
                            if isempty(find(coh < coherence_threshold))==0 % < bc this is low coh

                                %disp('Low Coherence Threshold Met')

                                % sustained coherence\
                                if length(coh) > 1
                                    if isnan(coh(end)) == 0 && isnan(coh(end-1)) == 0 % if both coh of interest are real
                                        if coh(end) < coherence_threshold && coh(end-1) < coherence_threshold
                                            % open the door
                                            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);
                                            coh_met  = 1;
                                            openDoor = 1;      
                                        end
                                    end
                                end         
                                %{
                                % open the door
                                writeline(s,[doorFuns.centralOpen doorFuns.tLeftOpen doorFuns.tRightOpen]);
                                coh_met  = 1;            
                                openDoor = 1;
                                %}

                                % if your timer has elapsed > some preset time, open the startbox door
                                if toc(tStart) > total_elapsed && openDoor == 0
                                    writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
                                    coh_met  = 0;                
                                    openDoor = 1;
                                end

                            % otherwise, erase these variables, resetting the coherence
                            % magnitude and duration counters
                            else

                                % if your timer has elapsed > some preset time, open the startbox door
                                if toc(tStart) > total_elapsed && openDoor == 0
                                    writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
                                    coh_met  = 0;                
                                    openDoor = 1;                
                                end

                            end 
                        else
                            error('Something is wrong...')
                        end

                    end
                elseif contains(trialType(triali),{'C'}) % control high/ control low
                    disp('Yoking Up... lol')
                    % define your control trials
                    conTrials = ((numTrials-1)/2)+1:numTrials;

                    % randomly select one of any non-nan values
                    nonNanVals = [];
                    nonNanVals = find(isnan(delay_duration_manipulate)==0);
                    
                    % pause for the corresponding duration and mark the
                    % trial according to whether its a yoked high or yoked
                    % low
                    trialMatch = randsample(nonNanVals,1);
                    yokedContr(triali) = [trialType{triali} trialType{trialMatch}];
                    
                    % pause
                    pause(delay_duration_manipulate(trialMatch))
                    
                end
                % stop treadmill
                pause(0.25)
                writeline(s,treadFuns.stop)

                % break out of while loop and continue maze
                next = 1;
            end
        end

        if triali == numTrials || toc(sStart)/60 > session_length
            writeline(s,doorFuns.closeAll)
            sessEnd = 1;            
            break % break out of for loop
        end
    end 
    
end

% get amount of time past since session start
c = clock;
session_time_update = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time = session_time_update-session_start;

% compute accuracy array
accuracy = [];
accuracy_text = cell(1, length(trajectory_text)-1);
for triali = 1:length(trajectory_text)-1
    if trajectory_text{triali} ~= trajectory_text{triali+1}
        accuracy(triali) = 0; % correct trial
        accuracy_text{triali} = 'correct';
    elseif trajectory_text{triali} == trajectory_text{triali+1}
        accuracy(triali) = 1; % incorrect trial
        accuracy_text{triali} = 'incorrect';
    end
end

%% ending noise - a fitting song to end the session
load handel.mat;
sound(y, 2*Fs);
writeline(s,[doorFuns.centralClose])

%% save data
% save data
c = clock;
c_save = strcat(num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(1)),'_','EndTime',num2str(c(4)),num2str(c(5)));

prompt   = 'Please enter the rats name ';
rat_name = input(prompt,'s');

prompt   = 'Please enter the task ';
task_name = input(prompt,'s');

%prompt   = 'Enter the directory to save the data ';
%dir_name = input(prompt,'s');

save_var = strcat(rat_name,'_',task_name,'_',c_save);

place2store = getCurrentPath();

cd(place2store);
save(save_var);



