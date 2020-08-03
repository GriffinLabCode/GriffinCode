function [idealTraj] = idealized_stem_trajectory(pos)
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

ideal = MakeCoord(pos(1,:),pos(2,:),'titl','Draw stem trajectory, press enter when done','XDir','reverse');

% put it all in a struct for tighter packing in the base workspace (when loading variables later)
idealTraj = struct('ideal',ideal);
