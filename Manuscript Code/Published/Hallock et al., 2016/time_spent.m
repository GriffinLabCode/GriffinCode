function [time_spent, velocity, performance] = time_spent(Int)
%%

%   This function calculates time spent at the maze choice-point, as well
%   as stem velocity

%   Outputs:
%       time_spent:     Time spent at the choice-point (seconds)
%       velocity:       Stem velocity (cm/sec)
%       performance:    Proportion correct choices

%   Inputs:
%       Int:            n trials x 8 matrix of maze timestamp values

%%

% Calculate time spent in the choice-point, and stem velocity
% Stem velocity is calculated based on the assumption that the maze stem is
% 135 cm long (if not, change value on line 24
% Stem velocity is not filtered for zero velocity epochs
for i = 1:size(Int,1)
    time(i) = (Int(i,6) - Int(i,5))/1e6;
    time_stem = (Int(i,5) - Int(i,1))/1e6;
    vel(i) = 135/time_stem;
end

time_spent = mean(time);
velocity = mean(vel);

Correct = find(Int(:,4) == 0);
performance = length(Correct)/size(Int,1);


