%% cleanLFP
%
% clean lfp data
%
% -- INPUTS -- %
% lfp_data: vector
% srate: sampling rate of lfp
% params: chronux parameters
% cleanFreqs: [58 62] tends to get the noise band out
% 
% -- OUTPUTS -- %
% cleaned_lfp_stationary: detrended, then cleaned. This wont change the
%                           size of your data. Use this when you're not
%                           controlling for time
% detrend_lfp: detrended, but not cleaned lfp
%
% written by John Stout

function [cleaned_lfp_stationary,detrend_lfp] = cleanLFP_nonWin(lfp_data,srate,params,cleanFreqs)

% defaults
if exist('params') == 0 | isempty(params)
    params.tapers    = [3 5];
    params.trialave  = 0;
    params.err       = [2 .05];
    params.pad       = 0;
    params.fpass     = [0 100]; % [1 100]
end

if exist('cleanFreqs') == 0 | isempty(cleanFreqs)
    cleanFreqs = [58 62];
end

% define Fs if it doesn't exist (srate)
try checkFields = extractfield(params,'Fs'); catch; params.Fs = srate; end

% detrend data, then remove 60Hz noise (chronux way)
detrend_lfp = locdetrend(lfp_data,srate);

% account for 60hz noise method 2
cleaned_lfp_stationary = rmlinesc2(detrend_lfp,params,[],[],cleanFreqs);

end




