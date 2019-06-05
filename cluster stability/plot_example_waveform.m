%% plot example waveform on cluster_stability figure
% this script will plot mean waveform in the beginning and end of
% recording from the tetrode that picked up on the peak voltage
%
%
% written by John Stout

%% initialize

% define a session
datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Thanos 12-9-18';

% define which cell to plot
cell_num = 1;

% define time window
time_window = 10; % minutes
timing      = 60*10; % seconds

% load video tracking data
cd(datafolder)
load VT1.mat

% load cluster data
Clusters = dir('TT*.ntt');
    
% add backslash to datafolders string - for Nlx function
datafolder = strcat(datafolder, '\');    

    for ci=1:length(Clusters)
        cd(datafolder);
        [Timestamps, ScNumbers, CellNumbers, Features,...
            Samples, Header] = Nlx2MatSpike(strcat(datafolder,...
            Clusters(ci).name), [1 1 1 1 1], 1, 1, [] );          
        spike_times = Timestamps;

        % extract unique ADbitVolt value and multiply by Samples
        ad_bit_string = cell2mat(Header(16));
        ad_bit = strsplit(ad_bit_string);
        ad_bit = ad_bit(end);
        ad_bit = cell2mat(ad_bit);
        ad_bit = str2num(ad_bit);

        % spike index - +600 and -600 bc 60sec*10min = 600sec
        pre_idx  = find(spike_times>=TimeStamps_VT(1) & ...
           spike_times<=(TimeStamps_VT(1)+(timing*1e6)));
        post_idx = find(spike_times>=(TimeStamps_VT(end)-(timing*1e6)) & ...
           spike_times<=TimeStamps_VT(end));       

        % extract mean peak for tetrode channel with highest voltage peak
        spike_avg = mean(Samples,3);

        % find max peak
        max_spike_avg = max(spike_avg);
        max_peak      = max(max_spike_avg);

        % this tells you which wire picked up on the highest voltage spike
        max_peak_ind  = find(max_peak == max_spike_avg);

        % extract wire from max_peak_ind, keeping all spikes and samples
        spike = (Samples(:,max_peak_ind,:))*ad_bit;

        pre_waveform{ci}  = (mean((spike(:,:,pre_idx)),3))*1000000;
        post_waveform{ci} = (mean((spike(:,:,post_idx)),3))*1000000;

        clear spike pre_idx post_idx ad_bit spike_times
    end
    
% create x label that reflects the sampling rate in fractions of a ms
% 32 samples in a ms
x_label = linspace(0,1,32);
  
% generate figure
figure();
plot(x_label,pre_waveform{cell_num},'r');
hold on
plot(x_label,post_waveform{cell_num},'b');
%ylabel('Mean peak voltage (uV) across wires')
%xlabel('one millisecond')
legend('first ten minutes', 'last ten minutes')
box off


