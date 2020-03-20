clear; clc

% put formatting data here
data_raw    = load('data_OFC_taskphase_formatting');

% put mean rate data here
data_split  = load('data_OFC_meanRates');

% define a split mark
splitBy = 2; % 2Hz based on figure

% get indices of inc and dec
idx_less  = find(data_split.FRdata.FR<splitBy);
idx_great = find(data_split.FRdata.FR>splitBy);

% clean data - note this data accounts for drifters, only examines neither
% and splits by 2Hz
data_raw.FRdata.sample_More2Hz = data_raw.FRdata.sample(idx_great);
data_raw.FRdata.choice_More2Hz = data_raw.FRdata.choice(idx_great);
data_raw.FRdata.sample_Less2Hz = data_raw.FRdata.sample(idx_less);
data_raw.FRdata.choice_Less2Hz = data_raw.FRdata.choice(idx_less);

% story goes like so: 1) we found task phase code, lets dig into it deeper
% and classify if a sub-group of neurons support it. We also show that
% changing the time epoch doesn't drive classifier alone. 2) 
% Next we wondered if their were low
% rate/high rate neurons that differentially coded task phase, so we
% visualized the data and found that ~56% of the data could be binned
% between 0 and 2Hz. Therefore, we separated the data at a 2Hz threshold
% and found ..... 4) Then we wondered about trajectory coding on task
% phases, we found ... We only examined .... 5) what about the delay?