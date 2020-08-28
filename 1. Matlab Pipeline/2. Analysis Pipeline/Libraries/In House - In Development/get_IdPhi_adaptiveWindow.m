%% IdPhi adaptive window
%
% Based on this code, it is so much simpler to take the derivative of x and
% y using diff. No real difference
%
% -- INPUTS -- %
% x_pos: x position data as a vector
% y_pos: y position data as a vector
%
% -- OUTPUTS -- %
% intPhi: integrated absolute phi, the metric used to assess VTE behaviors.
% 
% NOTE: 
% IdPhi is a metric used to assess VTE behaviors and is typically zscored
% across the session. See Papale et al., 2013 from Redish lab.
% Additionally, you can use https://github.com/auralius/velocity_estimation
% foaw_diff to use the Redish approach for estimated dx and dy
% (Janabi-Sharifi, Hayward, & Chen, 2000). This information was passed to
% me (John Stout) by Jesse Miles from Mizumori lab.
%
% python code received from Jesse Miles (Mizumori lab on 8-12-2020). The
% code was adapted and made into matlab code by John Stout on 8-14-2020.

function [IdPhi] = get_IdPhi_adaptiveWindow(x_pos,y_pos,ts_diff)

% ts_diff is the difference in time (in sec) of the traversal

% these parameters were defined based off the function foaw_diff
d = 0.05;
m = 20; % this set to 20 provided the same output as diff function

% get velocity - JS
vel_x = foaw_diff(x_pos, ts_diff, m, d);
vel_y = foaw_diff(y_pos, ts_diff, m, d);

% get the derivatives - JS
dx = vel_x*ts_diff;
dy = vel_y*ts_diff;

% get arctangent of the derivatives (Phi)
phi = atan2(dx,dy);

% unwrap orientation to prevent circular transitions
phi_unwrap = unwrap(phi);

% derivative of phi
%dPhi = diff(phi_unwrap);
vel_phi = foaw_diff(phi_unwrap, ts_diff, m, d);
dPhi    = vel_phi*ts_diff;

% absolute value
absPhi = abs(dPhi);

% integrated absolute phi - not sure what they actually meant by
% integrated, but Jesse summed it. Summation seems to be no different than 
% trapz integration.
IdPhi = sum(absPhi);
%IdPhi = trapz(absPhi);

end


