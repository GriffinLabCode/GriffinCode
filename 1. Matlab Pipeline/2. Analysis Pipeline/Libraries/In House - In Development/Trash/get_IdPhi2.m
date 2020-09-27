%% IdPhi
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

%function [IdPhi] = get_IdPhi2(x_pos,y_pos)

% get the derivative of x and y
deriv_x = diff(x_pos);
deriv_y = diff(y_pos);

% get arctangent of the derivatives (Phi)
phi = atan2(deriv_x,deriv_y);

% unwrap orientation to prevent circular transitions
phi_unwrap = unwrap(phi);

% derivative of phi
dPhi = diff(phi_unwrap);

% absolute value
absPhi = abs(dPhi);

% integrated absolute phi - not sure what they actually meant by
% integrated, but Jesse added it.
IdPhi = sum(absPhi);

IdPhi = trapz(absPhi)

IdPhi = integral(get_absPhi,min(x_pos),max(x_pos));

