%% sample script
%
% this script is an example script to inspire users

clear; clc;

% load data
load('data_sample_LFP_mazeLocations')

% remove empty arrays
LFP1 = LFPdata.data1LFP_cor;
LFP2 = LFPdata.data3LFP_cor;
LFP1 = LFP1(~cellfun('isempty',LFP1));
LFP2 = LFP2(~cellfun('isempty',LFP2));

% frequencies to clean
cleanFreqs = [58 62];

% define a moving window
movingwin  = [0.5 0.01]; % 500ms window with 10 ms overlap

% clean and detrend - this should be done, but its up to the user. Also,
% you don't have to do it this way. You could concatenate data across
% trials and clean data. To ensure the user has maximum control, the matlab
% pipeline doesn't do these steps, the user does.
for sessi = 1:length(LFP1)
    for triali = 1:length(LFP1{sessi})
        % signal 1
        lfp1_clean{sessi}{triali} = locdetrend(LFP1{sessi}{triali},LFPdata.params{sessi}.Fs,movingwin);
        lfp1_clean{sessi}{triali} = rmlinesmovingwinc2(lfp1_clean{sessi}{triali},movingwin,10,LFPdata.params{sessi},[],[],cleanFreqs);
        % signal 2
        lfp2_clean{sessi}{triali} = locdetrend(LFP2{sessi}{triali},LFPdata.params{sessi}.Fs,movingwin);
        lfp2_clean{sessi}{triali} = rmlinesmovingwinc2(lfp2_clean{sessi}{triali},movingwin,10,LFPdata.params{sessi},[],[],cleanFreqs);    
    end
end

% you can also define params to use across all sessions. We have them saved
% in case the sampling rate differs across sessions. However, we can also
% calculate the sampling rate.

% -- power -- %
for sessi = 1:length(LFP1)
    for triali = 1:length(LFP1{sessi})
        % signal 1
        lfp1_pow{sessi}{triali} = mtspectrumc(lfp1_clean{sessi}{triali},LFPdata.params{sessi});
    end
end



