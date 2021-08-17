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

prompt = ['What day of training is this? '];
TrainingDay  = str2num(input(prompt,'s'));

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

% define number of trials
numTrials  = 13;

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

% randomize delay durations
minDelay = 5;  % minimum delay duration set to 5 seconds
maxDelay = 15; % maximum delay duration set to 15 seconds
delay_durations = (maxDelay-minDelay).*rand(numTrials-1,1) + minDelay; % vector of values

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


if TrainingDay == 1
    speedVector = [1 2 3 4];
elseif TrainingDay == 2
    speedVector = [1 2 3 4 6];
elseif TrainingDay == 3 || TrainingDay > 3
    speedVector = [1 3 5 7];
end


%% coherence detection prep.

% define sampling rate
params.Fs     = srate;

% define number of samples that correspond to the amount of data in time
numSamples2use = threshold.coh_duration*srate;

% define for loop - 70 total sec
looper = ceil((amountOfTime*60/threshold.coh_duration)); %ceil((amountOfTime*60)/threshold.coh_duration); % N minutes * 60sec/1min * (1 loop is about .250 ms of data)

% define total loop time
total_loop_time = threshold.coh_duration*60; % in seconds

% this is the total amount of time coherence detection will proceed for...
total_window = 15; % total amount of time allowed for coherence to be detected

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

% mark session start
sStart = [];
sStart = tic;
sessEnd = 0;

c = clock;
session_start = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time  = session_start-session_start; % quick definitio of this so it starts the while loop
writeline(s,doorFuns.centralOpen);

% data_dirty refers to artifactual data, while _clean refers to artifact
% 'free' data
data_dirty = []; times_dirty = []; data_clean = []; times_clean = []; coh = [];
for triali = 1:numTrials

    % start out with this as a way to make sure you don't exceed 30
    % minutes of the session
    if toc(sStart)/60 > session_length
        writeline(s,doorFuns.closeAll)
        %sessEnd = 1;            
        break % break out of for loop
    end        

    % set central door timeout value
    s.Timeout = timeout_len; % 5 minutes before matlab stops looking for an IR break    

    % first trial - set up the maze doors appropriately
    if triali == 1
        pause(0.25);
        writeline(s,maze_prep)
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');
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
            trajectory_text{triali} = 'R';
            trajectory(triali)      = 0;

            pause(0.25)
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);
            pause(0.25)
            writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftClose doorFuns.tRightOpen]);

            % break while loop
            next = 1;

        elseif readDigitalPin(a,irArduino.lGoalArm)==0
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tLeftBeam" 212 2');

            % track the trajectory_text
            trajectory_text{triali} = 'L';
            trajectory(triali)      = 1;            

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
    if triali == 1 && trajectory_text{triali} == 'R'
        for rewardi = 1:pellet_count
            %pause(0.25)
            writeline(s,rewFuns.right)
            %pause(3)
        end
    elseif triali == 1 && trajectory_text{triali} == 'L'
        for rewardi = 1:pellet_count
           % pause(0.25)
            writeline(s,rewFuns.left)
            %pause(3)
        end        
    elseif triali > 1 && trajectory_text{triali} == 'R' && trajectory_text{triali-1} == 'L'
        % reward dispensers need about 3 seconds to release pellets
        for rewardi = 1:pellet_count
            %pause(0.25)
            writeline(s,rewFuns.right)
            %pause(3)
        end
    elseif triali > 1 && trajectory_text{triali} == 'L' && trajectory_text{triali-1} == 'R'
        % reward dispensers need about 3 seconds to release pellets
        for rewardi = 1:pellet_count
            %pause(0.25)
            writeline(s,rewFuns.left)
            %pause(3)
        end
    end

    % return arm
    %{
    next = 0;
    while next == 0
        irTemp = read(s,4,"uint8");         
        if irTemp == irBreakNames.tRight 
            % send neuralynx command for timestamp
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzRightBeam" 422 2');             

            % close both for audio symmetry
            pause(0.25)
            writeline(s,[doorFuns.gzLeftClose])
            pause(0.25)
            writeline(s,[doorFuns.gzRightClose])

            next = 1;                          
        elseif irTemp == irBreakNames.tLeft
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
    %}

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
            
            if triali == numTrials || toc(sStart)/60 > session_length
                next = 1;
                break
            end
            
            % begin treadmill
            write(s,treadFuns.start,'uint8');

            % increase tread speed gradually
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayStart" 600 2');
            for i = speedVector
                % set treadmill speed
                write(s,uint8(speed_cell{i}'),'uint8'); % add a second command in case the machine missed the first one
                pause(0.25)
            end 
            
            % start timer after treadmill started
            disp('Coherence Detection')
            tStart = tic;
            while (toc(tStart) < delay_durations(triali))
                %disp('Coherence Detection Start')
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
                
            end
            
            % pause for random time interval during delay
            %disp(['Pausing for delay of ',num2str(delay_durations(triali)) ' seconds'])
            %pause(delay_durations(triali))

            % open doors and stop treadmill
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen])
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPdoorOpen" 200 2');
            disp('CP doors opened');
            pause(0.25)
            write(s,treadFuns.stop,'uint8'); 
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "delayEnd" 601 2');                

            % break out of while loop and continue maze
            next = 1;
        end
    end

    checktime=toc(sStart)/60;
    if triali == numTrials || toc(sStart)/60 > session_length
        writeline(s,doorFuns.closeAll)
        break % break out of for loop
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
[succeeded, reply] = NlxSendCommand('-StopRecording');
load handel.mat;
sound(y, 2*Fs);
writeline(s,[doorFuns.centralClose])

%% save
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

place2store = ['C:\Users\jstout\Desktop\Data 2 Move\APPROACH 3\', targetRat];
cd(place2store);
save(save_var);

%% clean maze

% close doors
writeline(s,doorFuns.closeAll);

% unplug rat
next =0;
while next == 0
    prompt = ['Is the rat unplugged and wrapped up? '];
    ratReady = input(prompt,'s');
    if contains(ratReady,[{'Y'} {'y'}])
        next = 1;
    end
end

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



