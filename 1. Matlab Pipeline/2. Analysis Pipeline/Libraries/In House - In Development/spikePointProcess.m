%% spk2pp
%
% this function converts your spike times into point process data
%
% sessionMarkers
%
%

clear;
datafolder = 'X:\01.Experiments\RERh Inactivation Recording\Ratticus\Muscimol\Baseline';
cd(datafolder);
csc_name = 'HPC'
%datafolder = pwd;
[spkTimes,clusterID] = get_spikeData(datafolder,'TT');       

% load events
load('Events2','EventStrings','TimeStamps')

% identify start and ends of recordings
idxEnds = find(contains(EventStrings,'Stopping Recording')==1);
evEnd  = TimeStamps(idxEnds(end));
idxBegins = find(contains(EventStrings,'Starting Recording')==1);
evStart   = TimeStamps(idxBegins(end));         

% make timestamp variable to denote these epochs
sessionMarkers = [evStart evEnd];

% get lfp
lfp_data = []; lfp_times = []; lfp_srate = [];
[lfp_data,lfp_times,srate] = getLFPdata(datafolder,csc_name,sessionMarkers);

% considering downsampling to improve speed/performance
target_rate = 500;
lowPass  = 1;
highPass = 500/4;
[lfp_ds, times_ds] = downSampleLFPdata(lfp_data,lfp_times,srate,target_rate,lowPass,highPass);
                
% only include spikes occuring during the session
numNeurons = length(spkTimes);
spkdata = []; spk_pp = [];
for ci = 1:numNeurons
    % extract spiketimes that only occured during the session of interest
    spkdata{ci} = spkTimes{ci}(spkTimes{ci} >= times_ds(1) & spkTimes{ci} <= times_ds(end));

    % create a point-process spk distribution
    spk_pp{ci} = zeros([size(times_ds)]); % open var to all zeros
    
    % find nearest timestamp for each spike
    for spki = 1:length(spkdata{ci})
        idxSpk = dsearchn(times_ds',spkdata{ci}(spki));
        spk_pp{ci}(idxSpk) = 1;
    end
    
end

