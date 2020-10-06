%% 2D instantanious kinematics code
% This function estimates instantaneous speed, velocity, and acceleration
% by taking x and y coordinates, estimating their derivates using gradient,
% a central difference method for derivative estimation that allows the
% user to retain the same number of data points you start with, finding the
% hypotenuse between two coordinates, then dividing the hypotenuse by the
% derivative of time.
%
% ~~~ INPUTS ~~~
% x: a double array containing x-dimension data
% y: a double containing y-dimension data
% t: a double containing time stamps derived using the same method for
%       getting x and y position data (should both be found in VT1.mat)
% convert2sec : 'Y', 'y', 'n', or 'N'. The 'Y' indicates that you
%                   converted the timestamps variables to seconds. The 'N'
%                   option indicates that you did not. 
%
% ~~~ OUTPUTS ~~~
% speed: instantaneous speed. Unit depends on input. If recorded camera,
%           then pixels/sec^2
% vel: instantaneous velocity
% acc: instantaneous acceleration
%
% Written by John Stout
% last edit 10/6/2020

function [speed,vel,acc] = kinematics2D(x,y,t,convert2sec)

% sampling frequency
sfreq = ceil(getVTsrate(t,convert2sec)); % rounded to a integer for ease of computation and stuff

% handle whether seconds (timestamps variable "t") is converted into
% seconds. If not, do so.
if contains(convert2sec,'y') | contains(convert2sec,'y')
    t_og = t; t = []; % not necessary, but good practice to clear the variable
    t = t_og./1e6;
end

% get hypotenuse between x and y coordinates (a2+b2=c2). WHen
% considering an entire vector, we can just work with the derivatives.
% To retain the correct length of the vector, we can work with
% gradient, a centroid method for derivative estimation.
a2 = (gradient(x)).^2; %(x(jj+1)-x(jj)); - note that this is the same as derivative
b2 = (gradient(y)).^2; %(y(jj+1)-y(jj));
c  = sqrt(a2+b2);      % c2 = a2+b2, so c = sqrt(a2+b2)
dt = gradient(t);      % get derivative of time

% velocity should be the hypotenus/change in time
vel = c./dt;
      
% speed has no direction
speed = abs(vel);

% get acceleration
acc = gradient(vel)./dt;

end