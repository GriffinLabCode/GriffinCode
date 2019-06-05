%% filter out units with peak rate less than 1 across all maze locations
% this function eliminates units with mean peak rate less than 1, and
% returns an index of eliminated units
%
% INPUTS: data - N(maze bins)xCell-count sized matrix containing the mean
%                firing rate for each unit where N is rows that represent 
%                different maze locations
%         hz_filter - a scalar representing the filter
%
% OUTPUT: filtered_spkData - a matrix smaller than the data matrix so long
%                            as there was data to filter
%
% Written by John Stout

function [filtered_data,filter_idx] = filter_spkPeak(data,hz_filter)

% create an index to filter out data less than the hz_filter
for i = 1:size(data,2)
    if max(data(:,i)) < hz_filter
        filter_idx{i} = i;
    else
        filter_idx{i} = [];
    end
end

% convert to double
filter_idx = cell2mat(filter_idx);

% filter out data
filtered_data = data;
filtered_data(:,filter_idx)=[];

end
