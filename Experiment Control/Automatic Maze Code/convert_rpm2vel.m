%% convert rotations per minute to cm/sec

% https://www.quora.com/How-do-I-convert-rpm-in-m-s
%
% -- INPUTS -- %
% rpm: rotations per minute
%
% -- OUTPUTS -- %
% linear velocity

function [linV] = convert_rpm2vel(rpm)

% define radius
r = 3; % cm radius of the treadmill rotating device

% revolutions per minute
rpm = 16;
rps = rpm/60; % revolutions per sec

% converted velocity
angV = 2*pi*rps; % angular velocity is 2pi(rps)
linV = angV*r;   % linear velocity is angular velocity * radius


