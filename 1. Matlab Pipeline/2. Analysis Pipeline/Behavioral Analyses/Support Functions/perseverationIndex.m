%% Perseveration Index
% quantifying the rate by which a rat perseverates
%
% -- INPUTS -- %
% Int: Int file
%
% -- OUTPUTS -- %
% persevIdx: a ratio, indicating the degree of perseveration. Like above,
%               estimated by: # same side consecutive turns / # trials
%
% written by John Stout on 9/21/2020

function [persevIdx] = perseverationIndex(Int)

% numtrials
numTrials = size(Int,1);

% perseveration
% traj change tells you if the previous turn matched the current turn. so
% traj_change(1) indicates that trial 2 was the same direction as trial 1.
% However, perseveration indicates a pattern of turning in one direction,
% therefore, we must consider more than 1 instances. Here, we consider
% perseveration as an instance of > 2 simultaneous one direction turns
% if persev = 1, then there was a perseveration, if 0, then there wasn't
clear persev
for i = 2:size(Int,1)-1
    if (Int(i-1,3) == Int(i+1,3)) & (Int(i-1,3) == Int(i,3)) & (Int(i,3) == Int(i+1,3))
        persev(i-1) = 1;
    else
        persev(i-1) = 0;
    end
end

% perseveration index - because of indexing (consideration of 3 consecutive
% turns = perseveration), we have to do numTrials-2
persevIdx = sum(persev)/(numTrials-2);
