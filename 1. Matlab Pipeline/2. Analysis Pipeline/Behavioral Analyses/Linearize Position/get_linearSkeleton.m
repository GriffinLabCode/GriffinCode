%% get_linearPosition
% this function takes position data and actual maze measurements (not
% including startbox) and requires the user to create a linear skeleton.
% The next function used should be 'get_linearPosition'
% 
% -- INPUTS -- %
% datafolder: directory of data
% int_name: name of int file
% vt_name: video track file name
% missing_data: can be 'exclude', 'ignore', or 'interp'
% measurements: a structure array of measurements. Includes stem, goal arm,
%                   goal zone and return arm and should be formatted like
%                   below
% Int_indicator: Int_indicator.left = 1 tells the code that row 3 in the
%                   Int file, whos values are 1s, are left turns.
% EXAMPLE:
%{
    datafolder   = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-11-18'; 
    int_name     = 'Int_file.mat';
    vt_name      = 'VT1.mat';
    missing_data = 'exclude';
    measurements.stem     = 137;
    measurements.goalArm  = 50;
    measurements.goalZone = 37;
    measurements.retArm   = 130;
%}
%
% -- OUPUTS -- %
% data: a structure array containing linear position, linear skeleton and
%           other outputs.

function [data] = get_linearSkeleton(datafolder,int_name,vt_name,missing_data,measurements,Int_indicator)

% get vt data
[x,y,ts] = getVTdata(datafolder,missing_data,vt_name);

% load int file
load(int_name)

% what is the measured distance from stem entry to startbox entry? Note
% that this is easier than converting to cm, and provides clear size
% boundaries for the data
data.measurements = measurements;
data.measurements.total_distance = sum(cell2mat(struct2cell(measurements)));

% only two trajectories for now. In the future, you could make this
% flexible.
disp('Follow the trajectory on the screen ')
[stemX, stemY] = linearSkeleton_stem(x, y, ts, Int);
idealR = linearSkeleton(x, y, ts, stemX, stemY, Int, measurements, Int_indicator.right);
idealL = linearSkeleton(x, y, ts, stemX, stemY, Int, measurements, Int_indicator.left);

% put it all in a struct for tighter packing in the base workspace (when loading variables later)
data.idealTraj = struct('idealL',idealL,'idealR',idealR);

% information
data.information.measurements = 'Measurements of actual maze excluding startbox';
data.information.pos = 'Cartesian coordinates for rat position. Row 1 is X, row 2 is Y';
data.information.idealTraj = 'Idealized trajectory used for linearizing position ';

end
