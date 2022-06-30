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
    Datafolders = ['X:\01.Experiments\R21\',rats{i},'\Sessions\DA testing\'];
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
            
            % get vt data
            x = []; y = []; t = [];
            [x,y,t]=getVTdata(datafolder,'interp','VT1.mat');

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
            dataIN.indicatorOUT(numTrials+1:end)=[];
            dataIN.delayLenTrial(numTrials+1:end)=[];

            % load int
            load('sequenceTable')
            sequenceTable.Remove(remData.remTraj)=1;
            sequenceTable([remData.remTraj],:)   = [];
            sequenceTable([1],:)                 = []; % remove first trial

            % eliminate the first trajectory
            %Int(1,:)=[];

            % another way to remove data - not needed for sequence table
            remChoices = [];
            try
                remChoices = remData.remTraj-1;                  
            catch
            end

            % indicatorOUT temp
            tempInd = [];
            tempInd = dataIN.indicatorOUT;
            % delay times 
            delayTimes = [];
            delayTimes = dataIN.delayLenTrial;
            % trial accuracies
            accuracy  = []; 
            accuracy  = dataIN.accuracy;        

            % remove
            tempInd(remChoices)    = [];
            delayTimes(remChoices) = [];
            accuracy(remChoices)   = [];
            
            % get indices
            idxHigh = []; idxLow = []; idxYokedHigh = []; idxYokedLow = [];
            idxHigh = find(contains(tempInd,'highMET')==1);
            idxLow = find(contains(tempInd,'lowMET')==1);
            idxYokedHigh = find(contains(tempInd,'yokeH_MET')==1);
            idxYokedLow = find(contains(tempInd,'yokeL_MET')==1);
            idxNorm = find(contains(tempInd,[{'Norm'}, {'NormHighFail'} {'NormLowFail'}]));

            % find times and make sure everytihng lines up
            delayHighTimes = []; delayHighYTimes = [];
            delayHighTimes = delayTimes(idxHigh);
            delayHighYTimes = delayTimes(idxYokedHigh);

            delayLowTimes = []; delayLowYTimes = [];
            delayLowTimes = delayTimes(idxLow);
            delayLowYTimes = delayTimes(idxYokedLow);
            delayNorm = delayTimes(idxNorm);

            % do the same 
            % remove any delay times that don't have an equally matched partner
            % we're checking for equal delay High Times using the yoked
            % condition because there can only be a yoked trial if there is a
            % high trial
            % however, it is possible that some trials could get removed. So we
            % need to account for those too.
            idxRemHigh = [];
            for j = 1:length(delayHighYTimes)
                findYinHigh = find(delayHighTimes == delayHighYTimes(j));
                if isempty(findYinHigh)==1
                    idxRemHigh(j) = 1;
                else
                    idxRemHigh(j) = 0;
                end
            end       
            idxRemLow = [];
            for j = 1:length(delayLowYTimes)
                findYinLow = find(delayLowTimes == delayLowYTimes(j));
                if isempty(findYinLow)==1
                    idxRemLow(j) = 1;
                else
                    idxRemLow(j) = 0;
                end
            end   

            % idxRemLow: if yoked time isn't found in experimental, remove the
            % yoked time
            % removal of the top two are mostly to check my work
            delayLowYTimes(logical(idxRemLow))=[];
            delayHighYTimes(logical(idxRemHigh))=[];
            % remove from the index used above to get times
            idxYokedHigh(logical(idxRemHigh))=[];
            idxYokedLow(logical(idxRemLow))=[];

            %----------------------------------------%

            % do everything above, except switch variables
            idxRemHigh = [];
            for j = 1:length(delayHighTimes)
                findHighInY = find(delayHighYTimes == delayHighTimes(j));
                if isempty(findHighInY)==1
                    idxRemHigh(j) = 1;
                else
                    idxRemHigh(j) = 0;
                end
            end       
            idxRemLow = [];
            for j = 1:length(delayLowTimes)
                findLowInY = find(delayLowYTimes == delayLowTimes(j));
                if isempty(findLowInY)==1
                    idxRemLow(j) = 1;
                else
                    idxRemLow(j) = 0;
                end
            end   

            % idxRemLow: if yoked time isn't found in experimental, remove the
            % yoked time
            delayLowTimes(logical(idxRemLow))=[];
            delayHighTimes(logical(idxRemHigh))=[];
            % remove from the index used above to get times
            idxHigh(logical(idxRemHigh))=[];
            idxLow(logical(idxRemLow))=[];   
            
            % now use idxHigh and idxYokedHigh to get choicepoint times
            xCP = []; yCP = []; tCP = [];
            xD = []; yD = []; tD = [];
            IdPhi = []; dphi = [];
            totalDist = [];
            for triali = 1:size(sequenceTable,1)
                % time spent to choice from choice presentation
                tsCP(triali) = (sequenceTable.CPexit(triali) - sequenceTable.DelayExit(triali))/1e6;
            
                % get x/y behavior
                xCP{triali} = x((t > sequenceTable.DelayExit(triali) & t < sequenceTable.CPexit(triali)));
                yCP{triali} = y((t > sequenceTable.DelayExit(triali) & t < sequenceTable.CPexit(triali)));
                tCP{triali} = t((t > sequenceTable.DelayExit(triali) & t < sequenceTable.CPexit(triali)));
 
                % smooth position data a little bit
                xCP{triali} = smoothdata(xCP{triali},'gauss',10);
                yCP{triali} = smoothdata(yCP{triali},'gauss',10);
                
                % calculate IdPhi
                window_sec    = 1;   % redish inputs
                postSmoothing = 0.5; % redish inputs
                vt_srate      = 30; % rounded to a integer for ease of computation and stuff
                display       = 0;
                [IdPhi(triali),dphi{triali}] = IdPhi_RedishFun(xCP{triali},yCP{triali},window_sec,postSmoothing,vt_srate,display);

                % get behavior prior to choice presentation
                xD{triali} = x(t > (sequenceTable.DelayExit(triali)-(1.25*1e6)) & t < sequenceTable.DelayExit(triali));
                yD{triali} = y(t > (sequenceTable.DelayExit(triali)-(1.25*1e6)) & t < sequenceTable.DelayExit(triali));
                tD{triali} = t(t > (sequenceTable.DelayExit(triali)-(1.25*1e6)) & t < sequenceTable.DelayExit(triali));
                
                % get instantaneous distance
                instDistance = [];
                [~,~,instDistance] = kinematics2D(xD{triali},yD{triali},tD{triali},'y');
                
                % take the sum of instantaneous distance
                totalDist(triali) = sum(instDistance);
                
            end

            % separate trials - first for time spent
            tsCP_high{sessi}  = tsCP(idxHigh);
            tsCP_low{sessi}   = tsCP(idxLow);
            tsCP_yHigh{sessi} = tsCP(idxYokedHigh);
            tsCP_yLow{sessi}  = tsCP(idxYokedLow);   
            
            % next for idphi
            % first normalize it to account for individual variability
            IdPhiNorm = [];
            IdPhiNorm = normalize(IdPhi,'range');
            idphi_high{sessi}  = IdPhiNorm(idxHigh);
            idphi_low{sessi}   = IdPhiNorm(idxLow);
            idphi_yHigh{sessi} = IdPhiNorm(idxYokedHigh);
            idphi_yLow{sessi}  = IdPhiNorm(idxYokedLow);               

            % similarly normalize distance traveled
            normDist = [];
            normDist = normalize(totalDist,'range');
            dist_high{sessi}  = normDist(idxHigh);
            dist_low{sessi}   = normDist(idxLow);
            dist_yHigh{sessi} = normDist(idxYokedHigh);
            dist_yLow{sessi}  = normDist(idxYokedLow);               

            % feedback
            disp(['Completed with ',rats{i},' session ',num2str(sessi)])
        end
         
    end
    
    % concatenate variables
    tsCP_high_cat{i}  = horzcat(tsCP_high{:});
    tsCP_low_cat{i}   = horzcat(tsCP_low{:});
    tsCP_highY_cat{i} = horzcat(tsCP_yHigh{:});
    tsCP_lowY_cat{i}  = horzcat(tsCP_yLow{:});
    
    idphi_high_cat{i}  = horzcat(idphi_high{:});
    idphi_low_cat{i}   = horzcat(idphi_low{:});
    idphi_highY_cat{i} = horzcat(idphi_yHigh{:});
    idphi_lowY_cat{i}  = horzcat(idphi_yLow{:});    

    dist_high_cat{i}  = horzcat(dist_high{:});
    dist_low_cat{i}   = horzcat(dist_low{:});
    dist_highY_cat{i} = horzcat(dist_yHigh{:});
    dist_lowY_cat{i}  = horzcat(dist_yLow{:});
    
    disp(['Completed with ',rats{i}])
end

% average
tsCP_high_avg  = cellfun(@nanmean,tsCP_high_cat);
tsCP_highY_avg = cellfun(@nanmean,tsCP_highY_cat);
tsCP_low_avg   = cellfun(@nanmean,tsCP_low_cat);
tsCP_lowY_avg  = cellfun(@nanmean,tsCP_lowY_cat);
matPlot = [];
matPlot = horzcat(tsCP_high_avg',tsCP_highY_avg',tsCP_low_avg',tsCP_lowY_avg');
multiBarPlot(matPlot,[{'High'} {'Delay Matched Control'} {'Low'} {'Delay Matched Control'}],'Time-spent at CP (sec)')

% norm idphi
idphi_high_avg  = cellfun(@nanmean,idphi_high_cat);
idphi_highY_avg = cellfun(@nanmean,idphi_highY_cat);
idphi_low_avg   = cellfun(@nanmean,idphi_low_cat);
idphi_lowY_avg  = cellfun(@nanmean,idphi_lowY_cat);
matPlot = [];
matPlot = horzcat(idphi_high_avg',idphi_highY_avg',idphi_low_avg',idphi_lowY_avg');
multiBarPlot(matPlot,[{'High'} {'Delay Matched Control'} {'Low'} {'Delay Matched Control'}],'Mean Norm. IdPhi')

% norm distance
dist_high_avg  = cellfun(@nanmean,dist_high_cat);
dist_highY_avg = cellfun(@nanmean,dist_highY_cat);
dist_low_avg   = cellfun(@nanmean,dist_low_cat);
dist_lowY_avg  = cellfun(@nanmean,dist_lowY_cat);
matPlot = [];
matPlot = horzcat(dist_high_avg',dist_highY_avg',dist_low_avg',dist_lowY_avg');
multiBarPlot(matPlot,[{'High'} {'Delay Matched Control'} {'Low'} {'Delay Matched Control'}],'Mean Norm. Dist')

