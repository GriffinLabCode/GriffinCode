function [array] = zero2nan(array)
    for rowi = 1:size(array,1)
        for coli = 1:size(array,2)
            if array(rowi,coli) == 0
                array(rowi,coli) = NaN;       
            end
        end
    end
end

