% Int_traj_indicator tells you which boolean value is left and right.
%                       for example: Int_indicator = 0, tells us that using
%                       the int file, and focusing on column 3, we will do
%                       the trajectory assigned to values "0"

function [Xout,Yout] = linearSkeleton_general(x, y)


figure('color','w'); hold on;
title(['Define start and end points'])
plot(x,y,'Color',[.8 .8 .8])
[Xout,Yout] = ginput;
close;

% abs value to make positive
Xout = abs(Xout)';
Yout = abs(Yout)';

pause(2);
close 