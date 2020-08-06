%% conversion factor for pixels 2 cm
% make sure to run 'Startup'
% Directions: pick a session with good position data. Measure the maze (y
% axis would be from the bottom of the maze to the top of the maze; x would
% be the width of the maze - whatever the furthest points apart are.
%
% heres a diagram from van der meers lab:
% The T-maze is already approx lined up with the camera's field of view, so x = a and y = b
%     ......x.......
%  _ _ _ _ _ _ _ _ _ _ 
% |         a          |
% |    ____________    | .             
% |   |     |      |   | .
% |   |     |      |   | .
% |   |     |      |   | y
% |         | b        | .  
% |         |          | .
% |         |          | .
% |_ _ _ _ _ _ _ _ _ _ |
%
% note, while this code was written by John Stout, the image above and some
% variable names were taken from van der meer code.

function [convFact] = convertPixels(X,Y,realDims)

% take maximum and minimum points
xMax = max(X);
xMin = min(X);
yMax = max(Y);
yMin = min(Y);

% take difference of those points
xDiff = xMax-xMin;
yDiff = yMax-yMin;

% divide difference by dimensions. You must divide your position data to
% get the new unit.
ConvFact(1) = xDiff/realDims(1);
ConvFact(2) = yDiff/realDims(2);

end




