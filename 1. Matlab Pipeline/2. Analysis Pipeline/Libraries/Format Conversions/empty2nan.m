function [array] = empty2nan(array)
    for rowi = 1:size(array,1)
        for coli = 1:size(array,2)
            if isempty(array{rowi,coli})
                array{rowi,coli} = NaN;       
            end
        end
    end
end

