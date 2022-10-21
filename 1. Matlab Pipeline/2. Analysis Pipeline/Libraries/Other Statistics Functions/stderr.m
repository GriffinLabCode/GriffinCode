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

function [sem] = stderr(mat,fun_arg)

    if fun_arg == 1
        % loop over columns, computing sem over rows
        for i = 1:size(mat,2)
            % numobs
            numObs = size(mat(:,i),1) - sum(isnan(mat(:,i)));
            % sem
            sem(:,i) = (nanstd(mat(:,i)))./(sqrt(numObs)); % if mat is a vector        
        end
    elseif fun_arg == 2
        % loop over rows
        for i = 1:size(mat,1)
            % numObs
            numObs = size(mat(i,:),2) - sum(isnan(mat(i,:)));
            % sem
            sem(i,:) = (nanstd(mat(i,:)))./(sqrt(numObs)); % if mat is a vector                  
        end
    end
    
    if isempty(fun_arg) || exist('fun_arg')==0
        error('Add fun_arg, an argument telling stderr which direction to perform its computation along your matrix')
    end

end
