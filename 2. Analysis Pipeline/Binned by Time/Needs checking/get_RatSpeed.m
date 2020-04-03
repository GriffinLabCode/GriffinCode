%% get all rats locations from LFP sessions
% this script gets rat position data from LFP sessions and calculates speed
% define if you want to correct trajectories - I don't recommend as it will
% require random sub-sampling and removal of trials when the number of
% trajectories are probably similar in count
%
% ~~~~ INPUTS ~~~~
% Datafolders: a main directory houses more folders that contain the data
% int_name: The name of your int file you want analyzed
%
% future iterations will have a flexible time variable
%
% written by John Stout

function [] = get_RatSpeed(Datafolders, int_name)

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');

    %[input]=get_granger_inputs(); % this works for now
    [input]=get_coh_inputs();

    correct_trajectory = 0;

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

    %% get and format int
    
    % int_name will be the int file name
    load(strcat(datafolder,int_name));

    % store C variable
    C = [];
    C = strsplit(datafolder,'\');    
    name = C;

    cd(Datafolders);
    folder_names = dir;
    cd(datafolder);

    % remove clipped data - if you entered it this way
    if size(Int,2) >= 9
        try
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
                continue
            end

            % split into sample and choice trials
            Int_sample = Int(1:2:size(Int,1),:);
            Int_choice = Int(2:2:size(Int,1),:);

            % check that Int file is formatted correctly again
            if isempty(find(Int_sample(:,10)==1))==0 || isempty(find(Int_choice(:,10)==0))==0
                disp('Int file not formatted correctly')
                continue
            end  
        catch
            continue
        end
    else
        % split into sample and choice trials
        Int_sample = Int(1:2:size(Int,1),:);
        Int_choice = Int(2:2:size(Int,1),:);    
    end        

        %% interpolate missing data and convert to cm
        cd(datafolder);
        load('VT1.mat');
        [ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);

        % convert to cm
        ExtractedX = round(ExtractedX./2.09);
        ExtractedY = round(ExtractedY./2.04);

        %% get position data
            % loop across trials
            for triali = 1:size(Int,1)
                % define where you want to perform the analysis
                  time = [(Int(triali,5)-(2*1e6)) (Int(triali,5)+(1*1e6))];
              %time = [(Int(triali,5)-(0.8*1e6)) (Int(triali,5)+(0.2*1e6))];
                
                % get position data
                PosX{triali}       = ExtractedX(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
                PosY{triali}       = ExtractedY(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));  
                TrialTimes{triali} = (TimeStamps_VT(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2))/1e6);  

            end

            % velocity
            % sampling rate for video tracking data
            sfreq = round(29.97);

            % calculate velocity (cm/sec)
            for i = 1:length(PosX)
                for ii = 1:length(PosX{i})-1
                    vel{i}(ii)=sqrt(((PosX{i}(ii+1)-PosX{i}(ii))^2)+((PosY{i}(ii+1)-PosY{i}(ii))^2))/...
                        (TrialTimes{i}(ii+1)-TrialTimes{i}(ii));
                end
            end

            % interpolate to sfreq
            time_diff = (time(2)-time(1))/1e6;
            for jj = 1:length(vel)
                 y = []; x = []; x_new = [];
                 y         = abs(vel{jj});
                 x         = linspace(-0.8,0.2,length(vel{jj})); % the x and y in this are arbitrary, could be anything
                 x_new     = linspace(-0.8,0.2,sfreq*time_diff); % interp to time epoch  
                 speed{jj} = interp1(x,y,x_new);
            end
            
            % get matrix
            speed_mat{nn-2} = vertcat(speed{:});
            speed_avg{nn-2} = mean(speed_mat{nn-2});

        % display progress
        disp(['Finshed with session ', num2str(nn-2),'/',num2str(size(folder_names,1)-2)]);
        
        % store session title
        session_name{nn-2} = name;

        % house-keeping
        clearvars -except Datafolders session_name folder_names nn input ...
             correct_trajectory frequencies granger_sample_x2y ...
             granger_choice_x2y granger_sample_y2x granger_choice_y2x error_var ...
             timespent_sample timespent_choice fx2y fy2x freq ssmo speed_mat speed_avg int_name         
         
    end
    
    prompt   = 'Please enter a unique name for this dataset ';
    unique_name = input(prompt,'s');

    prompt   = 'Enter the directory to save the data ';
    dir_name = input(prompt,'s');

    save_var = unique_name;

    cd(dir_name);
    save(save_var);
end