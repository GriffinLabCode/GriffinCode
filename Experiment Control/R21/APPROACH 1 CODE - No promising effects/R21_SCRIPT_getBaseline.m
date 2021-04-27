%% get baseline while other matlab controls maze
clear; clc

codeDir = getCurrentPath();
addpath(codeDir);

disp('Make sure Cheetah is opened - do not hit record yet')

%% some parameters set by the user

% how long should the session be?
session_length = 13; % minutes

delay_length = 0; % seconds
numTrials    = 40;
pellet_count = 1;
timeout_len  = 60*10;

% define LFPs to use
LFP1name = 'CSC6';  % hpc
LFP2name = 'CSC10'; % pfc

% for multitapers
params.tapers = [5 9]; 
%params.Fs     = srate;
params.fpass  = [4 12];

% define amount of data
amountOfData = 0.25;

% define how much time for baseline run - MAKE SURE THIS MATCHES THE
% SESSION LENGTH YOU'RE RUNNING
amountOfTime = session_length; % minutes

%% MAKE SURE THIS MATCHES THE SESSION LENGTH OR IS LESS THAN IT
% define a looping time - this is in minutes
%amountOfTime = session_length/60;
%amountOfTime = .84; % 0.84 is 50/60min, to account for initial pause of 10sec .25; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

%% set up cheetah

%% get cheetah streaming
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,amountOfData);
[succeeded, reply] = NlxSendCommand('-StartRecording');

%% now run get baseline
[threshold,coh] = R21_getBaseline(LFP1name,LFP2name,amountOfData,amountOfTime,srate);

%% save threshold outputs

% save data
c = clock;
c_save = strcat(num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(1)),'_','EndTime',num2str(c(4)),num2str(c(5)));

prompt   = 'Please enter the rats name ';
rat_name = input(prompt,'s');

prompt   = 'Please enter the task ';
task_name = input(prompt,'s');

prompt   = 'Enter the directory to save the data ';
dir_name = input(prompt,'s');

save_var = strcat(rat_name,'_',task_name,'_',c_save);

cd(dir_name);
save(save_var);

% second save - for parameters
save_var2 = strcat(rat_name,'_','baselineParameters');
save(save_var2,'threshold','LFP1name','LFP2name','params','amountOfData');


