%% within session serial reversal task
% Gilespie et al 2021 used a crown-like maze and had rats learn how to
% perform rule switches within the task.
% required 2-3 60min sessions of the task per day for 3 weeks
%
% first subjects completed 3-4 60m sessions on a walled linear track and
% only subjects who completed >50 reward traversals moved on (highly
% motivated subjects)
%
% this task is going to have a search phase and repeat phase just like that
% paper, followed by uncued goal changes. If the rats perform 8/10 within
% 10 trials, the rule switches from L to R or from R to L
%
%

% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir)

%% some parameters
taskDuration = 60; % in minutes
%numTrials = 100;

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
irArduino.Delay       = 'D8';
irArduino.rGoalArm    = 'D10';
irArduino.lGoalArm    = 'D12';
irArduino.rGoalZone   = 'D7';
irArduino.lGoalZone   = 'D2';
irArduino.choicePoint = 'D6';

%writeline(s,doorFuns.closeAll);
%{
for i = 1:10000000
    readDigitalPin(a,irArduino.Delay)
end
%}

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

%% task

% randomly choose which arm will get rewarded on trial 1
rng('shuffle'); % make sure the seed is shuffled
trajOptions = [{'L'} {'R'}]; % define possible options
currentTraj = randsample(trajOptions,1); % randomly select one arm
currentTraj = currentTraj{1};

% mark session start
sStart = [];
sStart = tic;

% do a while loop and when the elapsed time > task DUration, end
sbOpen = []; tEntry = []; trajectory = []; time2choice = []; trajectory_text = [];
while toc(sStart)/60 < taskDuration

    % break out of the session if youre out of time
    if toc(sStart)/60 > taskDuration
        break % break out of for loop
    end           
    
    % the rat always starts in the startbox
    writeline(s,[doorFuns.sbRightOpen doorFuns.sbLeftOpen doorFuns.centralOpen]);
    disp('Trial start')
    %[succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayExit" 102 2'); 
    %sbOpen = [sbOpen tic];
    
    % mark when the choice-point is entered
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.choicePoint) == 0   % if central beam is broken
            disp('CP entry')
            tEntry = [];
            tEntry = tic;            
            % neuralynx timestamp command
            %[succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPentry" 202 2');
            next = 1; % break out of the loop
        end
    end 
    
    % check which direction the rat turns at the T-junction
    next = 0;
    while next == 0
        if readDigitalPin(a,irArduino.rGoalArm)==0 || readDigitalPin(a,irArduino.lGoalArm)==0
            
            % neuralynx timestamp command
            %[succeeded, cheetahReply] = NlxSendCommand('-PostEvent "CPexit" 202 2');            
            % track the trajectory_text
            time2choice     = [time2choice; toc(tEntry)]; % amount of time it took to make a decision
                    
            if readDigitalPin(a,irArduino.lGoalArm)==0
                trajectory_text = [trajectory_text;'L'];
                trajectory      = [trajectory; 1];  
                % neuralynx timestamp command
                %[succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Left" 312 2');
                
            elseif readDigitalPin(a,irArduino.rGoalArm)==0
                trajectory_text = [trajectory_text;'R'];
                trajectory      = [trajectory; 0];                    
                % neuralynx timestamp command
                %[succeeded, cheetahReply] = NlxSendCommand('-PostEvent "Right" 312 2');
            end
            disp(['CP exit - ideal turn is ' num2str(currentTraj),' Rat turned ',num2str(trajectory_text(end))])
            
            % if the current trajectory matches what it should 
            if trajectory_text(end) == currentTraj
                
                if numel(trajectory_text) < 10
                    if contains(currentTraj,'R')
                        writeline(s,rewFuns.right)
                    elseif contains(currentTraj,'L')
                        writeline(s,rewFuns.left)
                    end
                end
                
                % now, here comes the weird part. If there are more than 10
                % trials, and the rat has performed >80% on the last 10,
                % switch
                % last 11 as it takes a trial for the rat to discover
                if numel(trajectory) > 10
                    % find instances where trajectories were met
                    metTraj = [];
                    metTraj = contains(trajectory_text(end-9:end),currentTraj);
                    % get average across data (it's boolean, so it works)
                    avgMet = nanmean(metTraj)*100;
                    % if the rat performed over 80%
                    if avgMet > 80
                        if contains(currentTraj,'R')
                            currentTraj = 'L';
                        elseif contains(currentTraj,'L')
                            currentTraj = 'R';
                        end
                    end
                end      
            end
            pause(5)
            if contains(trajectory_text(end),'L')
                writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftClose doorFuns.tLeftOpen doorFuns.tRightClose]);
            elseif contains(trajectory_text(end),'R')
                writeline(s,[doorFuns.gzRightOpen doorFuns.gzLeftOpen doorFuns.sbRightClose doorFuns.sbLeftOpen doorFuns.tLeftClose doorFuns.tRightClose]);
            end                
            % break while loop
            next = 1;            
        end
    end
    
    % return arm
    next = 0;
    while next == 0
        
        if readDigitalPin(a,irArduino.lGoalZone) == 0
            
            % neuralynx timestamp command
           % [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "ReturnRight" 422 2');
            
            % close both for audio symmetry and do opposite doors first
            % with a slightly longer delay so the rats can have a fraction
            % of time longer to enter
            pause(0.5)
            writeline(s,[doorFuns.gzRightClose])
            pause(0.25)
            writeline(s,[doorFuns.gzLeftClose])
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);
            pause(0.25)
            %writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]); 
            
            next = 1;
            
        elseif readDigitalPin(a,irArduino.rGoalZone) == 0

            % neuralynx timestamp command
           % [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "ReturnLeft" 412 2');            
            
            % close both for audio symmetry
            pause(0.5)
            writeline(s,[doorFuns.gzLeftClose])
            pause(0.25)
            writeline(s,[doorFuns.gzRightClose])
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);
            pause(0.25)
            writeline(s,[doorFuns.sbLeftOpen doorFuns.sbRightOpen]);            

            next = 1;
        end
    end
    disp('Returning')

    %{
    next = 0;
    while next == 0   
        % track choice entry
        if readDigitalPin(a,irArduino.Delay)==0 
            disp('DelayEntry')
            % neuralynx timestamp command
          %  [succeeded, cheetahReply] = NlxSendCommand('-PostEvent "DelayEntry" 102 2');  
            %writeline(s,[doorFuns.tLeftClose doorFuns.tRightClose])
            %tEntry = [];
            %tEntry = tic;
            next = 1;

        end
    end
    %}
end
% make a noise to end
load handel.mat;
sound(y, 2*Fs);    



