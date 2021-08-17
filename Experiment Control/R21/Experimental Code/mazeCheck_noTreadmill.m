clear

% check port
if exist("s") == 0
    % connect to the serial port making an object
    s = serialport("COM6",19200);
end

% load in door functions
doorFuns = DoorActions;

% test reward wells
rewFuns = RewardActions;

% close doors
writeline(s,doorFuns.closeAll);
pause(2);

writeline(s,doorFuns.openAll);
pause(2);

% close doors
writeline(s,doorFuns.closeAll);
pause(2);

% reward pellets
pellet_count = 1;
for rewardi = 1:pellet_count
    %pause(0.25)
    writeline(s,rewFuns.left)
    pause(3)
    writeline(s,rewFuns.right)
    pause(3)
end  

prompt  = ['Did pellets come out of dispensors? [y/Y OR n/N] '];
moveOn  = input(prompt,'s');

if contains(moveOn,[{'N'} {'n'}])
    error('Restart hardware. Plug in to computer, turn on E-box, then air compressor.')
end



