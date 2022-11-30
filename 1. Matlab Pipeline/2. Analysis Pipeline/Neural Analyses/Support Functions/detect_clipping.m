%% detect and remove clipping events
%
% this function detects repeating events of non changing elements.
% Essentially, this reflects periods of clipping where the signal doesn't
% fluctuate. 
%
% ~~~ INPUTS ~~~
% data: LFP data in form of vector (element wise, should be voltage).
%       However, this code could be used on any kind of continuous data
%       where you want to remove clipped artifacts
%
% -- OUTPUTS -- %
% clip_saturation: percent of the signal saturated by clippings. Visually,
%					1% seems like a good threshold for trial exclusion.
% clip_idx: location of clipping artifacts in signal
% numClippings: number of clipping events
% data_new: clippings removed from data, not sure when this would be useful.
%
% written by John Stout

function [clip_saturation, clip_idx] = detect_clipping(data)
    
    % define output variable
    data_new = data;
    
    % Need to round to handle large numbers
    data_new = round(data);
    
    % find repeating elements
    repeats   = find(diff(data_new)==0);
    
    % among the repeating elements, there may be some that are naturally
    % occuring, so to remove the constant repeating events, find repeating
    % elements withint repeating elements variable.
    clippings = find(diff(repeats)==1); 
   
    % use the clippings variable to find the location of the clipping
    % events
    clip_idx  = repeats(clippings);

    % how many clipping events?
    numClippings = length(clip_idx);
    %numRepeats = length(repeats);
    
    % plot data
    % figure(); hold on; plot(data,'b'); plot(clip_idx,data(clip_idx),'.r');
    
    if isempty(clip_idx) == 0 && numClippings > 1
        
        
        % remove data
        data_new(clip_idx)=[];
        
        % figure(); subplot 211; hold on; plot(data,'b'); plot(clip_idx,data(clip_idx),'.r');
        % subplot 212; hold on; plot(data_new,'k');
        
    else
        clip_idx = NaN;
        
    end
    
	
	% percent of signal saturated
	clip_saturation = (numClippings/(length(data)-1))*100;
    %clip_saturation  = (numRepeats/(length(data)-1))*100;
    
end