%% plot spikewidth by firing rate
% this script uses a calculate_spike_duration and Average_Firingrate_Across
% Session to plot the spike width x mean firing rate
%
% written by John Stout

%% Initialize
clear; clc;

disp('Initializing script by loading/ defining variables and extracting info. from TT*.ntt files'); 
Functionfolder = 'X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Sorting pyramidal and interneurons';

%% Load and define variables of interest
    
% initialize variable
spike_duration = [];
neuron         = [];
neuron_temp    = [];

% this will be used for a later addition to script
input.mPFC      = 1; 
input.mPFC_poor = 0;

if input.mPFC == 1;
    Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';  
elseif input.mPFC_poor == 1;
    Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Poor Performance\Medial Prefrontal Cortex';
    disp('Warning - Error in loading Datafolders')
end

cd(Datafolders);
folder_names = dir;

for nn = 3:length(folder_names)

    
    if input.mPFC == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';  
    elseif input.mPFC_poor == 1
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Poor Performance\Medial Prefrontal Cortex';
        disp('Warning - Error in loading Datafolders')
    end
    
    
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
    datafolder = pwd;
    datafolder = strcat(datafolder,'\');
    cd(datafolder);
    Clusters = dir('TT*.ntt');

    %% Extract information from TT*.ntt files and calculate spike duration
    datafolder = strcat(datafolder, '\');        
    for ci=1:length(Clusters)
        cd(datafolder);
        neuron_temp(1,ci).name = Clusters(ci).name(1:end-4);
        [Timestamps, ScNumbers, CellNumbers, Features, Samples,...
            Header] = Nlx2MatSpike(strcat(datafolder,...
            Clusters(ci).name), [1 1 1 1 1], 1, 1, [] );          
    
    % Calculate spike duration        
    cd(Functionfolder)       
    spike_dur = calculate_spike_duration(Samples,Header);      
    spike_duration = vertcat(spike_duration,spike_dur');
    neuron_temp(1,ci).spike_duration = spike_duration;
    spike_duration = [];
    clear Timestamps ScNumbers CellNumbers Features Samples Header
    end  

% average firing rate    
[FiringRate, clusters] = Average_Firingrate_AcrossSession(datafolder);

for j = 1:size(FiringRate,2)
    neuron_temp(1,j).firing_rate = FiringRate(j);
end

% create master struct    
neuron      = horzcat(neuron_temp,neuron);
neuron_temp = [];
clear Clusters datafolder spike_dur Samples Header Features CellNumbers ScNumbers Timestamps clusters AverageFiringRate FiringRate TempAvFr  

% display progress
X = ['finished with session ',num2str(nn)];
disp(X)

end

a = extractfield(neuron,'spike_duration');
b = extractfield(neuron,'firing_rate');
figure();
plot(b,a,'k.')
ylim([0 .6])
xlim([0 15])
%ylabel('Spike width (ms)')
%xlabel('Mean firing rate')
box off
