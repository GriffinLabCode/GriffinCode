function [array] = nan2zero(array)
    for rowi = 1:size(array,1)
        for coli = 1:size(array,2)
            if isnan(array(rowi,coli))==1
                array(rowi,coli) = 0;       
            end
        end
    end
end

