%% view Int positions from an existing int file
% this function is meant to provide an easy way to view int file
% information from a file that does not contain int information
%
% datafolder: the directory location of the int file youre interested in
% int_name: the name of the int file you're interested in ('Int.mat')
% vt_name: the name of the VT file (typically 'VT1.mat')
% missing_data: can be 'exclude','interp',or 'ignore'. Would recommend
%               exclude or interp
%
% written by John Stout - 9/23/2020

function [] = viewExistingIntPositions(datafolder,int_name,vt_name,missing_data)

% load data
load(int_name)
[pos_x, pos_y, pos_t] = getVTdata(datafolder,missing_data,vt_name);

% checkInt script
checkInt;
