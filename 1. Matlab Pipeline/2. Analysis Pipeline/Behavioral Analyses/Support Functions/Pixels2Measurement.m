%% conversion factor for pixels 2 cm
% make sure to run 'Startup'
% Directions: pick a session with good position data. Measure the maze (y
% axis would be from the bottom of the maze to the top of the maze; x would
% be the width of the maze - whatever the furthest points apart are.
%
% note that this doesn't have to cm conversion, this can be anything you
% set
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
% -- INPUTS -- %
% X and Y: vectorized position data for entire session
% realDims: realDims_X is the real x dimension, realDims_Y is the
%            real Y dimension (cm)
%
% -- OUTPUTS -- %
% convFact: convFact.Xdim and .Ydim are what you divide the X and Y data by
%
% note, while this code was written by John Stout, the image above and some
% variable names were taken from van der meer code.

function [convFact,convX,convY] = Pixels2Measurement(X,Y,realDim_X,realDim_Y,xMax,xMin,yMax,yMin)

% take maximum and minimum points
if isempty(xMax) == 1
    xMax = max(X);
end
if isempty(xMin) == 1
    xMin = min(X);
end
if isempty(yMax) == 1
    yMax = max(Y);
end
if isempty(yMin) == 1
    yMin = min(Y);
end

% take difference of those points
xDiff = xMax-xMin;
yDiff = yMax-yMin;

% divide difference by dimensions. You must divide your position data to
% get the new unit.
convFact.Xdim = xDiff/realDim_X; % xMax pixels - yMin pixels / cm = N pixels/cm
convFact.Ydim = yDiff/realDim_Y;

% convert x and y data
convX = X./convFact.Xdim; % pixels / N pixels/cm -> pixels * (cm/pixels)
convY = Y./convFact.Ydim;

end




