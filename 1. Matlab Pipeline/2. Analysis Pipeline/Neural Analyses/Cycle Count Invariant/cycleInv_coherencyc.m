%% cycle count invariant version of lfp analyses
% number of cycles in your lfp analysis may influence the results you see.
% Therefore, this code accounts for that by controlling for time in a
% time-uncontrolled window

% actually, to account for cycles id prob have to use the entrainment cycle
% code. this is time invariant. there could be diff num cycles in 500ms if
% i gt 4-12hz bc peak freq
%
% -- INPUTS -- %
% data: vector of lfp
% srate: sampling rate
% movingwin: time window of interest [window overlap] [0.5 0.01]
%               indicates 500ms windows with 10ms overlap
%
% written by John Stout

function [] = cycleInv_coherencyc(data,srate,movingwin,params)

% using your vector and sampling rate, find what 0.5 sec and 10ms
% corresponds to in samples
windowSamples = round(movingwin*srate);

% move forward along your vector, calculating the lfp analysis of interest
numLoops = round(length(data)/windowSamples(1));
data_forward = [];
for i = 1:numLoops
    
    if i == 1
        % when i is 1, get 1:number samples that correspond to movingwin(1)
        idxGet = 1:windowSamples(1);
        % get data
        data_forward{i} = data(idxGet);
    elseif i > 1
        
        % if i is greater than 1, then you have to get the second 500ms
        % window, minus the 20ms overlap
        startIdx = windowSamples(1)*(i-1)-windowSamples(2);
        endIdx   = windowSamples(1)*i-(windowSamples(2)-1);
        
        % skip if your ideal end exceeds size of data
        true_end = length(data);
        if endIdx > true_end
            break
        end
        
        % do a check
        checkSize = endIdx-startIdx;
        if checkSize < windowSamples(1)+1 | checkSize > windowSamples(1)+1
            disp('Error - not using desired window size')
        end
        
        % get data
        idxGet = (startIdx:endIdx);
        data_forward{i} = data(idxGet);
        
    end
end

% move backwards along your vector calculating the lfp analysis of interest

% concat results into one vector

% average


