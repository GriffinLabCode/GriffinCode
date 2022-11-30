%% Parameters
%
% this function provides some basic parameters for mvgc
%
% -- INPUTS -- %
% data: matrix of data (rows = brain region, col = signal)
% srate: sampling rate
% 
% -- OUTPUTS -- %
% mvgc_params: a set of parameters that can be used as default for mvgc
%               toolbox granger prediction analysis
%
% JS 11/8/22

function [mvgc_params] = get_mvgc_parameters(data,srate)

% ensure data is of type double
data = double(data);

mvgc_params.ntrials   = size(data,3); % number of trials
mvgc_params.nobs      = size(data,2); % number of observations per trial

% model order - you would want to do this across all of your datasets, then
% take the rounded average to use across all data for granger prediction
% (Cohen 2014)
mvgc_params.momax     = 100;    % number of orders to test for
mvgc_params.icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)
mvgc_params.regmode   = 'LWR';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
mvgc_params.morder    = 'BIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)

mvgc_params.acmaxlags = [];% 1324; % maximum autocovariance lags (empty for automatic calculation)
mvgc_params.fs        = srate;   % sample rate (Hz)
mvgc_params.fres      = [];     % max frequency to calculate to. You should leave this empty for automatic calculation.
