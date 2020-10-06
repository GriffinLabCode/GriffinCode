%% 2D instantanious speed
% this function should be depricated once other code that incoporates it is
% updated to use instant_speed2
%
% This function calculates 2 dimensional instantaneous velocity,
% then takes the absolute value resulting in instantaneous speed.
%
% ~~~ INPUTS ~~~
% x: a double array containing x-dimension data
% y: a double containing y-dimension data
% t: a double containing time stamps derived using the same method for
%       getting x and y position data (should both be found in VT1.mat)
%
% ~~~ OUTPUTS ~~~
% speed: instantaneous speed. Unit depends on input. If recorded camera,
% then pixels/sec^2
% velocity: instantaneous velocity
% tDiff: difference in time (ie instantaneous time)
%
% Written by John Stout
% last edit 3/8/2020

function [speed,vel,pos,tDiff] = instant_speed(x,y,t)

% sampling frequency
sfreq = round(29.97);

% calculate instantaneous velocity 
for jj = 1:length(t)-1
    vel(jj) = ((sqrt(((x(jj+1)-x(jj))^2)+...
        ((y(jj+1)-y(jj))^2))))/...
        (t(jj+1)-t(jj));
    
    % instant position
    pos(jj) = sqrt(((x(jj+1)-x(jj))^2)+...
        ((y(jj+1)-y(jj))^2));
    
    % instant time diff
    tDiff(jj) = t(jj+1)-t(jj);
end  
    
% speed has no direction
speed = abs(vel);

end