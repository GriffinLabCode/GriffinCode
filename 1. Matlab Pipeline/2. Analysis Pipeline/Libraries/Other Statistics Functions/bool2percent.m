%% boolean accuracy vector to percent correct
% -- INPUTS -- %
% dataIn: boolean data
% correctInd: 0 if 0 is correct. 1 if 1 is correct
%
% -- OUTPUTS -- %
% dataOut: percent accurate
%
function [dataOut] = bool2percent(dataIn,correctInd)
    if correctInd == 0
        dataOut = (1-mean(dataIn))*100;
    elseif correctInd == 1
        dataOut = mean(dataIn)*100;
    end
end
        
        