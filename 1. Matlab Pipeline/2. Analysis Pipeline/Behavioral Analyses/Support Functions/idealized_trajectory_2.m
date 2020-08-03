function [idealTraj] = idealized_trajectory_2(pos)
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

% this code was taken and adapted from van der meer code by John stout. It
% now requires you to input the converted data. This makes for 
% more realistic bin sizes for distance. Additionally, now you only draw
% stem trajectory one time so that the bins are identical

[stemX,stemY] = MakeStemCoord(pos(1,:),pos(2,:),'titl','Draw stem trajectory, press enter when done','XDir','reverse');
idealL = MakeCoord2(pos(1,:),pos(2,:),stemX,stemY,'titl','Draw left trajectory, after T-junction, press enter when done','XDir','reverse');
idealR = MakeCoord2(pos(1,:),pos(2,:),stemX,stemY,'titl','Draw right trajectory, after T-junction, press enter when done','XDir','reverse');

next = 0;
while next == 0
    if size(idealL,2) > size(idealR,2)
        disp('try again - too many Left points')
        disp(['Offset by ',num2str(size(idealL,2)-size(idealR,2)),' points'])
        clear idealL
        idealL = MakeCoord2(pos(1,:),pos(2,:),stemX,stemY,'titl','Draw left trajectory, after T-junction, press enter when done','XDir','reverse');  
    elseif size(idealR,2) > size(idealL,2)
        disp('try again - too many Right points')
        disp(['Offset by ',num2str(size(idealR,2)-size(idealL,2)),' points'])
        clear idealR
        idealR = MakeCoord2(pos(1,:),pos(2,:),stemX,stemY,'titl','Draw right trajectory, after T-junction, press enter when done','XDir','reverse');        
    elseif size(idealR,2) == size(idealL,2)
        next = 1;
    end
end

%{
idealL_cm = idealL; % copy coordL under a new variable name, and apply some changes:
idealL_cm(1,:) = idealL_cm(1,:)./convFact(1); % apply x conversion
idealL_cm(2,:) = idealL_cm(2,:)./convFact(2); % apply y conversion

idealR_cm = idealR; % as above, for R instead
idealR_cm(1,:) = idealR_cm(1,:)./convFact(1); % apply x conversion
idealR_cm(2,:) = idealR_cm(2,:)./convFact(2); % apply y conversion
%}

% put it all in a struct for tighter packing in the base workspace (when loading variables later)
idealTraj = struct('idealL',idealL,'idealR',idealR);

clear idealL idealR