%% get_SessionFR
% this code gets the session averaged firing rate from the point at which
% you start recording until the end. This code then uses kmeans clustering
% to set an arbitrary threshold of low rate and high rate neurons. It also
% uses lit to identify
%
% ~~~ INPUTS ~~~
% Datafolders: Master directory
% int_name: the name of the int_file you want to use (ie 'Int_file.mat')
% vt_name: the name of the video tracking file (ie 'VT1.mat')
% task_type: Currently supports 'DNMP' or 'CA/DA/CD' 
% stem_dir: the direction of stem (can be 'X' or 'Y' as in the x and y plane)
% correct: 1 or 0, 1 if you want correct only
%
% ~~~ OUTPUTS ~~~
% FRdata: a struct array containing data
%
% written by John Stout. Last update 2/23/20

function [FRdata] = get_SessionFR(Datafolders,int_name,vt_name,task_type,correct)

    % calculate firing rate for all sessions
    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\1. Matlab Pipeline\2. Analysis Pipeline');
    cd(Datafolders);
    folder_names = dir;  
    
    for nn = 3:length(folder_names)

            Datafolders = Datafolders;
            cd(Datafolders);
            folder_names = dir;
            temp_folder = folder_names(nn).name;
            cd(temp_folder);
            datafolder = pwd;
            cd(datafolder);    

            % load animal parameters 
            load(int_name);
            load(vt_name,'ExtractedX','ExtractedY','TimeStamps_VT');
            TimeStamps = TimeStamps_VT; % rename

            % load TTs
            clusters = dir('TT*.txt');

            % include only correct?
            if correct == 1
                Int(find(Int(:,4)==1),:)=[];
            end
            
            % if DNMP was selected, separate sample and choice trials
            if task_type == 'DNMP' 
                task_params   = 2;
            elseif task_type == 'CA/DA/CD'
                task_params = 1;
            end

            %% Create firing rate arrays
            if task_params == 2
                trials = 1:size(Int,1); % retrospective
            elseif task_params == 1
                trials = 2:size(Int,1);
            end

            for ci=1:length(clusters)
                cd(datafolder);
                spikeTimes = textread(clusters(ci).name);
                cluster    = clusters(ci).name(1:end-4);
   
                % get an index of spikes
                spk_ind = find(spikeTimes > TimeStamps(1) & ...
                    spikeTimes < TimeStamps(end)); 
                % get spike timestamps
                spks = spikeTimes(spk_ind);
                % get firing rate
                FR = length(spks)/((TimeStamps(end)-TimeStamps(1))/1e6);
                % get spike counts
                spkCount = length(spks);
 
                % store
                FRdata.FR{nn-2}{ci}       = FR;
                FRdata.spkCount{nn-2}{ci} = spkCount;   
            end

        % display progress
        X = ['finished with session ',num2str(nn-2)];
        disp(X)
        
    end   
    
    % use Kmeans to set a threshold
    FRdata.FR = cell2mat(horzcat(FRdata.FR{:}));
    FRdata.spkCount = cell2mat(horzcat(FRdata.spkCount{:}));
    
    % use a histogram to determine the majority of neurons
    figure('color','w'); histogram(FRdata.FR); ylabel('Counts'); 
    xlabel('Firing Rate'); box off; set(gca,'FontSize',12);
    
    [counts,centers]=hist(FRdata.FR);
    ratio_counts = counts./(sum(counts));
    percent_counts = ratio_counts*100;
    
    % find where 50% mark is based on where ~50% of the distribution is
    % binned using the default binnings
    for i = 1:length(percent_counts)
        half1 = sum(percent_counts(1:i));
        if half1 >= 50
            half2 = sum(percent_counts(i+1:end));
            return
        end
    end
        
    % use i to plot line
    figure('color','w'); h1 = histogram(FRdata.FR); ylabel('Counts'); 
    xlabel('Firing Rate'); box off; set(gca,'FontSize',12);
    ylimits = ylim;
    line([i i],[0 ylimits(2)],'Color','r','LineStyle','--','LineWidth',2)    
    
    
    
end
