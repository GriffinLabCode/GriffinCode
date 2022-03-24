%% emptyCellErase
% this code eliminates any cell ararys that are empty
%
% -- INPUTS -- %
% cell array of vector formatting
%
% -- OUTPUTS -- %
% array: the corrected array
% array2rem: the index of removed cell containers
%
% JS

function [array,ind2rem] = emptyCellErase(array)
    if size(array,1) == 1 || size(array,2) == 1
        array2rem = zeros(size(array));
        for rowi = 1:size(array,1)
            for coli = 1:size(array,2)
                if isempty(array{rowi,coli})
                    array2rem(rowi,coli) = 1;       
                end
            end
        end
        array(array2rem==1)=[];
        % get index to remove
        ind2rem = find(array2rem==1);
    else
        error('This code only works if your cell array is a vector')
    end
end


    