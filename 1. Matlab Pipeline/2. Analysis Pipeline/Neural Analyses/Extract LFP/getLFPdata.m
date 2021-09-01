%% getLFPdata
% this function wraps some other functions into something that will easily
% load and convert lfp data for easy extraction and use
%
% -- INPUTS -- %
% datafolder: string directory for data of interest
% csc_name: string variable containing csc of interest (ie csc_name =
%             'CSC1.mat'
% sessionMarkers: vector of timestamps (no more than 2). This will tell the
%                   code to extract certain epochs for accuracy. Optional
%                   variable, but HIGHLY RECOMMENDED!
%
% -- OUTPUTS -- %
% lfp: vector of lfp
% lfpTimes: vector of timestamps that correspond to each element of lfp
% srate: sampling rate of lfp
%
% written by John Stout

function [lfp,lfpTimes,srate] = getLFPdata(datafolder,csc_name,sessionMarkers)

% change directory to datafolder
cd(datafolder)

% load data
load(csc_name,'Samples','Timestamps');
try load(csc_name,'SampleFrequencies'); catch; end % try to load sample frequencies for srate

if exist('sessionMarkers')
    
    % identify timestamps to keep
    idxKeep = find(Timestamps >= sessionMarkers(1) & Timestamps <= sessionMarkers(2));

    % get new samples and times
    SamplesKeep    = Samples(:,idxKeep);
    TimestampsKeep = Timestamps(idxKeep);
    
    % linspacing this works great as long as you do not have multiple
    % starting recording epochs
    lfp      = SamplesKeep(:)';
    lfpTimes = linspace(TimestampsKeep(1),TimestampsKeep(end),length(lfp));

    % replace old var
    Samples    = [];
    Timestamps = [];
    Samples    = SamplesKeep;
    Timestamps = TimestampsKeep;
    
else
    % load events
    load('Events','EventStrings','TimeStamps')
    numStarts = numel(find(contains(EventStrings,'Starting Recording')==1));
    
    if numStarts > 1
        error(['Multiple stop/start recordings were detected. Data will not be processed unless you select which epochs to use'])
    else
        % convert data - do not linspace. Interpolation is much closer to
        % accurate timestamp generation
        [lfpTimes, lfp] = convertLFPdata(Timestamps, Samples); 
    end
    
end

if exist('SampleFrequencies')
    srate = mean(SampleFrequencies);
else
    srate = getLFPsrate(Timestamps,Samples);
end