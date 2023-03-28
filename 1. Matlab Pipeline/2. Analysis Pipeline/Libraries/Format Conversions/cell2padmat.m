%% cell2padmat
% this function takes a cell array of elements differing in size, then
% reshapes it into a matrix with padded data
% this only works if your array is a vector cell
% this also only works if your data are vectors inside of each cell array:
%   array{1} = size of (1 x N)e
%
% -- INPUTS -- %
% array: cell array of vector shape (1 x N). Each cell element is also of
%           size (1 x N). Note that N x 1 should also work.

function [mat] = cell2padmat(array,var,paddim)

    % check format
    array = change_row_to_column(array);
    if size(array,2)>1
        error('This function does not work if your data is a cell-matrix')
    end
        
    % change shape if its not already
    for i = 1:length(array)
        array{i} = change_row_to_column(array{i});
    end
    
    % get padsize
    padsize = max(cell2mat(cellfun2(array,'size',{'1'})));
    
    % now reformat array
    for i = 1:length(array)
        array{i} = padmat(array{i},padsize,NaN,paddim);
    end
    
    % return new array
    mat = horzcat(array{:});
end
