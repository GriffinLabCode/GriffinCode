%% getLFPdata
% this function wraps some other functions into something that will easily
% load and convert lfp data for easy extraction and use
%
% -- INPUTS -- %
% datafolder: string directory for data of interest
% csc_name: string variable containing csc of interest (ie csc_name =
%             'CSC1.mat'
%
% -- OUTPUTS -- %
% lfp: vector of lfp
% lfpTimes: vector of timestamps that correspond to each element of lfp
% srate: sampling rate of lfp
%
% written by John Stout

function [lfp,lfpTimes,srate] = getLFPdata(datafolder,csc_name)

% change directory to datafolder
cd(datafolder)

% load data
load(csc_name,'Samples','Timestamps');
try load(csc_name,'SampleFrequencies'); catch; end % try to load sample frequencies for srate

% convert data - do not linspace
[lfpTimes, lfp] = convertLFPdata(Timestamps, Samples);   

if exist('SampleFrequencies')
    srate = mean(SampleFrequencies);
else
    srate = getLFPsrate(Timestamps,Samples);
end







