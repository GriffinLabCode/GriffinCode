%% percent accuracy on DA so far
clear;
% theres like no theta on 21-15. I dont think we can include him

% define rat IDs
rats{1} = '21-12';
rats{2} = '21-13';
rats{3} = '21-14';
rats{4} = '21-33';
rats{5} = '21-15';
rats{6} = '21-16';
rats{7} = '21-21';
rats{8} = '21-37';

tsCP_high_cat = []; tsCP_low_cat = []; tsCP_highY_cat = []; tsCP_lowY_cat = [];
for i = 1:length(rats)
    
    % get datafolders (session names) into a cell array
    Datafolders = ['X:\01.Experiments\R21\',rats{i},'\Sessions\DA Habituation\'];
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
    tsCP_high = []; tsCP_low = []; tsCP_yLow = []; tsCP_yHigh = [];
    for sessi = 1:length(dir_content)
        try
          
            % define datafolder
            datafolder = [Datafolders,dir_content{sessi}];

            % load maze and matlab data
            cd(datafolder);
            dataINfolder = dir(datafolder);
            dataINfolder = extractfield(dataINfolder,'name');
            idxKeep = find(contains(dataINfolder,rats{i})==1);
            dataINfolder = dataINfolder(idxKeep);

            if length(dataINfolder) > 1
                error('Make sure there is only one .mat file name with your rat')
            end

            % pull in matlab data
            dataIN = load(dataINfolder{1},'accuracy','delayLenTrial','indicatorOUT','trajectory_text','percentAccurate');
            try remData = load('removeTrajectories');
            catch remData = [];
            end

            % eliminate trials
            % remove any trials after length of trials
            numTrials = length(dataIN.accuracy);
            dataIN.delayLenTrial(numTrials+1:end)=[];

            % delay times 
            delayTimes = [];
            delayTimes = dataIN.delayLenTrial;
            % trial accuracies
            accuracy  = []; 
            accuracy  = dataIN.accuracy;        

            % get delay and accuracy data into one variable
            delayXaccuracy{i,sessi} = horzcat(delayTimes',accuracy');

            % feedback
            disp(['Completed with ',rats{i},' session ',num2str(sessi)])
        end
         
    end
    disp(['Completed with ',rats{i}])
end

% collapse data into a rat based array
delayXaccuracy_rat = cellcat(delayXaccuracy,'vertcat','col');

% use kmeans to separate high and low
data4k = vertcat(delayXaccuracy_rat{:});

% kmeans to define long and short duration
[k,c] = kmeans(data4k(:,1),2);
c(1)=10; c(2)=25;

% using centroids to determine thresholds
shortDelay = []; longDelay = [];
for i = 1:length(delayXaccuracy_rat)
    idxShort = [];
    idxShort = find(delayXaccuracy_rat{i}(:,1) >= 5 & delayXaccuracy_rat{i}(:,1) <= c(1));
    shortDelay{i} = delayXaccuracy_rat{i}(idxShort,2);
    
    idxLong = [];
    idxLong = find(delayXaccuracy_rat{i}(:,1) >= c(2) & delayXaccuracy_rat{i}(:,1) <= 30);
    longDelay{i} = delayXaccuracy_rat{i}(idxLong,2);
end

shortDelayAvg = cellfun(@nanmean,shortDelay);
longDelayAvg  = cellfun(@nanmean,longDelay);
shortDelayAvg = (1-shortDelayAvg)*100;
longDelayAvg = (1-longDelayAvg)*100;

multiBarPlot(horzcat(shortDelayAvg',longDelayAvg'),[{'Short Delays'} {'Long Delays'}],'Choice Accuracy (%)');
[h,p,ci,stat]=ttest(shortDelayAvg,longDelayAvg);
ylim([50 100])


% what about an anova style analysis

shortDelay = []; longDelay = [];
looper1 = 5:2:15;
looper2 = 20:2:30;
looper = vertcat(looper1,flipud(looper2')');
looper = 5:4:30;
ratAcc = [];
for i = 1:length(delayXaccuracy_rat)
    for k = 1:size(looper,2)-1
        idx = [];
        idx = find(delayXaccuracy_rat{i}(:,1) >= looper(k) & delayXaccuracy_rat{i}(:,1) < looper(k+1));
        acc = [];
        acc = delayXaccuracy_rat{i}(idx,2);
        acc = 1-nanmean(acc);
        ratAcc(i,k) = acc;
    end
end
figure('color','w')
errorbar(1:length(looper)-1,mean(ratAcc,1),stderr(ratAcc,1),'k','LineWidth',2);
xlim([0 7])
box off
ylabel('Choice Accuracy')
xlabel('Delay Duration Bin')
ratAccCat = ratAcc(:);
ratID = repmat(rats,6);
ratID = ratID(1,:)';
delayMeas = vertcat(repmat('meas1',[8,1]),repmat('meas2',[8,1]),...
    repmat('meas3',[8,1]),repmat('meas4',[8,1]),repmat('meas5',[8,1]),...
    repmat('meas6',[8,1]));
t = table(ratID,delayMeas,ratAccCat);
place2store = getCurrentPath;
cd(place2store);
writetable(t,'data_choiceXdelay_spreadSheet.csv');

