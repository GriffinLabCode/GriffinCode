%% powerSpectrogram
% this plots a spectrogram pretty nicely for you
%
% -- INPUTS -- %
% data2plot: LFP data as a vector (should only be 1 trial)
% movingwin: in seconds [totalWindow, movingWindow]. First input is how
%               long the window is, second input is how much to move the
%               window. These could also be empty
% srate: sampling rate
% f: frequencies [1:.1:100].
%
% -- OUTPUTS -- %
% S: power, not log corrected
% f: frequencies
% t: time, converted
%
% written by John Stout

function [S,f,t] = powerSpectrogram(data2plot,movingwin,srate,f,plotData)

% prep
if isempty(movingwin)==0
    window   = movingwin(1)*srate; % window lenght
    noverlap = movingwin(2)*srate; % overlap
    %f = [1:1:100];
else
    window = [];
    noverlap = [];
end

% run spectrogram function
[s,f,t] = spectrogram(data2plot,window,noverlap,f,srate,'yaxis');
S       = abs(s); % absolute value of complex output
Slog    = log10(S); % log 10 corrected
tConv   = linspace(-6.25,6.25,length(t)); % time variable computed
t       = tConv; % t renamed
       
if contains(plotData,[{'y'} {'Y'}]) || plotData == 1
    figure('color','w');
    pcolor(tConv,f,Slog)
    colormap(jet)
    shading interp
    ylimits = ylim;
    xlabel('Time around ...');
    ylabel('Frequency (Hz)')
    colorbar
end