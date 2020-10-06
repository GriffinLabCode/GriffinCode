%% get video tracking srate
%
% -- INPUTS -- %
% TimeStamps: vector of video tracking timestamps that correspond to x and
%               y positions from camera
% convert2sec: if 'y' or 'Y', then convert to seconds. 'n' would be 
%               selected if you've already done so.
%
% -- OUTPUT -- %
% vt_srate: number of frames per second (VT samples/sec)
%
% written by John Stout

function [vt_srate] = get_vtSrate(TimeStamps,convert2sec)
    if contains(convert2sec,'n') | contains(convert2sec,'n')
        % if you already converted timestamps to seconds
        vt_srate = (1/mean(diff(TimeStamps)));
    else
        % if you did not convert timestamps to seconds
        vt_srate = (1/mean(diff(TimeStamps./1e6)));
    end
end
