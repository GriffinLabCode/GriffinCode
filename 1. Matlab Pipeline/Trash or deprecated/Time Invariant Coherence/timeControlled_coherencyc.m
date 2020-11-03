%% cycle count invariant version of lfp analyses
% number of cycles per lfp analysis can influence your findings. I (JS)
% found this to especially be the case for coherence, when examining
% coherence distributions when data was sampled at 250ms vs 500ms.
% Particularly, the more data you have, the more cycles considered, the
% lower coherence (it seems). There are two conceivable ways to handle
% this: 1) control the amount of time per coherence score or 2) control the
% number of cycles considered. This code does 1) controls the amount of
% time per coherence score by computing coherence in movingwin(1) length
% times in the forward and reverse direction, with no overlap. Then, an
% average coherence score is taken, called time-controlled coherence.
%
% IN SHORT: This code removes time-spent as a confounding variable.
%
% -- INPUTS -- %
% data: vector of lfp
% srate: sampling rate
% movingwin: time window of interest [window overlap] [0.5 0.01]
%               indicates 500ms windows with 10ms overlap. However, only
%               500ms will be considered. No overlap for this code.
%
% -- OUTPUTS -- %
% PlEASE NOTE: Coherence outputs are specific to one frequency range. So if
%               you want theta, do params.fpass = [4 12] or whatever theta
%               is defined as. Note that this does not handle the entire
%               dataset yet.
%
% varargout: please look at coherencyc for specifics on what the nomeclature
%               indicates. The difference here is that each output is
%               controlled for time. So data_out.C (a vector of coherence
%               values that correspond to data_out.f frequencies), is the
%               average coherence in movingwin(1) millisecond non
%               overlapping windows in the forward and reverse direction.
%               In other words, we're removing time-spent as a confounding
%               variable
%
% note that not all coherencyc values are outputted here
%
% written by John Stout

function [C,phi,S12,S1,S2,f] = timeControlled_coherencyc(data1,data2,srate,movingwin,params)

% using your vector and sampling rate, find what 0.5 sec and 10ms
% corresponds to in samples
windowSamples = round(movingwin*srate);

% move forward along your vector, calculating the lfp analysis of interest
numLoops = round(length(data1)/windowSamples(1));
data_forward = [];
for i = 1:numLoops
    
    if i == 1
        % when i is 1, get 1:number samples that correspond to movingwin(1)
        idxGet = 1:windowSamples(1);
        % get data
        data_forward1{i} = data1(idxGet);
        data_forward2{i} = data2(idxGet);
        
    elseif i > 1
        
        % if i is greater than 1, then you have to get the second 500ms
        % window, minus the 20ms overlap
        startIdx = windowSamples(1)*(i-1);
        endIdx   = (windowSamples(1)*i)-1;
        
        % skip if your ideal end exceeds size of data
        true_end = length(data1);
        if endIdx > true_end
            break
        end
        
        % do a check
        checkSize = endIdx-startIdx;
        if checkSize < windowSamples(1)-1 | checkSize > windowSamples(1)+1
            disp('Error - not using desired window size for forward direction')
        end
        
        % get data
        idxGet = (startIdx:endIdx);
        data_forward1{i} = data1(idxGet);
        data_forward2{i} = data2(idxGet);
        
    end
end

% move backwards along your vector calculating the lfp analysis of interest
data_backward = [];
backLoop = flipud(flipud(1:numLoops)')';
for i = 1:length(backLoop)
    
    % if i is 1, in otherwords, backLoop is max
    if backLoop(i) == max(backLoop)
        % define start and end indices, but go backwards now
        endIdx   = length(data1);
        startIdx = endIdx-(windowSamples(1)-1);
    elseif i > 1
        endIdx   = length(data1)-(windowSamples(1)*(i-1));
        startIdx = endIdx-(windowSamples(1)-1);
    end
    
    % check that sizing is correct
    checkSize = endIdx - startIdx;
    if checkSize < windowSamples(1)-1 | checkSize > windowSamples(1)+1
        disp('Error - not using desired window size for backward direction')
    end 
    
    % if you run out of data going backwards (index will be negative, or
    % zero)
    if startIdx < 1
        break
    end    
    
    % get data
    idxGet = (startIdx:endIdx);
    data_backward1{i} = data1(idxGet);    
    data_backward2{i} = data2(idxGet);
end

% concat results into one vector
data_cat1 = horzcat(data_forward1,data_backward1);
data_cat2 = horzcat(data_forward2,data_backward2);

% calculate coherence using coherencyc
C_cell   = cell([1 length(data_cat1)]); phi_cell = cell([1 length(data_cat1)]); 
S12_cell = cell([1 length(data_cat1)]); S1_cell  = cell([1 length(data_cat1)]); 
S2_cell  = cell([1 length(data_cat1)]); f_cell   = cell([1 length(data_cat1)]);
for i = 1:length(data_cat1)
    [C_cell{i},phi_cell{i},S12_cell{i},S1_cell{i},S2_cell{i},f_cell{i}] = coherencyc(data_cat1{i},data_cat2{i},params);
end

% set up outputs
C   = mean(horzcat(C_cell{:}),2);
S12 = mean(horzcat(S12_cell{:}),2);
S1  = mean(log10(horzcat(S1_cell{:})),2);
S2  = mean(log10(horzcat(S2_cell{:})),2);
phi = mean(horzcat(phi_cell{:}),2);
f   = mean(vertcat(f_cell{:}),1);

