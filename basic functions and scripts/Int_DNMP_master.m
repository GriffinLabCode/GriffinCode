%% This script creates an "Int" variable for DNMP sessions. 
%
% Must define datafolder as a string variable containing the directory to
% your session of interest

clearvars -except datafolder
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')

% define whether to interpolate missing position data
interp_missing_VT_data = 1;

% Load position data
load(strcat(datafolder,'\VT1.mat'));

% interpolate missing vt data
if interp_missing_VT_data == 1
    ExtractedX = []; ExtractedY = [];
    [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);
else
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
choice_trials = 2:2:numtrials;
for i = 1:size(choice_trials,2);
        if  Int(choice_trials(i),3)== Int(choice_trials(i)-1,3);
            Int(choice_trials(i),4)= 1;
            Int(choice_trials(i)-1,4) = 1;
        end
end
percentCorrect = (((numtrials/2)-(sum(Int(:,4))/2))/(numtrials/2))*100;

% display progress
C = [];
C = strsplit(datafolder,'\');
X = [];
X = [C{end},' behavioral accuracy = ',num2str(percentCorrect),'%'];
disp(X);

% save data
save(strcat(datafolder,'\Int_file.mat'),'Int');
