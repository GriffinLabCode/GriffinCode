%% detrend all LFP
%
% this script uses the detrend_LFP function Henry wrote to store detrended
% LFPs in datafolders
%
%
% written by John Stout

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');

%% define inputs
 % region
    input.mPFC_good = 0;
    input.mPFC_poor = 0;
    input.OFC       = 0;
 
    % sub-region
    input.Prelimbic         = 1;    
    input.AnteriorCingulate = 0;
    input.MedialOrbital     = 0;
    input.VentralOrbital    = 0;

%% flip over all folders    
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
for n = 3:length(folder_names)
    
        Datafolders = Datafolders;
        cd(Datafolders);
        folder_names = dir;
        temp_folder = folder_names(n).name;
        cd(temp_folder);
        datafolder = pwd;
        cd(datafolder); 
        
	    % define and load some variables 
        cd(Datafolders);
        folder_names = dir;
        cd(datafolder);
        
        try       
          %% clean pfc data
            % check if pfc data exists and load if so
            if input.Prelimbic == 1
                region = '\PrL.mat';
            elseif input.AnteriorCingulate == 1
                region = '\ACC.mat';
            elseif input.mPFC_good == 1
                region = '\mPFC.mat';
            end
            
            load(strcat(datafolder,region)); 
            lfp_1 = Samples(:);
                % detrend Samples data
                Samples_detrended = locdetrend(lfp_1);
                
                % clean detrended data
                
                
                    % check if pfc data exists and save the region
                    if input.Prelimbic == 1
                        cd(datafolder);
                        save('PrL_detrended.mat','Header_*',...
                            'NumberOfValidSamples','SampleFrequencies',...
                            'Samples','ChannelNumbers',...
                            'Timestamps');                       
                    elseif input.AnteriorCingulate == 1
                        cd(datafolder);
                        save('ACC_detrended.mat','Header_*',...
                            'NumberOfValidSamples','SampleFrequencies',...
                            'Samples','ChannelNumbers',...
                            'Timestamps');  
                    elseif input.mPFC_good == 1
                        cd(datafolder);
                        save('mPFC_detrended.mat','Header_*',...
                            'NumberOfValidSamples','SampleFrequencies',...
                            'Samples','ChannelNumbers',...
                            'Timestamps');                      
                    end         
                
              % house keeping
              clearvars -except datafolder Datafolders folder_names n ...
                  params region temp_folder input
              
         %% clean hpc data
                % load data
                load(strcat(datafolder,'\HPC.mat'));
                % detrend Samples data
                Samples_detrended = detrend_LFP(Samples);              
                save('HPC_detrended.mat','Header_*',...
                     'NumberOfValidSamples','SampleFrequencies','Samples',...
                     'ChannelNumbers','Timestamps'); 
                 
        catch
            % for display
            C = [];
            C = strsplit(datafolder,'\');
            X = [];
            X = ['error in loading data from ', C{end}];
            disp(X);
        end
        
X = ['finished with session ',num2str(n-2)];
disp(X)        
end