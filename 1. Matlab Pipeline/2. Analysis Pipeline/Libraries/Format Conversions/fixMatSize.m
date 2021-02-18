%% fixMatSize
% quick and easy function to fix differences in size between two variables.
% The while loo

function [datax,datay] = fixMatSize(datax,datay)

    sizeX = size(datax);
    sizeY = size(datay);
    
    while sizeX ~= sizeY 
        
        datax = datax';
        sizeX = size(datax);
        sizeY = size(datay);

    end

    
end