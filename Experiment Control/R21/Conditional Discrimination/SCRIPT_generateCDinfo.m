%% this is the first code to run
% use the excel sheet in the R21 folder
clear; clc;
prompt = ['What is your rats name? '];
targetRat = input(prompt,'s');

prompt   = ['Confirm that your rat is ' targetRat,' [y/Y OR n/N] '];
confirm  = input(prompt,'s');

prompt  = ['Enter ',targetRat,'s condition ID found in the RAT LOGGER excel sheet (0 or 1) '];
condID  = str2num(input(prompt,'s'));

% later identification
if condID == 0
    condInfo = 'WoodLeft';
elseif condID == 1
    condInfo = 'MeshLeft';
end

% save data
disp('Creating folder and saving data...')
mkdir(['X:\01.Experiments\R21\' targetRat,'\CD\conditionID'])
cd(['X:\01.Experiments\R21\' targetRat,'\CD\conditionID'])
save('CDinfo','condID','condInfo')
