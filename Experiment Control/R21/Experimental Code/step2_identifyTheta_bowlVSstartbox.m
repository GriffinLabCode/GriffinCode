clear;

% define rat IDs
rats{1} = '21-12';
rats{2} = '21-13';
rats{3} = '21-14';
%rats{4} = '21-15';
rats{4} = '21-16';
rats{5} = '21-21';
%rats{7} = '21-22';

%%
clearvars -except cohData dataIN rats dataOUT

% now get data for every session and compute coherence like for 21-13 below
%Datafolders = 'X:\01.Experiments\R21';

cohSB_cache = []; cohB_cache = [];
for i = 1:length(rats)
    
    % get datafolders (session names) into a cell array
    Datafolders = ['X:\01.Experiments\R21\',rats{i},'\Sessions\DA Habituation\'];
    dir_content = [];
    dir_content = dir(Datafolders);
    dir_content = extractfield(dir_content,'name');
    remIdx = contains(dir_content,'.mat') | contains(dir_content,'.');
    dir_content(remIdx)=[];
    rem2 = contains(dir_content,'DA');
    dir_content(rem2)=[];

    % define LFP names
    %hpcName = dataIN{i}.LFP1name;
    %pfcName = dataIN{i}.LFP2name;

    % loop across
    for sessi = 1:length(dir_content)

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
        dataIN = load(dataINfolder{1},'dataStored','dataStoredB','detected','detectedB');
        
        % -- FIRST focus on the startbox -- %
        
        % identify detected events as clean or dirty
        detectB_art = find(dataIN.detectedB==1);
        detectB_cle = find(dataIN.detectedB==0);
        
        % compute coherence, then separate clean and dirty
        cohB = []; window = []; noverlap = []; fpass = [1:.5:20]; srate = 2000;
        for j = 1:length(dataIN.dataStoredB)
            temp_data = [];
            temp_data = dataIN.dataStoredB{j};
            % detrend
            data_det = [];
            data_det(1,:) = detrend(temp_data(1,:));
            data_det(2,:) = detrend(temp_data(2,:));
            % coherence
            [cohB{j},fB] = mscohere(data_det(1,:),data_det(2,:),window,noverlap,fpass,srate);
        end
        
        % sep data
        cohB_clean = []; cohB_dirty = [];
        cohB_clean = cohB(detectB_cle);
        cohB_dirty = cohB(detectB_art);
        
        % organize data 
        cohB_clean_mat = []; cohB_dirty_mat = [];
        cohB_clean_mat = vertcat(cohB_clean{:});
        cohB_dirty_mat = vertcat(cohB_dirty{:});
        
        % get averages and stderr
        cohB_clean_avg = []; cohB_dirty_avg = []; cohB_clean_ser = []; cohB_dirty_ser = [];
        cohB_clean_avg = nanmean(cohB_clean_mat);
        cohB_dirty_avg = nanmean(cohB_dirty_mat);
        cohB_clean_ser = stderr(cohB_clean_mat,1);
        cohB_dirty_ser = stderr(cohB_dirty_mat,1);  
        
        %{
        % figure
        figure('color','w'); hold on;
        s1 = shadedErrorBar(fB,cohB_clean_avg,cohB_clean_ser,'b',0);
        s2 = shadedErrorBar(fB,cohB_dirty_avg,cohB_dirty_ser,'r',0);
        legend([s1.mainLine,s2.mainLine],'Accepted LFP','Rejected LFP')
        box off
        ylabel('Coherence')
        xlabel('Frequency')
        title(['Rat ',num2str(rats{i}),' session ',num2str(sessi)])
        cd('X:\01.Experiments\R21\Figures\Method parameters')
        savefig(['Rat',num2str(rats{i}),'_session',num2str(sessi),'_artifReject.fig'])
        %}
        % create a distribution of coherence 
        ftheta     = [6 10];
        idxTheta   = find(fB > 6 & fB < 10);
        distTheta_cleanB = nanmean(cohB_clean_mat(:,idxTheta),2);
        distTheta_dirtyB = nanmean(cohB_dirty_mat(:,idxTheta),2);   
        
        %{
        data       = [];
        data{1}    = distTheta_cleanB;
        data{2}    = distTheta_dirtyB;
        xRange     = [0:.05:1];
        colors{1}  = 'b'; colors{2} = 'r'; 
        dataLabels = [{'Accepted LFP'} {'Rejected LFP'}];
        distType   = 'normal';
        [y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
        title('Bowl')
        ylabel('Cumulative density')
        xlabel('Mean coherence (6-10hz)')
        savefig(['Rat',num2str(rats{i}),'_session',num2str(sessi),'_cleanDirty_B_dist.fig'])        

        %}
        
        % cache data
        cohB_cache{i}.clean_cXf_avg{sessi}  = cohB_clean_avg;
        cohB_cache{i}.clean_cXf_ser{sessi}  = cohB_clean_ser;
        cohB_cache{i}.dirty_cXf_avg{sessi}  = cohB_dirty_avg;
        cohB_cache{i}.dirty_cXf_ser{sessi}  = cohB_dirty_ser;
        cohB_cache{i}.clean_cXf_mat{sessi}  = cohB_clean_mat;
        cohB_cache{i}.dirty_cXf_mat{sessi}  = cohB_dirty_mat;
        cohB_cache{i}.clean_coh_dist{sessi} = distTheta_cleanB;
        cohB_cache{i}.dirty_coh_dist{sessi} = distTheta_dirtyB;
        
        % -- do the same for startbox data -- %
        
        %_____________________________________%
        
        dataSB = horzcat(dataIN.dataStored{:});
        detectedSB = horzcat(dataIN.detected{:});       
        
        % identify detected events as clean or dirty
        detectSB_art = find(detectedSB==1);
        detectSB_cle = find(detectedSB==0);
        
        % compute coherence, then separate clean and dirty
        cohSB = []; window = []; noverlap = []; fpass = [1:.5:20]; srate = 2000;
        for j = 1:length(detectedSB)
            temp_data = [];
            temp_data = dataSB{j};
            % detrend
            data_det = [];
            data_det(1,:) = detrend(temp_data(1,:));
            data_det(2,:) = detrend(temp_data(2,:));
            % coherence
            [cohSB{j},fSB] = mscohere(data_det(1,:),data_det(2,:),window,noverlap,fpass,srate);
        end
        
        % sep data
        cohSB_clean = []; cohSB_dirty = [];
        cohSB_clean = cohSB(detectSB_cle);
        cohSB_dirty = cohSB(detectSB_art);
        
        % organize data 
        cohSB_clean_mat = []; cohSB_dirty_mat = [];
        cohSB_clean_mat = vertcat(cohSB_clean{:});
        cohSB_dirty_mat = vertcat(cohSB_dirty{:});
        
        % get averages and stderr
        cohSB_clean_avg = []; cohSB_dirty_avg = []; cohSB_clean_ser = []; cohSB_dirty_ser = [];
        cohSB_clean_avg = nanmean(cohSB_clean_mat);
        cohSB_dirty_avg = nanmean(cohSB_dirty_mat);
        cohSB_clean_ser = stderr(cohSB_clean_mat,1);
        cohSB_dirty_ser = stderr(cohSB_dirty_mat,1);  
        
        %{
        % figure
        figure('color','w'); hold on;
        s1 = shadedErrorBar(fSB,cohSB_clean_avg,cohSB_clean_ser,'b',0);
        s2 = shadedErrorBar(fSB,cohSB_dirty_avg,cohSB_dirty_ser,'r',0);
        legend([s1.mainLine,s2.mainLine],'Accepted LFP','Rejected LFP')
        box off
        ylabel('Coherence')
        xlabel('Frequency')
        title(['Rat ',num2str(rats{i}),' session ',num2str(sessi)])
        cd('X:\01.Experiments\R21\Figures\Method parameters')
        savefig(['Rat',num2str(rats{i}),'_session',num2str(sessi),'_artifReject_startbox.fig'])

        %}
        
        % create a distribution of coherence 
        distTheta_clean = []; distTheta_dirty = [];
        ftheta     = [6 10];
        idxTheta   = find(fSB > 6 & fB < 10);
        distTheta_clean = nanmean(cohSB_clean_mat(:,idxTheta),2);
        distTheta_dirty = nanmean(cohSB_dirty_mat(:,idxTheta),2);   
        
        %{
        data       = [];
        data{1}    = distTheta_clean;
        data{2}    = distTheta_dirty;
        xRange     = [0:.05:1];
        colors{1}  = 'b'; colors{2} = 'r'; 
        dataLabels = [{'Accepted LFP'} {'Rejected LFP'}];
        distType   = 'normal';
        [y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
        title('Startbox')
        ylabel('Probability density')
        xlabel('Mean coherence (6-10hz)')
        savefig(['Rat',num2str(rats{i}),'_session',num2str(sessi),'_cleanDirty_SB_dist.fig'])        
        
        %}
        
        % cache data
        cohSB_cache{i}.clean_cXf_avg{sessi}  = cohSB_clean_avg;
        cohSB_cache{i}.clean_cXf_ser{sessi}  = cohSB_clean_ser;
        cohSB_cache{i}.dirty_cXf_avg{sessi}  = cohSB_dirty_avg;
        cohSB_cache{i}.dirty_cXf_ser{sessi}  = cohSB_dirty_ser;
        cohSB_cache{i}.clean_cXf_mat{sessi}  = cohSB_clean_mat;
        cohSB_cache{i}.dirty_cXf_mat{sessi}  = cohSB_dirty_mat;
        cohSB_cache{i}.clean_coh_dist{sessi} = distTheta_cleanB;
        cohSB_cache{i}.dirty_coh_dist{sessi} = distTheta_dirtyB;

        % compare startbox
        %{
        data       = [];
        data{1}    = distTheta_clean;
        data{2}    = distTheta_cleanB;
        xRange     = [0:.05:1];
        colors{1}  = 'b'; colors{2} = 'k'; 
        dataLabels = [{'Startbox LFP'} {'Bowl LFP'}];
        distType   = 'normal';
        [y,a] = plotCurves(data,xRange,colors,dataLabels,distType);
        ylabel('Probability density')
        xlabel('Mean coherence (6-10hz)')        
        savefig(['Rat',num2str(rats{i}),'_session',num2str(sessi),'_startboxVbowl_dist.fig'])        

        figure('color','w'); hold on;
        s1 = shadedErrorBar(fSB,cohSB_clean_avg,cohSB_clean_ser,'b',0);
        s2 = shadedErrorBar(fB,cohB_clean_avg,cohB_clean_ser,'k',0);
        legend([s1.mainLine,s2.mainLine],'Startbox LFP','Bowl LFP')
        box off
        ylabel('Coherence')
        xlabel('Frequency')
        title(['Rat ',num2str(rats{i}),' session ',num2str(sessi)])
        cd('X:\01.Experiments\R21\Figures\Method parameters')
        savefig(['Rat',num2str(rats{i}),'_session',num2str(sessi),'_startboxVbowl.fig'])        
        close all;
        %}
    end       

    disp(['Finished with ' rats{i}])
end
