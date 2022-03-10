%% Parameters
%
% this script gets parameters based on your data variable. For info on how
% to format 'data' see mvgc_GCCA_estimateModelOrder

ntrials   = size(data,3);     % number of trials
nobs      = size(data,2);   % number of observations per trial

regmode   = 'OLS';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)

morder    = 'BIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
momax     = 100;     % maximum model order for model order estimation

tstat     = '';     % statistical test for MVGC:  'chi2' for Geweke's chi2 test (default) or'F' for Granger's F-test
alpha     = 0.05;   % significance level for significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')

seed      = 0;      % random seed (0 for unseeded)

acmaxlags = 1000;   % maximum autocovariance lags (empty for automatic calculation)

fs        = srate;    % sample rate (Hz)
fres      = [];     % frequency resolution (empty for automatic calculation)