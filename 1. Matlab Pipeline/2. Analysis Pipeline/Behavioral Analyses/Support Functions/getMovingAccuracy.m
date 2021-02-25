%
% this code creates a moving average of behavioral data
% 
% -- INPUTS -- %
% accuracy: binary vector where 0 is either correct or incorrect, and 1 is
%               the opposite. Each element in your vector tells you if the
%               rat performed correctly or incorrectly on a trial by trial
%               basis
% correct_indicator: if 0 = correct, set this to 0. If 1 = correct, set
%               this to 1
%
% written by John Stout

function [AccAcrossTime] = getMovingAccuracy(accuracy,correct_indicator)

    % get accuracy
    for i = 1:length(accuracy)
        if correct_indicator == 1
            AccAcrossTime(i) = (length(find(accuracy(1:i)==1))/i)*100;
        elseif correct_indicator == 0
            AccAcrossTime(i) = (length(find(accuracy(1:i)==0))/i)*100;
        else
            error('Did not format variable "correct_indicator" correctly...')
        end
    end 
end