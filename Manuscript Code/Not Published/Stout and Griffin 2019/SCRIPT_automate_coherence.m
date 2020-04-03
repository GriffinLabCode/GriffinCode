%% addpaths/ startup
clear; clc
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\LFP Analyses');
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');

[input]=get_coh_inputs()

%% loop across input iterations

% make all granger relevant inputs 0
input.coh_pfc = 0; input.coh_hpc = 0; input.coh_re = 0;
input.Tjunction = 0;

for h = 1:2 % loop across stem and tjunction
    if h == 1
        input.stem_bin = 1; input.tjunction_bin = 0;
    elseif h == 2
        input.stem_bin = 0; input.tjunction_bin = 1;
    end
    for i = 1:3 % loop across region combos
        if i == 1 % hpc-pfc
            input.coh_pfc = 1; input.coh_hpc = 1; input.coh_re = 0;
            get_coherence_data_fun(input)
            close all % a bunch of figs may pop up - clear them
        elseif i == 2 % hpc-re
            input.coh_pfc = 0; input.coh_hpc = 1; input.coh_re = 1;
            get_coherence_data_fun(input)         
            close all
        elseif i == 3 % pfc-re
            input.coh_pfc = 1; input.coh_hpc = 0; input.coh_re = 1;
            get_coherence_data_fun(input)                     
            close all
        end
    end
end

