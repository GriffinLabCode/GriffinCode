%% Calculate mean firing rate across a session
% This returns a vector with the columns being number of cluster and 
% element values being the firing rate
%
% INPUTS: datafolder: a string variable containing session directory
%
% OUTPUTS: firing rate and clusters
%
% written by John Stout

function [FiringRate, clusters] = Average_Firingrate_AcrossSession(datafolder)
%% Initializing
disp('- Initializing...')

    %% Load Variables for initializing
    load(strcat(datafolder, '\VT1.mat'));
        TimeStamps = TimeStamps_VT;
        % convert to seconds
        TimeStamps = TimeStamps/1e6;
    cd(datafolder)
    clusters = dir('TT*.txt');
    
    %% Clear Unnecessary variables in workspace
    clearvars -except datafolder Functionfolder TimeStamps EventStrings ...
        DelayLength ExtractedX ExtractedY ExtractedAngle clusters
    
    %% Designate the TS for the start of recording and TS for the end of recording
        TimestampStart = TimeStamps(1,1);
        TimestampEnd = TimeStamps(1,end);
        SessionTime = (TimestampEnd-TimestampStart);  
        
%% Calculate firing rate across session
   disp('- Calculating firing rate for the entire session for each cluster...');  
   for ci = 1:length(clusters);
       cd(datafolder);
       spikeTimes = textread(clusters(ci).name);
       cluster = clusters(ci).name(1:end-4); 
       spikeTimes = spikeTimes/1e6;       
       %% Calculate and store firing rate for each cluster iteratively
       numspikes_index = find(spikeTimes>TimestampStart & spikeTimes<TimestampEnd);
       spikecount = length(numspikes_index);
       FiringRate(ci) = spikecount/SessionTime;
   end
end
    