%% reduce sampling rate of raw lfp
%
% this function downsamples raw lfp and timestamps BEFORE conversion. This
% function is identical to the rate reducer neuralynx application. This
% could be useful if you accidentally sampled at a really high srate (say
% 30,000 samples/sec), but you want 2000hz.
%
% -- INPUTS -- %
% datafolder: string directory
% csc_name: string of name of csc
% target_rate: down sample target rate (say 2000hz), a double variable
% saveName: name of data you want saved as. If this is empty, the variable
%               will automatically be saved as your 'csc_name_rateReduced'
%
% -- OUTPUTS -- %
% Samples: matrix of 512xN samples, in raw, downsampled format.
% Timestamps: vector of N timestamps, in raw, downsampled format
%
% written by John Stout

function [Samples, Timestamps] = rateReducerLFP(datafolder,csc_name,target_rate,saveName);

% load csc data
cd(datafolder);
load(csc_name);

% get current rate
srate = getLFPsrate(Timestamps,Samples);

if srate ~= target_rate
    disp('Sampling rate does not match the target rate, therefore data will be down-sampled...')
    disp('WARNING - rate reduction does not always provide you with values that match another LFP that was down-sampled during recording')
    
    % get the downsampling rate divisor
    %target_rate = 2000;
    [divisor] = find_downsample_rate(srate,target_rate);

    % downsample data
    samples_ds = []; times_ds = [];
    samples_ds = Samples(:,1:divisor:end);
    times_ds   = Timestamps(:,1:divisor:end);
    
    for i = 1:size(Samples,2)
        samples_ds(:,i) = Samples(1:divisor:end,i);
        times_ds(:,i)   = Timestamps(1:divisor:end,i);
        
    samples_ds = Samples(:,1:divisor:end);
    times_ds   = Timestamps(:,1:divisor:end);

    % format data for output
    Samples = []; Timestamps = [];
    Samples = samples_ds;
    Timestamps = times_ds;
else
    disp('Sampling rate matches the target rate, therefore data was not down-sampled')
end

% save data
if exist('saveName') 
    save(saveName,'Samples','Timestamps')
else
    save([csc_name,'_rateReduced'])
end

end