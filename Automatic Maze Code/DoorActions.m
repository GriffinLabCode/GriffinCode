%% door functions
% 
% this code grabs all door possibilities and stores them into a structure
% array
%
% written by John Stout

function [doorFuns] = DoorActions();

% broad actions
doorFuns.closeAll = 'DS01 DS11 DS21 DA11 DA21 DP11 DP21';
doorFuns.openAll  = 'DS00 DS10 DS20 DA10 DA20 DP10 DP20';

% central door
doorFuns.centralOpen  = 'DS00';
doorFuns.centralClose = 'DS01';

% tjunction exit
doorFuns.tLeftOpen   = 'DS10';
doorFuns.tLeftClose  = 'DS11';
doorFuns.tRightOpen  = 'DS20';
doorFuns.tRightClose = 'DS21';

% goal zone exit
doorFuns.gzLeftOpen   = 'DA10';
doorFuns.gzLeftClose  = 'DA11';
doorFuns.gzRightOpen  = 'DA20';
doorFuns.gzRightClose = 'DA21';

% startbox entry
doorFuns.sbLeftOpen   = 'DP10';
doorFuns.sbLeftClose  = 'DP11';
doorFuns.sbRightOpen  = 'DP20';
doorFuns.sbRightClose = 'DP21';

end
