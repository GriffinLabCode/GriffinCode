%% cleaning script

% check port
if exist("s") == 0
    % connect to the serial port making an object
    s = serialport("COM6",19200);
end

% load in door functions
doorFuns = DoorActions;

% close doors
writeline(s,closeAll);

% clean treadmill
[treadFuns,treadSpeed] = TreadMillFuns;
% load treadmill functions and settings
[treadFuns,treadSpeeds] = TreadMillFuns;
targetSpeed = 10;
speedVector = 4:2:targetSpeed;

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
