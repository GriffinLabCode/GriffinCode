%% This script creates an "Int" variable for DNMP sessions. 
%
% Must define datafolder as a string variable containing the directory to
% your session of interest
%
% this script was not written by me

clear;
% theres like no theta on 21-15. I dont think we can include him

% define rat IDs
rats{1} = '21-12';
rats{2} = '21-13';
rats{3} = '21-14';
rats{4} = '21-15';
rats{5} = '21-16';
rats{6} = '21-21';
%rats{7} = '21-22';

for diri = 1:length(rats)
    
    % Each of your rats should share identical folder names so that you can
    % use this variable
    Datafolders = ['X:\01.Experiments\R21\',rats{diri},'\Sessions\DA testing\'];
    dir_content = [];
    dir_content = dir(Datafolders);
    if isempty(dir_content)
        continue
    end
    dir_content = extractfield(dir_content,'name');
    remIdx = contains(dir_content,'.mat') | contains(dir_content,'.');
    dir_content(remIdx)=[];
    rem2 = contains(dir_content,'DA');
    dir_content(rem2)=[];

    % loop across
    for sessi = 1:length(dir_content)

        try 
            % define datafolder
            datafolder = [Datafolders,dir_content{sessi}];

            % load maze and matlab data
            dataINfolder = [];
            cd(datafolder);
            dataINfolder = dir(datafolder);
            dataINfolder = extractfield(dataINfolder,'name');
            idxKeep = find(contains(dataINfolder,rats{diri})==1);
            dataINfolder = dataINfolder(idxKeep);

            % convert events
            convertFiles(datafolder);
            
            % load in events
            pos_x = []; pos_y = [];  pos_t = []; Events = []; EventStrings = []; TimeStamps = [];
            load('Events','EventStrings','TimeStamps')
            [pos_x,pos_y,pos_t] = getVTdata(datafolder,'interp','VT1.mat');

            %% get sequence of events
            dataINfolder = dir(datafolder);
            dataINfolder = extractfield(dataINfolder,'name');
            idxKeep = find(contains(dataINfolder,ratName)==1);
            dataINfolder = dataINfolder(idxKeep);

            numTrials_maze = load(dataINfolder{1},'numTrials');

            % get CP entry
            CPentry = [];
            CPentry = find(contains(EventStrings,'CPentry')==1);

            % get gz entry
            CPexit = [];
            CPexit = find(contains(EventStrings,{'CPexit'})==1);

            % get gz exit
            Return = [];
            Return = find(contains(EventStrings,[{'Return'}])==1);

            RightTurn = []; LeftTurn = [];
            RightTurn = find(contains(EventStrings,[{'ReturnRight'}]));
            LeftTurn  = find(contains(EventStrings,[{'ReturnLeft'}]));

            % delay
            delayEntry = []; delayExitTemp = []; firstDelayExit = []; delayExit = [];
            delayEntry = find(contains(EventStrings,[{'DelayEntry'}])==1);
            delayExitTemp  = find(contains(EventStrings,[{'DelayExit'}])==1);
            % first delay entry
            firstDelayExit = find(contains(EventStrings,[{'TrialStart'}])==1);
            delayExit = vertcat(firstDelayExit,delayExitTemp);

            numTrials = []; Int = [];
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

            save('Int_IR','Int')
        end
    end
end



