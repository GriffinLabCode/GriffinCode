%% get video tracking contents
%
% this function gets video tracking data. You must decide if you will
% ignore, exclude, or interpolate missing video tracking data. 
%
% -- INPUTS -- %
% datafolder: string variable indicating the directory of interest
% missing_data: a string that tells the function whether to ignore,
%               exclude, or interpolate video tracking data. 
%               Inputs can be:
%                   'interp'
%                   'exclude'
%                   'ignore'
% vt_name: name of VT data 'VT1.mat'
%
% -- OUTPUTS -- %
% ExtractedX: X position in pixels
% ExtractedY: Y position in pixels
% TimeStamps: Timestamps of the video tracking data
%
% written by John Stout

function [ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name)

ExtractedX = []; ExtractedY = []; TimeStamps = [];
if strfind(missing_data,'interp') == 1
    % interpolate missing vt data
    [ExtractedX,ExtractedY,TimeStamps] = correct_tracking_errors(datafolder,vt_name);
elseif strfind(missing_data,'exclude') == 1
    % exclude missing vt data
    [ExtractedX,ExtractedY,TimeStamps] = exclude_missing_VTdata(datafolder,vt_name);        
elseif strfind(missing_data,'ignore') == 1
    % ignore missing vt data
    [ExtractedX,ExtractedY,TimeStamps] = ignore_missing_VTdata(datafolder,vt_name);
end
