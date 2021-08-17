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

% load treadmill functions and settings
[treadFuns,treadSpeeds] = TreadMillFuns;

% close doors
writeline(s,doorFuns.closeAll);
pause(2);

writeline(s,doorFuns.openAll);
pause(2);

% close doors
writeline(s,doorFuns.closeAll);
pause(2);

% begin treadmill
write(s,treadFuns.start,'uint8');

prompt  = ['Did doors properly open and close? [y/Y OR n/N] '];
moveOn  = input(prompt,'s');

if contains(moveOn,[{'N'} {'n'}])
    error('Restart hardware. Plug in to computer, turn on E-box, then air compressor.')
end

% increase tread speed gradually
speed_cell = cell(size(fieldnames(treadSpeeds),1)+1,1);

% fill the first cell with nan because there is no 1mpm rate
speed_cell{1} = NaN;

% make an array where its row index is the speed
speed_cell(2:end) = struct2cell(treadSpeeds);
speedVector = [2 4 6];
for i = speedVector
    % set treadmill speed
    write(s,uint8(speed_cell{i}'),'uint8'); % add a second command in case the machine missed the first one
    pause(0.25)
end  

prompt  = ['Is the treadmill working properly? [y/Y OR n/N] '];
moveOn  = input(prompt,'s');

if contains(moveOn,[{'N'} {'n'}])
    error('Restart hardware. Plug in to computer, turn on E-box, then air compressor.')
end

write(s,treadFuns.stop,'uint8');

% reward pellets
pause(0.25)
writeline(s,rewFuns.right)
pause(3)
writeline(s,rewFuns.left)

prompt  = ['Did pellets come out of dispensors? [y/Y OR n/N] '];
moveOn  = input(prompt,'s');

if contains(moveOn,[{'N'} {'n'}])
    error('Restart hardware. Plug in to computer, turn on E-box, then air compressor.')
end



