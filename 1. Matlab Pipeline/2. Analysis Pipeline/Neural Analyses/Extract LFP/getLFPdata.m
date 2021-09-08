%% getLFPdata
% this function wraps some other functions into something that will easily
% load and convert lfp data for easy extraction and use
%
% 'Events.mat' must be named as so
%
% -- INPUTS -- %
% datafolder: string directory for data of interest
% csc_name: string variable containing csc of interest (ie csc_name =
%             'CSC1.mat'
% sessionMarkers: vector of timestamps (no more than 2). This will tell the
%                   code to extract certain epochs for accuracy. Optional
%                   variable, but HIGHLY RECOMMENDED!

%                 ->>> if you do not specify sessionMarkers, your lfp data
%                 will be returned as a cell array organized by starting
%                 and stopping epochs
%
%				  ->>> If the processes above fail, your timestamps will be interpolated.
%				  it should be noted that this will definitely cause inaccurate data extraction
%				  if you have multiple 'starting recording' and 'stopping recording' events in 
%				  cheetah
%
% -- OUTPUTS -- %
% lfp: vector of lfp
%		-> returned as a cell array if you do not specify sessionMarkers
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
	disp('Using session markers to extract LFP - data will be returned as a vector')
    
    % make sure there are only two
    if numel(sessionMarkers)>2
        error('sessionMarkers must contain 2 timestamp values, no more')
    end
    
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
    try
        % load events and separate LFP based on the event markers
        load('Events','EventStrings','TimeStamps');
        evStarts = find(contains(EventStrings,'Starting Recording')==1);
        evEnds   = find(contains(EventStrings,'Stopping Recording')==1);
        evEdges  = [TimeStamps(evStarts);TimeStamps(evEnds)]';
        
        % loop across evnt markers
        for i = 1:size(evEdges,1)
            
             % identify timestamps to keep
             idxKeep = [];
             idxKeep = find(Timestamps >= evEdges(i,1) & Timestamps <= evEdges(i,2));

             % get new samples and times
             SamplesKeep = []; TimestampsKeep = [];
             SamplesKeep    = Samples(:,idxKeep);
             TimestampsKeep = Timestamps(idxKeep);

             % linspacing this works great as long as you do not have multiple
             % starting recording epochs
             lfp{i}      = SamplesKeep(:)';
             lfpTimes{i} = linspace(TimestampsKeep(1),TimestampsKeep(end),length(lfp{i}));
        end
        disp('LFP will be returned as a cell array organized by starting and stopping recording epochs')
    
    catch
	    warning('Timestamps will be interpolated to match the length of the LFP signal - this IS A PROBLEM if you have multiple starting recording and stopping recording event markers')
        
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
end

if exist('SampleFrequencies')
    srate = mean(SampleFrequencies);
else
    srate = getLFPsrate(Timestamps,Samples);
end