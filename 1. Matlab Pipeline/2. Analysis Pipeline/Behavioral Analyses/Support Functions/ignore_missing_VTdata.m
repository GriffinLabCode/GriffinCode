%% ignore_missing_data
%
% when tracking rat position, sometimes we lose him/her. This option is to
% ignore those losses

function [ExtractedX,ExtractedY,TimeStamps] = ignore_missing_VTdata(datafolder)

% load vt data in specific datafolder
cd(datafolder);
load('VT1.mat');

% various ways that video tracking data has been defined in the past. From
% now on, we use ExtractedX, ExtractedY, TimeStamps
if exist('VT_ExtractedX') == 1 && exist('VT_ExtractedY') == 1 && exist('VT_Timestamps') == 1
    ExtractedX = VT_ExtractedX;
    ExtractedY = VT_ExtractedY;
    TimeStamps = VT_Timestamps;
elseif exist('ExtractedX_VT') == 1 && exist('ExtractedY_VT') == 1 && exist('TimeStamps_VT') == 1
    ExtractedX = ExtractedX_VT;
    ExtractedY = ExtractedY_VT;
    TimeStamps = TimeStamps_VT;    
elseif exist('ExtractedX') == 1 && exist('ExtractedY') == 1 && exist('TimeStamps_VT') == 1  
    ExtractedX = ExtractedX;
    ExtractedY = ExtractedY;
    TimeStamps = TimeStamps_VT;
elseif exist('ExtractedX') == 1 && exist('ExtractedY') == 1 && exist('TimeStamps') == 1  
    ExtractedX = ExtractedX;
    ExtractedY = ExtractedY;
    TimeStamps = TimeStamps;    
end 

end
