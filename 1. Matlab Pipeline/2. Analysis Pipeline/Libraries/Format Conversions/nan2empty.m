function [array] = nan2empty(array)
    for rowi = 1:size(array,1)
        for coli = 1:size(array,2)
            if isnan(array{rowi,coli})
                array{rowi,coli} = [];       
            end
        end
    end
end