%% addpaths/ startup
clear; clc

cd('X:\03. Lab Procedures and Protocols\MATLABToolbox\mvgc_v2.0')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\mvgc_v2.0\demo')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous\GC code\GCtoolbox\bsmart')

startup_fun;

[input]=get_granger_inputs();

TEntryEpoch   = 1; % this is -.5 and +.5 around t-entry
EpochsAroundT = 0; % this assess -.5 to t-entry and t-entry to 0.5 separately

%% loop across input iterations

% make all granger relevant inputs 0
input.pfc = 0; input.hpc = 0; input.re = 0;
input.T_before = 0; input.T_after = 0; input.T_entry = 0;

if EpochsAroundT == 1 % separately assess time around t
    for h = 1:2 % loop across T-options - this doesn't examine all T
        if h == 1 % before T
            input.T_before = 1; input.T_after = 0; input.T_entry = 0;
        elseif h == 2 % after T
            input.T_before = 0; input.T_after = 1; input.T_entry = 0;
        end
        for i = 1:3 % loop across region combos
            if i == 1 % hpc-pfc
                input.pfc = 1; input.hpc = 1; input.re = 0;
                GetAllGrangerStateSpace_Fun(input);
                %GetAllGranger_Bsmart_Fun(input);
                close all % a bunch of figs may pop up - clear them
            elseif i == 2 % hpc-re
                input.pfc = 0; input.hpc = 1; input.re = 1;
                GetAllGrangerStateSpace_Fun(input);
                %GetAllGranger_Bsmart_Fun(input);          
                close all
            elseif i == 3 % pfc-re
                input.pfc = 1; input.hpc = 0; input.re = 1;
                GetAllGrangerStateSpace_Fun(input);
                %GetAllGranger_Bsmart_Fun(input);                      
                close all
            end
        end
    end
elseif TEntryEpoch == 1 % collapse across T (good for assess slow freqs)
    input.T_before = 0; input.T_after = 0; input.T_entry = 1;
        for i = 1:3 % loop across region combos
            if i == 1 % hpc-pfc
                input.pfc = 1; input.hpc = 1; input.re = 0;
                GetAllGrangerStateSpace_Fun(input);
                %GetAllGranger_Bsmart_Fun(input);
                close all % a bunch of figs may pop up - clear them
            elseif i == 2 % hpc-re
                input.pfc = 0; input.hpc = 1; input.re = 1;
                GetAllGrangerStateSpace_Fun(input);
                %GetAllGranger_Bsmart_Fun(input);          
                close all
            elseif i == 3 % pfc-re
                input.pfc = 1; input.hpc = 0; input.re = 1;
                GetAllGrangerStateSpace_Fun(input);
                %GetAllGranger_Bsmart_Fun(input);                      
                close all
            end
        end
end
