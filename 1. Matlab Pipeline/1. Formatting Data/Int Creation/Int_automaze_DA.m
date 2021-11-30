%% This script creates an "Int" variable for DNMP sessions. 
%
% Must define datafolder as a string variable containing the directory to
% your session of interest
%
% this script was not written by me
clear; clc


% datafolder directory - stopped on baseline 1 need to do baseline 2 -
% 9-2-2020 at 2:19
datafolder = pwd;
datafolderNew = datafolder;
cd(datafolder);
clearvars -except datafolder datafolderNew

ratName = '21-16';

% load in events
load('Events','EventStrings','TimeStamps')
[pos_x,pos_y,pos_t] = getVTdata(datafolder,'interp','VT1.mat');

%% get sequence of events
dataINfolder = dir(datafolder);
dataINfolder = extractfield(dataINfolder,'name');
idxKeep = find(contains(dataINfolder,ratName)==1);
dataINfolder = dataINfolder(idxKeep);
        
numTrials_maze = load(dataINfolder{1},'numTrials');

% get trial onset
%trialOnset = contains(EventStrings,'centralOpen');

% get CP entry
CPentry = find(contains(EventStrings,'CPentry')==1);

% get gz entry
CPexit = find(contains(EventStrings,{'CPexit'})==1);

% get gz exit
Return = find(contains(EventStrings,[{'Return'}])==1);

RightTurn = find(contains(EventStrings,[{'ReturnRight'}]));
LeftTurn  = find(contains(EventStrings,[{'ReturnLeft'}]));

% delay
delayEntry = find(contains(EventStrings,[{'DelayEntry'}])==1);
delayExitTemp  = find(contains(EventStrings,[{'DelayExit'}])==1);
% first delay entry
firstDelayExit = find(contains(EventStrings,[{'TrialStart'}])==1);
delayExit = vertcat(firstDelayExit,delayExitTemp);

%% use sequence of events to piece together the int file
numTrials = length(CPentry);
if numTrials > numTrials_maze.numTrials
    numTrials = numTrials_maze.numTrials;
end
Int = zeros([numTrials 8]);

for triali = 1:numTrials
    
    % delay exit
    Int(triali,1) = TimeStamps(delayExit(triali));
    
    % cp entry
    Int(triali,5) = TimeStamps(CPentry(triali));
    
    % cp exit
    Int(triali,6) = TimeStamps(CPexit(triali));
    
    % delay entry
    %Int(triali,8) = TimeStamps(Return(triali));\
    Int(triali,8) = TimeStamps(delayEntry(triali));


    % Track left/right
    if contains(EventStrings(Return(triali)),'ReturnRight')
        Int(triali,3)=0;
    elseif contains(EventStrings(Return(triali)),'ReturnLeft')
        Int(triali,3)=1;
    else
        error('Something is wrong with turn direction')
    end
    
end

for i = 1:numTrials-1
    if Int(i,3) == 1 && Int(i+1,3) == 0 || Int(i,3) == 0 && Int(i+1,3) == 1
        Int(i+1,4) = 0;
    else
        Int(i+1,4) = 1;
    end
end
percentCorrect = (((numTrials)-(sum(Int(:,4))))/(numTrials-1))*100;


% check Int for timing-position accuracy
question = 'Would you like to confirm your int file is correct? [Y/N] ';
answer   = input(question,'s');

if contains(answer,'Y') | contains(answer,'y')

    % number of trials
    numTrials = size(Int,1);

    p1 = []; p2 = [];
    for i = 1:numTrials-1
        figure('color','w'); hold on;    
        p1 = plot(pos_x,pos_y,'Color',[.8 .8 .8]); 
        p1.Annotation.LegendInformation.IconDisplayStyle = 'off';

        % get position data on a trial-by-trial basis
        x_trial = pos_x(pos_t >= Int(i,5) & pos_t <= Int(i,6));
        y_trial = pos_y(pos_t >= Int(i,5) & pos_t <= Int(i,6));
        
        x_trial = pos_x(pos_t >= Int(i,8) & pos_t <= Int(i+1,1));
        y_trial = pos_y(pos_t >= Int(i,8) & pos_t <= Int(i+1,1));
        
        plot(x_trial,y_trial,'r','LineWidth',2)

        % correct any issues
        question = 'Keep trial? [Y/N] / [y/n] ';
        answer   = input(question,'s');

        if contains(answer,[{'N'} {'n'}])
            remData(i) = 1;
        else
            remData(i) = 0;
        end

        %pause;
        close;
    end 
    remData = logical(remData);
    
    % remove data selected by user
    Int(remData,:)=[];

    numtrials = size(Int,1);
    for i = 1:numtrials-1
        if Int(i,3) == 1 && Int(i+1,3) == 0 || Int(i,3) == 0 && Int(i+1,3) == 1
            Int(i+1,4) = 0;
        else
            Int(i+1,4) = 1;
        end
    end
    percentCorrect = (((numTrials)-(sum(Int(:,4))))/(numTrials-1))*100;

    % display progress
    C = [];
    C = strsplit(datafolder,'\');
    X = [];
    X = [C{end},' behavioral accuracy = ',num2str(percentCorrect),'%'];
    disp(X);
else
    disp('IT IS RECOMMENDED that you check your int file as missing data will be stored as a non-existing trial');
end



save('Int_IR','Int')




