% IR beam break labels
% these are the ascii code for beam breaks
%
% to check, highlight read(s,4,"uint8") hit F9, then go break an ir beam
%
%
% written by John Stout

function [irBreak] = irBreakLabels()

% central arm
irBreak.central  = [77,83,48,10];

% right side
irBreak.gzRight  = [77,65,50,10];
irBreak.tRight   = [77,83,50,10];
irBreak.sbRight  = [77,80,50,10];
irBreak.rewRight = [77,70,50,10];

% left side
irBreak.gzLeft  = [77,65,49,10];
irBreak.tLeft   = [77,83,49,10];
irBreak.sbLeft  = [77,80,49,10];
irBreak.rewLeft = [77,70,49,10];

end

