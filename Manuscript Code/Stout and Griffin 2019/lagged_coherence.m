%% lagged_LFP

% This function calculates lagged coherence by shifting vector x with
% respect to a centered vector y, calculating coherence along the way. 
%
% this function is currently not flexible, and only works in 150ms windows
% (300 samples). Therefore, one signal should have 600 extra points as
% another if examining a single trial and if the srate is 2000 samples/sec.
%
% INPUTS: 
% signalx_trials: this is a cell array containing your lagged signals
%                 trials - note this will have more data points then your
%                 signal that won't be lagged. See above.
% signaly_trials: this is a cell array containing your normal signals
%                   trials
% params: see chronux tutorial for params needed. Or see any of their code
%
% OUTPUTS:
% C: averaged coherence
% f: frequency 
% lag: lag - mostly used for x-axis plotting
%
% last edit 11-13-2019
%
% written by John Stout

function [C,f,lag]=lagged_coherence(signalx_trials,signaly_trials,params)

%%

% loop across trials
for triali = 1:length(signalx_trials)
    % loop across lags, storing same sized data. Lag analysis is sort of
    % like convolution. Notice how I skip a pnt (1:2:N). This is because
    % I'm interested in 1ms windows, my srate was 2000 samples/second or
    % 2samples/ms
    for i = 1:2:600 % 300 ms
        % notice how I used length(signaly_trials). This is because
        % signaly_trials is the correct size that I need (lets say 1000). 
        % So this line takes i (lets say 1), then finds 1 through the first
        % 1000-1 (minus 1 so that I can add i to it - makes sense next).
        % Next, for i = 3 (skip 2, 2samples/ms = 1ms), you find 3:999+3, so
        % 3:1002, this is 1000 pnts long, with a 1ms overlap.
        signalx_lags{triali}{i} = signalx_trials{triali}(i:((length(signaly_trials{1})-1)+i));
    end
    % this removes any empty cell arrays. Since i'm skipping an element
    % (were examining 1ms overlaps), I'll have a total size of roughly 2x
    % the number of lags.
    signalx_lags{triali}=signalx_lags{triali}(~cellfun('isempty',signalx_lags{triali}));  
end

% concatenate data so rows are trials, columns are number of lags
signalx_AllLags = vertcat(signalx_lags{:});
% get data into format for chronux (samples X trials)
for lagi = 1:length(signalx_AllLags)
    %signalx_cell{lagi} = reshape(horzcat(signalx_AllLags{:,lagi})', 1,
    %1000, 16); % stored data into a 3D array across cells - not what I
    %meant to do.
    
    % store data into signalXtrials format
    signalx_lag{lagi} = horzcat(signalx_AllLags{:,lagi});
end
signaly = horzcat(signaly_trials{:}); % centered signal Y

% note that as of now, you should have 1 signaly variable that has a
% signal. You're signalx_lag will be a cell array of vectors lagged by 2
% elements (1ms since the srate was 2000)

% loop across lags. Note that each lagged signal is stored as a cell.
for lagi = 1:length(signalx_lag)
    % calculate coherence between normal and lagged signal
    [C{lagi},~,~,~,~,f]=coherencyc(signalx_lag{lagi},signaly,params);
end

% define lag variable
lag = linspace(-150,150,length(C));
