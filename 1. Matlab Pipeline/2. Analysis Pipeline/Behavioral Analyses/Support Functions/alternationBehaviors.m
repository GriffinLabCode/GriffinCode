%% alternation and perseveration indices
% this function estimates the degree to which the rat alternates or
% perseverates in a session. The output are ratios, which when converted to
% percentages, can be interpreted as "The rat perseveratied (or alternated
% depending on the variable) on N% of trials"
%
% -- INPUTS -- %
% datafolder: directory indicating datafolder
% int_name: int file name within datafolder directory
%
% -- OUTPUTS -- %
% alternIdx: a ratio, indicating the degree of alternation with respect to
%               the entire session. Estimated by: # alternations / # trials
% persevIdx: a ratio, indicating the degree of perseveration. Like above,
%               estimated by: # same side consecutive turns / # trials
%
% written by John Stout on 9/21/2020

function [alternIdx,persevIdx,turnBias,errorRate,traj_change,errorCorrectError] = alternationBehaviors(Int)

% numtrials
numTrials = size(Int,1);

% if 0, it indicates that the trajectory on trial+1 is the same as trial.
% Absolute value indicates no negative values (can occur bc trajectory is
% indicated by ones and zeros).
traj_change = abs(diff(Int(:,3)));  

% perseveration rate: number of errors / total number of trials
errorRate  = numel(find(traj_change == 0))/numTrials; % if changed to percent, it can be interpreted as N% of trials were perseveration

% alternation rate: number of alternations/number of trials
alternIdx = numel(find(traj_change == 1))/numTrials;

% perseveration index: proportion of same side lefts/ proportion of same
% side rights
turn_idx  = Int(2:end,3);
error_idx = Int(2:end,4);

% left turns
left_errors  = find(error_idx == 1 & turn_idx == 1);
right_errors = find(error_idx == 1 & turn_idx == 0);
numErrors    = numel(left_errors)+numel(right_errors);

% perseveration index - this doesn't capture it bc it doesn't normalize by
% numbr of trials
%persevIdx = numel(right_errors)/(numel(left_errors)+numel(right_errors));

% how many errors are in one direction, normalized by trial count?
persevErrorIdx = abs(numel(right_errors)-numel(left_errors))/numTrials;

% Turn bias
right_turns = find(Int(:,3) == 1);
left_turns  = find(Int(:,3) == 0);
turnBias   = abs(numel(right_turns)-numel(left_turns))/numTrials;

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

% error correction - find instances like the following: LL RR or RR LL or
% RRR LL or LLLLL RR etc... essentially, it finds an error correction error
clear errorCorrectError
for i = 2:size(Int,1)-2
    if (Int(i-1,3) == Int(i,3)) & (Int(i,3) ~= Int(i+1,3)) & (Int(i+1,3) == Int(i+2,3))
        errorCorrectError(i-1) = 1;
    else
        errorCorrectError(i-1) = 0;
    end
end
eCe_possibilities = length(2:2:numTrials)-1;
errorCorrectError = sum(errorCorrectError)/eCe_possibilities; % n-1 bc going by twos
