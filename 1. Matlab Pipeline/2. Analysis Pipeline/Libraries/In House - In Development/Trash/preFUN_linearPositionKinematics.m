%% instantaneous velocity and acceleration
% this code uses linear position and differentiation to estimate velocity
% and acceleration
%
% -- INPUTS -- %
% linearPosition: linearized position for one trajectory
% times: times of the trajectory (in seconds), starting from 0, ending with
%         total time spent in trajectory
% 
% -- OUTPUTS -- %
% velocity: in units/sec
% acceleration: in units/sec^2
%
% written by John Stout

function [velocity,acceleration] = linearPositionKinematics(linearPosition,times)

% velocity (dx/dt)
%velocity = diff(linearPosition)./(diff(times));
velocity = gradient(linearPosition)./(gradient(times));

% acceleration (dv/dt)
acceleration = gradient(velocity)./(gradient(times));

end
