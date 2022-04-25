clear;

% define rat IDs
rats{1} = '21-12';
rats{2} = '21-13';
rats{3} = '21-14';
%rats{4} = '21-15';
rats{4} = '21-16';
rats{5} = '21-21';
rats{7} = '21-22';

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
    folder2load = ['X:\01.Experiments\R21\',rats{i},'\baseline'];
    cd(folder2load);
    load('baselineData')
    %baselineSTD = baselineStd;
    
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
        dataIN = [];
        dataIN = load(dataINfolder{1},'dataStored','dataStoredB');
        
        
        % -- FIRST focus on the startbox -- %
        
        % compute coherence, then separate clean and dirty
        noiseThreshold = []; noisePercent = [];
        cohB = []; window = []; noverlap = []; 
        %baselineMean = []; baselineSTD = [];
        
        % define some parameters
        fpass = [1:.5:20]; srate = 2000;
        %noiseThreshold = dataIN.noiseThreshold;
        %baselineMean   = dataIN.baselineMean;
        %baselineSTD    = dataIN.baselineSTD;
        
        noiseThreshold(1) = 4;
        noiseThreshold(2) = 4;
        noisePercent      = 1;
        
        try 
            checker = dataIN.dataStoredB;
        catch
            checker = [];
        end
        if isempty(checker)==0
            detectedB = [];
            for j = 1:length(dataIN.dataStoredB)
                temp_data = [];
                temp_data = dataIN.dataStoredB{j};

                % detrend
                data_det = [];
                %data_det(1,:) = polyDetrend(temp_data(1,:)');
                %data_det(2,:) = polyDetrend(temp_data(2,:)');
                data_det(1,:) = detrend(temp_data(1,:),3);
                data_det(2,:) = detrend(temp_data(2,:),3);

                % determine if data is noisy
                zArtifact = [];
                zArtifact(1,:) = ((data_det(1,:)-baselineMean(1))./baselineSTD(1));
                zArtifact(2,:) = ((data_det(2,:)-baselineMean(2))./baselineSTD(2));              

                idxNoise = find(zArtifact(1,:) > noiseThreshold(1) | zArtifact(1,:) < -1*noiseThreshold(1) | zArtifact(2,:) > noiseThreshold(2) | zArtifact(2,:) < -1*noiseThreshold(2) );
                percSat = (length(idxNoise)/length(zArtifact))*100;

                % theta delta ratio
                td = []; 
                %[detrended_signal] = polyDetrend(Sample)
                %td = tdRatio(data_det(1,:),srate);

                if percSat > noisePercent %|| td < 2
                    detectedB(j)=1;
                else
                    detectedB(j)=0;
                end  

                %{
                figure('color','w')
                subplot 211
                plot(zArtifact(1,:),'b')
                subplot 212;
                plot(zArtifact(2,:),'r')
                title(['Noise = ',num2str(percSat),'%, TD = ',num2str(td)])            
                pause;
                close;
                %}
                % coherence
                [cohB{j},fB] = mscohere(data_det(1,:),data_det(2,:),window,noverlap,fpass,srate);
            end

            % identify detected events as clean or dirty
            detectB_art = []; detectB_cle = [];
            detectB_art = find(detectedB==1);
            detectB_cle = find(detectedB==0);

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
            try
                distTheta_cleanB = nanmean(cohB_clean_mat(:,idxTheta),2);
            catch
                distTheta_cleanB = [];
            end
            try
                distTheta_dirtyB = nanmean(cohB_dirty_mat(:,idxTheta),2);   
            catch
                distTheta_dirtyB = [];
            end
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
        end
        
        % -- do the same for startbox data -- %
        
        %_____________________________________%
        
        dataSB = horzcat(dataIN.dataStored{:});
        %detectedSB = horzcat(dataIN.detected{:});       
        
        % compute coherence, then separate clean and dirty
        cohSB = []; window = []; noverlap = []; fpass = [1:.5:20]; srate = 2000;
        detectedSB = [];
        for j = 1:length(dataSB)
            temp_data = [];
            temp_data = dataSB{j};
            
            % detrend
            data_det = [];
            %data_det(1,:) = polyDetrend(temp_data(1,:)');
            %data_det(2,:) = polyDetrend(temp_data(2,:)');
            data_det(1,:) = detrend(temp_data(1,:),3);
            data_det(2,:) = detrend(temp_data(2,:),3);

            % determine if data is noisy
            zArtifact = [];
            zArtifact(1,:) = ((data_det(1,:)-baselineMean(1))./baselineSTD(1));
            zArtifact(2,:) = ((data_det(2,:)-baselineMean(2))./baselineSTD(2));              
            
            idxNoise = find(zArtifact(1,:) > noiseThreshold(1) | zArtifact(1,:) < -1*noiseThreshold(1) | zArtifact(2,:) > noiseThreshold(2) | zArtifact(2,:) < -1*noiseThreshold(2) );
            percSat = (length(idxNoise)/length(zArtifact))*100;
            %{
            if percSat > noisePercent
                detectedSB(j)=1;
            else
                detectedSB(j)=0;
            end
            %}
            % theta delta ratio
            %td = []; 
            %[detrended_signal] = polyDetrend(Sample)
            %td = tdRatio(data_det(1,:),srate);
   
            if percSat > noisePercent% || td < 2
                detectedSB(j)=1;
            else
                detectedSB(j)=0;
            end              
            
            % coherence
            [cohSB{j},fSB] = mscohere(data_det(1,:),data_det(2,:),window,noverlap,fpass,srate);
        end
        
        % identify detected events as clean or dirty
        detectB_art = []; detectB_cle = [];        
        detectSB_art = find(detectedSB==1);
        detectSB_cle = find(detectedSB==0);
        
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
        try
            distTheta_clean = nanmean(cohSB_clean_mat(:,idxTheta),2);
        catch
            distTheta_clean = [];
        end
        try
            distTheta_dirty = nanmean(cohSB_dirty_mat(:,idxTheta),2);   
        catch
            distTheta_dirty = [];
        end  
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
        randData = [];
        minSize = min([length(distTheta_clean) length(distTheta_cleanB)]);
        randData{1}   = randsample(distTheta_clean,minSize);
        randData{2}   = randsample(distTheta_cleanB,minSize);        
        data       = [];
        data = randData;
        %data{1}    = distTheta_clean;
        %data{2}    = distTheta_cleanB;
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
        disp(['Finished with ' rats{i},' session ', num2str(sessi)])
    end       

    disp(['Finished with ' rats{i}])
end
f = fSB;
cd('X:\01.Experiments\R21\Figures\Method parameters')
save('data_cohBowl_cohDelay','cohSB_cache','cohB_cache','rats','f')

%% loop across rats
clearvars -except cohSB_cache cohB_cache rats f
for i = 1:length(cohSB_cache)
    cohSB_cache{i}.clean_cXf_mat_all = vertcat(cohSB_cache{i}.clean_cXf_mat{:});
    cohB_cache{i}.clean_cXf_mat_all = vertcat(cohB_cache{i}.clean_cXf_mat{:});
end

ftheta     = [6 10];
idxTheta   = find(f > 6 & f < 10);

for i = 1:length(cohSB_cache)
    % first generate distributions
    cohOUT{i}.SB_cXf_avg   = nanmean(cohSB_cache{i}.clean_cXf_mat_all,1);
    cohOUT{i}.SB_cXf_ser   = stderr(cohSB_cache{i}.clean_cXf_mat_all,1);
    %cohOUT{i}.SB_cXf_theta =  cohSB_cache{i}.clean_cXf_mat_all(:,idxTheta);
    cohOUT{i}.B_cXf_avg   = nanmean(cohB_cache{i}.clean_cXf_mat_all,1);
    cohOUT{i}.B_cXf_ser   = stderr(cohB_cache{i}.clean_cXf_mat_all,1);
end

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on;
    s1 = shadedErrorBar(f,cohOUT{i}.SB_cXf_avg,cohOUT{i}.SB_cXf_ser,'b',0);
    s2 = shadedErrorBar(f,cohOUT{i}.B_cXf_avg,cohOUT{i}.B_cXf_ser,'k',0);
    legend([s1.mainLine, s2.mainLine],'Delay','Bowl')
    ylabel('Coherence')
    xlabel('Frequency')
    box off;
    ylim([0 1])
    title(rats{i})
end
    
    

