%% get current script path
% this function grabs the path that houses the script/function thats being
% run
%
% -- INPUTS -- %
% N/A
%
% -- OUTPUTS -- %
% myPath: the directory that houses your script - you can cd to this
%
% written by John Stout

function [myPath] = getCurrentPath()

% get current path + function name
getPath = matlab.desktop.editor.getActiveFilename;

% remove function name
splitPath = split(getPath,'\');
splitPath(end)=[];

% join for path
myPath = cell2mat(join(splitPath,'\'));
