%% Cluster stability function
% This function calculates mean peak voltage for spikes recorded on tetrodes
% by first choosing the electrode with the largest mean amplitude peak,
% extracting that channel within a specific time frame in the beginning
% and end of a session, taking the mean of the specified timeframes 
% individually and comparing the two.
%
% This script may not be extremely generalizable without specific storing
% of your data. However, the content of how I determined cluster stability
% from neural data could be useful.
%
% IMPORTANT: I had to save the Nlx2MatSpike .mex and .m file to each
%               session folder. There's probably a more efficient way.
%
% INPUTS: Datafolders: a string variable containing the directory for 
%                       all sessions
%
%         time_window: a scalar containing a single value in minutes (i.e.
%                       time_window = 10; tells the function to examine the
%                       first and last ten minutes of the recording.
%
% OUTPUTS: neuron is a N(cluster) x 3 struct array containing cluster
%           name, mean pre peak in volts, and mean post peak in volts.
%          pre_peak_data and post_peak_data are variables extracted 
%           from the struct array 'neuron' and converted to uV
%
%
% written by John Stout

function [neuron, pre_peak_data, post_peak_data] = cluster_stability(Datafolders,time_window)
%% Initialize

% I like to display stuff :)
disp('Initializing script by loading/ defining variables and extracting info. from TT*.ntt files'); 

% define time window during session to examine - convert min to seconds
timing = 60*time_window;

% initialize variable
neuron         = [];
neuron_temp    = [];

cd(Datafolders);
folder_names = dir;

%% loop across folders 
for nn = 3:length(folder_names)
    
    Datafolders = Datafolders;
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
    datafolder = pwd;
    cd(datafolder);
    % save session for later
    session = datafolder;
    % load clusters
    Clusters = dir('TT*.ntt');
    % load video tracking
    load(strcat(datafolder,'\VT1.mat'));
    
    %% Extract information from TT*.ntt files and calculate spike duration
    % fix datafolder for loading of .ntt files
    datafolder = strcat(datafolder, '\');  
    % prepare variable for saving
    C = [];
    C = strsplit(session,'\');
    session_name = C{end};
    for ci=1:length(Clusters)
        cd(datafolder);
        neuron_temp(1,ci).sess_name = session_name;        
        neuron_temp(1,ci).name = Clusters(ci).name(1:end-4);
        [Timestamps, ScNumbers, CellNumbers, Features, Samples, Header] = Nlx2MatSpike(strcat(datafolder,Clusters(ci).name), [1 1 1 1 1], 1, 1, [] );          
        spike_times = Timestamps;

        % extract unique ADbitVolt value and multiply by Samples
        ad_bit_string = cell2mat(Header(16));
        ad_bit = strsplit(ad_bit_string);
        ad_bit = ad_bit(end);
        ad_bit = cell2mat(ad_bit);
        ad_bit = str2num(ad_bit);

        % spike index based on timing variable
        pre_idx  = find(spike_times>=TimeStamps_VT(1) & ...
           spike_times<=(TimeStamps_VT(1)+(timing*1e6)));
        post_idx = find(spike_times>=(TimeStamps_VT(end)-(timing*1e6)) & ...
           spike_times<=TimeStamps_VT(end));

        % extract mean peak for tetrode channel with highest voltage peak
        spike_avg = (mean(Samples,3));

        % find max peak
        max_spike_avg = max(spike_avg);
        max_peak      = max(max_spike_avg);

        % this tells you which wire picked up on the highest voltage spike
        max_peak_ind  = find(max_peak == max_spike_avg);

        % extract wire from max_peak_ind, keeping all spikes and samples
        spike = (Samples(:,max_peak_ind,:))*ad_bit;

        % extract peak spikes
        peak_spikes = max(spike(:,:,:));
        peak_spikes = peak_spikes(:);   

        % use index to find mean peak spikes for time of interest
        pre_spikes  = peak_spikes(pre_idx);
        post_spikes = peak_spikes(post_idx);

        mean_pre_peak  = (mean(pre_spikes));
        mean_post_peak = (mean(post_spikes));

        % fill in temp struct variable
        neuron_temp(1,ci).mean_pre_peak  = mean_pre_peak;
        neuron_temp(1,ci).mean_post_peak = mean_post_peak;

        clear spike_times pre_idx post_idx spike peak_spikes pre_spikes post_spikes mean_pre_peak mean_post_peak ad_bit
    end
    
    neuron      = horzcat(neuron, neuron_temp);
    neuron_temp = [];
   
% display progress
X = ['finished with session ',num2str(nn)];
disp(X)    
    
end

pre_peak_data  = extractfield(neuron,'mean_pre_peak');
post_peak_data = extractfield(neuron,'mean_post_peak');

% convert volts to uvolts
pre_peak_data = pre_peak_data*1000000;
post_peak_data = post_peak_data*1000000;

figure();
scatter(pre_peak_data,post_peak_data,'k')
Y = ['Mean peak voltage (uv) first ',num2str(time_window),' minutes'];
ylabel(Y);
X = ['Mean peak voltage (uv) last ',num2str(time_window),' minutes'];
xlabel(X);
box off
end