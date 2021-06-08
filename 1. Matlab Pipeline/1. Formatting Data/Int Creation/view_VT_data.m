%% view_VT_data
%
% this script allows you to view video-tracking data and 'maze zones'
% that will be used for making the 'Int' variable
%
% this script also allows you to modify/update coordinates for specific
% zones, which can then be copy/pasted into the corresponding
% use 'whereishe_master' script after, then the Int file conversion script.

%% define some parameters
clear; clc; %close all;

% datafolder directory
datafolder = pwd;
cd(datafolder);

% Interpolate missing data? Alternatives is to exclude missing data, or ignore missing data.
missing_data = 'exclude'; % can also be 'exclude' or 'ignore'

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
minY = 400; addY = 500-minY;
minX = 425; addX = 600-minX;
rRW_fld = [minX minY addX addY];

% left reward zone (sideways room, R)
minY = -10; addY = 65-minY;
minX = 425; addX = 600-minX;
lRW_fld = [minX minY addX addY];

% central stem (sideways room, R)
minY = 200; addY = 280-minY;
minX = 225; addX = 500-minX;
STM_fld = [minX minY addX addY]; 

% delay pedestal (sideways room, R) OR T-maze base junction
minY = 200; addY = 280-minY;
minX = 100; addX = 225-minX;
PED_fld = [minX minY addX addY];

% choice point/T-junction (sideways room, R)
minY = 200; addY = 280-minY;
minX = 500; addX = 650-minX;
CP_fld = [minX minY addX addY]; %[260 150 30 270];

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

