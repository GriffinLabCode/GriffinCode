
function [data_raw] = split2Hz(dataName)

% put formatting data here
data_raw    = load(dataName);

% put mean rate data here
data_split  = load('data_mPFC_averageRates');

% define a split mark
splitBy = 2; % 2Hz based on figure

% get indices of inc and dec
idx_less  = find(data_split.FRdata.FR<splitBy);
idx_great = find(data_split.FRdata.FR>splitBy);

% clean data - note this data accounts for drifters, only examines neither
% and splits by 2Hz
data_raw.FRdata.lefts_More2Hz = data_raw.FRdata.lefts(idx_great);
data_raw.FRdata.rights_More2Hz = data_raw.FRdata.rights(idx_great);
data_raw.FRdata.lefts_Less2Hz = data_raw.FRdata.lefts(idx_less);
data_raw.FRdata.rights_Less2Hz = data_raw.FRdata.rights(idx_less);

end