%% preprocessLFP
%
% this function was designed as a quick-easy preprocessing step
% first, a notch filter is used to scrub of 60hz noise (Wirt et al., 2021)
% then, the data is detrended by fitting and subtracting low-order polynomials
% from the dataset
%
% -- INPUTS -- %
% lfp_data: vector of LFP
% Fs: sampling rate
%
% -- OUTPUTS -- %
% lfpReady: cleaned and detrended LFP
%
% written by John Stout

function [lfpReady] = preprocessLFP(lfp_data,Fs)

% notch filter for noise
lfp_data  = change_row_to_column(lfp_data);
[filtLFP] = notchfilt(lfp_data,Fs)

% detrend
filtLFP   = change_row_to_column(filtLFP);
lfpReady  = polyDetrend(filtLFP)