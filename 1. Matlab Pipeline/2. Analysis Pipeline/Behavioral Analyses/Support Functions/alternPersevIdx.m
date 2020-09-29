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

function [alternIdx,persevErrorIdx,persevIdx,errorRate,traj_change] = alternPersevIdx(datafolder,int_name)

% load int
cd(datafolder);
load(int_name);

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

% how many turns are in one direction, in general?
right_turns = find(Int(:,3) == 1);
left_turns  = find(Int(:,3) == 0);
persevIdx   = abs(numel(right_turns)-numel(left_turns))/numTrials;

% if you don't consider the number of incorrect trials, then you have
% values approaching 1/1 when the rat performed really well, but got a
% right turn wrong twice (and no lefts). This isn't really perseveration,
% it could be, but not many samples. Therefore, this metric accounts for
% the number of lefts and right turns via subtraction, then it normalizes
% by the number of trials to account for cases where there are minimal
% incorrect trials, but every incorrect is in one direction

% alternation index
%left_alts  = find(error_idx == 0 & turn_idx == 1);
%right_alts = find(error_idx == 0 & turn_idx == 0);
%alternIdx = abs(numel(right_alts)-numel(left_alts))/numTrials;
%alternIdx  = numel(right_alts)/(numel(left_alts)+numel(right_alts));
