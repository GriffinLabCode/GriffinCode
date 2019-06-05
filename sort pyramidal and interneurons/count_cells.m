%% Count cells for each subregion for each rat

datafolders.acc = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Anterior Cingulate';
datafolders.prl = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Prelimbic';

% cells in acc
    cd(datafolders.acc)
    folder_names.acc = dir;

    sessions.acc.rat{1} = 3:4;
    sessions.acc.rat{2} = 5;
    sessions.acc.rat{3} = 6:12;
    sessions.acc.rat{4} = 13:20;

for iii = 1:size(sessions.acc.rat,2)
    kendog = sessions.acc.rat{iii};
    
    for n = kendog 
        cd(datafolders.acc);
        folder_names.acc = dir;
        temp_folder = folder_names.acc(n).name;
        cd(temp_folder);
        datafolder = pwd;
        cd(datafolder);            
        
        cell_count_temp{n} = size(dir('TT*.txt'),1);
        
    end
    
    % save folder names
    split_string{iii} = strsplit(temp_folder);
    rat_names.acc{iii}    = char(split_string{iii}(1));
    
    % add up recorded cells
    cell_count.acc{iii} = sum(cell2mat(cell_count_temp...
        (~cellfun('isempty',cell_count_temp))));
    
    % empty variable
    cell_count_temp = [];
end
    
clearvars -except sessions cell_count datafolders rat_names
    
    
% cells in prl
    cd(datafolders.prl)
    folder_names.prl = dir;

    sessions.prl.rat{1} = 3:14;
    sessions.prl.rat{2} = 15:18;
    sessions.prl.rat{3} = 19:21;
    sessions.prl.rat{4} = 22:26;
    sessions.prl.rat{5} = 27:34;
    sessions.prl.rat{6} = 35:43;
    
for iii = 1:size(sessions.prl.rat,2)
    kendog = sessions.prl.rat{iii};
    
    for n = kendog 
        cd(datafolders.prl);
        folder_names.prl = dir;
        temp_folder = folder_names.prl(n).name;
        cd(temp_folder);
        datafolder = pwd;
        cd(datafolder);            
        
        cell_count_temp{n} = size(dir('TT*.txt'),1);
        
    end

    % save folder names
    split_string{iii} = strsplit(temp_folder);
    rat_names.prl{iii}    = char(split_string{iii}(1));    
    
    % add up recorded cells
    cell_count.prl{iii} = sum(cell2mat(cell_count_temp...
        (~cellfun('isempty',cell_count_temp))));
    
    % empty variable
    cell_count_temp = [];
end

% generate figure
f = figure;
uit = uitable(f,'Data',char(rat_names.prl),cell2mat(cell_count.prl)')
