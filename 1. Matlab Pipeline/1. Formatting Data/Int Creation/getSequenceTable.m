%% getSequenceTable
%
% this code replaces the Int file, but requires the automated T-maze with
% IR based tracking being logged into cheetahs recording software
%
% written by John Stout on 4/27/22

% datafolder directory
datafolder = pwd;
datafolderNew = datafolder;
cd(datafolder);
clearvars -except datafolder datafolderNew

ratName = '21-36';

% load in events
load('Events','EventStrings','TimeStamps')
[pos_x,pos_y,pos_t] = getVTdata(datafolder,'interp','VT1.mat');

%% get sequence of events
dataINfolder = dir(datafolder);
dataINfolder = extractfield(dataINfolder,'name');
idxKeep = find(contains(dataINfolder,ratName)==1);
dataINfolder = dataINfolder(idxKeep);
        
%numTrials_maze = load(dataINfolder{1},'numTrials');

% if there are multiple start/stops
sessStart = find(contains(EventStrings,'SessionStart')==1);
if numel(sessStart) > 1
    EventStrings(2:sessStart(end)-1)=[];
    TimeStamps(2:sessStart(end)-1)=[];
end

% get CP entry
CPentry = find(contains(EventStrings,'CPentry')==1);

% get gz entry
CPexit = find(contains(EventStrings,{'CPexit'})==1);

% get gz exit
Return = find(contains(EventStrings,[{'Return'}])==1);
RightTurn = find(contains(EventStrings,[{'Right'}]));
LeftTurn  = find(contains(EventStrings,[{'Left'}]));

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
%trajectories{end+1} = 'NaN';

% get accuracy
numTrials = size(sequenceTable,1);
accuracyTemp = []; accuracy = [];
for triali = 1:numTrials-1
    if contains(trajectories{triali},'Left') && contains(trajectories{triali+1},'Right')
        accuracyTemp(triali,:) = 0;
    elseif contains(trajectories{triali},'Right') && contains(trajectories{triali+1},'Left')
        accuracyTemp(triali,:) = 0;
    elseif contains(trajectories{triali},'NaN') || contains(trajectories{triali+1},'NaN')
        accuracyTemp(triali,:) = NaN;
    else
        accuracyTemp(triali,:) = 1;
    end
end
accuracy(1)=NaN;
accuracy(2:numel(accuracyTemp)+1,:) = accuracyTemp;

sequenceTable.Trajectory = trajectories;
sequenceTable.Accuracy   = accuracy;
sequenceTable.Remove     = zeros([size(sequenceTable,1) 1]);

% percent correct
percentCorrect = (1-nanmean(accuracy))*100;

% check Int for timing-position accuracy
question = 'Would you like to confirm your int file is correct? [Y/N] ';
answer2check   = input(question,'s');

if contains(answer2check,'Y') | contains(answer2check,'y')

    % number of trials
    numTrials = size(sequenceTable,1);

    prompt = 'Did this task have a delay phase? ';
    delayP = input(prompt,'s');
    
    if contains(delayP,'n')

        p1 = []; p2 = [];
        for i = 1:numTrials
            figure('color','w'); hold on;    
            p1 = plot(pos_x,pos_y,'Color',[.8 .8 .8]); 
            p1.Annotation.LegendInformation.IconDisplayStyle = 'off';

            % get position data on a trial-by-trial basis
            x_trial = pos_x(pos_t >= (sequenceTable.CPentry(i)-(5*1e6)) & pos_t <= sequenceTable.Return(i));
            y_trial = pos_y(pos_t >= (sequenceTable.CPentry(i)-(5*1e6)) & pos_t <= sequenceTable.Return(i));
            plot(x_trial,y_trial,'r','LineWidth',2)

            % correct any issues
            question = 'Keep trial? [Y/N] / [y/n] ';
            answer   = input(question,'s');

            if contains(answer,[{'N'} {'n'}])
                remData(i,:) = 1;
            else
                remData(i,:) = 0;
            end

            %pause;
            close;
        end         
    else
        p1 = []; p2 = [];
        for i = 1:numTrials
            figure('color','w'); hold on;    
            p1 = plot(pos_x,pos_y,'Color',[.8 .8 .8]); 
            p1.Annotation.LegendInformation.IconDisplayStyle = 'off';

            % get position data on a trial-by-trial basis
            x_trial = pos_x(pos_t >= sequenceTable.DelayExit(i) & pos_t <= sequenceTable.CPexit(i));
            y_trial = pos_y(pos_t >= sequenceTable.DelayExit(i) & pos_t <= sequenceTable.CPexit(i));

            plot(x_trial,y_trial,'r','LineWidth',2)

            % correct any issues
            question = 'Keep trial? [Y/N] / [y/n] ';
            answer   = input(question,'s');

            if contains(answer,[{'N'} {'n'}])
                remData(i,:) = 1;
            else
                remData(i,:) = 0;
            end

            %pause;
            close;
        end 
        %remData = logical(remData);
    end
    % remove data selected by user
    sequenceTable.Remove = remData;

    % display progress
    C = [];
    C = strsplit(datafolder,'\');
    X = [];
    X = [C{end},' behavioral accuracy = ',num2str(percentCorrect),'%'];
    disp(X);
    save('sequenceTable_checked','sequenceTable')
else
    save('sequenceTable','sequenceTable')
    disp('You should spot check this data. With IR beam tracking, it is much more precise though**');
end




