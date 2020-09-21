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

function [alternIdx,persevIdx] = alternPersevIdx(datafolder,int_name)

% load int
cd(datafolder);
load(int_name);

% numtrials
numTrials = size(Int,1);

% if 0, it indicates that the trajectory on trial+1 is the same as trial.
% Absolute value indicates no negative values (can occur bc trajectory is
% indicated by ones and zeros).
traj_change = abs(diff(Int(:,3)));  

% perseveration index: number of perseverations / total number of trials
persevIdx = numel(find(traj_change == 0))/numTrials; % if changed to percent, it can be interpreted as N% of trials were perseveration

% alternation index: number of alternations/number of trials
alternIdx = numel(find(traj_change == 1))/numTrials;

