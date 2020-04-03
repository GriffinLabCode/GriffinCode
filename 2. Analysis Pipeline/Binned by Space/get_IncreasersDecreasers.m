%% get_IncreasersDecreasers
% This code creates an index of neurons that significantly increased or
% decreased their firing activity across the sessions
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

function [FRdata] = get_IncreasersDecreasers(Datafolders,int_name,vt_name,task_type,correct)

    % calculate firing rate for all sessions
    addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');
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

                for triali = 1:length(trials)    
                    % get an index of spikes
                    spk_ind = find(spikeTimes > Int(trials(triali),1) & ...
                        spikeTimes < Int(trials(triali),6)); 
                    % get spike timestamps
                    spks = spikeTimes(spk_ind);
                    % get firing rate
                    FR(triali) = length(spks)/((Int(trials(triali),6)-...
                        Int(trials(triali),1))/1e6);
                    % get spike counts
                    spkCount(triali) = length(spks);
                end  
                % store
                FRdata.FR{nn-2}{ci}       = FR;
                FRdata.spkCount{nn-2}{ci} = spkCount;   
            end

        % display progress
        X = ['finished with session ',num2str(nn-2)];
        disp(X)
        
    end   
    
    % get the correlation between progressing trial number and firing
    for outi = 1:length(FRdata.FR)
        for ini = 1:length(FRdata.FR{outi})
            % numtrials
            FRdata.numTrials{outi}{ini} = 1:length(FRdata.FR{outi}{ini});
            % correlation between trial number and Firing rate
            [R,P] = corrcoef(FRdata.numTrials{outi}{ini},FRdata.FR{outi}{ini});
            rFR{outi}{ini} = R(2);
            pFR{outi}{ini} = P(2);
            % correlation between trial number and spikes
            [R,P] = corrcoef(FRdata.numTrials{outi}{ini},FRdata.spkCount{outi}{ini});
            rSPK{outi}{ini} = R(2);
            pSPK{outi}{ini} = P(2);            
        end
    end
        
    % store data
    FRdata.pFR  = cell2mat(horzcat(pFR{:}));
    FRdata.rFR  = cell2mat(horzcat(rFR{:}));
    FRdata.pSPK = cell2mat(horzcat(pSPK{:}));
    FRdata.RSPK = cell2mat(horzcat(rSPK{:}));
    
    % extract increasers and decreasers
    FRdata.decreasers_idx = find(FRdata.pFR<0.05 & FRdata.rFR<0);
    FRdata.increasers_idx = find(FRdata.pFR<0.05 & FRdata.rFR>0);
    FRdata.neither_idx    = find(FRdata.pFR>0.05);
    
    % find number of each
    FRdata.decreasers_num = length(FRdata.decreasers_idx);
    FRdata.increasers_num = length(FRdata.increasers_idx);
    
end
