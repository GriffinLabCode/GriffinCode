%% prep 1 - clear history, workspace, get working directory
% _____________________________________________________

% --- MAKE SURE YOU RUN STARTUP_EXPERIMENTCONTROL --- %

%______________________________________________________

% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

%% prep 3 - connect with cheetah
% connect to netcom - automate this for github
pathName   = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21\NetComDevelopmentPackage_v3.1.0\MATLAB_M-files';
serverName = '192.168.3.100';
connect2netcom(pathName,serverName)

%% experiment design prep.

% define number of trials
numTrials  = 18;

% how long should the session be?
session_length = 30; % minutes
pellet_count = 1;
timeout_len  = 60*15;

% delay length
delay_length = 1; % seconds
iti_length   = delay_length*2;

%% auto maze prep.

% -- automaze set up -- %

% check port
if exist("maze") == 0
    % connect to the serial port making an object
    maze = serialport("COM6",19200);
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

irArduino.Treadmill = 'D9';

%{
for i = 1:10000000
    readDigitalPin(a,irArduino.Treadmill)
end
%}

%% clean the stored data just in case IR beams were broken
s.Timeout = 1; % 1 second timeout
next = 0; % set while loop variable
while next == 0
   irTemp = read(maze,4,"uint8"); % look for stored data
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
writeline(maze,[doorFuns.centralClose doorFuns.sbLeftClose ...
    doorFuns.sbRightClose doorFuns.tLeftClose doorFuns.tRightClose]);

pause(0.25)
writeline(maze,[doorFuns.gzLeftClose doorFuns.gzRightClose])

% reward dispensers need about 3 seconds to release pellets
for rewardi = 1:pellet_count
    writeline(maze,rewFuns.right)
    pause(4)
    writeline(maze,rewFuns.left)
    pause(4)
end

%% create sample phase trials
% cant have more than 3 turns in the same direction
redo = 1;
while redo == 1
    left  = repmat('L',[numTrials/2 1]);
    right = repmat('R',[numTrials/2 1]);
    both  = [left; right];
    both_shuffled = both;
    for i = 1:1000
        % notice how it rewrites the both_shuffled variable
        both_shuffled = both_shuffled(randperm(numel(both_shuffled)));
    end
    trajectory_binary = cellstr(both_shuffled);

    % no more than 3 turns in one direction
    idxL = double(contains(trajectory_binary,'L'));
    idxR = double(contains(trajectory_binary,'R'));

    for i = 1:length(trajectory_binary)-3
        if idxL(i) == 1 && idxL(i+1) == 1 && idxL(i+2) == 1 && idxL(i+3)==1
            redo = 1;
            break        
        elseif idxR(i) == 1 && idxR(i+1) == 1 && idxR(i+2) == 1 && idxR(i+3)==1
            redo = 1;
            break        
        else
            redo = 0;
        end
    end
end
choice_traversals = cellstr(repmat('C',[numTrials 1]));
both = [trajectory_binary,choice_traversals];
trialType = cell([1 numTrials*2])';
trialType(1:2:numTrials*2) = trajectory_binary;
trialType(2:2:numTrials*2) = choice_traversals;

%% start recording - make a noise when recording begins
[succeeded, reply] = NlxSendCommand('-StartRecording');
load gong.mat;
sound(y);
pause(5)

%% trials
open_t  = [doorFuns.tLeftOpen doorFuns.tRightOpen];
close_t = [doorFuns.tLeftClose doorFuns.tRightClose];
maze_prep = [doorFuns.tLeftOpen doorFuns.tRightOpen ...
    doorFuns.gzLeftOpen doorFuns.gzRightOpen];

% mark session start
sStart = [];
sStart = tic;
sessEnd = 0;
while toc(sStart)/60 < session_length || sessEnd == 0
    c = clock;
    session_start = str2num(strcat(num2str(c(4)),num2str(c(5))));
    session_time  = session_start-session_start; % quick definitio of this so it starts the while loop
    for travi = 1:numTrials*2 % 2*numTrials bc 2*num traversals

        % set central door timeout value
        s.Timeout = timeout_len; % 5 minutes before matlab stops looking for an IR break    

        % sample trial
        if trialType{travi} == 'L'
            writeline(maze,doorFuns.sbLeftOpen)
            pause(0.25)
            writeline(maze,doorFuns.gzLeftOpen)
        elseif trialType{travi} == 'R'
            writeline(maze,doorFuns.sbRightOpen)
            pause(0.25)
            writeline(maze,doorFuns.gzRightOpen)       
        end

        % open central door to let rat off of treadmill
        pause(0.25);
        writeline(maze,doorFuns.centralOpen)

        % send a neuralynx command to track the trial
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "centralOpen" 100 2');    

        % set irTemp to empty matrix
        irTemp = []; 

        % central beam
        % while loop so that we continuously read the IR beam breaks
        next = 0;
        while next == 0
            if readDigitalPin(a,irArduino.Treadmill) == 0
                
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "centralBeam" 102 2');

                % close door
                %writeline(maze,doorFuns.centralClose) % close the door behind the rat
                next = 1;                          % break out of the loop
            end
        end
        
        % t-beam
        % check which direction the rat turns at the T-junction
        next = 0;
        while next == 0
            irTemp = [];
            irTemp = read(maze,4,"uint8");         
            if irTemp == irBreakNames.gzRight 
                 writeline(maze,rewFuns.right)                
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzRightBeam" 222 2');                                    

                % track the trajectory_text
                if contains(trialType{travi},'C')
                    trajectory_text{travi}   = 'R';
                    trajectory_binary(travi) = 0;
                end

                % close door
                writeline(maze,[doorFuns.sbRightClose]) 
                pause(.25)
                writeline(maze,doorFuns.tLeftClose);

                %writeline(maze,doorFuns.centralClose) % close the door behind the rat  
                pause(.25);
                writeline(maze,doorFuns.centralClose);     
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "centralClose" 101 2'); 

                % open sb door
                pause(0.25)
                writeline(maze,doorFuns.sbRightOpen)

                if travi > 1 && trajectory_text{travi} == 'R' && trajectory_text{travi-1} == 'L'
                    % reward dispensers need about 3 seconds to release pellets
                    for rewardi = 1:pellet_count
                        writeline(maze,rewFuns.left)
                        pause(3)
                    end
                end

                % break while loop
                next = 1;

            elseif irTemp == irBreakNames.tLeft
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tLeftBeam" 212 2');

                % track the trajectory_text
                if contains(trialType{travi},'C')
                    trajectory_text{travi}   = 'L';
                    trajectory_binary(travi) = 1;
                end         

                % close door
                writeline(maze,[doorFuns.tRightClose]);
                pause(.25)
                writeline(maze,doorFuns.tLeftClose);

                pause(.25);
                writeline(maze,doorFuns.centralClose);

                % open sb door
                pause(0.25)            
                writeline(maze,doorFuns.sbLeftOpen)

                if travi > 1 && trajectory_text{travi} == 'L' && trajectory_text{travi-1} == 'R'
                    % reward dispensers need about 3 seconds to release pellets
                    for rewardi = 1:pellet_count
                        writeline(maze,rewFuns.right)
                        pause(3)
                    end
                end             

                % break out of while loop
                next = 1;
            end
        end    

        % Reward zone and eating
        % send to netcom 

        % return arm
        next = 0;
        while next == 0
            irTemp = read(maze,4,"uint8");         
            if irTemp == irBreakNames.gzRight 
                % send neuralynx command for timestamp
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzRightBeam" 422 2');             

                % close both for audio symmetry
                writeline(maze,doorFuns.gzLeftClose)
                pause(0.25)
                writeline(maze,doorFuns.gzRightClose)
                pause(0.25)
                writeline(maze,doorFuns.tRightClose)

                next = 1;                          
            elseif irTemp == irBreakNames.gzLeft
                % send neuralynx command for timestamp
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzLeftBeam" 412 2');

                % close both for audio symmetry
                writeline(maze,doorFuns.gzLeftClose)
                pause(0.25)
                writeline(maze,doorFuns.gzRightClose)
                pause(0.25)
                writeline(maze,doorFuns.tLeftClose)            

                next = 1;
            end
        end      

        % startbox
        next = 0;
        while next == 0
            s.Timeout = timeout_len;
            irTemp = read(maze,4,"uint8");         
            if irTemp == irBreakNames.sbRight 
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbRightBeam" 522 2');             

                % track animals traversal onto the treadmill
                next_tread = 0; % hardcode next as 0 - this value gets updated when criteria is met
                while next_tread == 0 
                    % try to see if the rat goes and checks out the other doors
                    % IR beam
                    s.Timeout = 0.1;
                    irTemp = read(maze,4,"uint8");
                    % if rat enters the startbox, only close the door behind
                    % him if he has either checked out the opposing door or
                    % entered the center of the startbox zone. This ensures
                    % that the rat is in fact in the startbox
                    if readDigitalPin(a,irArduino.Treadmill) == 0
                        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "TreadmillBeam" 602 2');

                        % close startbox door
                        pause(.25);                    
                        writeline(maze,doorFuns.sbRightClose)
                        % tell the loop to move on
                        next_tread = 1;
                    elseif isempty(irTemp) == 0
                        if irTemp == irBreakNames.sbLeft
                            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbLeftBeam - after Right" 512 3'); 

                            % close startbox door
                            pause(0.25)
                            writeline(maze,doorFuns.sbRightClose)
                            % tell the loop to move on
                            next_tread = 1;
                        end
                    elseif isempty(irTemp)==1 && readDigitalPin(a,irArduino.Treadmill) == 1
                        next_tread = 0;
                    end
                end

                next = 1;
            elseif irTemp == irBreakNames.sbLeft 
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbLeftBeam" 512 2');       
                
                % track animals traversal onto the treadmill
                next_tread = 0; % hardcode next as 0 - this value gets updated when criteria is met
                while next_tread == 0 
                    % try to see if the rat goes and checks out the other doors
                    % IR beam
                    s.Timeout = 0.1;
                    irTemp = read(maze,4,"uint8");
                    % if rat enters the startbox, only close the door behind
                    % him if he has either checked out the opposing door or
                    % entered the center of the startbox zone. This ensures
                    % that the rat is in fact in the startbox
                    if readDigitalPin(a,irArduino.Treadmill) == 0
                        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "TreadmillBeam" 602 2');

                        % close startbox door
                        pause(.25);                    
                        writeline(maze,doorFuns.sbLeftClose)
                        %[succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbLeftClose" 511 2');                    

                        % tell the loop to move on
                        next_tread = 1;
                    elseif isempty(irTemp) == 0
                        if irTemp == irBreakNames.sbRight
                            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbRightBeam - after Left" 522 3');                         

                            % close startbox door
                            pause(0.25)
                            writeline(maze,doorFuns.sbLeftClose)
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

        % initialize some variables
        timeStamps = []; timeConv  = [];
        coh_met    = []; coh_store = [];
        dur_met    = []; dur_sum   = [];    
        % only during delayed alternations will you start the treadmill
        if delay_length > 1

            % pause
            if contains(trialType{travi},'C')
                
                disp('ITI')
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "ITIStart" 810 2');                            
                pause(iti_length); % no pause - start it immediately
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "ITIEnd" 810 3');       
                
            else
                
                disp('Delay')
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayStart" 810 4');                            
                pause(delay_length); % no pause - start it immediately
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayEnd" 810 5'); 
                
            end

            % use tic toc to store timing for yoked control
            tStart = [];
            tStart = tic;

        end

        % out time
        delay_duration_master(travi) = toc(tStart);

        if travi == numTrials
            writeline(maze,doorFuns.closeAll)
            sessEnd = 1;
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
for travi = 1:length(trajectory_text)-1
    if trajectory_text{travi} ~= trajectory_text{travi+1}
        accuracy(travi) = 0; % correct trial
        accuracy_text{travi} = 'correct';
    elseif trajectory_text{travi} == trajectory_text{travi+1}
        accuracy(travi) = 1; % incorrect trial
        accuracy_text{travi} = 'incorrect';
    end
end

%% ending noise - a fitting song to end the session
load handel.mat;
sound(y, 2*Fs);
writeline(maze,[doorFuns.centralClose])


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



