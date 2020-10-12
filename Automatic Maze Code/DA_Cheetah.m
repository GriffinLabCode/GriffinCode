% Alternation task
%
% Can be delayed or non delayed
%
% written by John Stout

addpath('X:\03. Lab Procedures and Protocols\MazeEngineers')

if exist("s") == 0
    % connect to the serial port making an object
    s = serialport("COM9",19200);
end

% load in door functions
doorFuns = DoorActions;

% test reward wells
rewFuns = RewardActions;

% load treadmill functions and settings
[treadFuns,treadSpeeds] = TreadMillFuns;

% get IR information
irBreakNames = irBreakLabels;

% for arduino
if exist("a") == 0
    % connect arduino
    a = arduino('COM10','Uno','Libraries','Adafruit\MotorShieldV2');
end

irArduino.Treadmill = 'D9';

%{
for i = 1:10000000
    readDigitalPin(a,irArduino.Treadmill)
end
%}

%% some parameters set by the user
set_speed    = treadSpeeds.ten; % seven meters per minute
delay_length = 5; % seconds
numTrials    = 6;
pellet_count = 1;
timeout_len  = 60*5;

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
    disp('Prepping reward wells, this may take a few seconds...')
    writeline(s,rewFuns.right)
    pause(8)
    writeline(s,rewFuns.left)
    pause(8)
end
 
%% Netcom connection

next = 0;
while next == 0
    prompt = 'Is the Digital Lynx box on and cheetah opened? [Y/N] ';
    cheetah_resp = input(prompt,'s');

    if cheetah_resp ~= 'Y'
        disp('Please turn the Digital Lynx box on, wait until light stops blinking, then open Cheetah');
        pause(2);
        next = 0;
    elseif cheetah_resp == 'Y'
        next = 1; 
    end
end

% addpath to the netcom functions
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\NetCom\Matlab_M-files')

% define the computers server name
serverName = '192.168.0.200'; % from C. Sanger's sticker on the console

% connected via netcom to cheetah
disp('Connecting with NetCom. This may take a few minutes...')
if NlxAreWeConnected() ~= 1
    succeeded = NlxConnectToServer(serverName);
    if succeeded ~= 1
        error('FAILED to connect');
        return
    else
        display('Connected to NetCom Server - Ready to run session.');
    end
end

% start acquisition
prompt  = 'If you are ready to begin acquisition, type "Begin" ';
acquire = input(prompt,'s');

if acquire == 'Begin'
    % end acquisition if its already occuring as a safety precaution
    [succeeded, cheetahReply] = NlxSendCommand('-StopAcquisition');    
    [succeeded, cheetahReply] = NlxSendCommand('-StartAcquisition');
else
    disp('Please manually start data acquisition')
end

% open a stream to interface with events
[succeeded, cheetahObjects, cheetahTypes] = NlxGetDASObjectsAndTypes; % gets cheetah objects and types
succeeded = 0;
while succeeded == 0
    try 
        succeeded = NlxOpenStream(cheetahObjects(33));
        disp('Successfully opened a stream with Events')
    catch
        disp('Failed to open stream with Events')
    end
end

% make user enter information for the task
next = 0;
while next == 0
    prompt = 'How many trials? Type a number in numerical format: ' ;
    numTrials = str2num(input(prompt,'s'));

    prompt = 'What is the delay length? Type a time (ie 20 is 20 seconds) ' ;
    delay_length = str2num(input(prompt,'s'));
    
    if numTrials > 0 && exist('delay_length') == 1
        next = 1;
    end
end

% ask user if he/she is ready to begin recording
prompt = 'Would you like to begin recording? You can start manually at a later time otherwise. [Y/N] ';
rec_start = input(prompt,'s');

if rec_start == 'Y'
    prompt = 'Will this be a pre-recording? [Y/N] ';
    pre_rec = input(prompt,'s');
    
    if pre_rec == 'Y'
        prompt = 'Please enter an integer time in minutes (i.e. 1 = 1 minute) for the pre-recording: ';
        pre_time = input(prompt,'s');
        
        % begin recording
        [succeeded, cheetahReply] = NlxSendCommand('-StartRecording');
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "PreRecordingStart" 10 1'); % prerecording is TTL 00000000001010
        
        disp('Recording started - check the Cheetah screen');
        
        % set a timer for diplay
        counter = linspace(pre_time*-1,-1,pre_time);
        for i = 1:length(counter)
            X_disp = [num2str(counter(i)*-1), ' minutes of pre-recording remaining'];
            disp(X_disp)
            pause(1);       % 60 seconds  
            if i == length(counter)
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "PreRecordingEnd" 11 1'); % prerecording end is TTL 00000000001011
            end
        end
    else
        [succeeded, cheetahReply] = NlxSendCommand('-StartRecording');
    end    
end

%% trials
open_t  = [doorFuns.tLeftOpen doorFuns.tRightOpen];
close_t = [doorFuns.tLeftClose doorFuns.tRightClose];
maze_prep = [doorFuns.tLeftOpen doorFuns.tRightOpen ...
    doorFuns.gzLeftOpen doorFuns.gzRightOpen];

for triali = 1:numTrials
    
    % set central door timeout value
    s.Timeout = timeout_len; % 5 minutes before matlab stops looking for an IR break    
        
    % first trial - set up the maze doors appropriately
    writeline(s,maze_prep)

    % open central door to let rat off of treadmill
    writeline(s,doorFuns.centralOpen)
    
    % send a neuralynx command to track the trial
    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "centralOpen" 100 2');
    
    % Start trial message
    if triali == 1
       [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "TrialStart" 600 2');
    end  
    
    % set irTemp to empty matrix
    irTemp = []; 
    
    % central beam
    % while loop so that we continuously read the IR beam breaks
    next = 0;
    while next == 0
        irTemp = read(s,4,"uint8");            % look for IR beam breaks
        if irTemp == irBreakNames.central      % if central beam is broken
            % neuralynx timestamp command
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "centralBeam" 102 2');             
            
            % close door
            writeline(s,doorFuns.centralClose) % close the door behind the rat
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "centralClose" 101 2'); 
            
            next = 1;                          % break out of the loop
        end
    end
    
    % t-beam
    % check which direction the rat turns at the T-junction
    next = 0;
    while next == 0
        irTemp = [];
        irTemp = read(s,4,"uint8");         
        if irTemp == irBreakNames.tRight 
            % broke tjunction right beam
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tRightBeam" 222 2');                        
            
            % track the trajectory_text
            trajectory_text{triali} = 'R';
            trajectory(triali)      = 0;
            
            % close opposite door
            writeline(s,doorFuns.tLeftClose) 
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tLeftClose" 211 2'); % left will be 200s; close door because 201            
                        
            % open sb door
            pause(0.25)
            writeline(s,doorFuns.sbRightOpen)
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbRightOpen" 520 2'); % left will be 200s; close door because 201            
            
            if triali > 1 && trajectory_text{triali} == 'R' && trajectory_text{triali-1} == 'L'
                % reward dispensers need about 3 seconds to release pellets
                for rewardi = 1:pellet_count
                    writeline(s,rewFuns.left)
                    pause(3)
                end
            end
            
            % break while loop
            next = 1;
            
        elseif irTemp == irBreakNames.tLeft
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tLeftBeam" 212 2');
              
            % track the trajectory_text
            trajectory_text{triali} = 'L';
            trajectory(triali)      = 1;            
            
            % close door
            writeline(s,doorFuns.tRightClose)
           [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tRightClose" 221 2'); % right will be 300s            
            
            % open sb door
            pause(0.25)            
            writeline(s,doorFuns.sbLeftOpen)
           [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbLeftOpen" 510 2'); % left will be 200s; close door because 201            
            
            if triali > 1 && trajectory_text{triali} == 'L' && trajectory_text{triali-1} == 'R'
                % reward dispensers need about 3 seconds to release pellets
                for rewardi = 1:pellet_count
                    writeline(s,rewFuns.right)
                    pause(3)
                end
            end             
            
            % break out of while loop
            next = 1;
        end
    end    
    
    %%%% ~~~~ Reward zone and eating ~~~~ %%%%
    % send to netcom 
    irTemp = read(s,4,"uint8");         
    if irTemp == irBreakNames.rewRight     
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "rewardRight" 322 2'); 
    elseif irTemp == irBreakNames.rewLeft
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "rewardLeft" 312 2');
    end
    irTemp = []; 
    
    % return arm
    next = 0;
    while next == 0
        irTemp = read(s,4,"uint8");         
        if irTemp == irBreakNames.gzRight 
            % send neuralynx command for timestamp
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzRightBeam" 422 2');             

            % close both for audio symmetry
            writeline(s,doorFuns.gzLeftClose)
            pause(0.25)
            writeline(s,doorFuns.gzRightClose)
            pause(0.25)
            writeline(s,doorFuns.tRightClose)
            
            % only code as gzRightClose
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzRightClose - gzLeft and tLeft close too" 421 2');             
            
            next = 1;                          
        elseif irTemp == irBreakNames.gzLeft
            % send neuralynx command for timestamp
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzLeftBeam" 412 2');
            
            % close both for audio symmetry
            writeline(s,doorFuns.gzLeftClose)
            pause(0.25)
            writeline(s,doorFuns.gzRightClose)
            pause(0.25)
            writeline(s,doorFuns.tLeftClose)  
            
            % only code as gzLeftClose
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzLeftClose - gzRight and tLeft close too" 411 2');             
            
            next = 1;
        end
    end      
    
    % startbox
    next = 0;
    while next == 0
        s.Timeout = timeout_len;
        irTemp = read(s,4,"uint8");         
        if irTemp == irBreakNames.sbRight
             % neuralynx ttl
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbRightBeam" 522 2');             

            % track animals traversal onto the treadmill
            next_tread = 0; % hardcode next as 0 - this value gets updated when criteria is met
            while next_tread == 0 
                % try to see if the rat goes and checks out the other doors
                % IR beam
                s.Timeout = 0.1;
                irTemp = read(s,4,"uint8");
                % if rat enters the startbox, only close the door behind
                % him if he has either checked out the opposing door or
                % entered the center of the startbox zone. This ensures
                % that the rat is in fact in the startbox
                if readDigitalPin(a,irArduino.Treadmill) == 0
                    % neuralynx ttl
                    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "TreadmillBeam" 602 2');
                    
                    % close startbox door
                    pause(.25);                    
                    writeline(s,doorFuns.sbRightClose)
                    
                    % neuralynx ttl
                    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbRightClose" 521 2');                    
                    
                    % tell the loop to move on
                    next_tread = 1;
                elseif isempty(irTemp) == 0
                    if irTemp == irBreakNames.sbLeft
                        % neuralynx ttl
                        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbLeftBeam - after Right" 512 3'); 
                        
                        % close startbox door
                        pause(0.25)
                        writeline(s,doorFuns.sbRightClose)
                        
                        % neuralynx ttl
                        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbRightClose" 521 2');                        

                        % tell the loop to move on
                        next_tread = 1;
                    end
                elseif isempty(irTemp)==1 && readDigitalPin(a,irArduino.Treadmill) == 1
                    next_tread = 0;
                end
            end
            
            next = 1;
        elseif irTemp == irBreakNames.sbLeft 
            % neuralynx ttl
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbLeftBeam" 512 2');                         
            
            % track animals traversal onto the treadmill
            next_tread = 0; % hardcode next as 0 - this value gets updated when criteria is met
            while next_tread == 0 
                % try to see if the rat goes and checks out the other doors
                % IR beam
                s.Timeout = 0.1;
                irTemp = read(s,4,"uint8");
                % if rat enters the startbox, only close the door behind
                % him if he has either checked out the opposing door or
                % entered the center of the startbox zone. This ensures
                % that the rat is in fact in the startbox
                if readDigitalPin(a,irArduino.Treadmill) == 0
                    % close startbox door
                    pause(.25);                    
                    writeline(s,doorFuns.sbLeftClose)
                    
                    % neuralynx ttl
                    [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbLeftClose" 511 2');                    
                    
                    % tell the loop to move on
                    next_tread = 1;
                elseif isempty(irTemp) == 0
                    if irTemp == irBreakNames.sbRight
                        % neuralynx ttl
                        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbRightBeam - after Right" 522 3');                         
                        
                        % close startbox door
                        pause(0.25)
                        writeline(s,doorFuns.sbLeftClose)
                        
                        % neuralynx ttl
                        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbLeftClose" 511 2'); 
                        
                        % tell the loop to move on
                        next_tread = 1;
                    end
                elseif isempty(irTemp)==1 && readDigitalPin(a,irArduino.Treadmill) == 1
                    next_tread = 0;
                end
            end
            
            next = 1;
        end 
    end
    
    % reset timeout
    s.Timeout = timeout_len;
    
    % only during delayed alternations will you start the treadmill
    if delay_length > 1

        % start treadmill
        pause(0.25)
        write(s,treadFuns.start,'uint8');

        % short pause before sending the machine the speed data
        pause(0.25)

        % set treadmill speed
        write(s,uint8(set_speed'),'uint8');
        write(s,uint8(set_speed'),'uint8'); % add a second command in case the machine missed the first one

        % neuralynx command
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "treadmillStart" 600 2');        

        % delay
        pause(delay_length);

        % stop treadmill
        pause(0.25)                
        write(s,treadFuns.stop,'uint8');
        
        % neuralynx command
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "treadmillStop" 601 2');        
    end
    
    % indicate trial start
    if triali ~= 1
        % neuralynx
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "trialStart" 600 2'); 
    end 
    
end

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

% save data - this is very important! This save section stores a unique
% name for each save file. It requires the user to interface.
c = clock;
c_save = strcat(num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(1)),'_','EndTime',num2str(c(4)),num2str(c(5)));

prompt   = 'Please enter the rats name ';
rat_name = input(prompt,'s');

prompt   = 'Please enter the task ';
task_name = input(prompt,'s');

prompt   = 'Enter the directory to save the data ';
dir_name = input(prompt,'s');

save_var = strcat(rat_name,'_',task_name,'_',c_save);

cd(dir_name);
save(save_var);



