%% cellcat
% direction: which orientation you want to collapse across the cell array
% cat_method: which form of concatenation to apply; 'horzcat' or 'vertcat'
%
% -- OUTPUTS -- %
% fun_out: output of concatenation
% 
% written by John Stout on 10/15/2020

function [fun_out] = cellcat(cell_array,cat_method,direction)

% take arguments and function and change for application
%fun_argument = str2double(fun_input);
fun_apply = str2func(cat_method);

% must decide which way to loop
if contains(direction,'row')
    looper = size(cell_array,2);
elseif contains(direction,'col')
    looper = size(cell_array,1);
end

for i = 1:looper
    if contains(direction,'row')
        try
            fun_out{i} = fun_apply(cell_array{:,i});
        catch
            warning('Data were concatenated via NaN padding. Try inverting.')
            fun_out{i} = padcat(cell_array{:,i});
        end
    elseif contains(direction,'col')
        try
            fun_out{i} = fun_apply(cell_array{i,:});
        catch
            warning('Data were concatenated via NaN padding. Try inverting.')
            fun_out{i} = padcat(cell_array{i,:});
        end
    end
end
    
