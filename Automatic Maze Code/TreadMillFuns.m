%% All treadmill functions
%
% get treadmill functions

function [treadFuns,treadSpeed] = TreadMillFuns
addpath('X:\03. Lab Procedures and Protocols\MazeEngineers')

% treadmill start
treadFuns.start = uint8([3 6 0 0 0 1 73 232]');

% treadmill end
treadFuns.stop  = uint8([3 6 0 0 0 0 136 40]');

% get treadmill speeds
treadSpeed = TreadMillSpeeds;

end



