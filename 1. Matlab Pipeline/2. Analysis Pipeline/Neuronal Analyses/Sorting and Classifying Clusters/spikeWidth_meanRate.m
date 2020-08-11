%% plot spikewidth by firing rate
% this script gets spike width and averaged firing rate to plot against
% another
%
% INPUTS
% Datafolders: master folder containing all datafolders
% vt_name: video track file name
% missing_data: how to handle missing vt data. Can be 'ignore','interp', or
%               'exclude'
%
% written by John Stout

function [FRdata] = spikeWidth_meanRate(Datafolders,vt_name,missing_data)

% define folder_names
cd(Datafolders);
folder_names = dir;  
    
% adjust the looping index?
prompt  = 'Adjust the looping index? [Y/N] ';
adjLoop = input(prompt,'s');

if adjLoop == 'Y'
    prompt = 'Enter the loop index ';
    looper = str2num(input(prompt,'s'));
else
    looper = 3:length(folder_names);
end

neuron = [];
neuron_temp = [];

% loop across folders
for nn = looper

    Datafolders = Datafolders;
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
    datafolder = pwd;
    cd(datafolder);    

    % get vt_data 
    [~,~,TimeStampsVT] = getVTdata(datafolder,missing_data,vt_name);      
            
    % save session for later
    session = datafolder;
    
    % fix variable for loading of .ntt file
    datafolder = strcat(datafolder,'\');
    
    % load clusters
    clusters_ntt = dir('TT*.ntt');
    clusters_txt = dir('TT*.txt');

    %% Extract information from TT*.ntt files and calculate spike duration
    %datafolder = strcat(datafolder, '\'); 
    
    % prepare variable for saving
    C = [];
    C = strsplit(session,'\');
    session_name = C{end};   
    
    for ci=1:length(clusters_ntt)
        cd(datafolder);
        neuron_temp(1,ci).sess_name = session_name;                
        neuron_temp(1,ci).name = clusters_ntt(ci).name(1:end-4);
        [Timestamps, ScNumbers, CellNumbers, Features, Samples,...
            Header] = Nlx2MatSpike(strcat(datafolder,...
            clusters_ntt(ci).name), [1 1 1 1 1], 1, 1, [] ); 
    
        % Calculate spike duration        
        spike_duration = [];
        spike_duration = calculate_spike_duration(Samples,Header);      
        %spike_duration = vertcat(spike_duration,spike_dur');
        neuron_temp(1,ci).spike_duration = spike_duration;
        clear Timestamps ScNumbers CellNumbers Features Samples Header
        
        % -- get mean fr -- %
        
        % load spiketimes
        cd(datafolder);
        spikeTimes = textread(clusters_txt(ci).name);
        % get an index of spikes
        spk_ind = find(spikeTimes > TimeStampsVT(1) & ...
            spikeTimes < TimeStampsVT(end)); 
        % get spike timestamps
        spks = spikeTimes(spk_ind);
        % get firing rate
        FR = length(spks)/((TimeStampsVT(end)-TimeStampsVT(1))/1e6);
        % get spike counts
        spkCount = length(spks);

        % store
        FRdata.FR{nn-2}{ci}       = FR;
        FRdata.spkCount{nn-2}{ci} = spkCount;
        FRdata.spikeDur{nn-2}{ci} = spike_duration;
        
    end  


% create master struct    
neuron      = horzcat(neuron_temp,neuron);
neuron_temp = [];
clear Clusters datafolder spike_dur Samples Header Features CellNumbers ScNumbers Timestamps clusters AverageFiringRate FiringRate TempAvFr  

% display progress
X = ['finished with session ',num2str(nn)];
disp(X)

end

% plot
spikeDur = cell2mat(horzcat(FRdata.spikeDur{:}));
avgFr    = cell2mat(horzcat(FRdata.FR{:}));

figure('color','w');
plot(avgFr,spikeDur,'k.')
ylim([0 .6])
%xlim([0 15])
ylabel('Spike width (ms)')
xlabel('Mean firing rate (Hz)')
box off

figure('color','w');
sc = scatterhist(avgFr,spikeDur,'Color','k','Kernel','on','Direction','out','Marker','.');
box off

