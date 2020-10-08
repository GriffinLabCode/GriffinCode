% Int_traj_indicator tells you which boolean value is left and right.
%                       for example: Int_indicator = 0, tells us that using
%                       the int file, and focusing on column 3, we will do
%                       the trajectory assigned to values "0"

function [stemX,stemY] = linearSkeleton_stem(x, y, ts, Int)

% inputs will be stem entry, T-junction location, and end points for
% trajectory 
for i = 1:size(Int,1)
    xPos(1,i) = x(ts == Int(i,1));
    xPos(2,i) = x(ts == Int(i,6));
    xPos(3,i) = x(ts == Int(i,2)); 
    xPos(4,i) = x(ts == Int(i,7)); 
    xPos(5,i) = x(ts == Int(i,8)); 
    
    yPos(1,i) = y(ts == Int(i,1));
    yPos(2,i) = y(ts == Int(i,6));    
    yPos(3,i) = y(ts == Int(i,2)); 
    yPos(4,i) = y(ts == Int(i,7));     
    yPos(5,i) = y(ts == Int(i,8));     
end

figure('color','w'); hold on;
title(['Note the Int locations. ' newline 'Define your stem skeleton to be within the Int locations'])
plot(x,y,'Color',[.8 .8 .8])
for i = 1:size(yPos,1)
    plot(xPos(i,:),yPos(i,:),'o','Color','b')
    ylim([min(yPos(4,:))-200 max(yPos(4,:))+200]);
    xlim([min(xPos(5,:))-200 max(xPos(2,:))+200]);
end
[stemX,stemY] = ginput;
close;

% abs value to make positive
stemX = abs(stemX)';
stemY = abs(stemY)';

pause(2);
close 