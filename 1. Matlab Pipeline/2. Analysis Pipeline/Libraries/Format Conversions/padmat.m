%% function that pads matrices along rows or columns to whatever variable you choose

% --- INPUTS --- %
% array: matrix
% padsize: scalar denoting size to pad matrix (e.g. say you want to matrix
%           padded to 50)
% var: variable to pad matrix with (eg var = NaN)
% paddim: dimension to pad (eg 'col' or 'row')
%
% -- OUTPUTS -- %
% paddedArray: matrix padded
%
% written by John Stout

function [paddedArray] = padmat(array,padsize,var,paddim)

    if contains(paddim,'row')
        
        % assign variable
        paddedArray = array;
        
        % find difference of variable to what you want to pad
        diffVar = padsize-size(array,1);
        
        % do end+1 through the difference and set to nan
        paddedArray(end+1:end+diffVar,:)=var;
        
    elseif contains(paddim,'col')
        
        % assign variable
        paddedArray = array;
        
        % find difference of variable to what you want to pad
        diffVar = padsize-size(array,2);

        % do end+1 through the difference and set to nan
        paddedArray(:,end+1:end+diffVar)=var; 
        
    end
    