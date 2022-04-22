%%
% one thing that I noticed was depending on how much the rats moved in the
% bowl massively impacts the artifact detection. So, use the baseline
% alternative, which generates baselines using startbox data to be
% consistent with their behaviors

%% to generate thresholds
% 1) run this code
% 2) run identifyingHighAndLowThresholds
% 3) run against testing_artifact_rejection_coherenceMethod in the pipeline

%%
clear;

addpath(getCurrentPath())

% define rat IDs
ratName = '21-33';

% now get data for every session and compute coherence like for 21-13 below
%Datafolders = 'X:\01.Experiments\R21';
  
% get datafolders (session names) into a cell array
Datafolders = ['X:\01.Experiments\R21\',ratName,'\Sessions\DA Habituation\'];
cd(Datafolders);
dir_content = [];
dir_content = dir(Datafolders);
dir_content = extractfield(dir_content,'name');
remIdx = contains(dir_content,'.mat') | contains(dir_content,'.');
dir_content(remIdx)=[];
rem2 = contains(dir_content,'DA');
dir_content(rem2)=[];

% define LFP names
%hpcName = dataIN.LFP1name;
%pfcName = dataIN.LFP2name;

% starbtox data - this was generated using baselineDetect2
folder2load = ['X:\01.Experiments\R21\',ratName,'\baseline alternative'];
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
    idxKeep = find(contains(dataINfolder,ratName)==1);
    dataINfolder = dataINfolder(idxKeep);

    if length(dataINfolder) > 1
        error('Make sure there is only one .mat file name with your rat')
    end

    try
        dataIN = [];
        dataIN = load(dataINfolder{1},'dataStored');
    catch
        continue
    end

    % remove the last trial as it leads nowhere
    try
        dataIN.dataStored(end)=[];
    catch
        continue
    end
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
    title(['Rat ',num2str(ratName),' session ',num2str(sessi)])
    cd('X:\01.Experiments\R21\Figures\Method parameters')
    savefig(['Rat',num2str(ratName),'_session',num2str(sessi),'_artifReject_startbox.fig'])

    %}

    % create a distribution of coherence 
    distTheta_clean = []; distTheta_dirty = [];
    ftheta     = [6 11];
    idxTheta   = find(fSB > 6 & fSB < 11);
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
    savefig(['Rat',num2str(ratName),'_session',num2str(sessi),'_cleanDirty_SB_dist.fig'])        

    %}

    % cache data
    cohSB_cache.clean_cXf_avg{sessi}  = cohSB_clean_avg;
    cohSB_cache.clean_cXf_ser{sessi}  = cohSB_clean_ser;
    cohSB_cache.dirty_cXf_avg{sessi}  = cohSB_dirty_avg;
    cohSB_cache.dirty_cXf_ser{sessi}  = cohSB_dirty_ser;
    cohSB_cache.clean_cXf_mat{sessi}  = cohSB_clean_mat;
    cohSB_cache.dirty_cXf_mat{sessi}  = cohSB_dirty_mat;
    cohSB_cache.clean_coh_dist{sessi} = distTheta_clean;
    cohSB_cache.dirty_coh_dist{sessi} = distTheta_dirty;

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
    savefig(['Rat',num2str(ratName),'_session',num2str(sessi),'_startboxVbowl_dist.fig'])        

    figure('color','w'); hold on;
    s1 = shadedErrorBar(fSB,cohSB_clean_avg,cohSB_clean_ser,'b',0);
    s2 = shadedErrorBar(fB,cohB_clean_avg,cohB_clean_ser,'k',0);
    legend([s1.mainLine,s2.mainLine],'Startbox LFP','Bowl LFP')
    box off
    ylabel('Coherence')
    xlabel('Frequency')
    title(['Rat ',num2str(ratName),' session ',num2str(sessi)])
    cd('X:\01.Experiments\R21\Figures\Method parameters')
    savefig(['Rat',num2str(ratName),'_session',num2str(sessi),'_startboxVbowl.fig'])        
    close all;
    %}
    disp(['Finished with ' ratName,' session ', num2str(sessi)])
end       

f = fSB;
cd(['X:\01.Experiments\R21\',ratName])
mkdir(['X:\01.Experiments\R21\' ratName,'\ThetaFreqDist'])

prompt = 'Are you ready to save? (y/n) - DO NOT SAVE OVER OLD DATA!';
answer = input(prompt,'s');
if contains(answer,[{'y'} {'Y'}])==1
    save('data_defineFrequencies','cohSB_cache','f','ratName')
else
end

%{
%% goals:
% 1) generate coherence frequency plot with rats as the sample size
% 2) create distribution of 


%% loop across rats
clearvars -except cohSB_cache cohB_cache rats f
for i = 1:length(cohSB_cache)
    cohSB_cache.clean_cXf_mat_all = vertcat(cohSB_cache.clean_cXf_mat{:});
    cohB_cache.clean_cXf_mat_all = vertcat(cohB_cache.clean_cXf_mat{:});
end

ftheta     = [6 10];
idxTheta   = find(f > 6 & f < 10);

for i = 1:length(cohSB_cache)
    % first generate distributions
    cohOUT.SB_cXf_avg   = nanmean(cohSB_cache.clean_cXf_mat_all,1);
    cohOUT.SB_cXf_ser   = stderr(cohSB_cache.clean_cXf_mat_all,1);
    %cohOUT.SB_cXf_theta =  cohSB_cache.clean_cXf_mat_all(:,idxTheta);
    cohOUT.B_cXf_avg   = nanmean(cohB_cache.clean_cXf_mat_all,1);
    cohOUT.B_cXf_ser   = stderr(cohB_cache.clean_cXf_mat_all,1);
end

figure('color','w')
for i = 1:length(cohSB_cache)
    subplot(1,length(rats),i);
    hold on;
    s1 = shadedErrorBar(f,cohOUT.SB_cXf_avg,cohOUT.SB_cXf_ser,'b',0);
    s2 = shadedErrorBar(f,cohOUT.B_cXf_avg,cohOUT.B_cXf_ser,'k',0);
    legend([s1.mainLine, s2.mainLine],'Delay','Bowl')
    ylabel('Coherence')
    xlabel('Frequency')
    box off;
    ylim([0 1])
    title(ratName)
end
%} 
    

