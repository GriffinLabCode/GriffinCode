%Specifics- This function aims to remove false positive sharp-wave ripple
%events by identifying mPFC events and their temporal proximity to HPC
%events, then removing events in HPC that coincide too closely with
%perceived mPFC events. Thus far in the research SWRs are not shown to
%occur simultaneously in mPFC along with HPC therefore these occurances are
%considered "noise" or false positives.
   
%% INPUTS//OUTPUTS

%--INPUTS--

% fp_swr_times = a time index organized by trial (triali = 1:numTrials),
%                composed of extracted SWR events within each trial, from the brain region
%                percieved to be have false-positive events(mPFC). 

% real_swr_times = a time index organized by trial (triali = 1:numTrials),
%                composed of extracted SWR events within each trial, from the brain region
%                percieved to have real events (HPC), and the region in which removal of
%                identified fp events will occur. 


%--OUTPUTS--

%swr2close = an logical index organized by trial (triali = 1:numTrials) of SWR
%            events that are too close and considered false positives


function [swr2close] = remFalsePositiveSWRs(fp_swr_times,real_swr_times)

% number of trials
numTrials = length(real_swr_times);

% get the difference between false positive event onset and 'real' swr
% event onset. Make sure the difference is absolute value (no direction
% required). Additionally, for every single fp ripple, you have to compare
% it to every single real.
swr_diff_idx = cell([1 numTrials]);
for triali = 1:numTrials
    % can only do stuff below if there is data from both trials
    if isempty(real_swr_times{triali}) == 0 && isempty(fp_swr_times{triali}) == 0
        numFPripples = length(fp_swr_times{triali});
        numRLripples = length(real_swr_times{triali});
        for swri_fp = 1:numFPripples
            % for each fp swr times, subtract all real_swr_times
            for swri_real = 1:numRLripples
                swr_diff_idx{triali}{swri_real}(swri_fp) = abs(fp_swr_times{triali}{swri_fp}(1)-real_swr_times{triali}{swri_real}(1))/1e6;
            end
        end
    end
end

% find any events that co-occur within or equal to 100ms
swr2close = cell([1 numTrials]);
for triali = 1:numTrials
    if isempty(swr_diff_idx{triali}) == 0 && isempty(fp_swr_times{triali}) == 0
        numRLripples = length(real_swr_times{triali});
        for swri = 1:numRLripples
            % make this boolean, and specifically, a 1 if there were any
            % overlap in fp and real ripples. Do not remove the 'find' function below. 
            swr2close{triali}{swri} = ~isempty(find(swr_diff_idx{triali}{swri} <= .1)); % find(isempty(find(swr_diff_idx{triali}{swri} <= .1))==0);         
        end
        swr2close{triali} = find(double(cell2mat(swr2close{triali}))==1); % find(isempty(find(swr_diff_idx{triali}{swri} <= .1))==0);         
    end
end



