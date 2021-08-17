%% interleave variables


function [out] = interleave_vars(x,y);

    x = change_row_to_column(x)';
    y = change_row_to_column(y)';
    out_temp = [x;y];
    out = out_temp(:)';
    
end