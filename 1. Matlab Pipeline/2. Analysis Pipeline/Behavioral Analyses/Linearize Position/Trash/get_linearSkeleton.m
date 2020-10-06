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

function [data] = get_linearSkeleton(datafolder,int_name,vt_name,missing_data,measurements)

% addpaths
%Startup_linearSkeleton

% get vt data
[ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% -- this needs to be flexible, change me! -- %
%{
% define the convFact variable
data.measurements.convFact(1:2) = [2.09 2.04]; % left room is easy. its almost a perfect square. first col is x, second y

% converted
ExtractedX = ExtractedX./data.measurements.convFact(1);
ExtractedY = ExtractedY./data.measurements.convFact(2);
%}
% conversion shouldn't be necessary if you provide the actual maze
% dimensions. This is bc linearizing is binning and we can restrict the
% number of bins.
%{
% define the convFact variable
data.measurements.convFact(1:2) = [2.09 2.04]; % left room is easy. its almost a perfect square. first col is x, second y

% convert x and y data
ExtractedX = ExtractedX./data.measurements.convFact(1);
ExtractedY = ExtractedY./data.measurements.convFact(2);
%}

% load int file
load(int_name)

% what is the measured distance from stem entry to startbox entry? Note
% that this is easier than converting to cm, and provides clear size
% boundaries for the data
data.measurements = measurements;
data.measurements.total_distance = sum(cell2mat(struct2cell(measurements)));

% position data
data.pos(1,:) = ExtractedX;
data.pos(2,:) = ExtractedY;

% get linear skeleton
data.idealTraj = idealized_trajectory_2(data.pos,data.measurements.total_distance);

Coord = linearSkeleton(x, y, meas_distance, Int_indicator)

% put it all in a struct for tighter packing in the base workspace (when loading variables later)
idealTraj = struct('idealL',idealL,'idealR',idealR);

% information
data.information.measurements = 'Measurements of actual maze excluding startbox';
data.information.pos = 'Cartesian coordinates for rat position. Row 1 is X, row 2 is Y';
data.information.idealTraj = 'Idealized trajectory used for linearizing position ';

end
