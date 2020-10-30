%% downSampleLFPdata
%
% this function downsamples lfp data
%
% -- INPUTS -- %
% datafolder: string directory
% csc_name: string of name of csc
% target_rate: down sample target rate (say 2000hz), a double variable
%
% -- OUTPUTS -- %

function [Samples, Timestamps] = downSampleLFPdata(datafolder,csc_name,target_rate,saveName);

% load csc data
load(csc_name);

% get current rate
srate = getLFPsrate(Timestamps,Samples);

% get the downsampling rate divisor
%target_rate = 2000;
[divisor] = find_downsample_rate(srate,target_rate);

% downsample data
samples_ds = []; times_ds = [];
samples_ds = Samples(:,1:divisor:end);
times_ds   = Timestamps(:,1:divisor:end);

% format data for output
Samples = []; Timestamps = [];
Samples = samples_ds;
Timestamps = times_ds;

% save data
if exist('saveName') 
    save(saveName,'Samples','Timestamps')
end

end