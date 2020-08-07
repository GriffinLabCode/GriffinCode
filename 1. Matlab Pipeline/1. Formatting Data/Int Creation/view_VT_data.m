%% view_VT_data
%
% this script allows you to view video-tracking data and 'maze zones'
% that will be used for making the 'Int' variable
%
% this script also allows you to modify/update coordinates for specific
% zones, which can then be copy/pasted into the corresponding
% use 'whereishe_master' script after, then the Int file conversion script.

%% define some parameters
clear

% datafolder directory
datafolder = 'C:\Users\uggriffin\Documents\GitHub\GriffinCode\1. Matlab Pipeline\Sample Data\Baby Groot 9-12 Sample data'; 

% Interpolate missing data? Alternatives is to exclude missing data, or ignore missing data.
interp_missing_data  = 1;
exclude_missing_data = 0;
ignore_missing_data  = 0;

%% extracting vt data

% change datafolder
cd(datafolder);

% get X, Y, and timestamps
ExtractedX = []; ExtractedY = []; TimeStamps = [];
if interp_missing_data == 1
    % interpolate missing vt data
    [ExtractedX,ExtractedY,TimeStamps] = correct_tracking_errors(datafolder);
elseif exclude_missing_data == 1
    % exclude missing vt data
    [ExtractedX,ExtractedY,TimeStamps] = exclude_missing_VTdata(datafolder);        
elseif ignore_missing_data == 1
    % ignore missing vt data
    [ExtractedX,ExtractedY,TimeStamps] = ignore_missing_VTdata(datafolder);
end
pos_x = ExtractedX; pos_y = ExtractedY; pos_t = TimeStamps;

%% example for modifying 2-D fields below (important)

% exmpl_fld = [505 310 85 75];
% exmpl_fld = [lower x-coordinate, lower y-coord., quantity to add to lower x-coord., quantity to add to lower y-coord.]

% meaning a rectangle will extend sideways from x(505) to x(590), & will expand from y(310) to y(385)
    % because 505 + 85 = 580, and 310 + 75 = 385;

%% Create boxes around locations of interest for int creation

% right reward zone
rRW_fld = [480 310 75 100]; 

% left reward zone
lRW_fld = [150 310 77 100];

% central stem
STM_fld = [335 135 37 225];

% delay pedestal
PED_fld = [280 35 150 100];

% choice point/T-junction
CP_fld = [335 360 37 65];

% Left Goal Arm 
GAL_fld = [227 360 108 65];

% Right Goal Arm 
GAR_fld = [372 360 108 65];

% Return Arm Left
%RAL_fld = [180 135 160 175];

figure('color','w');
plot(ExtractedX, ExtractedY);
rectangle ('position', rRW_fld);  % right reward field
rectangle ('position', lRW_fld);  % left reward field
rectangle ('position', STM_fld);  % stem
rectangle ('position', PED_fld);  % startbox
rectangle ('position', CP_fld);   % choice point / t-junction
rectangle ('position', GAL_fld);  % left goal arm
rectangle ('position', GAR_fld);  % right goal arm

%-- format for output and readability --%

% save data
cd(datafolder)
save('Int_information','rRW_fld','lRW_fld','STM_fld','PED_fld','CP_fld','GAL_fld','GAR_fld')


