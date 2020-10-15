%% cellfun2
% cellfun is good, but its hard to control certain functions that have
% direction. For example, mean(n,1) vs mean(n,2) would give you very
% different outputs. Therefore, this code takes a matrix (or vector) of
% cell arrays, and computes a function (fun_name) using user guidance
% (fun_inputs)
%
% -- INPUTS -- %
% cell_array: matrix or vector of cell arrays
% fun_name: function name ('mean' for mean)
% fun_inputs: if you selected 'mean', you could write fun_inputs = {'1'},
%               fun_inputs = {'2'}, or fun_inputs = {'3'} for the different
%               mean orientations
% 
% -- OUTPUTS -- %
% fun_out: the output of what you put in
%
% written by John Stout on 10/15/2020

function [fun_out] = cellfun2(cell_array,fun_name,fun_inputs)

%fun_inputs   = {'1'};
fun_argument = str2double(cell2mat(fun_inputs));

%fun_name   = 'mean';
fun_apply  = str2func(fun_name);

for rowi = 1:size(cell_array,1) 
    for coli = 1:size(cell_array,2)
        fun_out{rowi,coli} = fun_apply(cell_array{rowi,coli},fun_argument);
    end
end



        