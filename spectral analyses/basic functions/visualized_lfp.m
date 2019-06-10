%% visualize LFP
%
% this script is used to visualize lfp at the location of interest
% to change the location of interest, scroll down to 'time' variable and
% change it
%
% written by John Stout


clear; clc; close all
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
%datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-12-18';   
input = get_lfp_inputs;

%% folders checked - only between Int 1 and 6 for PrL saved as Int_lfp.mat
%Prelimbic
   %baby g
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-11-18';
        % notes from above: some potential drifting artifacts - hard to discern
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-12-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-13-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-14-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-16-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-17-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-18-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-19-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-20-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-21-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-25-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Baby Groot 9-27-18';

   %capn
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Capn_Session 4';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Capn_Session 7';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Capn_Session 11';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Capn_Session 12';
    
   %groot 
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Groot 3-13-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Groot 3-14-18';
    
   %meusli
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Meusli 6-13-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Meusli 6-14-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Meusli 6-15-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Meusli 6-16-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Meusli 6-18-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Meusli 6-19-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Meusli 6-21-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Meusli 6-22-18';
    
   %thanos
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Thanos 12-13-18';
    %datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Thanos 12-14-18';
    datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic\Thanos 12-20-18';

% acc
    % groot
    datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Anterior Cingulate\Groot 3-3-18';
    
    
%% population VT data
load(strcat(datafolder, '\VT1.mat'));
load(strcat(datafolder,'\Int_file.mat'));

%% load detrended lfp
% use inputs to guide which data to pull from pfc
if input.Prelimbic == 1
    region = '\PrL.mat';
elseif input.AnteriorCingulate == 1
    region = '\ACC.mat';
elseif input.mPFC_good == 1
    region = '\mPFC.mat';
end

%% set parameters
bandpass_frex           = input.phase_bandpass; 
params.tapers           = [5 9];
params.trialave         = 0;
params.err              = [2 .05];
params.pad              = 0;
movingwin_yn            = 0; % 1 for yes, 0 for no

% Henry mentioned he detrended data for all LFP analyses. The cleaning
% script tends to change the size of the LFP - I don't want data lost, so I
% won't be using it.
load(strcat(datafolder,region)); 
params.Fs = SampleFrequencies(1,1); 
    EEG_pfc = Samples(:)';
    %EEG_pfc = Samples_detrended(:)';
    %EEG_pfc_og = detrend_LFP(Samples);
    %EEG_pfc_og = locdetrend(Samples(:),params.Fs,[]);    
    %EEG_pfc    = EEG_pfc_og(:)';
    %[EEG_pfc] = cleaningscript(EEG_pfc', params);

try 
load(strcat(datafolder,'\HPC.mat'));   
    EEG_hpc = Samples(:)';
    %EEG_hpc = Samples_detrended(:)';
    %EEG_hpc_og = detrend_LFP(Samples);
    %EEG_hpc_og = locdetrend(Samples(:),params.Fs,[]);
    %EEG_hpc    = EEG_hpc_og(:)';
    %[EEG_hpc] = cleaningscript(EEG_hpc', params);    
end
%% reformat timestamps
% linspace(Timestamps(1,1),Timestamps(1,end),length(EEG_pfc));  % old way
%cd ('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
[Timestamps_new, ~] = interp_TS_to_CSC_length_non_linspaced(Timestamps, Samples); % figure; subplot 121; plot(Timestamps); subplot 122; plot(Timestamps_new)

Timestamps_og = Timestamps;
Timestamps = [];
Timestamps = Timestamps_new;

%% load VT data
load(strcat(datafolder,'\VT1.mat'));
load(strcat(datafolder,'\Events.mat'));
load(strcat(datafolder,'\Int_file.mat'));

%%  Extract location data
for triali=1:size(Int,1) % trial

    % vector of start and stop times - went with 1 and 6 bc the win_bin
    % loses a little bit of data - this isn't the biggest deal though. I'm
    % extracting coherence for the sake of extracting entrainment. I don't
    % need to nail down where it's happening necessarily.
    
    % note: you can't use delay iti here yet since int file is gonna rely
    % on Int being defined as sample or choice Int 
    time = [];
    time = [(Int(triali,1)) Int(triali,6)];
    %time = [(Int(triali,5)-(1*1e6)) (Int(triali,5)+(1*1e6))];

    data1{triali} = EEG_pfc(Timestamps > time(1,1) & Timestamps < time(1,2));
    
    try
    data2{triali} = EEG_hpc(Timestamps > time(1,1) & Timestamps < time(1,2));
    end
    %data1{triali} = cleaningscript(data1{triali},params);
    %data2{triali} = cleaningscript(data2{triali},params);    
    
    [data1_bpfilt{triali}] = skaggs_filter_var(data1{triali},...
        4,12,params.Fs);
    try
    [data2_bpfilt{triali}] = skaggs_filter_var(data2{triali},...
        4,12,params.Fs);
    end
    
    %x_label = linspace(0,(size(data1{triali},2)/params.Fs),size(data1{triali},2));
    %figure(); subplot 211; plot(x_label,data1{triali},'r'); hold on; 
    %subplot 212; plot(x_label,data2{triali},'b');
    figure(); 
    subplot 211; plot(data1{triali},'k'); hold on; 
                           plot(data1_bpfilt{triali},'r');
    title('raw data - with clippings')  
    try
    subplot 212; plot(data2{triali},'b'); hold on;  
                 plot(data2_bpfilt{triali},'r');
    end
    %xlabel('time (sec)'); ylabel('voltage');
    %legend('pfc','hpc','Location','southeast'); box off
    
    % without clippings
    %{
    var1_n = []; 
    var2_n = data2{triali};
    [var1_n,clip_idx] = detect_clipping(data1{triali});
    var2_n(clip_idx)=[];
    [var2_n2,clip_idx2] = detect_clipping(var2_n);
    var1_n2 = var1_n;
    var1_n2(clip_idx2)=[];
    
    [var1_bpfilt] = skaggs_filter_var(var1_n2,...
        4,12,params.Fs);
    [var2_bpfilt] = skaggs_filter_var(var2_n2,...
        4,12,params.Fs);     

    figure();  
    subplot 211; plot(var1_n2,'k'); hold on; plot(var1_bpfilt,'r');
    title('data without clippings') 
    subplot 212; plot(var2_n2,'b'); hold on; plot(var2_bpfilt,'r'); 
  %}
    
    %{
    % get data surrounding clipping events
    var1_n = []; 
    [~,~,clip_events] = detect_clipping(data1{triali});
    
    % create a variable that is the index of data1{triali}
    data1_idx = 1:length(data1{triali});
    
    % find the last index of clip_events
    clip_events_end = length(clip_events);
    
    % loop through the events - note you have to handle the data
    % differently depending on when the clip occured. If it occured in the
    % beginning find the data less than the first clip.
    
    % below extracts data surrounding the clip events, but doesn't include
    % the clipped events
    
    for i = 1:length(clip_events)
        if i == 1 % find data less than the first clip if any exists
            var1_n{i} = find(data1_idx<clip_events(i));
        elseif i > 1 % note that this would include finding data before the last clip
            var1_n{i} = find(data1_idx<clip_events(i) & data1_idx>clip_events(i-1));
            if i == clip_events_end % this will include data following the final event
                var1_n{i+1} = find(data1_idx>clip_events(i));
            end
        end
    end
    
    % use the above index for hippocampus lfp
    
    % run the same above for hippocampus lfp
    
    % index out mPFC lfp (this ensures that mPFC and HPC lfp are same
    % length)
    
    % next filter the signals
    
    % combine the mPFC signals. Combine the HPC signals. This may not work
    % - you'll have edges likely that could induce coherence.
    
    % calculate coherence
     
   %}
    pause
end

% fill in column 9 with rows that have clipping events, set them to 1
% Int([1,3,4,5,6,10,11,12,13,14,16,19,20,22,24,25,29,30,32,33,36],9)=1;
cd(datafolder);