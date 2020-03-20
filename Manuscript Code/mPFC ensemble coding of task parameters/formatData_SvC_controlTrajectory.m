clear; clc
% this script will organize data so that you can test task phase prediction
% while holding constant left/right trajectories. For example: left runs
% sample vs left runs choice.

% load sample data
data_sample  = load('data_mPFC_sample_FRLvR_7bins');

% load choice data
data_choice  = load('data_mPFC_Choice_FRLvR_7bins');

data1_L = data_sample.FRdata.lefts;
data2_L = data_choice.FRdata.lefts;

data1_R = data_sample.FRdata.rights;
data2_R = data_choice.FRdata.rights;
