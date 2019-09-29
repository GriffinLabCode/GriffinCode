%% svm_stem_taskphase_binned
%
% This function estimates classifier accuracy by training and testing
% on binned firing rate data. To bin, it pulls the averaged minimum and
% maximum position x and y coordinates, then automatically estimates the
% maze bins{nn-2} for the rat. The alternative would be to manually select maze
% bins{nn-2}.
%
% written by John Stout

function [svm_data,bins] = svm_stem_taskphase_binned(input,numbins)

%% Function that calculates firing rate across multiple stem points
% Written by John Stout
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions');

%% Initializing
disp(' - Initializing stem svm function...')
    
    % initialize variables that change size over each loop across sessions
    svm_var       = cell([1 (numbins-1)]);
    svm_var_temp  = cell([1 (numbins-1)]);
    
    %% Initialize variables to flip over all folders    
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

%% For loop across folders
% old formatting
for iii = 1:size(input.rat,2)
    kendog = input.rat{iii}

    session_cells = cell([1 (numbins-1)]);

    for nn = kendog

        Datafolders = Datafolders; 
        cd(Datafolders);
        folder_names = dir;
        temp_folder = folder_names(nn).name;
        cd(temp_folder);
        datafolder = pwd;
        cd(datafolder);
        
        %% Load, define, timing variables
        % load int
        load (strcat(datafolder,'\Int_file.mat')); 

        % load vt data
        load(strcat(datafolder, '\VT1.mat'));
        try load(strcat(datafolder,'\ExtractedYSample.mat'));
            disp('Successfully loaded ExtractedY Sample')
        catch 
             disp('ExtractedY from VT1 will be included');
        end
        TimeStamps = TimeStamps_VT;

        cd(Datafolders);
        folder_names = dir;
        
        %% Define stem boundaries
        % due to maze potentially shifting, this should be dynamically
        % defined. Also while it sucks that timestamps may vary on a trial
        % to trial basis, averaging across all entrances should give a
        % general concensis on the coordinates that correspond to maze
        % location entry
        
         % correct tracking errors     
        [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder); 
        
        % after examining all the bins for all sessions, the min and max
        % are super similar. For example, 137 is a common minimum and lower
        % 390s are max. Hardcode this to 135 min and 400 max
        % ymin
        %{
            ymin = [];
            for i = 1:size(Int(:,1),1)
                ymin(i) = ExtractedY(find(TimeStamps == Int(i,1)));
            end
            ymin(find(ymin == 0))=[];
            ymin = round(mean(ymin));
            %ymin = min(ymin);
        % ymax
            ymax = [];
            for i = 1:size(Int(:,1),1)
                ymax(i) = ExtractedY(find(TimeStamps == Int(i,6)));
            end
            ymax(find(ymax == 0))=[];
            %ymax = round(mean(ymax));
            ymax = max(ymax); % do not use mean here, its underestimates the rats position
        %}
        ymin = 135; % do not underestimate - you'll end up in start-box
        ymax = 400; % over estimate - this doesn't hurt anything
        bins{nn-2} = round(linspace(ymin,ymax,numbins));

%% load variables and define clusters    
    cd(datafolder);
    % load clusters
    clusters = dir('TT*.txt');        

    % define index of sample and choice trials
    sample_trials = 1:2:size(Int,1);
    choice_trials = 2:2:size(Int,1);
    
    % initialize a variable that changes size over loops
    svm_choice = cell([1 (numbins-1)]);
    svm_sample = cell([1 (numbins-1)]);

    %% Calculate firing rates and store in svm variable

    % first for choice
        for ci=1:length(clusters) 
            cd(datafolder);
            spikeTimes = textread(clusters(ci).name);
            cluster = clusters(ci).name(1:end-4);

            % define a cell array used to store fr data
            svm_choice_temp = cell([1 (numbins-1)]);

            for i = 1:length(choice_trials)
                ts_ind = find(TimeStamps>Int(choice_trials(i),1) & ...
                    TimeStamps<=Int(choice_trials(i),6)); 
                ts_temp = TimeStamps(ts_ind); 

                    if input.rec_room == 1;
                        loc_temp = ExtractedY(ts_ind);
                    elseif input.rec_room == 2;
                        loc_temp = ExtractedX(ts_ind);
                    end

                loc_temp = loc_temp';
                bins{nn-2} = bins{nn-2}';
                k = dsearchn(loc_temp,bins{nn-2}); 
                bins{nn-2} = bins{nn-2}'; 
                loc_temp = loc_temp';
                spk_ts = ts_temp(k); 

                    for j = 1:length(bins{nn-2})-1
                        numspikes_ind = find(spikeTimes>spk_ts(j) & ...
                            spikeTimes<=spk_ts(j+1));
                        numspikes = length(numspikes_ind);
                        time_temp = spk_ts(j+1) - spk_ts(j); 
                        time_temp = time_temp/1e6;
                        fr_temp(j) = numspikes/time_temp;
                    end

            fr_new(i,1:size(fr_temp,2)) = fr_temp; 

            clear fr_temp time_temp numspikes numspikes_ind spk_ts loc_temp k ts_ind ts_temp loc_temp
            end

        % store single cell data
        % first row corresponds to first bin
            for ii = 1:size(fr_new,2);
                svm_choice_temp{ii} = fr_new(:,ii);     
            end

        % store data for each cell in cell array    
            for j = 1:size(fr_new,2)
                 svm_choice{j} = horzcat(svm_choice_temp{j},svm_choice{j});             
            end
        end

    clear fr_new svm_choice_temp spikeTimes

    % next for ChoiceR
    cd(datafolder);

         for ci=1:length(clusters) 
            cd(datafolder);
            spikeTimes = textread(clusters(ci).name);
            cluster = clusters(ci).name(1:end-4);

            % define a cell array used to store fr data
            svm_sample_temp = cell([1 (numbins-1)]);

            for i = 1:length(sample_trials)
                ts_ind = find(TimeStamps>Int(sample_trials(i),1) & ...
                    TimeStamps<=Int(sample_trials(i),6)); 
                ts_temp = TimeStamps(ts_ind); 

                    if input.rec_room == 1;
                        loc_temp = ExtractedY(ts_ind);
                    elseif input.rec_room == 2;
                        loc_temp = ExtractedX(ts_ind);
                    end

                loc_temp = loc_temp';
                bins{nn-2} = bins{nn-2}';
                k = dsearchn(loc_temp,bins{nn-2}); 
                bins{nn-2} = bins{nn-2}'; 
                loc_temp = loc_temp';
                spk_ts = ts_temp(k); % spike timestamps is equal to the timestamps dictated by location (timestamps bw stem entry and exit) that is further dependent on the bins{nn-2}

                    for j = 1:length(bins{nn-2})-1
                        numspikes_ind = find(spikeTimes>spk_ts(j) & ...
                            spikeTimes<=spk_ts(j+1)); % find the spikes within the timestamps of the bins{nn-2} (0 and 1, 1 and 2 etc.)
                        numspikes = length(numspikes_ind);
                        time_temp = spk_ts(j+1) - spk_ts(j); 
                        time_temp = time_temp/1e6;
                        fr_temp(j) = numspikes/time_temp;
                    end

            fr_new(i,1:size(fr_temp,2)) = fr_temp; 

            clear fr_temp time_temp numspikes numspikes_ind spk_ts loc_temp k ts_ind ts_temp loc_temp
            end

        % store single cell data
        % first row corresponds to first bin
            for ii = 1:size(fr_new,2);
                svm_sample_temp{ii} = fr_new(:,ii);     
            end

        % store data for each cell in cell array    
            for j = 1:size(fr_new,2)
                 svm_sample{j} = horzcat(svm_sample_temp{j},svm_sample{j});             
            end
         end

        cd(datafolder);   
        clear fr_new svm_choice_temp spikeTimes

    % combine sample_trials and sampleR
    for gee = 1:size(svm_choice,2);
        svm_var_temp{gee} = vertcat(svm_choice{gee},svm_sample{gee});
    end

    % combine data from all sessions
    session_cells = vertcat(session_cells,svm_var_temp);

    clear svm_choice svm_sample svm_var_temp 
    end
    
session_cells(1,:) = [];

%format new array thats as long as there are bins{nn-2}. Within each bins{nn-2},
%there should be 
for n = 1:size(session_cells,2)
    svm_var{1,n} = horzcat(session_cells{:,n});
end

% get rid of NaNs
for goawayNaN = 1:size(svm_var,2)
    svm_var{goawayNaN}(isnan((svm_var{goawayNaN})))=0;
end

% store data
svm_data{iii} = svm_var;

clearvars -except iii input stem_mean stem_sem svm_data...
    folder_names kendog Datafolders bins roc input numbins

% re-initialize variables
svm_var      = cell([1 (numbins-1)]);
svm_var_temp = cell([1 (numbins-1)]);

end 


end  
