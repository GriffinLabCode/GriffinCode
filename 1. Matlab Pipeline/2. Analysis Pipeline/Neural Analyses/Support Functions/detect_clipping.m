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
% IMPORTANT: While it does find clipping events, it may also remove short
% time scale changes in LFP that are repeats. This is on a timescale that
% shouldn't matter too much. This code should not be an alternative to you
% looking at your data, but a method to prevent you from having to toss out
% trials
%
% written by John Stout. Last edit 3/23/2020

function [data_new,clip_idx,numClippings] = detect_clipping(data)
    
    % define output variable
    data_new = data;
    
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
    
    % plot data
    % figure(); hold on; plot(data,'b'); plot(clip_idx,data(clip_idx),'.r');
    
    if isempty(clip_idx) == 0 && numClippings > 1
        
        %{
        % create an index to remove a 10th of a second before and after the
        % clipping events
        remove_idx = (clip_idx(1)-(Fs/100)):(clip_idx(end)+(Fs/100));
        
        % remove data
        data_new(remove_idx)=[];
        %}
        
        % remove data
        data_new(clip_idx)=[];
        
        % figure(); subplot 211; hold on; plot(data,'b'); plot(clip_idx,data(clip_idx),'.r');
        % subplot 212; hold on; plot(data_new,'k');
        
    else
        clip_idx = NaN;
        
    end
    
end