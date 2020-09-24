%% manual fix int
% this function is designed so that should a user redefine an int file for
% a sessions worth of data that he/she did not collect, but wants to remove
% specific trials based on the original int, they can easily sift through
% them, manually
%
% written by John Stout - 9/23/2020

function [Int2check,Int2copy] = manualFixInt(Int2check_name,Int2copy_name)

disp('Make sure your current folder is the datafolder you want to get data from')

datafolder = pwd;

Int2check = load(Int2check_name);
Int2check = Int2check.Int;

Int2copy = load(Int2copy_name);
Int2copy = Int2copy.Int;

