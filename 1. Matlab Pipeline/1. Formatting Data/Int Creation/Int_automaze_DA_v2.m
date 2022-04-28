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

ratName = '21-37';

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

% if there are multiple start/stops
sessStart = find(contains(EventStrings,'SessionStart')==1);
if numel(sessStart > 1)
    EventStrings(2:sessStart(end)-1)=[];
    TimeStamps(2:sessStart(end)-1)=[];
end

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

% a novel approach -
sequenceTimes = []; sequenceTemp = [];
sequenceTemp = padcat(delayExit,CPentry,CPexit,Return,delayEntry);
for rowi = 1:size(sequenceTemp,1)
    for coli = 1:size(sequenceTemp,2)
        try 
            sequenceTimes(rowi,coli) = TimeStamps(sequenceTemp(rowi,coli));
        catch
            sequenceTimes(rowi,coli) = NaN;
        end
    end
end
sequenceTable = array2table(sequenceTimes);
% Default heading for the columns will be A1, A2 and so on. 
% You can assign the specific headings to your table in the following manner
sequenceTable.Properties.VariableNames(1:5) = {'DelayExit','CPentry','CPexit','Return','DelayEntry'};

% behavioral table - remove 'Return'
trajData = EventStrings(contains(EventStrings,[{'ReturnLeft'} {'ReturnRight'}]));
clear trajectories
for i = 1:length(trajData)
    trajectories{i,:} = erase(trajData{i},'Return');
end

% get accuracy
numTrials = size(sequenceTable,1);
accuracyTemp = []; accuracy = [];
for triali = 1:numTrials-1
    if contains(trajData{triali},'Left') && contains(trajData{triali+1},'Right')
        accuracyTemp(triali,:) = 0;
    elseif contains(trajData{triali},'Right') && contains(trajData{triali+1},'Left')
        accuracyTemp(triali,:) = 0;
    else
        accuracyTemp(triali,:) = 1;
    end
end
accuracy(1)=NaN;
accuracy(2:numel(accuracyTemp)+1,:) = accuracyTemp;

sequenceTable.Properties.VariableNames(6:7) = {'Trajectory','Accuracy'};
sequenceTable.Trajectory = trajectories;
sequenceTable.Accuracy   = accuracy;

% percent correct
percentCorrect = (1-nanmean(accuracy))*100;

% check Int for timing-position accuracy
question = 'Would you like to confirm your int file is correct? [Y/N] ';
answer   = input(question,'s');

if contains(answer,'Y') | contains(answer,'y')

    % number of trials
    numTrials = size(sequenceTable,1);

    p1 = []; p2 = [];
    for i = 1:numTrials-1
        figure('color','w'); hold on;    
        p1 = plot(pos_x,pos_y,'Color',[.8 .8 .8]); 
        p1.Annotation.LegendInformation.IconDisplayStyle = 'off';

        % get position data on a trial-by-trial basis
        x_trial = pos_x(pos_t >= sequenceTable.DelayExit(i) & pos_t <= sequenceTable.CPexit(i));
        y_trial = pos_y(pos_t >= sequenceTable.DelayExit(i) & pos_t <= sequenceTable.CPexit(i));

        %x_trial = pos_x(pos_t >= Int(i,8) & pos_t <= Int(i+1,1));
        %y_trial = pos_y(pos_t >= Int(i,8) & pos_t <= Int(i+1,1));
        
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




