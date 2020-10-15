%% convert cell array to 3D array
% this only works if your array is all of equal sizes
%
% -- INPUTS --%
% cell_array: a cell array
%
% -- OUTPUTS -- %
% newArray: a 3D array containing the data from the cell array, except now
%               in double format
%
% written by John Stout, but the newArray code was found here -> https://www.mathworks.com/matlabcentral/answers/35766-cell-array-into-3d-matrix

function [newArray] = cellTo3D(cell_array)

    % if cell array is empty
    if isempty(cell_array)
        newArray = [];
        disp('Input argument was an empty array, output is therefore empty')
        return
    end
    
    % check sizes
    check_size = cellfun(@size,cell_array,'UniformOutput',false);
    check_size = vertcat(check_size{:});
    
    if numel(unique(check_size(:,1))) > 1 | numel(unique(check_size(:,2))) > 1
        error(['The sizes of your cell array are not equal in dimensions'])
    end
    
    % convert to a 3D array
    newArray = cat(3, cell_array{:});

end   