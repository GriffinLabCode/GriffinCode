%% This script creates an "Int" variable for DNMP sessions. 
%
% Must define datafolder as a string variable containing the directory to
% your session of interest
%
% this script was not written by me

datafolder = 'X:\01.Experiments\DA prospective coding - analyses on old data\dHPC data - Hallock and Griffin 2013\0903-15';
datafolderNew = datafolder;

clearvars -except datafolder datafolderNew
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')

% interpolate missing vt data
interp_missing_data = 1;

% Load position data
cd(datafolder);
load('VT1.mat');
datafolder = datafolderNew;

% interpolate missing vt data
if interp_missing_data == 1
    ExtractedX = []; ExtractedY = [];
    [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);
else
end

if exist('TimeStamps') == 1
    TimeStamps_VT = TimeStamps;
end

% define some old school variables
pos_x = ExtractedX; pos_y = ExtractedY; pos_t = TimeStamps_VT;

% Define the beginning and end of the session
start  = TimeStamps_VT(1);
finish = TimeStamps_VT(end); 
Int = [];

% Define the Int variable
[Int] = whereishe_master(pos_x,pos_y,pos_t,datafolder);

% set up for populating correct/incorrect column 4
ind         = find(pos_t>=start & pos_t<=finish);
pos_t1=pos_t(ind); pos_x1=pos_x(ind); pos_y1=pos_y(ind);
Int_ind     = find(Int(:,1)>start & Int(:,8)<finish);
starttrials = Int_ind(1,1);
endtrials   = Int_ind(end);
Int         = Int(1:endtrials,:);

% Populate column 4 of the Int variable 
% 0 = Correct, 1 = Incorrect
numtrials = size(Int,1);
for i = 1:numtrials-1
    if Int(i,3) == 1 && Int(i+1,3) == 0 || Int(i,3) == 0 && Int(i+1,3) == 1
        Int(i+1,4) = 0;
    else
        Int(i+1,4) = 1;
    end
end
percentCorrect = (((numtrials/2)-(sum(Int(:,4))/2))/(numtrials/2))*100;

% load in old int file - the first is DA task
load('Intervals')
numDA1 = size(Int1,1);

% extract first set of DA trials
Int_new = Int(1:numDA1,:);

clearvars -except datafolder Int_new percentCorrect
Int = Int_new;

clear Int_new
% display progress
C = [];
C = strsplit(datafolder,'\');
X = [];
X = [C{end},' behavioral accuracy = ',num2str(percentCorrect),'%'];
disp(X);

% save data
cd(datafolder); clear datafolder
save('Int_DA.mat','Int');