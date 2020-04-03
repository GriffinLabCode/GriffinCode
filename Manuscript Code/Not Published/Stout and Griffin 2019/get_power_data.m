%% This script calculates power during the interval of interest
% note that to change this interval, you will need to manually go into the
% function 'power_fun.m' to change
% Future updates will target changing this from the inputs function
%
% Int_lfp is only corrected for stem entry-tjunction exit in col9. col10 is
% taskphase 0 sample 1 choice
%
% This script controls for:
% 1) behavior by including only correct trials
% 2) poor lfp - all sessions included from stem entry to t-junction were
%       visually inspected for clipping artifacts
% 3) number of sample and choice trials by subsampling
% 4) trajectory - differing numbers of sampleL sampleR choiceL and 
%       choiceR; there is the same amount of each trial-type
%
% written by John Stout
clear; clc

correct_trajectory = 0;

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');

[input]=get_power_inputs();

% flip over all folders    
    if input.Prelimbic == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic';
    elseif input.OFC ==1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Orbital Frontal';    
    elseif input.AnteriorCingulate == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Anterior Cingulate';
    elseif input.mPFC_good == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';
    elseif input.mPFC_poor == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Poor Performance\Medial Prefrontal Cortex'; 
    elseif input.VentralOrbital == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Ventral Orbital';
    elseif input.MedialOrbital == 1;
        Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Orbital';
    else
        disp('Warning - Error in loading Datafolders')
    end
    
    cd(Datafolders);
    folder_names = dir;    
    
% loop across folders
for nn = 3:length(folder_names)
    
    Datafolders = Datafolders;
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
    datafolder = pwd;
    cd(datafolder); 

    %% only analyze sessions with Re, hpc, and prl recordings
    if input.simultaneous == 1 && input.Tentry_longepoch;
        Files.pfc=dir(fullfile(datafolder,'mPFC.mat'));
        Files.re=dir(fullfile(datafolder,'Re.mat'));
        Files.hpc=dir(fullfile(datafolder,'HPC.mat'));
        if input.Tentry_longepoch == 1
            Files.int=dir(fullfile(datafolder,'Int_lfp_StemT_Col10.mat'));
        elseif input.Tjunction == 1
            Files.int=dir(fullfile(datafolder,'Int_lfp_T.mat'));
        end
        fn = fieldnames(Files);
        for fieldi = 1:length(fn)
            if size(Files.(fn{fieldi}),1) == 0
                store_size(fieldi) = 0;
            elseif size(Files.(fn{fieldi}),1) == 1
                store_size(fieldi) = 1;                    
            end
        end
    
    % if any of the data is missing, skip to the next loop
    if isempty(find(store_size == 0)) == 0 % this means one of the store_size values are zero. in other words, this session does not have simultaneous recordings
        sessionslog{nn-2} = 'skipped';
        continue
    else
        sessionslog{nn-2} = 'included';
    end
    end
    
    %% get int and format it
    if input.Tjunction == 1
        if input.pow_pfc == 1
            try
                load (strcat(datafolder,'\Int_lfp_T.mat')); 
                % display
                C = [];
                C = strsplit(datafolder,'\');
                X = [];
                X = ['successfully loaded Int_lfp_T.mat from ', C{end}];
                disp(X);               
            catch
                % display
                C = [];
                C = strsplit(datafolder,'\');
                X = [];
                X = [C{end}, ' had no Int_lfp_T.mat file'];
                disp(X);              
                continue
            end 
        elseif input.pow_hpc == 1 || input.pow_re == 1
            try
                load (strcat(datafolder,'\Int_HPCRE_T.mat')); 
                % display
                C = [];
                C = strsplit(datafolder,'\');
                X = [];
                X = ['successfully loaded Int_HPCRE_T.mat from ', C{end}];
                disp(X);               
            catch
                % display
                C = [];
                C = strsplit(datafolder,'\');
                X = [];
                X = [C{end}, ' had no Int_HPCRE_T.mat file'];
                disp(X);              
                continue
            end 
        end
    elseif input.Tentry_longepoch == 1;
        if input.pow_pfc == 1 || input.simultaneous == 1
            try
                load (strcat(datafolder,'\Int_lfp_StemT_Col10.mat')); 
                % display
                C = [];
                C = strsplit(datafolder,'\');
                X = [];
                X = ['successfully loaded Int_lfp_StemT_Col10.mat from ', C{end}];
                disp(X);               
            catch
                % display
                C = [];
                C = strsplit(datafolder,'\');
                X = [];
                X = [C{end}, ' had no Int_lfp_StemT_Col10.mat file'];
                disp(X);              
                continue
            end
        elseif (input.pow_re == 1 || input.pow_hpc == 1) && input.simultaneous == 0
            try
                load (strcat(datafolder,'\Int_HPCRE_StemTCol10.mat')); 
                % display
                C = [];
                C = strsplit(datafolder,'\');
                X = [];
                X = ['successfully loaded Int_HPCRE_StemTCol10.mat from ', C{end}];
                disp(X);               
            catch
                if input.pow_hpc == 1
                    try
                        load (strcat(datafolder,'\Int_lfp_StemT_Col10.mat')); 
                        % display
                        C = [];
                        C = strsplit(datafolder,'\');
                        X = [];
                        X = ['successfully loaded Int_lfp_StemT_Col10.mat from ', C{end}];
                        disp(X);               
                    catch
                        % display
                        C = [];
                        C = strsplit(datafolder,'\');
                        X = [];
                        X = [C{end}, ' had no Int_lfp_StemT_Col10.mat file'];
                        disp(X);              
                        continue
                    end
                end
                % display
                C = [];
                C = strsplit(datafolder,'\');
                X = [];
                X = [C{end}, ' had no Int_HPCRE_StemTCol10.mat file'];
                disp(X);              
            end            
        end
    else
        try
            load (strcat(datafolder,'\Int_lfp.mat')); 
            % display
            C = [];
            C = strsplit(datafolder,'\');
            X = [];
            X = ['successfully loaded Int_lfp.mat from ', C{end}];
            disp(X);               
        catch
            % display
            C = [];
            C = strsplit(datafolder,'\');
            X = [];
            X = [C{end}, ' had no Int_lfp.mat file'];
            disp(X);              
            continue
        end
    end

    cd(Datafolders);
    folder_names = dir;
    cd(datafolder);

    % get correct trials  
    Int(find(Int(:,4)==1),:)=[];
    
    % remove clipped trials
    Int(Int(:,9)==1,:)=[];
    
    % control for differing number of sample and choice trials by
    % removing the entire trial. 
    Int_og = Int;
    Int = [];
    Int = correct_taskphase_counts_nonsubsample(Int_og); 
    
    % end script if either a choice trial is first or sample is last. This
    % would mess up odd even distinction of sample and choice trials
    if Int(1,10) == 1 || Int(end,10) == 0
        disp('Int file not formatted correctly')
        return
    end
    
    % control for differing number of left and right trials during sample
    % and choice. But also make sure theres an equal number of different
    % trial-type combinations (sampleL sampleR choiceL choiceR)
    if correct_trajectory == 1
        [Int_corrected,corrected_trials,num_orig{nn-2},num_types{nn-2},...
            turn_nam{nn-2}]=correct_trajectory_differences(Int);
        Int_og2 = Int;
        Int = [];
        Int = Int_corrected;
    else
        Int = Int;
    end
   
    % split into sample and choice trials
    Int_sample = Int(1:2:size(Int,1),:);
    Int_choice = Int(2:2:size(Int,1),:);
   
    % check that Int file is formatted correctly again
    if isempty(find(Int_sample(:,10)==1))==0 || isempty(find(Int_choice(:,10)==0))==0
        disp('Int file not formatted correctly')
        return
    end   
    
    % set parameters
    params.fpass           = input.phase_bandpass; 
    params.tapers           = [2 3];    %[2 3]
    params.trialave         = 1;
    params.err              = [2 .05];
    params.pad              = 0;
    %params.fpass            = [0 100]; % [1 100]
    params.movingwin        = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper

    % get power
    try
     [power_sample{nn-2},frex_sample{nn-2}] = power_fun(datafolder,input,Int_sample,params);
     [power_choice{nn-2},frex_choice{nn-2}] = power_fun(datafolder,input,Int_choice,params); 
    catch
        continue
    end
    
    clearvars -except power_sample power_choice power_mean_sample power_mean_choice ...
        frex_sample frex_choice nn folder_names Datafolders input correct_trajectory ...
        sessionslog

    X = ['finished with session ',num2str(nn-2)];
    disp(X)    

end

%{

if input.specgram == 1
    % remove empty variables
    power_sample = power_sample(~cellfun('isempty',power_sample));
    power_choice = power_choice(~cellfun('isempty',power_choice)); 
    
    % create an index for extracting frequencies
    freqs = frex_sample{1};
    time  = linspace(-0.5,0.5,size(power_sample{1},1));
    
    % reformat data
    pow_choice_3d=cat(3, power_choice{:});
    pow_sample_3d=cat(3, power_sample{:});
    
    % average
    pow_choice_mean = mean(pow_choice_3d,3);
    pow_sample_mean = mean(pow_sample_3d,3);

    figure('color',[1 1 1])
        pcolor(time,freqs,log10(pow_choice_mean)');
        set(gca,'fontsize', 13);
        colormap(jet)
        colorbar   
        %caxis([0.0548 0.0563])    
        shading 'interp'
        ylabel('frequency')
        xlabel('time')  

    figure('color',[1 1 1])
        pcolor(time,freqs,log10(pow_sample_mean)');
        set(gca,'fontsize', 13);
        colormap(jet)
        colorbar   
        %caxis([0.0548 0.0563])    
        shading 'interp'
        ylabel('frequency')
        xlabel('time')  
        
    % make index of theta
    theta_freqs = find(freqs>4 & freqs<12);
    
    % index out sample and choice means
    theta_power_sample = pow_sample_mean(:,theta_freqs);
    theta_power_choice = pow_choice_mean(:,theta_freqs);
    
    % means
    theta_mean.sample = mean(theta_power_sample,2);
    theta_mean.choice = mean(theta_power_choice,2);
    theta_GrandMean = mean([theta_mean.sample theta_mean.choice],2);
    
    figure();
    plot(time,log10(theta_GrandMean))

    figure();
    plot(time,log10(theta_mean.sample),'b'); hold on;
    plot(time,log10(theta_mean.choice),'r');
    
    % correct size differences
    % if you look at the frex_* variables and some are different sizes, you'll
    % notice that every other value is the same. So extract every other value

    % get lengths of the sample and choice data
    sam_lens = cellfun(@length,power_sample(~cellfun('isempty',power_sample)));
    cho_lens = cellfun(@length,power_choice(~cellfun('isempty',power_choice)));

    % if you examined a controlled time epoch, the two variables above will
    % cancel out. If you did not, they shouldn't cancel out
    diff_lens = cho_lens-sam_lens;
    notempty = find(diff_lens~=0);
    
if isempty('notempty') == 1

    % find sizes of all variables
    for i = 1:length(frex_choice)
        len_frex{i} = size(frex_choice{i},2);
    end

    % find max value of len_frex
    max_frex_length = max(cell2mat(len_frex));

    % find cells that don't match the max_frex_length
    not_maxFrexLen = find(cell2mat(len_frex)~=max_frex_length & cell2mat(len_frex)>0);

    % find min value of len_frex
    min_frex_length = len_frex{not_maxFrexLen(1)};

    % get maxFrex
    maxFrexLen = find(cell2mat(len_frex)==max_frex_length);

    % define the large and small sized variables as being representatives from
    % the dataset
    var_small = frex_choice{not_maxFrexLen(1)};
    var_large = frex_choice{maxFrexLen(1)};

    % create an index that gets all values in the large variable from the small
    % variable - this will be used to make the variables the same size
    idx_new_frex = dsearchn(var_large',var_small');
    frex_new = var_small;

    % save old variables
    power_choice_og = power_choice;
    power_sample_og = power_sample;

    % remove empty variables
    power_sample = power_sample(~cellfun('isempty',power_sample));
    power_choice = power_choice(~cellfun('isempty',power_choice));

    % loop across data and downsample
    for i = 1:length(power_sample)
        if size(power_choice{i},1) ~= min_frex_length
            power_choice_new{i} = power_choice{i}(idx_new_frex);
        else
            power_choice_new{i} = power_choice{i};
        end

        if size(power_sample{i},1) ~= min_frex_length
            power_sample_new{i} = power_sample{i}(idx_new_frex);
        else
            power_sample_new{i} = power_sample{i};
        end    
    end

    % get all data into a matrix - this matrix will be (session,power value)
    power_sample_matrix = (horzcat(power_sample_new{:}))';
    power_choice_matrix = (horzcat(power_choice_new{:}))';

    power_sample_matrix = log10(power_sample_matrix);
    power_choice_matrix = log10(power_choice_matrix);

    % get average and sem
    power_avg_sample = mean(power_sample_matrix);
    power_avg_choice = mean(power_choice_matrix);

    power_sem_sample = (std(power_sample_matrix))/(sqrt(size(power_sample_matrix,1)));
    power_sem_choice = (std(power_choice_matrix))/(sqrt(size(power_choice_matrix,1)));

    % plot
    x_label = frex_new;

    figure('color',[1 1 1])
        shadedErrorBar(x_label,power_avg_sample,power_sem_sample,'-r',1);
        hold on;
        shadedErrorBar(x_label,power_avg_choice,power_sem_choice,'-b',1);
        %set(gca, 'XTick',[1,2,3,4,5,6,7])
        %set(gca, 'xticklabel',{'stem','stem','stem','stem','stem','t-junction'})
        %ax = gca;
        %ax.XTickLabelRotation = 45;    
        box off
        ylabel('Power (log10)')
        xlabel('Frequency')
        axis tight
        hold on;
        xlim=get(gca,'xlim');
        hold on
        set(gca,'FontSize',14)
else

    % find smallest of the two sam_lens and cho_lens
    lens_taskphase = horzcat(sam_lens,cho_lens);
    smallest_size_fx = min(lens_taskphase);
    
    % find the frequency cell that is smallest, this will be used as an
    % index reference for dsearchn
    min_lens = find(lens_taskphase == smallest_size_fx);
    % we only need one - in fact, it's hard to use more than one and not
    % necessary since the frequencies will be identical
    min_lens = min_lens(1);
    
    % times that add up to the smallest sized time
    power_sample_og = power_sample;
    power_choice_og = power_choice;
    power_sample = power_sample(~cellfun('isempty',power_sample));
    power_choice = power_choice(~cellfun('isempty',power_choice));
    
    % find whether the smallest sized frequency length was in the the
    % sample or choice phase index of frequency lengths. It changes where
    % you draw the frequencies from
    if isempty(find(sam_lens == smallest_size_fx))==0;
        for i = 1:length(power_sample)
            idx_sam{i} = dsearchn(power_sample{i}',power_sample_og{min_lens}');
            idx_cho{i} = dsearchn(power_choice{i}',power_choice_og{min_lens}');
        end
    else
        for i = 1:length(frex_sample)
            idx_sam{i} = dsearchn(frex_sample{i}',frex_choice_og{min_lens}');
            idx_cho{i} = dsearchn(frex_choice{i}',frex_choice_og{min_lens}');
        end
    end
    % save old variables
    power_choice_og = power_choice;
    power_sample_og = power_sample;

    % remove empty variables
    power_sample = power_sample(~cellfun('isempty',power_sample));
    power_choice = power_choice(~cellfun('isempty',power_choice));

    % loop across data and downsample
    for i = 1:length(power_sample)
        if size(power_choice{i},1) ~= smallest_size_fx
            power_choice_new{i} = power_choice{i}(idx_cho{i});
        else
            power_choice_new{i} = power_choice{i};
        end

        if size(power_sample{i},1) ~= smallest_size_fx
            power_sample_new{i} = power_sample{i}(idx_sam{i});
        else
            power_sample_new{i} = power_sample{i};
        end    
    end

    % get all data into a matrix - this matrix will be (session,power value)
    power_sample_matrix = (horzcat(power_sample_new{:}))';
    power_choice_matrix = (horzcat(power_choice_new{:}))';

    power_sample_matrix = log10(power_sample_matrix);
    power_choice_matrix = log10(power_choice_matrix);

    % get average and sem
    power_avg_sample = mean(power_sample_matrix);
    power_avg_choice = mean(power_choice_matrix);

    power_sem_sample = (std(power_sample_matrix))/(sqrt(size(power_sample_matrix,1)));
    power_sem_choice = (std(power_choice_matrix))/(sqrt(size(power_choice_matrix,1)));

    % plot
    if isempty(find(sam_lens == smallest_size_fx))==0;
        x_label = frex_sample_og{min_lens};
        new_frex = x_label;
    else
        x_label = frex_choice_og{min_lens};
        new_frex = x_label;
    end    
    
    figure('color',[1 1 1])
        shadedErrorBar(x_label,power_avg_sample,power_sem_sample,'-r',1);
        hold on;
        shadedErrorBar(x_label,power_avg_choice,power_sem_choice,'-b',1);
        %set(gca, 'XTick',[1,2,3,4,5,6,7])
        %set(gca, 'xticklabel',{'stem','stem','stem','stem','stem','t-junction'})
        %ax = gca;
        %ax.XTickLabelRotation = 45;    
        box off
        ylabel('Power (log10)')
        xlabel('Frequency')
        axis tight
        hold on;
        xlim=get(gca,'xlim');
        hold on
        set(gca,'FontSize',14)    
    
end
    
    
    
end

%}

if input.freqplot == 1
%% correct size differences
% if you look at the frex_* variables and some are different sizes, you'll
% notice that every other value is the same. So extract every other value

% get lengths of the sample and choice data
sam_lens = cellfun(@length,power_sample(~cellfun('isempty',power_sample)));
cho_lens = cellfun(@length,power_choice(~cellfun('isempty',power_choice)));

% if you examined a controlled time epoch, the two variables above will
% cancel out. If you did not, they shouldn't cancel out
diff_lens = cho_lens-sam_lens;
notempty = find(diff_lens~=0);

if isempty('notempty') == 1

    % find sizes of all variables
    for i = 1:length(frex_choice)
        len_frex{i} = size(frex_choice{i},2);
    end

    % find max value of len_frex
    max_frex_length = max(cell2mat(len_frex));

    % find cells that don't match the max_frex_length
    not_maxFrexLen = find(cell2mat(len_frex)~=max_frex_length & cell2mat(len_frex)>0);

    % find min value of len_frex
    min_frex_length = len_frex{not_maxFrexLen(1)};

    % get maxFrex
    maxFrexLen = find(cell2mat(len_frex)==max_frex_length);

    % define the large and small sized variables as being representatives from
    % the dataset
    var_small = frex_choice{not_maxFrexLen(1)};
    var_large = frex_choice{maxFrexLen(1)};

    % create an index that gets all values in the large variable from the small
    % variable - this will be used to make the variables the same size
    idx_new_frex = dsearchn(var_large',var_small');
    frex_new = var_small;

    % save old variables
    power_choice_og = power_choice;
    power_sample_og = power_sample;

    % remove empty variables
    power_sample = power_sample(~cellfun('isempty',power_sample));
    power_choice = power_choice(~cellfun('isempty',power_choice));

    % loop across data and downsample
    for i = 1:length(power_sample)
        if size(power_choice{i},1) ~= min_frex_length
            power_choice_new{i} = power_choice{i}(idx_new_frex);
        else
            power_choice_new{i} = power_choice{i};
        end

        if size(power_sample{i},1) ~= min_frex_length
            power_sample_new{i} = power_sample{i}(idx_new_frex);
        else
            power_sample_new{i} = power_sample{i};
        end    
    end

    % get all data into a matrix - this matrix will be (session,power value)
    power_sample_matrix = (horzcat(power_sample_new{:}))';
    power_choice_matrix = (horzcat(power_choice_new{:}))';

    power_sample_matrix = log10(power_sample_matrix);
    power_choice_matrix = log10(power_choice_matrix);

    % get average and sem
    power_avg_sample = mean(power_sample_matrix);
    power_avg_choice = mean(power_choice_matrix);

    power_sem_sample = (std(power_sample_matrix))/(sqrt(size(power_sample_matrix,1)));
    power_sem_choice = (std(power_choice_matrix))/(sqrt(size(power_choice_matrix,1)));

    % plot
    x_label = frex_new;

    figure('color',[1 1 1])
        shadedErrorBar(x_label,power_avg_sample,power_sem_sample,'-r',0);
        hold on;
        shadedErrorBar(x_label,power_avg_choice,power_sem_choice,'-b',0);
        %set(gca, 'XTick',[1,2,3,4,5,6,7])
        %set(gca, 'xticklabel',{'stem','stem','stem','stem','stem','t-junction'})
        %ax = gca;
        %ax.XTickLabelRotation = 45;    
        box off
        ylabel('Power (log10)')
        xlabel('Frequency')
        axis tight
        hold on;
        xlim=get(gca,'xlim');
        hold on
        set(gca,'FontSize',14)
else

    % find smallest of the two sam_lens and cho_lens
    lens_taskphase = horzcat(sam_lens,cho_lens);
    smallest_size_fx = min(lens_taskphase);
    
    % find the frequency cell that is smallest, this will be used as an
    % index reference for dsearchn
    min_lens = find(lens_taskphase == smallest_size_fx);
    % we only need one - in fact, it's hard to use more than one and not
    % necessary since the frequencies will be identical
    min_lens = min_lens(1);
    
    % frequencies that add up to the smallest sized frequency
    frex_sample = frex_sample(~cellfun('isempty',frex_sample));
    frex_choice = frex_choice(~cellfun('isempty',frex_choice));
    
    % find whether the smallest sized frequency length was in the the
    % sample or choice phase index of frequency lengths. It changes where
    % you draw the frequencies from
    % draw from sample since the min_lens(1) will inherently be sample
    % phase
    if isempty(find(sam_lens == smallest_size_fx))==0;
        for i = 1:length(frex_sample)
            idx_sam{i} = dsearchn(frex_sample{i}',frex_sample{min_lens}');
            idx_cho{i} = dsearchn(frex_choice{i}',frex_sample{min_lens}');
        end
    else
        for i = 1:length(frex_sample)
            idx_sam{i} = dsearchn(frex_sample{i}',frex_sample{min_lens}');
            idx_cho{i} = dsearchn(frex_choice{i}',frex_sample{min_lens}');
        end
    end
    % remove empty variables
    power_sample = power_sample(~cellfun('isempty',power_sample));
    power_choice = power_choice(~cellfun('isempty',power_choice));

    % loop across data and downsample
    for i = 1:length(power_sample)
        if size(power_choice{i},1) ~= smallest_size_fx
            power_choice_new{i} = power_choice{i}(idx_cho{i});
        else
            power_choice_new{i} = power_choice{i};
        end

        if size(power_sample{i},1) ~= smallest_size_fx
            power_sample_new{i} = power_sample{i}(idx_sam{i});
        else
            power_sample_new{i} = power_sample{i};
        end    
    end

    % get all data into a matrix - this matrix will be (session,power value)
    power_sample_matrix = (horzcat(power_sample_new{:}))';
    power_choice_matrix = (horzcat(power_choice_new{:}))';

    power_sample_matrix = log10(power_sample_matrix);
    power_choice_matrix = log10(power_choice_matrix);

    % get average and sem
    power_avg_sample = mean(power_sample_matrix);
    power_avg_choice = mean(power_choice_matrix);

    power_sem_sample = (std(power_sample_matrix))/(sqrt(size(power_sample_matrix,1)));
    power_sem_choice = (std(power_choice_matrix))/(sqrt(size(power_choice_matrix,1)));

    % plot
    x_label = frex_sample{min_lens};
    new_frex = x_label;
  
    figure('color',[1 1 1])
        shadedErrorBar(x_label,power_avg_sample,power_sem_sample,'-r',1);
        hold on;
        shadedErrorBar(x_label,power_avg_choice,power_sem_choice,'-b',1);
        %set(gca, 'XTick',[1,2,3,4,5,6,7])
        %set(gca, 'xticklabel',{'stem','stem','stem','stem','stem','t-junction'})
        %ax = gca;
        %ax.XTickLabelRotation = 45;    
        box off
        ylabel('Power (log10)')
        xlabel('Frequency')
        axis tight
        hold on;
        xlim=get(gca,'xlim');
        hold on
        set(gca,'FontSize',14)    
    
end

%% difference score
power_delta.sample = mean(power_sample_matrix(:,find(new_frex>1 & new_frex<4)),2);
power_delta.choice = mean(power_choice_matrix(:,find(new_frex>1 & new_frex<4)),2);
power_theta.sample = mean(power_sample_matrix(:,find(new_frex>4 & new_frex<12)),2);
power_theta.choice = mean(power_choice_matrix(:,find(new_frex>4 & new_frex<12)),2);
power_beta.sample  = mean(power_sample_matrix(:,find(new_frex>15 & new_frex<30)),2);
power_beta.choice  = mean(power_choice_matrix(:,find(new_frex>15 & new_frex<30)),2);
power_slowg.sample = mean(power_sample_matrix(:,find(new_frex>30 & new_frex<50)),2);
power_slowg.choice = mean(power_choice_matrix(:,find(new_frex>30 & new_frex<50)),2);
power_fastg.sample = mean(power_sample_matrix(:,find(new_frex>65 & new_frex<100)),2);
power_fastg.choice = mean(power_choice_matrix(:,find(new_frex>65 & new_frex<100)),2);

% diffscore
diffscore_delta = (power_delta.choice-power_delta.sample)./...
    (power_delta.choice+power_delta.sample);
diffscore_theta = (power_theta.choice-power_theta.sample)./...
    (power_theta.choice+power_theta.sample);
diffscore_beta = (power_beta.choice-power_beta.sample)./...
    (power_beta.choice+power_beta.sample);
diffscore_slowg = (power_slowg.choice-power_slowg.sample)./...
    (power_slowg.choice+power_slowg.sample);
diffscore_fastg = (power_fastg.choice-power_fastg.sample)./...
    (power_fastg.choice+power_fastg.sample);

[h,p]=swtest(diffscore_delta)
    if p < 0.05
        [p_delta]=signrank(diffscore_delta);
    else
        [h,p_delta]=ttest(diffscore_delta);
    end

[h,p]=swtest(diffscore_theta)
    if p < 0.05
        [p_theta]=signrank(diffscore_theta);
    else
        [h,p_theta]=ttest(diffscore_theta);
    end

[h,p]=swtest(diffscore_beta)
    if p < 0.05
        [p_beta]=signrank(diffscore_beta);
    else
        [h,p_beta]=ttest(diffscore_beta);
    end
    
[h,p]=swtest(diffscore_slowg)
    if p < 0.05
        [p_slowg]=signrank(diffscore_slowg);
    else
        [h,p_slowg]=ttest(diffscore_slowg);
    end
    
[h,p]=swtest(diffscore_fastg)
    if p < 0.05
        [p_fastg]=signrank(diffscore_fastg);
    else
        [h,p_fastg]=ttest(diffscore_fastg);
    end  
    
end

