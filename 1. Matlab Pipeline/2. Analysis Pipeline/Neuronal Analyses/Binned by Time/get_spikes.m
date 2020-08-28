%% get_spikes
%
% ~~~ INPUTS ~~~
% Datafolders: Master directory
% int_name: the name of the int_file you want to use (ie 'Int_file.mat')
% vt_name: the name of the video tracking file (ie 'VT1.mat')
% missing_data: 'interp','ignore', or 'exclude'
% task_type: Currently supports 'DNMP' or 'CA/DA/CD' 
% bin_num: number of bins
% stem_dir: the direction of stem (can be 'X' or 'Y' as in the x and y plane)
% 
% written by John Stout. Last update 3/23/20

function [SpkTSdata] = get_spikes(Datafolders,int_name,vt_name,missing_data)

    % calculate firing rate for all sessions
    cd(Datafolders);
    folder_names = dir;
    
    % adjust the looping index?
    prompt  = 'Adjust the looping index? [Y/N] ';
    adjLoop = input(prompt,'s');

    if adjLoop == 'Y'
        prompt = 'Enter the loop index ';
        looper = str2num(input(prompt,'s'));
    else
        looper = 3:length(folder_names);
    end

    % loop across folders
    for nn = looper    

            Datafolders = Datafolders;
            cd(Datafolders);
            folder_names = dir;
            temp_folder = folder_names(nn).name;
            cd(temp_folder);
            datafolder = pwd;
            cd(datafolder);
            
            % only define these one time, on the very first loop
            if  nn == looper(1)
                prompt = 'Enter maze section based on Int (ie T-entry == 5) ';
                mazeIdx = str2num(input(prompt,'s'));  

                prompt = 'Enter time from that maze section (ie 1 == 1 second) ';
                timing = str2num(input(prompt,'s'));
            end            

            % load animal parameters 
            varlist = who; %Find the variables that already exist
            varlist = strjoin(varlist','$|'); %Join into string, separating vars by '|'
            load(int_name,'-regexp', ['^(?!' varlist ')\w']);
                
            % get vt_data 
            [ExtractedX,ExtractedY,TimeStamps_VT] = getVTdata(datafolder,missing_data,vt_name);                   

            % correct/incorrect trials index
            IntCorrect   = find(Int(:,4)==0);
            IntIncorrect = find(Int(:,4)==1);
            
            %% get spikes
            
            % load TTs
            cd(datafolder);
            clusters = dir('TT*.txt');

            % initialize variables
            spikeTS = []; posX    = []; posY    = []; TS      = [];        

            % index of trials
            trials = 1:size(Int,1);   

            for ci=1:length(clusters)
                cd(datafolder);
                spikeTimes = textread(clusters(ci).name);
                cluster    = clusters(ci).name(1:end-4);
                
                for triali = 1:size(Int,1) % loop across trials

                    % define where you want to perform the analysis
                    time = [];                
                    time = [(Int(triali,mazeIdx)-(timing*1e6)) (Int(triali,mazeIdx))];

                    % get data
                    spikeTS{triali}{ci} = spikeTimes(spikeTimes>time(1,1) & spikeTimes<time(1,2));

                    % get position data
                    posX{triali} = ExtractedX(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
                    posY{triali} = ExtractedY(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
                    TS{triali}   = TimeStamps_VT(TimeStamps_VT>time(1,1) & TimeStamps_VT<time(1,2));
                    
                end
                
            end
            
            % get correct and incorrect
            SpkTSdata.spikeTS_cor{nn-2} = spikeTS(IntCorrect);
            SpkTSdata.spikeTS_inc{nn-2} = spikeTS(IntIncorrect);

            % store bhavior
            SpkTSdata.beh{nn-2} = Int;
            
            % store position data
            SpkTSdata.posX{nn-2}     = posX;
            SpkTSdata.posY{nn-2}     = posY;
            SpkTSdata.posTimes{nn-2} = TS;

            X = ['finished with session ',num2str(nn-2)];
            disp(X)
            
            % offline steps should include cleaning, removing artifacts,
            % then running analyses.
    end
    
    clearvars -except LFPdata Datafolders int_name numbins stem_dir task_type vt_name correct timing mazeIdx
    
    prompt = 'Please briefly describe this dataset ';
    data_description = input(prompt,'s');

    prompt   = 'Please enter a unique name for this dataset ';
    unique_name = input(prompt,'s');

    prompt   = 'Enter the directory to save the data ';
    dir_name = input(prompt,'s');

    save_var = unique_name;

    cd(dir_name);
    save(save_var);    
    
end   
