%% This script creates an "Int" variable for DNMP sessions. 
%
% Must define datafolder as a string variable containing the directory to
% your session of interest
%
% JS modified and consolidated this on 8/7/2020

% datafolder directory
datafolder = 'C:\Users\jstout\Documents\GitHub\GriffinCode\1. Matlab Pipeline\Sample Data\Baby Groot 9-12 Sample data'; 
datafolderNew = datafolder;
cd(datafolder);
clearvars -except datafolder datafolderNew

% get video tracking data
missing_data = 'interp'; % this could be 'exclude' or 'ignore'
vt_name      = 'VT1.mat';
[ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% define some old school variables
pos_x = ExtractedX; pos_y = ExtractedY; pos_t = TimeStamps;

% Define the beginning and end of the session
start  = TimeStamps(1);
finish = TimeStamps(end); 
Int = [];

% Define the Int variable
[Int] = whereishe_master(pos_x,pos_y,pos_t);

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
for i = 1:size(choice_trials,2)
        if  Int(choice_trials(i),3)== Int(choice_trials(i)-1,3)
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

% check Int for timing-position accuracy
question = 'Would you like to confirm your int file is correct? [Y/N] ';
answer   = input(question,'s');

if contains(answer,'Y') | contains(answer,'y')
    checkInt;
else
    disp('It is recommended that you check your int file');
end

% save data
question = 'Are you satisfied with the Int file and ready to save? [Y/N] ';
answer   = input(question,'s');

if contains(answer,'Y') | contains(answer,'y')
    cd(datafolder);
    
    % have user define a name
    question    = 'Please enter an Int file name: ';
    IntFileName = input(question,'s');
    
    % save
    save(IntFileName,'Int');
end

% save data
cd(datafolder)
save('Int_DNMP.mat','Int');