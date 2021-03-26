function[cleaneeg] = cleaningscript(eeg, params)
%       params      structure containing parameters - params has the
%       following fields: tapers, Fs, fpass, pad

% first detrend
winLen = [1 0.5];
deteeg = locdetrend(eeg,params.Fs,winLen);

% then clean
[cleaneeg, datafit] = rmlinesmovingwinc(deteeg,winLen,10,params,'n');
cleaneeg = cleaneeg';

end