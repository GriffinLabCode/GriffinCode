function[cleaneeg] = cleaningscript(eeg, params)
%       params      structure containing parameters - params has the
%       following fields: tapers, Fs, fpass, pad

[cleaneeg, datafit] = rmlinesmovingwinc(eeg,[1 0.5],10,params,'n');
cleaneeg = locdetrend(cleaneeg,params.Fs,[1 0.5]);
cleaneeg = cleaneeg';

end