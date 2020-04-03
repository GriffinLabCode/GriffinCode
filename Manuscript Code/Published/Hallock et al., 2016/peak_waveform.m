%% peak_waveform

%   This script compares mean peak waveforms from the tetrode channel with
%   the highest overall peak waveform between pre- and post-session
%   recording epochs

%   Output:
%       pre_v_post = n clusters x 2 matrix, with rows = clusters, column 1
%                    equal to pre-session peak wavelength and column 2 equal to post-session peak wavelength

%                    Peak wavelength units are in arbitrary Neuralynx units
%                    (A/D units). These have to be converted to uV by using
%                    a value specified in each cluster's Header
%       
%       [b,dev,stats] = Output from "glmfit" function performing Poisson
%                       regression on pre- vs. post-session waveform
%                       amplitudes

%%

clear all, clc, close all

netDrive = 'X:\';
expFolder = '01.Experiments\mPFC-Hippocampus_DualTask\';
session = '1203\1203-12\';
extension = '.ntt';

datafolder = strcat(netDrive,expFolder,session);
load(strcat(datafolder, 'Events.mat'));

cd(datafolder)
clusters = dir('TT*.txt');

clear rat session expFolder

% For each cluster, grab the cluster's features during pre- and
% post-session recording epochs, find the tetrode channel that contains the
% cluster's peak waveform amplitude, and then find the mean peak waveform
% amplitude from that tetrode channel
for ci=1:length(clusters)
    cd(datafolder);
    cluster = clusters(ci).name(1:end-4);
    spikeTimes = textread(clusters(ci).name);
    cd(strcat(netDrive, '03. Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat\'));
    [Features, Header] = Nlx2MatSpike(strcat(datafolder,cluster,extension), [0 0 0 1 0], 1, 1, []);
    pre_spikes = find(spikeTimes>EV_Timestamps(1,2) & spikeTimes<EV_Timestamps(1,3)); % Manually define pre-session timestamps
    post_spikes = find(spikeTimes>EV_Timestamps(1,12) & spikeTimes<EV_Timestamps(1,13)); %   Manually define post-session timestamps
    channel0 = Features(1,:);
    channel1 = Features(2,:);
    channel2 = Features(3,:);
    channel3 = Features(4,:);
    pre(1,:) = channel0(pre_spikes);
    pre(2,:) = channel1(pre_spikes);
    pre(3,:) = channel2(pre_spikes);
    pre(4,:) = channel3(pre_spikes);
    post(1,:) = channel0(post_spikes);
    post(2,:) = channel1(post_spikes);
    post(3,:) = channel2(post_spikes);
    post(4,:) = channel3(post_spikes);
    max_0 = max(pre(1,:));
    max_1 = max(pre(2,:));
    max_2 = max(pre(3,:));
    max_3 = max(pre(4,:));
    max_temp(1,1) = max_0; max_temp(2,1) = max_1; max_temp(3,1) = max_2; max_temp(4,1) = max_3;
    max_temp = max_temp';
    max_all = find(max(max_temp));
    pre_peak = mean(pre(max_all(1),:));
    post_peak = mean(post(max_all(1),:));
    pre_v_post(ci,1) = pre_peak; pre_v_post(ci,2) = post_peak;
    clear pre_spikes post_spikes channel0 channel1 channel3 pre post max_0 max_1 max_2 max_3 max_temp max_all pre_peak post_peak
end

clear spikeTimes netDrive Header Features extension EV_Timestamps EV_EventStrings EV_EventIDs datafolder clusters cluster ci channel2

% Perform Poisson regression between pre- and post-session peak waveform
% amplitudes
[b,dev,stats] = glmfit(pre_v_post(:,1),pre_v_post(:,2),'poisson');

scatter(pre_v_post(:,1),pre_v_post(:,2))
lsline
ylabel('Peak Wavelength Post-Session')
xlabel('Peak Wavelength Pre-Session')
    