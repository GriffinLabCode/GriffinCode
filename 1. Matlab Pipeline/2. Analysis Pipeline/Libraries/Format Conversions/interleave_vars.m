%% interleave variables


function [out] = interleave_vars(x,y);

    out_temp = [x;y];
    out = out_temp(:)';
    
end