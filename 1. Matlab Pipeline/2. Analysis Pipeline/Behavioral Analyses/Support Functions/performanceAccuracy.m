%% percent correct
%
% -- INPUTS -- %
% datafolder: directory indicating datafolder
% int_name: int file name within datafolder directory
%
% -- OUTPUTS -- %
% accuracy: in percent, how well the rat performed
%
% written by John Stout on 9/23/2020

function [percent_accuracy] = performanceAccuracy(datafolder,int_name)

% load int
cd(datafolder);
load(int_name);

% numtrials
numTrials = size(Int,1);

% percent accuracy
percent_accuracy = ((numel(find(Int(:,4)==0)))/numTrials)*100;

