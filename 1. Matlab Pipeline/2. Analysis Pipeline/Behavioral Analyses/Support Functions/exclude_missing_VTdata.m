%% ignore_missing_data
%
% INPUTS:
% datafolder: directory of interest
% vt_name: video track name 'VT1.mat' for example
%
% when tracking rat position, sometimes we lose him/her. This option is to
% ignore those losses

function [ExtractedX,ExtractedY,TimeStamps] = exclude_missing_VTdata(datafolder,vt_name)

% load video tracking data
cd(datafolder);

% account for variability in how data used to be stored. Note that using
% updated functions will not have this problem. If you run into any issues
% with naming, add another elseif line
[VT_data.ExtractedX,VT_data.ExtractedY,VT_data.TimeStamps] = ignore_missing_VTdata(datafolder,vt_name);

% find cases where video tracking is zero
zeroX = find(VT_data.ExtractedX == 0);

% remove data
VT_data.ExtractedX(zeroX)=[];
VT_data.ExtractedY(zeroX)=[];
VT_data.TimeStamps(zeroX)=[];

% find remaining cases where Y is 0
zeroY = find(VT_data.ExtractedY == 0);

% remove data
VT_data.ExtractedX(zeroY)=[];
VT_data.ExtractedY(zeroY)=[];
VT_data.TimeStamps(zeroY)=[];

% outputs
ExtractedX = VT_data.ExtractedX;
ExtractedY = VT_data.ExtractedY;
TimeStamps = VT_data.TimeStamps;

end
