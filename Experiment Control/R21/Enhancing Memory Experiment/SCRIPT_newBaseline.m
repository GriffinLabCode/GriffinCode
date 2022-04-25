%% new baseline
% used to make baseline mean and std on recorded data from the bowl

clear;

% define rat IDs
%{
rats{1} = '21-12';
rats{2} = '21-13';
rats{3} = '21-14';
rats{4} = '21-15';
rats{5} = '21-16';
rats{6} = '21-21';
rats{7} = '21-22';
%}
rats{1} = '';
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
    dataSess = [];
    for sessi = 1:length(dir_content)-1

        clear lfp_pf_cp lfp_hc_cp lfp_pfc lfp_hpc lfp_ts Int

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
        
        % load data
        dataIN = [];
        dataIN = load(dataINfolder{1},'dataStored');

        % detrend signals
        try
            dataUSE = [];
            dataUSE = dataIN.dataStored;
        catch
            continue
        end
        
        % collapse
        dataUSE = horzcat(dataUSE{:});
        
        % detrend by removing 3rd degree polynomial
        dataDET = [];
        for ii = 1:length(dataUSE)
            dataDET{ii}(1,:) = detrend(dataUSE{ii}(1,:),3);
            dataDET{ii}(2,:) = detrend(dataUSE{ii}(2,:),3);            
        end
        
        % collapse data
        dataCOL = [];
        dataCOL = horzcat(dataDET{:});
        
        % store it for output
        dataSess{sessi} = dataCOL;
        
        % feedback
        disp(['Completed with ',rats{i},' session ',num2str(sessi)])
         
    end
    
    % collapse data across all sessions to create a very long vector of
    % data to estimate mean and std
    try
        dataREADY = [];
        dataREADY = horzcat(dataSess{:});

        % take the mean and standard deviation
        baselineMean = []; baselineStd = [];
        baselineMean(1) = nanmean(dataREADY(1,:));
        baselineMean(2) = nanmean(dataREADY(2,:));        
        baselineSTD(1)  = std(dataREADY(1,:));        
        baselineSTD(2)  = std(dataREADY(2,:)); 

        % info
        info = 'Collapsing bowl recordings per rat to derive at a new threshold';

        % store data
        cd(['X:\01.Experiments\R21\' rats{i}])
        mkdir(['X:\01.Experiments\R21\' rats{i},'\baseline alternative'])
        cd(['X:\01.Experiments\R21\' rats{i},'\baseline alternative'])
        save('baselineData.mat','baselineMean','baselineSTD','info')
    catch
        continue
    end
    disp(['Completed with ',rats{i}])
end



