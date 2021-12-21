%% looper

clear;

% define rat IDs
rats{1} = '21-12';
rats{2} = '21-13';
rats{3} = '21-14';
rats{4} = '21-15';
rats{5} = '21-16';
rats{6} = '21-21';
rats{7} = '21-22';

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
    for sessi = 1:length(dir_content)

        clear lfp_pf_cp lfp_hc_cp lfp_pfc lfp_hpc lfp_ts Int

        % define datafolder
        datafolder = [Datafolders,dir_content{sessi}];
        fun_IntCreate_automaze_DAtask(datafolder,rats{i});

    end
end



