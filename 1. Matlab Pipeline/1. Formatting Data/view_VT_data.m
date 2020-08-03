
%clear; clc; close all

% this script allows you to view video-tracking data and 'maze zones'
% that will be used for making the 'Int' variable

% this script also allows you to modify/update coordinates for specific
% zones, which can then be copy/pasted into the corresponding
% use 'whereishe_andrew' script (Lroom or Rroom depending) after, then
% INT_DNMP_andrew


%% ~~~~~~~~ edit 'dir' & 'room' below

dir = 'X:\01.Experiments\DA prospective coding - analyses on old data\dHPC data - Hallock and Griffin 2013\Good\1101-23';  %Input field name

datafolder = strcat(dir);
%clear dir;

% to view current zone-designation:

% enter 1 for Right room (sideways), 2 for Left room (up-down), or 0 for room unknown
room = 1;
interp_missing_data = 1;

%% leave as is

%Load position data
cd(datafolder);
load('VT1.mat');

if interp_missing_data == 1
    % interpolate missing vt data
    ExtractedX = []; ExtractedY = [];
    [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);
else
end

try
TimeStamps = TimeStamps_VT;
catch
end
pos_x = ExtractedX; pos_y = ExtractedY; pos_t = TimeStamps;
%clear ExtractedX ExtractedY TimeStamps


%% example for modifying 2-D fields below (important)


% exmpl_fld = [505 310 85 75];
% exmpl_fld = [lower x-coordinate, lower y-coord., quantity to add to lower x-coord., quantity to add to lower y-coord.]

% meaning a rectangle will extend sideways from x(505) to x(590), & will expand from y(310) to y(385)
    % because 505 + 85 = 580, and 310 + 75 = 385;
    

%% L room (up/down)
if room == 2 

% right reward zone (up/down room, L)
    rRW_fld = [480 310 75 100]; 
    
    % left reward zone (up/down room, L)
    lRW_fld = [150 310 77 100];
    
    % central stem (up/down room, L)
    STM_fld = [335 135 37 225];
    
    % delay pedestal (up/down room, L)
    PED_fld = [280 35 150 100];
    
    % choice point/T-junction (up/down room, L)
    CP_fld = [335 360 37 65];
    
    % Left Goal Arm 
    GAL_fld = [227 360 108 65];
    
    % Right Goal Arm 
    GAR_fld = [372 360 108 65];
    
    % Return Arm Left
    RAL_fld = [180 135 160 175];
    
    figure
    plot(ExtractedX, ExtractedY);
    
    rectangle ('position', rRW_fld);  %rRW
    rectangle ('position', lRW_fld);  %lRW
    rectangle ('position', STM_fld);  %Stem
    rectangle ('position', PED_fld);  % Box
    rectangle ('position', CP_fld);  %CP
    rectangle ('position', GAL_fld);  %GAL
    rectangle ('position', GAR_fld);  %GAR
    rectangle ('position', RAL_fld);  %RAL
    rectangle ('position', LAL_fld);  %LAL
    
%% R room (sideways)
elseif room == 1
    
    
    % right reward zone (sideways room, R)
    rRW_fld = [500 -10 100 85];
    
    % left reward zone (sideways room, R)
    lRW_fld = [510 410 90 90];
     
    % central stem (sideways room, R)
    STM_fld = [180 215 395 50];
    
    % delay pedestal (sideways room, R)
    PED_fld = [15 140 165 220];
    
    % choice point/T-junction (sideways room, R)
    CP_fld = [575 185 125 110];

    
    
    figure
    %plot(ExtractedX, ExtractedY);
    plot(posX3,posY3)
    
    rectangle ('position', rRW_fld);  %rRW
    rectangle ('position', lRW_fld);  %lRW
    rectangle ('position', STM_fld);  %Stem
    rectangle ('position', PED_fld);  % Box
    rectangle ('position', CP_fld);  %CP
    
    
    
%% room unknown
else 
    
figure();
plot(ExtractedX, ExtractedY);
    
end







