%% IdPhi
%
% -- INPUTS -- %
% x_pos: x position data as a vector
% y_pos: y position data as a vector
% smooth: set to 1 if you to smooth x and y data
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

function [IdPhi] = get_IdPhi(x_pos,y_pos,smooth_data)

% try smoothing - moving seems to be smoothest
if smooth_data == 1
    x_pos = smooth(x_pos,'moving');
    y_pos = smooth(y_pos,'moving');
end

% get the derivative of x and y
dx = diff(x_pos);
dy = diff(y_pos);

% get arctangent of the derivatives (Phi)
phi = atan2(dx,dy);

% unwrap orientation to prevent circular transitions
phi_unwrap = unwrap(phi);

% derivative of phi
dPhi = diff(phi_unwrap);

% absolute value
absPhi = abs(dPhi);

% integrated absolute phi - not sure what they actually meant by
% integrated, but Jesse summed it. Summation seems to be no different than 
% trapz integration.
IdPhi = sum(absPhi);
%IdPhi = trapz(absPhi); 

end


