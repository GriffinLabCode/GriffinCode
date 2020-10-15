%% cellcat
% fun_inputs: which orientation you want to collapse across the cell array
% cat_apply: which form of concatenation to apply; 'horzcat' or 'vertcat'
%
% -- OUTPUTS -- %
% fun_out: output of concatenation
% 
% written by John Stout on 10/15/2020

function [fun_out] = cellcat(cell_array,cat_apply,fun_input)

% take arguments and function and change for application
fun_argument = str2double(fun_input);
fun_apply = str2func(cat_apply);

% must decide which way to loop
if contains(fun_input,'row')
    looper = size(cell_array,2);
elseif contains(fun_input,'col')
    looper = size(cell_array,1);
end

for i = 1:looper
    if contains(fun_input,'row')
        fun_out{i} = fun_apply(cell_array{:,i});
    elseif contains(fun_input,'col')
        fun_out{i} = fun_apply(cell_array{i,:});
    end
end
    
