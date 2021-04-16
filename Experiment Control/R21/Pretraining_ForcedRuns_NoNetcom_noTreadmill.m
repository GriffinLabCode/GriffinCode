%% preparation
clear;

% user enter trials
prompt    = 'Enter the number of trials ';
numTrials = str2num(input(prompt,'s'));

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

%% some parameters set by the user
%numTrials    = 12;
pellet_count = 1;
timeout_len  = 60*10;
treadmill    = 0; % set this to 1 if you want to use

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

%% trials
open_t  = [doorFuns.tLeftOpen doorFuns.tRightOpen];
close_t = [doorFuns.tLeftClose doorFuns.tRightClose];
maze_prep = [doorFuns.gzLeftOpen doorFuns.gzRightOpen];

for triali = 1:numTrials
    
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
        next = 0;
        while next == 0
            if readDigitalPin(a,irArduino.Treadmill) == 0

                % close startbox door
                pause(.25);                    
                writeline(maze,doorFuns.centralOpen)
                % tell the loop to move on
                next = 1; 
            else
                next = 0;
            end
        end
    else 
        pause(5); % a brief pause between trials
        writeline(maze,doorFuns.centralOpen)    
    end
    
    % central t beam
    % while loop so that we continuously read the IR beam breaks
    irTemp = [];
    next = 0;
    while next == 0
        irTemp = read(maze,4,"uint8");            % look for IR beam breaks
        if irTemp == irBreakNames.central         % if central beam is broken           
            % close door
            writeline(maze,doorFuns.centralClose) % close the door behind the rat  
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
            % close opposite door
            writeline(maze,doorFuns.tRightClose) 
                    
            % open sb door
            pause(0.25)
            writeline(maze,doorFuns.sbRightOpen)
         
            if triali > 1
               writeline(maze,rewFuns.left);
            end
            
            % break while loop
            next = 1;
            
        elseif irTemp == irBreakNames.tLeft
     
            % track the trajectory_text
            trajectory_text{triali} = 'L';          
            
            % close door
            writeline(maze,doorFuns.tLeftClose)
           
            % open sb door
            pause(0.25)            
            writeline(maze,doorFuns.sbLeftOpen)
       
            if triali > 1
                writeline(maze,rewFuns.right); 
            end             
            
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

                    % close startbox door
                    pause(.25);                    
                    writeline(maze,doorFuns.sbRightClose)

                    % tell the loop to move on
                    next_tread = 1;
                elseif isempty(irTemp) == 0
                    if irTemp == irBreakNames.sbLeft
                
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
                    % close startbox door
                    pause(.25);                    
                    writeline(maze,doorFuns.sbLeftClose)

                    % tell the loop to move on
                    next_tread = 1;
                elseif isempty(irTemp) == 0
                    if irTemp == irBreakNames.sbRight
  
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
