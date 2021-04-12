%% get best frequency
%
% this code is designed to extract the 'best' frequency, or the frequency
% that corresponds to the maximum power.
%
% -- INPUTS -- %
% data: can be a vector or matrix. If a matrix, ensure that columns are
%       trials and rows are samples (same as chronux requirements).
%
% f: frequencies. Should match the distribution of spectral estimates. in
%    this code, it should match size(data,1); The code will error out
%    otherwise
%
% freq_range: range of frequencies of interest. If theta is your target you
%             would do -> freq_range = [5 10]; 
%
% written by John Stout

function [best_freq] = get_bestFrequency(data,f,freq_range)

if size(data,1) ~= length(f)
    error(['data not formatted correctly. "data" columns should be trials if a matrix.' newline ...
        'Ensure that your frequency variable is a single vector.'])
end

% get an index of frequencies of interest
freqIdx = find(f >= freq_range(1) & f <= freq_range(2));

% if array is a matrix, average across trials. if array is a vector, 
% it doesn't matter
data_avg = nanmean(data,2);

% check variable
if length(data_avg) == 1
    error('"data" variable not formatted appropriately. Try inversion.')
end

% extract spectral estimates that correspond to your frequencies of
% interest
data_of_interest = data_avg(freqIdx);

% extract frequencies in the range of interest
f_of_interest = f(freqIdx);

% get an index of maximum power
[~,freqLoc] = max(data_of_interest);

% get 'best' frequency, or the frequency that corresponds to the maximum
% power in the frequency range of interest
best_freq = f_of_interest(freqLoc);


