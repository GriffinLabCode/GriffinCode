%% lagged_entrainment

% This script calculates spike-phase entrainment (MRL) at a range of lags
% for simultaneously recorded single units

% Note: This script takes forever to run (estimate - 5 minutes per
% cluster). You can easily cannibalize this code to analyze lagged
% phase-locking for a single neuron if you don't want to wait

%%

clear all, clc, close all


datafolder = 'X:\01.Experiments\Reuniens related_acg\Rats_all\AAA_all_rats\Armadiller\data\1';

load(strcat(datafolder, 'Int.mat'));
load(strcat(datafolder, 'CSC8.mat'));   % Manually select CSC for entrainment analyses

phase_bandpass = [5 11];    %   Toggle these values depending on your frequency band of interest

srate = 2034;   %   Manually define sampling rate (Hz)

cd(datafolder)
clusters = dir('TT*.txt');


% Define lag values as -150 ms through 150 ms
lags = linspace(-(srate*0.15),srate*0.15,75);
lags = round(lags);

Samples = Samples(:)';
Timestamps = linspace(Timestamps(1,1),Timestamps(1,end),length(Samples));
phase_EEG = Samples;

numtrials = size(Int,1);

signal_ts = cell(1,numtrials-1);

% Grab LFP timestamp values for start-box occupancy. Don't shift these
for i = 2:numtrials 
    signal_ts{i-1} = find(Timestamps>Int(i-1,8) & Timestamps<Int(i,1));
    signal_ts{i-1} = signal_ts{i-1}';
end

    signal_ts_new = vertcat(signal_ts{:});
    signal_ts_new = signal_ts_new';
    signal_ts_new = Timestamps(signal_ts_new);
    
phase_EEG_temp = cell(1,numtrials-1);

cd(strcat(netDrive, '03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\'));

% Grab LFP values for start-box occupancy, plus and minus 150 ms per trial
% Filter the signals, and extract phases for each signal
for i = 2:numtrials
    ts_ind_start = dsearchn(Timestamps',Int(i-1,8));
    ts_ind_finish = dsearchn(Timestamps',Int(i,1));
    phase_EEG_temp{i-1} = phase_EEG(1,ts_ind_start+lags(1):ts_ind_finish+lags(end));
    phase_EEG_temp{i-1} = skaggs_filter_var(phase_EEG_temp{i-1},phase_bandpass(:,1),phase_bandpass(:,2),srate);
    [phase_EEG_temp{i-1}, ~, ~, ~] = phase_freq_detect(phase_EEG_temp{i-1}, linspace(1, length(phase_EEG_temp{i-1}), length(phase_EEG_temp{i-1})), phase_bandpass(:,1), phase_bandpass(:,2), srate);
    phase_EEG_temp{i-1} = phase_EEG_temp{i-1}*(pi/180);
end
        
% Cycle through lag values, and calculate MRL at each LFP shift while keeping LFP timestamp and spike timestamp values non-shifted       
for ci=1:length(clusters)
    cd(datafolder);
    spikeTimes = textread(clusters(ci).name);
    cluster = clusters(ci).name(1:end-4);
    cd(strcat(netDrive, '03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\'));
    spk = spikeTimes';
    for i = 2:numtrials; 
        s{i-1} = find(spk>Int(i-1,8) & spk<Int(i,1));
        s{i-1} = s{i-1}';
    end 
    spk_new = vertcat(s{:});
    spk_new = spk(spk_new);
        for j = 1:length(lags)
            phase_EEG_shifted = cell(1,numtrials-1);
            for i = 1:numtrials-1
            phase_EEG_shifted_temp = phase_EEG_temp{i};
            phase_EEG_shifted_temp = phase_EEG_shifted_temp';
            phase_EEG_shifted{i} = phase_EEG_shifted_temp(1,(abs(lags(j))+lags(j))+1:((end-abs(lags(j)))+lags(j))-1);
            phase_EEG_shifted{i} = phase_EEG_shifted{i}';
            end
            phase_EEG_shifted = vertcat(phase_EEG_shifted{:});
            
                for jj = 1:length(spk_new)
                    spk_ind = dsearchn(signal_ts_new',spk_new(jj)');
                    spk_phase_radians(jj,:) = phase_EEG_shifted(spk_ind,:);
                end

            spk_phase_radians(isnan(spk_phase_radians)) = [];
            
            mrl(ci,j) = circ_r(spk_phase_radians);
        
            clear phase_EEG_shifted phase_EEG_shifted_temp spk_ind spk_phase_radians 
        
        end
        
        ans = zscore(mrl(ci,:));
        mrl_z(ci,:) = ans;
        clear ans
        
        clear spk s spikeTimes spk_new
end

% Find the lag at which the max MRL value occurs
for si = 1:size(mrl_z,1)
    max(mrl_z(si,:));
    loc = find(mrl_z(si,:) == ans);
    sorted(si,:) = loc(1,1);
end

% Sort z-scored MRL values according to which lag they prefer
sorted(:,2) = (1:1:size(mrl_z,1));

sorted = sortrows(sorted,1);

for ni = 1:size(sorted,1)
    sorted_mrl(ni,:) = mrl_z(sorted(ni,2),:);
end

% Plot heatmap of z-scored MRL values according to preferred lag
xaxis = linspace(-150,150,75);
yaxis = linspace(1,length(clusters),length(clusters));
imagesc(xaxis,yaxis,sorted_mrl)
colormap(jet)
xlabel('Lag (ms)')
ylabel('Single Unit')

        


        
       
    

