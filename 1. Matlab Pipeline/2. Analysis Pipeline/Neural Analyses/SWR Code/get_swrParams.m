%% default swr parameters

function [swrParams] = get_swrParams()
    % phase bandpass filter
    swrParams.phase_bandpass = [150 250];
    % how many stds above mean for swr detection?
    swrParams.swr_stdevs = [4 1];
    % smooth hilbert with gaussian?
    swrParams.gauss = 1;
    % This excludes ripples that occur within its defined time window
    % converted to seconds
    swrParams.InterRippleInterval = 0; % this is the time required between ripples. if ripple occurs within this time range (in sec),
    % maze position - refers to the Int file. [2 7] refers to goal zone
    % occupancy as of 10/22/2020 and has been so as long as I (JS) know.
    swrParams.mazePos = [2 7];
    % do you want to use a second lfp wire to detect 'false positives'?
    % This should be used if your 2nd wire is not in hpc, and does not
    % share the same reference.
    swrParams.falsePositive = 'n';
end