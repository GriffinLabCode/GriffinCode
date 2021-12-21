%% Int vs auto accuracy
% this code is meant to cross-validate the Int file with the automaze
% accuracies to ensure no weird business is happening.
%
% you should have already run Int_hybrid
clear; clc;
datafolder   = pwd;

% load int file
cd(datafolder);
load('Int_hybrid')

ratName = '21-21';
dataINfolder = dir(datafolder);
dataINfolder = extractfield(dataINfolder,'name');
idxKeep = find(contains(dataINfolder,ratName)==1);
dataINfolder = dataINfolder(idxKeep);
load(dataINfolder{1},'accuracy')        

% cross-validate
Int_accuracy = Int(2:end,4);
validated = Int_accuracy-accuracy';

if isempty(find(validated == 1))==0
    disp('Erase the Int file - do not use this session')
else
    disp('Int file cross-validated! Data is ready.')
end

