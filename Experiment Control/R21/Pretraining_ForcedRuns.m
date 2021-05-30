%% preparation
clear;

% prep stuff for maze
rng shuffle

addpath('X:\03. Lab Procedures and Protocols\MazeEngineers')

if exist("maze") == 0
    % connect to the serial port making an object
    maze = serialport("COM6",19200);
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
    a = arduino('COM5','Uno','Libraries','Adafruit\MotorShieldV2');
end

irArduino.Treadmill = 'D9';

% arduino IR tester
%{
for i = 1:10000000
    readDigitalPin(a,irArduino.Treadmill)
end
%}
%% Connect to netcom
prompt = 'Are you recording this session? [Y/y N/n] ';
answer = input(prompt,'s');
if contains(answer,[{'Y'} {'y'}])
    pathName   = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21\NetComDevelopmentPackage_v3.1.0\MATLAB_M-files';
    serverName = '192.168.3.100';
    connect2netcom(pathName,serverName)
end

%% some parameters set by the user
%numTrials    = 12;
pellet_count = 1;
timeout_len  = 60*10;
treadmill    = 0; % set this to 1 if you want to use
delay_length = 0;

%% clean the stored data just in case IR beams were broken
 
% close all maze doors - this gives problems with solenoid box
pause(0.25)
writeline(maze,[doorFuns.centralClose doorFuns.sbLeftClose ...
    doorFuns.sbRightClose doorFuns.tLeftClose doorFuns.tRightClose]);

pause(0.25)
writeline(maze,[doorFuns.gzLeftClose doorFuns.gzRightClose])

%{
% reward dispensers need about 3 seconds to release pellets
for rewardi = 1:pellet_count
    disp('Prepping reward wells, this may take a few seconds...')
    writeline(maze,rewFuns.right)
    pause(4)
    writeline(maze,rewFuns.left)
    pause(4)
end
%}

%% user enter trials
prompt    = 'Enter the number of trials ';
numTrials = str2num(input(prompt,'s'));
pause(5)

%% create a random organization of forced run trajectories
left  = repmat('L',[numTrials/2 1]);
right = repmat('R',[numTrials/2 1]);
both  = [left; right];
both_shuffled = both;
for i = 1:1000
    % notice how it rewrites the both_shuffled variable
    both_shuffled = both_shuffled(randperm(numel(both_shuffled)));
end
trajectory = cellstr(both_shuffled);

% add 1 to trajectory - the rat won't run on this trial
trajectory{end+1} = 'E';

% update the numTrials variable
numTrials = length(trajectory);

%% trials
open_t  = [doorFuns.tLeftOpen doorFuns.tRightOpen];
close_t = [doorFuns.tLeftClose doorFuns.tRightClose];
maze_prep = [doorFuns.gzLeftOpen doorFuns.gzRightOpen];

disp('Maze ready');
for triali = 1:numTrials-1
    
    % set central door timeout value
    maze.Timeout = timeout_len; % 5 minutes before matlab stops looking for an IR break    
    
    if trajectory{triali} == 'L'
        writeline(maze,doorFuns.tLeftOpen)
        pause(0.25)
        writeline(maze,doorFuns.gzLeftOpen)
    elseif trajectory{triali} == 'R'
        writeline(maze,doorFuns.tRightOpen)
        pause(0.25)
        writeline(maze,doorFuns.gzRightOpen)       
    end
    
    % set irTemp to empty matrix
    irTemp = []; 
    
    if triali == 1
        
        % bate the arm on the first trial
        if contains(trajectory{triali},'L')
            writeline(maze,rewFuns.left);
        elseif contains(trajectory{triali},'R')
            writeline(maze,rewFuns.right);
        end
        pause(.5)
        
        next = 0;
        while next == 0
            if readDigitalPin(a,irArduino.Treadmill) == 0

                % close startbox door
                pause(.25);                    
                writeline(maze,doorFuns.centralOpen)
                [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "centralOpen" 100 2');    
                
                % tell the loop to move on
                next = 1; 
            else
                next = 0;
            end
        end
    else 
        pause(5); % a brief pause between trials
        writeline(maze,doorFuns.centralOpen)    
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "centralOpen" 100 2');         
    end
    
    % central t beam
    % while loop so that we continuously read the IR beam breaks
    irTemp = [];
    next = 0;
    while next == 0
        irTemp = read(maze,4,"uint8");            % look for IR beam breaks
        if irTemp == irBreakNames.central         % if central beam is broken    
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "centralBeam" 102 2');       

            % close door
            %writeline(maze,doorFuns.centralClose) % close the door behind the rat  
            next = 1;
        else
            next = 0;
        end
    end    
    
    
    % t-beam
    % check which direction the rat turns at the T-junction
    next = 0;
    while next == 0
        irTemp = [];
        irTemp = read(maze,4,"uint8");         
        if irTemp == irBreakNames.tRight      
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tRightBeam" 222 2');                                    
            
            % close opposite door
            writeline(maze,[doorFuns.tRightClose]) 
            %writeline(maze,doorFuns.centralClose) % close the door behind the rat  
            pause(.25);
            writeline(maze,doorFuns.centralClose);            
            
            % open sb door
            pause(0.25)
            writeline(maze,doorFuns.sbRightOpen)
         
            %{
            if triali > 1
               writeline(maze,rewFuns.left);
            end
            %}
            %{
            if contains(trajectory{triali+1},'L')
                writeline(maze,rewFuns.left);
            elseif contains(trajectory{triali+1},'R')
                writeline(maze,rewFuns.right);
            elseif contains(trajectory{triali+1},'E')
                disp('Session ending')
            end                
            %}
            % break while loop
            next = 1;
            
        elseif irTemp == irBreakNames.tLeft
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "tLeftBeam" 212 2');
     
            % track the trajectory_text
            trajectory_text{triali} = 'L';          
            
            % close door
            writeline(maze,[doorFuns.tLeftClose])
            pause(.25);
            writeline(maze,doorFuns.centralClose);
            
            % open sb door
            pause(0.25)            
            writeline(maze,doorFuns.sbLeftOpen)
       
            %{
            if triali > 1
                writeline(maze,rewFuns.right); 
            end             
            %}
            %{
            if contains(trajectory{triali+1},'L')
                writeline(maze,rewFuns.left);
            elseif contains(trajectory{triali+1},'R')
                writeline(maze,rewFuns.right);
            elseif contains(trajectory{triali+1},'E')
                disp('Session ending')
            end        
            %}
            
            % break out of while loop
            next = 1;
        end
    end        
       
    % return arm and eating
    next = 0;
    while next == 0   
        
        % reward zone
        irTemp = read(maze,4,"uint8");         
        if irTemp == irBreakNames.rewRight     
            irTemp = read(maze,4,"uint8");         
        elseif irTemp == irBreakNames.rewLeft
            irTemp = read(maze,4,"uint8");         
        end
        
        if irTemp == irBreakNames.gzRight
            % send neuralynx command for timestamp
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "gzRightBeam" 422 2');             

            % close both for audio symmetry
            writeline(maze,doorFuns.gzLeftClose)
            pause(0.25)
            writeline(maze,doorFuns.gzRightClose)
            pause(0.25)
            writeline(maze,doorFuns.tRightClose)
            
            % only code as gzRightClose
            
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
            
            % only code as gzLeftClose
            
            next = 1;
        end
    end
    
    % startbox
    next = 0;
    while next == 0
        maze.Timeout = timeout_len;
        irTemp = read(maze,4,"uint8");         
        if irTemp == irBreakNames.sbRight
            [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "sbRightBeam" 522 2');             
            % track animals traversal onto the treadmill
            next_tread = 0; % hardcode next as 0 - this value gets updated when criteria is met
            while next_tread == 0 
                % try to see if the rat goes and checks out the other doors
                % IR beam
                maze.Timeout = 0.1;
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
                maze.Timeout = 0.1;
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
    
    if delay_length > 1

        % pause
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayStart" 810 2');                            
        pause(delay_length); % no pause - start it immediately
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayEnd" 810 2');                            
    else
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayStart" 810 2');                            
        [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayEnd" 810 2');                                    
    end    
    
    % fill reward for next trial
    if contains(trajectory{triali+1},'L')
        writeline(maze,rewFuns.left);
    elseif contains(trajectory{triali+1},'R')
        writeline(maze,rewFuns.right);
    elseif contains(trajectory{triali+1},'E')
        disp('Session end')
    end     
    pause(2); % give the reward wells some time to fill
end

% save data
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
