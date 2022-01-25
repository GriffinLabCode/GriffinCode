%% getIntFile
% this is super easy code, really doesnt need to be a function
function [Int] = getIntFile(datafolder,int_name)
    cd(datafolder)
    load(int_name);
end