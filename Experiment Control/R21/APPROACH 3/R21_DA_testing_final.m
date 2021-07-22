 %% prep 1 - clear history, workspace, get working directory
% _____________________________________________________

% --- MAKE SURE YOU RUN STARTUP_EXPERIMENTCONTROL --- %

%______________________________________________________

%% BUG
% sometimes if the session is not exceeding the time limit of 30 minutes,
% then the code will continue performing trials, but not save the data.
% Cheetah w%%

% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

% DA task that incorporates coherence detection
% must have the matlab pipeline Startup run and startup_experimentControl
%targetRat = '21-5';

%% confirm this is the correct code
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');
prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
confirm  = input(prompt,'s');

if ~contains(confirm,[{'y'} {'Y'}])
    error('This code does not match the target rat')
end

%% Load in rat-specific threshold and data

% location of data
%dataStored = ['C:\Users\jstout\Desktop\Data 2 Move\' targetRat];
dataStored = 'C:\Users\jstout\Desktop\Data 2 Move\APPROACH 3\Rat Specific Inputs';
cd(dataStored)
% name of rat
ratID = strsplit(targetRat,'-');
dataLoad = ['baselineData_', ratID{1},'_',ratID{2}];
load(dataLoad)
disp(['Loaded baseline data for ' targetRat])

%% interface with user to appropriately test rat on the blinded session
prompt   = ['Is this the experimental or control session? '];
sessType = input(prompt,'s');

prompt  = 'What day of testing is this? ';
testDay = input(prompt,'s');

% pull in appropriately randomized and blind sessions
cd(dataStored)
load(['blindedSessionTypes_' targetRat])

% define the type of blinded session based on the testing day
experimentalType = blindedSessions(str2num(testDay));
clear blindedSessions % clear it out so the experimenter doesn't accidentally see it

% load in data or define a place to store data depending on the session
if contains(sessType,[{'experimental'} {'Experimental'} {'E'} {'e'}])
    
    place2store = ['C:\Users\jstout\Desktop\Data 2 Move\APPROACH 3\' targetRat '\Testing Updated\Day ' testDay '\Experimental'];

elseif contains(sessType,[{'control'} {'Control'} {'C'} {'c'}])
    
    place2load  = ['C:\Users\jstout\Desktop\Data 2 Move\APPROACH 3\' targetRat '\Testing Updated\Day ' testDay '\Experimental'];
    place2store = ['C:\Users\jstout\Desktop\Data 2 Move\APPROACH 3\' targetRat '\Testing Updated\Day ' testDay '\Yoked'];

    % load in delays to yoke from
    cd(place2load);
    load([targetRat,'_experimentalData_Day' testDay '.mat'],'delay_duration_manipulate','delay_duration_master')

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
session_length = 20; % minutes

% minimum and maximum times for the delay
min_delay = 5;
max_delay = 20; % total amount of time allowed for coherence to be detected

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
rng('shuffle') % set to random

% block style randomization. This is to account for the case where rats are
% getting tired on the second half, and therefore could perform worse.
% first 4 trials are experimental randomized, second 4 are control. This
% also allows for cases where the rat is having a bad day. We can try to
% squeeze out 8 or 16 trials as it is better than having no data, or losing
% the last control trials (last 10 - old method).
trialType = [];
if contains(sessType,[{'experimental'} {'Experimental'} {'E'} {'e'}])
    % define number of trials - add 1 to the number of trials bc first DA
    % trajectory doesnt count for anything
    numTrials = 12;
    numTrials = numTrials+1;

    if contains(experimentalType,'H')
        trialType = cellstr(repmat('H',[(numTrials-1) 1]));
    elseif contains(experimentalType,'L')
        trialType = cellstr(repmat('L',[(numTrials-1) 1]));
    end
elseif contains(sessType,[{'control'} {'Control'} {'C'} {'c'}])
    
    % define number of trials based on trial 'hits'
    numTrials  = length(delay_duration_manipulate)+1;

    trialType = cellstr(repmat('C',[(numTrials) 1]));
end            

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
irArduino.rGoalArm  = 'D10';
irArduino.lGoalArm  = 'D12';
irArduino.rGoalZone = 'D7';
irArduino.lGoalZone = 'D2';

%{
for i = 1:10000000
    readDigitalPin(a,irArduino.Treadmill)
end
%}


%% treadmill setup
% get treadmill
[treadFuns,treadSpeed] = TreadMillFuns;

% load treadmill functions and settings
[treadFuns,treadSpeeds] = TreadMillFuns;
targetSpeed = 10;
speedVector = 4:2:targetSpeed;

% make an empty array
speed_cell = cell(size(fieldnames(treadSpeeds),1)+1,1);

% fill the first cell with nan because there is no 1mpm rate
speed_cell{1} = NaN;

% make an array where its row index is the speed
speed_cell(2:end) = struct2cell(treadSpeeds);

speedVector = [1 3 5 7];

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

% storage variables
coherence_met  = [];
coherence_data = [];
trajectory_text = [];
trajectory = [];

% mark session start
sStart = [];
sStart = tic;
sessEnd = 0;

% clocker
c = clock;
session_start = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time  = session_start-session_start; % quick definitio of this so it starts the while loop
writeline(s,doorFuns.centralOpen);

% a repeat method to repeat experimental trials
repeat = 0;
resetLoop = 0; % set to zero as a default for circular methods

% set looper and prepare more variables
trajectory_text = []; trajectory = []; 
if contains(sessType,[{'experimental'} {'Experimental'} {'E'} {'e'}])
    delay_duration_master = []; delay_duration_notMet = []; delay_duration_manipulate = [];
    data_clean = []; data_dirty = []; times_clean = []; times_dirty = [];
    delay_durations = [];
else contains(sessType,[{'control'} {'Control'} {'C'} {'c'}])
    yokedDelay = [];
end

looper = 1:numTrials; % - this will get updated as we go
while repeat == 0
    
    % reset looper
    if resetLoop == 1
        disp(['Resetting for loop counter - current trial is ' num2str(triali) ', an ' trialType{triali} ' condition'])
        looper = triali:numTrials;
        %trialTypeHist = [trialTypeHist; trialType{triali}];
        resetLoop = 0; % default back to 0
    end
    
    for triali = looper

        % start out with this as a way to make sure you don't exceed 30
        % minutes of the session
        if toc(sStart)/60 > session_length
            writeline(s,doorFuns.closeAll)
            repeat = 1;           
            break % break out of for loop
        end      

        % set central door timeout value
        s.Timeout = timeout_len; % 5 minutes before matlab stops looking for an IR break    

        % first trial - set up the maze doors appropriately
        pause(0.25);
        if triali == 1
            
            writeline(s,maze_prep)
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');   
            
        elseif resetLoop == 1
            
            % open doors and stop treadmill
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]) 
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');
            pause(0.25)
            write(s,treadFuns.stop,'uint8'); 
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayEnd" 601 2');
            
        end
        

        % set irTemp to empty matrix
        irTemp = []; 

        % central beam
        % while loop so that we continuously read the IR beam breaks
        %{
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
  %}
        % t-beam
        % check which direction the rat turns at the T-junction
        next = 0;
        while next == 0       
            if readDigitalPin(a,irArduino.rGoalArm)==0
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tRightBeam" 222 2');                                    

                % track the trajectory_text
                trajectory_text = [trajectory_text; 'R'];
                trajectory      = [trajectory 0];

                pause(0.25)
                writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);
                pause(0.25)
                writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);

                % break while loop
                next = 1;

            elseif readDigitalPin(a,irArduino.lGoalArm)==0
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tLeftBeam" 212 2');

                % track the trajectory_text
                trajectory_text = [trajectory_text; 'L'];
                trajectory      = [trajectory 1];           

                pause(0.25)
                writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tRightClose doorFuns.tLeftOpen]);
                pause(0.25)
                writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tRightClose doorFuns.tLeftOpen]);

                % break out of while loop
                next = 1;
            end
        end    

        % Reward zone and eating
        % send to netcom 
        if numel(trajectory_text) == 1 && trajectory_text(end) == 'R' 
            for rewardi = 1:pellet_count
                %pause(0.25)
                writeline(s,rewFuns.right)
                %pause(0.25)
            end
        elseif numel(trajectory_text) == 1 && trajectory_text(end) == 'L'
            for rewardi = 1:pellet_count
                %pause(0.25)
                writeline(s,rewFuns.left)
                %pause(3)
            end        
        elseif numel(trajectory_text) > 1 && trajectory_text(end) == 'R' && trajectory_text(end-1) == 'L'
            % reward dispensers need about 3 seconds to release pellets
            for rewardi = 1:pellet_count
                %pause(0.25)
                writeline(s,rewFuns.right)
                %pause(3)
            end
        elseif numel(trajectory_text) > 1 && trajectory_text(end) == 'L' && trajectory_text(end-1) == 'R'
            % reward dispensers need about 3 seconds to release pellets
            for rewardi = 1:pellet_count
                %pause(0.25)
                writeline(s,rewFuns.left)
                %pause(3)
            end
        end    

        % return arm
        next = 0;
        while next == 0
            %irTemp = read(s,4,"uint8");  

            if readDigitalPin(a,irArduino.lGoalZone)==0
                % send neuralynx command for timestamp
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzRightBeam" 422 2');             

                % close both for audio symmetry
                pause(0.25)
                writeline(s,[doorFuns.gzLeftClose])
                pause(0.25)
                writeline(s,[doorFuns.gzRightClose])

                next = 1;                          
            elseif readDigitalPin(a,irArduino.rGoalZone)==0
                % send neuralynx command for timestamp
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzLeftBeam" 412 2');

                % close both for audio symmetry
                pause(0.25)
                writeline(s,[doorFuns.gzLeftClose])
                pause(0.25)
                writeline(s,[doorFuns.gzRightClose])

                next = 1;
            end

        end      

        % startbox beam
        next = 0;
        while next == 0
            s.Timeout = timeout_len;
            irTemp = read(s,4,"uint8");  
            if irTemp == irBreakNames.central
                next = 1;
            end
        end

        % treadmill and coherence stuff
        next = 0;
        while next == 0
            if readDigitalPin(a,irArduino.Treadmill)==0
                writeline(s,[doorFuns.tLeftClose doorFuns.tRightClose])
                pause(0.25)
                writeline(s,[doorFuns.tLeftClose doorFuns.tRightClose])    

                % session end
                if triali == numTrials || toc(sStart)/60 > session_length
                    next = 1;
                    writeline(s,doorFuns.closeAll)
                    repeat = 1; % end          
                    break
                end

                % begin treadmill
                write(s,treadFuns.start,'uint8');

                % increase tread speed gradually
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayStart" 600 2');                
                for i = speedVector
                    % set treadmill speed
                    write(s,uint8(speed_cell{i}'),'uint8'); % add a second command in case the machine missed the first one
                    pause(0.5)
                end       

                % pause for a minimum of 5 seconds
                pause(min_delay);

                % coherence detection
                tStart = [];
                tStart = tic; % required for timing the coherence detection

                % initialize
                timeStamps = []; timeConv  = [];
                coh_met    = []; coh_store = [];
                dur_met    = []; dur_sum   = []; 
                coh_temp   = []; 

                % VERY IMPORTANT
                coh = []; timings = []; timeStamps = []; data_out = []; times_out = [];                

                if contains(trialType(triali),[{'H'} {'L'}])

                    % interface with user
                    disp('Estimating Coherence...')   

                    % set this to 0 for the while loop
                    openDoor = 0; 

                    % while you are within the alloted time window and so
                    % long as the door is closed (openDoor = 0)
                    while openDoor == 0

                        % if a total seconds have passed, open up doors
                        if toc(tStart) > max_delay && openDoor == 0

                            % report for troubleshooting
                            disp('Ran out of time - coherence threshold not met')

                            % stop treadmill
                            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
                            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');
                            pause(0.25)
                            write(s,treadFuns.stop,'uint8'); 
                            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayEnd" 601 2');          

                            % if not the first trial, track how long the delay was
                            delay_duration_notMet = [delay_duration_notMet toc(tStart)];   
                            
                            % master keeper
                            delay_durations = [delay_durations toc(tStart)];                            

                            % assign to 0 for not met, and open the
                            % door by setting openDoor to 1
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
                            
                            % store data for later
                            data_dirty  = [data_dirty data_det];
                            times_dirty = [times_dirty timeStampArray];
                    
                            coh = [coh NaN]; % add nan to know this was ignored
                            continue
                            disp('scratch detected - coherence not calculated')
                        else     
                            
                            % store data for later
                            data_clean  = [data_clean data_det];
                            times_clean = [times_clean timeStampArray];
                    
                            coh_temp = [];
                            %coh_temp = coherencyc(data_det(1,:),data_det(2,:),params); 
                            [coh_temp,~,~,S1,S2,f] = coherencyc(data_det(1,:),data_det(2,:),params); 
                            coh = [coh nanmean(coh_temp)]; % add nan to know this was ignored

                        end

                        % amount of data in consideration
                        timings = [timings length(dataArray)/srate];

                        % store timestamp array to check later
                        timeStamps = [timeStamps size(timeStampArray,2)]; % size(x,2) bc we want columns (tells you how many samples occured per sample)

                        % first, if coherence magnitude is met, do whats below
                        if contains(trialType(triali),'H')

                            % set coherence threshold to empty, then define
                            % it to the high setting based on your rats
                            % data
                            coherence_threshold = [];
                            coherence_threshold = threshold.high_coherence_magnitude;

                            % if you are able to find instances where
                            % coherence is greater than your threshold (ie
                            % the variable is not empty)
                            if isempty(find(coh > coherence_threshold))==0 % < bc this is low coh

                                %disp('High Coherence Threshold Met')

                                % sustained coherence
                                if length(coh) > 1
                                    if isnan(coh(end)) == 0 && isnan(coh(end-1)) == 0
                                        if coh(end) > coherence_threshold && coh(end-1) > coherence_threshold
                                            % report for troubleshooting
                                            % purposes
                                            disp('High Coherence Threshold Met')

                                            % open the door, then stop the
                                            % treadmill
                                            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
                                            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');
                                            pause(0.25)
                                            write(s,treadFuns.stop,'uint8');
                                            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayEnd" 601 2');

                                            % track how long the delay was
                                            delay_duration_master = [delay_duration_master toc(tStart)];
                                    
                                            % master keeper
                                            delay_durations = [delay_durations toc(tStart)];
                                            
                                            % assign these variables to 1
                                            coh_met  = 1;
                                            openDoor = 1;      
                                        end
                                    end
                                end

                                % if your timer has elapsed > some preset time, open the startbox door
                                if toc(tStart) > max_delay && openDoor == 0
                                    % report for troubleshooting
                                    disp('High Coherence Threshold Not Met')

                                    % stop treadmill
                                    writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
                                    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');
                                    pause(0.25)
                                    write(s,treadFuns.stop,'uint8');
                                    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayEnd" 601 2');

                                    % if not the first trial, track how long the delay was
                                    delay_duration_notMet = [delay_duration_notMet toc(tStart)];                               

                                    % master keeper
                                    delay_durations = [delay_durations toc(tStart)];                                    
                                    
                                    % assign to 0 for not met, and open the
                                    % door by setting openDoor to 1
                                    coh_met  = 0;
                                    openDoor = 1;            
                                end

                            % otherwise, erase these variables, resetting the coherence
                            % magnitude and duration counters
                            else

                                % if your timer has elapsed > some preset time, open the startbox door
                                if toc(tStart) > max_delay && openDoor == 0
                                    % report for troubleshooting
                                    disp('High Coherence Threshold Not Met')

                                    % stop treadmill
                                    writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
                                    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');
                                    pause(0.25)
                                    write(s,treadFuns.stop,'uint8'); 
                                    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayEnd" 601 2');

                                    % if not the first trial, track how long the delay was
                                    delay_duration_notMet = [delay_duration_notMet toc(tStart)];

                                    % master keeper
                                    delay_durations = [delay_durations toc(tStart)];                                    
                                    
                                    % assign to 0 for not met, and open the
                                    % door by setting openDoor to 1
                                    coh_met  = 0;
                                    openDoor = 1;             
                                end

                            end

                        elseif contains(trialType(triali),'L') % if the trial is a low-coherence trial

                            % again, set to empty to prevent any previous
                            % rewrites, even though they won't happen
                            coherence_threshold = [];
                            coherence_threshold = threshold.low_coherence_magnitude;  

                            % first, if coherence magnitude is met, do whats below
                            if isempty(find(coh < coherence_threshold))==0 % < bc this is low coh

                                %disp('Low Coherence Threshold Met')

                                % sustained coherence\
                                if length(coh) > 1
                                    if isnan(coh(end)) == 0 && isnan(coh(end-1)) == 0 % if both coh of interest are real
                                        if coh(end) < coherence_threshold && coh(end-1) < coherence_threshold
                                            % report for troubleshooting
                                            disp('Low Coherence Threshold Met')

                                            % stop treadmill
                                            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
                                            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');
                                            pause(0.25)
                                            write(s,treadFuns.stop,'uint8'); 
                                            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayEnd" 601 2');

                                            % track how long the delay was
                                            delay_duration_master = [delay_duration_master toc(tStart)];

                                            % master keeper
                                            delay_durations = [delay_durations toc(tStart)];
                                        
                                            % assign to 0 for not met, and open the
                                            % door by setting openDoor to 1
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
                                if toc(tStart) > max_delay && openDoor == 0
                                    
                                    % report for troubleshooting
                                    disp('Low Coherence Threshold Not Met')

                                    % stop treadmill
                                    writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
                                    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');
                                    pause(0.25)
                                    write(s,treadFuns.stop,'uint8'); 
                                    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayEnd" 601 2');

                                    % if not the first trial, track how long the delay was
                                    delay_duration_notMet = [delay_duration_notMet toc(tStart)];
                                    
                                    % master keeper
                                    delay_durations = [delay_durations toc(tStart)];
                                        
                                    % assign to 0 for not met, and open the
                                    % door by setting openDoor to 1
                                    coh_met  = 0;
                                    openDoor = 1;
                                end

                            % otherwise, erase these variables, resetting the coherence
                            % magnitude and duration counters
                            else

                                % if your timer has elapsed > some preset time, open the startbox door
                                if toc(tStart) > max_delay && openDoor == 0
                                    % report for troubleshooting
                                    disp('Low Coherence Threshold Not Met')

                                    % stop treadmill
                                    writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
                                    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');
                                    pause(0.25)
                                    write(s,treadFuns.stop,'uint8');
                                    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayEnd" 601 2');                

                                    % if not the first trial, track how long the delay was
                                    delay_duration_notMet = [delay_duration_notMet toc(tStart)];

                                    
                                    % master keeper
                                    delay_durations = [delay_durations toc(tStart)];
                                        
                                    % assign to 0 for not met, and open the
                                    % door by setting openDoor to 1
                                    coh_met  = 0;
                                    openDoor = 1;             
                                end

                            end 
                        else
                            error('Something is wrong...')
                        end

                    end

                    % logger for experimental conditions
                    coherence_met  = [coherence_met coh_met];
                    coherence_data{end+1} = coh; 
                    
                    % if coherence was not met, redo the trial
                    if coh_met == 0 % if coherence was not met
                        
                        % break loops
                        next = 1;
                        break;
                
                    end                    

                elseif contains(trialType(triali),{'C'}) % control high/ control low

                    disp('Yoking Up... lol')

                    % define your control trials
                    %conTrials = ((numTrials-1)/2)+1:numTrials-1;

                    % randomly select one of any non-nan values
                    nonNanVals = [];
                    nonNanVals = find(isnan(delay_duration_manipulate)==0);

                    % pause for the corresponding duration and mark the
                    % trial according to whether its a yoked high or yoked
                    % low
                    trialMatch = randsample(nonNanVals,1);
                    yokedContr{triali} = [trialType{triali} trialType{trialMatch}];

                    % pause
                    disp(['Pausing for delay of ',num2str(delay_duration_manipulate(trialMatch)) ' seconds to match an ' trialType{trialMatch} ' trial'])
                    pause(delay_duration_manipulate(trialMatch))
                    yokedDelay = [yokedDelay delay_duration_manipulate(trialMatch)];

                    % then set to NaN so it can't be re-used
                    delay_duration_manipulate(trialMatch) = NaN;

                end

                % open doors and stop treadmill
                writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]) 
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');
                pause(0.25)
                write(s,treadFuns.stop,'uint8'); 
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayEnd" 601 2');

                % break out of while loop and continue maze
                next = 1;
            end
        end
        
        % if coherence was not met, redo the trial
        if coh_met == 0 % if coherence was not met
            
            % break loop
            resetLoop = 1;
            break;

        end        

        if triali == numTrials || toc(sStart)/60 > session_length
            writeline(s,doorFuns.closeAll)
            repeat = 1; % end          
            break % break out of for loop
        end
    end 
end

% get amount of time past since session start
c = clock;
session_time_update = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time = session_time_update-session_start;

% compute accuracy array
trajectory_text = cellstr(trajectory_text);
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

%save_var = strcat(rat_name,'_',task_name,'_',c_save);
%place2store = getCurrentPath();

% save data
delay_duration_manipulate = delay_duration_master;
if contains(sessType,[{'experimental'} {'Experimental'} {'E'} {'e'}])

    % prep for excel
    behavioralData = table(coherence_met', accuracy','VariableNames',{'CoherenceMet(1=YES)','ChoiceAccuracy(0=CORRECT)'});

    save_var = [targetRat,'_experimentalData_Day' testDay '.mat'];
    
elseif contains(sessType,[{'control'} {'Control'} {'C'} {'c'}])

    % prep for excel
    behavioralData = table(accuracy','VariableNames',{'YokedAccuracy(0=CORRECT)'});

    save_var = [targetRat,'_controlData_Day' testDay '.mat'];    
end
%place2store = ['C:\Users\jstout\Desktop\Data 2 Move\APPROACH 3\', targetRat];

cd(place2store);
save(save_var);

%% clean maze

% close doors
writeline(s,doorFuns.closeAll);

% begin treadmill
write(s,treadFuns.start,'uint8');

% increase tread speed gradually
[succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayStart" 600 2');
for i = speedVector
    % set treadmill speed
    write(s,uint8(speed_cell{i}'),'uint8'); % add a second command in case the machine missed the first one
    pause(0.25)
end                

next = 0;
while next == 0
    
    % open doors and stop treadmill
    prompt = ['Are you finished cleaning (ie treadmill, walls, floors clean)? '];
    cleanUp = input(prompt,'s');

    if contains(cleanUp,[{'Y'} {'y'}])
        write(s,treadFuns.stop,'uint8'); 
        next = 1;
    else
        disp('Clean the maze!!!')
    end
end




