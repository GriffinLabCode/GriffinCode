function [varFilled] = interp_helper(var2fill,fill2var)

    x  = linspace(0, 1,length(var2fill));
    xq = linspace(0, 1,length(fill2var));
    v  = var2fill;
    varFilled = interp1(x,v,xq,'spline');
    
end