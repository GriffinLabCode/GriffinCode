%% stderr
%
% this function calculates standard error of the mean
%
% mat can be a vector or matrix, but MUST be formatted where rows are the
% number of observations that you would average across. In other words, if
% you have N subjects with each one having a particular score and you want
% the sem of the scores across subjects, your vector would be (N subjects,
% 1 Independent variable Score). If you had multiple scores and you want a
% matrix of SEMs per IV score type, your matrix would be (N subjects, M IV
% score types) where the first input is row and the second is column.
%
% written by John Stout

function [sem] = stderr(mat)
    
    if size(mat,1) == 1 || size(mat,2) == 1
        sem    = (nanstd(mat))./(sqrt(length(mat))); % if mat is a vector
    else
        sem    = (nanstd(mat))./(sqrt(size(mat,1))); % if mat is a matrix (observations X variables)
    end

end