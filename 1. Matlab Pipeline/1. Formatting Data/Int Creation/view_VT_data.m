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
missing_data = 'interp'; % can also be 'exclude' or 'ignore'

%% extracting vt data

% change datafolder
cd(datafolder);

% get X, Y, and timestamps
missing_data = 'interp'; % this could be 'exclude' or 'ignore'
[pos_x,pos_y,pos_t] = getVTdata(datafolder,missing_data);

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


