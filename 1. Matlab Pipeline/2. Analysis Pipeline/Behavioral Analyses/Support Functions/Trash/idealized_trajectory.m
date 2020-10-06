function [idealTraj] = idealized_trajectory(pos,convFact)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%%                    Making a Coord File                              %%%
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open the function MakeCoord() and read its internal documentation for
% more information

% let's get the idealized trajectories; MakeCoord() takes varargins that can
% reorient your maze as you prefer to see it. If you recorded in RR1 you
% should always flip the Y axis unless LoadPos() is changed to do load the
% Y data differently

% this code is used to craft an idealized trajectory to fit position data
% to. This is for linearizing position data

% this code was taken and adapted from van der meer code by John stout

idealL = MakeCoord(pos(1,:),pos(2,:),'titl','Draw left trajectory, press enter when done','XDir','reverse');
idealR = MakeCoord(pos(1,:),pos(2,:),'titl','Draw right trajectory, press enter when done','XDir','reverse');

idealL_cm = idealL; % copy coordL under a new variable name, and apply some changes:
idealL_cm(1,:) = idealL_cm(1,:)./convFact(1); % apply x conversion
idealL_cm(2,:) = idealL_cm(2,:)./convFact(2); % apply y conversion

idealR_cm = idealR; % as above, for R instead
idealR_cm(1,:) = idealR_cm(1,:)./convFact(1); % apply x conversion
idealR_cm(2,:) = idealR_cm(2,:)./convFact(2); % apply y conversion

% put it all in a struct for tighter packing in the base workspace (when loading variables later)
idealTraj = struct('idealL',idealL,'idealL_cm',idealL_cm,'idealR',idealR,'idealR_cm',idealR_cm);

clear idealL idealL_cm idealR idealR_cm