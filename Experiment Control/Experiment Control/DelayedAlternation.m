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

%% some parameters set by the user
set_speed    = treadSpeeds.ten; % seven meters per minute
delay_length = 5; % seconds
numTrials    = 6;
pellet_count = 1;

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
    pause(8)
    writeline(s,rewFuns.left)
    pause(8)
end
        
%% trials
open_t  = [doorFuns.tLeftOpen doorFuns.tRightOpen];
close_t = [doorFuns.tLeftClose doorFuns.tRightClose];
maze_prep = [doorFuns.tLeftOpen doorFuns.tRightOpen ...
    doorFuns.gzLeftOpen doorFuns.gzRightOpen];

for triali = 1:numTrials
    
    % set central door timeout value
    s.Timeout = 60*5; % 5 minutes before matlab stops looking for an IR break    
        
    % first trial - set up the maze doors appropriately
    writeline(s,maze_prep)

    % open central door to let rat off of treadmill
    writeline(s,doorFuns.centralOpen)

    % set irTemp to empty matrix
    irTemp = []; 
    
    % central beam
    % while loop so that we continuously read the IR beam breaks
    next = 0;
    while next == 0
        irTemp = read(s,4,"uint8");            % look for IR beam breaks
        if irTemp == irBreakNames.central      % if central beam is broken
            % neuralynx timestamp command
            
            % close door
            writeline(s,doorFuns.centralClose) % close the door behind the rat
            next = 1;                          % break out of the loop
        end
    end


    %{
    % release pellets while rat is on the treadmill
    if triali > 2
        % apply reward on correct trials
        if trajectory_text{triali-1} == 'L' && trajectory_text{triali-2} == 'R'
            % reward dispensers need about 3 seconds to release pellets
            for rewardi = 1:pellet_count
                writeline(s,rewFuns.right)
                pause(3)
            end
        elseif trajectory_text{triali-1} == 'R' && trajectory_text{triali-2} == 'L'
            % reward dispensers need about 3 seconds to release pellets
            for rewardi = 1:pellet_count
                writeline(s,rewFuns.left)
                pause(3)
            end
        end 
    end
    %}
    
    % t-beam
    % check which direction the rat turns at the T-junction
    next = 0;
    while next == 0
        irTemp = [];
        irTemp = read(s,4,"uint8");         
        if irTemp == irBreakNames.tRight  
            % track the trajectory_text
            trajectory_text{triali} = 'R';
            trajectory(triali)      = 0;
            
            % close opposite door
            writeline(s,doorFuns.tLeftClose)  
            
            % open sb door
            pause(0.25)
            writeline(s,doorFuns.sbRightOpen)
            
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
            % track the trajectory_text
            trajectory_text{triali} = 'L';
            trajectory(triali)      = 1;            
            
            % close door
            writeline(s,doorFuns.tRightClose)
            
            % open sb door
            pause(0.25)            
            writeline(s,doorFuns.sbLeftOpen)
            
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
    
    % Reward zone and eating
    % send to netcom 
    
    
    % return arm
    next = 0;
    while next == 0
        irTemp = read(s,4,"uint8");         
        if irTemp == irBreakNames.gzRight 
            % send neuralynx command for timestamp

            % close both for audio symmetry
            writeline(s,doorFuns.gzLeftClose)
            pause(0.25)
            writeline(s,doorFuns.gzRightClose)
            pause(0.25)
            writeline(s,doorFuns.tRightClose)
            
            next = 1;                          
        elseif irTemp == irBreakNames.gzLeft
            % send neuralynx command for timestamp

            % close both for audio symmetry
            writeline(s,doorFuns.gzLeftClose)
            pause(0.25)
            writeline(s,doorFuns.gzRightClose)
            pause(0.25)
            writeline(s,doorFuns.tLeftClose)            
            
            next = 1;
        end
    end      
    
    % startbox
    next = 0;
    while next == 0
        irTemp = read(s,4,"uint8");         
        if irTemp == irBreakNames.sbRight 
            % send neuralynx command for timestamp
            
            pause(1) % give them time to get situated
            
            % close startbox door
            writeline(s,doorFuns.sbRightClose)
            
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
                
                % send neuralynx command

                % delay
                pause(delay_length);

                % stop treadmill
                pause(0.25)                
                write(s,treadFuns.stop,'uint8');
            end
            
            next = 1;                          
        elseif irTemp == irBreakNames.sbLeft
            % send neuralynx command for timestamp
            
            pause(1) % give them time to get situated
            
            % close startbox door
            writeline(s,doorFuns.sbLeftClose)            

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
                
                % delay - accounting for pellet lag
                pause(delay_length); % there is a 3 second pause between pellet releases

                % stop treadmill
                pause(0.25)                
                write(s,treadFuns.stop,'uint8');
            end
            
            next = 1;  
        end 
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






