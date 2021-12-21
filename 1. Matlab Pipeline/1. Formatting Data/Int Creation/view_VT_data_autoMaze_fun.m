%% view_VT_data
%
% this script allows you to view video-tracking data and 'maze zones'
% that will be used for making the 'Int' variable
%
% this script also allows you to modify/update coordinates for specific
% zones, which can then be copy/pasted into the corresponding
% use 'whereishe_master' script after, then the Int file conversion script.

%% define some parameters
%clear; clc; %close all;
function [] = view_VT_data_autoMaze_fun(datafolder)

% datafolder directory
%datafolder = pwd; 
cd(datafolder);

% Interpolate missing data? Alternatives is to exclude missing data, or ignore missing data.
missing_data = 'interp'; % can also be 'exclude' or 'ignore'

% vt_name
vt_name = 'VT1.mat';

% get X, Y, and timestamps
[ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

%% example for modifying 2-D fields below (important)

% exmpl_fld = [505 310 85 75];
% exmpl_fld = [lower x-coordinate, lower y-coord., quantity to add to lower x-coord., quantity to add to lower y-coord.]

% meaning a rectangle will extend sideways from x(505) to x(590), & will expand from y(310) to y(385)
    % because 505 + 85 = 580, and 310 + 75 = 385;

%% Create boxes around locations of interest for int creation

% right reward zone (sideways room, R)
minY = 50;  addY  = 110-minY;
minX = 380; addX = 450-minX;
rRW_fld = [minX minY addX addY];

% left reward zone (sideways room, R)
minY = 304; addY = 350-minY;
minX = 380; addX = 450-minX;
lRW_fld = [minX minY addX addY];

% central stem (sideways room, R)
minY = 180; addY = abs(minY-235);
minX = 355; addX = abs(minX-395);
STM_fld = [minX minY addX addY]; %[180 215 395 50]; % x,y (first corner) , x,y (second right top corner)

% choice point/T-junction (sideways room, R)
minY = 110; addY = abs(minY-304);
minX = 395; addX = abs(minX-440);
CP_fld = [minX minY addX addY]; %[260 150 30 270];

% delay pedestal (sideways room, R)
minY = 190; addY = abs(minY-220);
minX = 260; addX = abs(minX-342);
PED_fld = [minX minY addX addY];

figure('color','w');
plot(ExtractedX, ExtractedY);
rectangle ('position', rRW_fld);  % right reward field
rectangle ('position', lRW_fld);  % left reward field
rectangle ('position', STM_fld);  % stem
rectangle ('position', PED_fld);  % startbox
rectangle ('position', CP_fld);   % choice point / t-junction
%rectangle ('position', GAL_fld);  % left goal arm
%rectangle ('position', GAR_fld);  % right goal arm

%-- format for output and readability --%

quest  = 'Would you like to save these dimensions? [Y/N] ';
answer = input(quest,'s');

if contains(answer,'Y') | contains(answer,'y')
    % save data
    cd(datafolder)
    save('Int_information','rRW_fld','lRW_fld','STM_fld','PED_fld','CP_fld')
    disp('Int_information file saved')
else
    disp('Data not saved')
end

