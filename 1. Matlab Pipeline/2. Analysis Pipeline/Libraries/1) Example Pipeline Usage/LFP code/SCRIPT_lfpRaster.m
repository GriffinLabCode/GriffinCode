% SCRIPT
cd(getCurrentPath);

% example usage of lfpRaster
load('data4lfpRaster');
disp('These data were collected from Henry Hallock and formatted by J.S.')
disp('These data reflect high coherence states, so they are concatenated signals - this isnt important but will explain why theta looks funny here and there')
disp('First two rows reflect PFC (1) and HPC (2) signals')
disp('Third row is a placeholder - ignore it')
disp('Fourth row is timestamps')
disp('The rest of the rows are spike timestamps converted into 0s (no spike) and 1s (spike)');

% now to the good stuff
lfpIdx = [1 2]; % first two signals are the LFP
unitIdx = [7:20]; % example units 7-20
lfpRaster(lfp,lfpIdx,unitIdx);