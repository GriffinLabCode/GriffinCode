%% state space granger causality
% using this code: first run a get_LFP function. Save the data. Then load
% it into workspace, define lfp_1 and lfp_2 and srate, then run function.
%
% -- INPUTS --
% lfp_1 and lfp_2: data must be in cell array format such that individual
%                   cells indicate sessions, then within each cell are
%                   individual cell arrays containing trial data
% srate: sampling rate
%
% -- OUTPUTS --
%
%
% Written by john Stout

function [fx2y,fy2x,freqs,srateNew,ssmo,pf] = GrangerCausality_StateSpace(lfp_1,lfp_2,srate)

% addpaths
startup_GC_fun;

% remove empty arrays
lfp_1 = lfp_1(~cellfun('isempty',lfp_1));
lfp_2 = lfp_2(~cellfun('isempty',lfp_2));

% concatenate across trials within sessions
for i = 1:length(lfp_1)
    lfp_1{i} = horzcat(lfp_1{i}{:});
    lfp_2{i} = horzcat(lfp_2{i}{:});
end

%{
% detrend and denoise signals
for i = 1:length(lfp_1)
    lfp1_cle{i} = DetrendDenoise(lfp_1{i},srate);
    lfp2_cle{i} = DetrendDenoise(lfp_2{i},srate);
    disp(['cleaned data from session ',num2str(i)])
end
%}

% down-sample data
target_sample = 125; % hz
div = find_downsample_rate(srate,target_sample);

% replace with clean data
for i = 1:length(lfp1_cle)
    signalx{i} = lfp_1{i}(1:div:end);
    signaly{i} = lfp_2{i}(1:div:end);
end

% provide new srate
srateNew   = length(1:div:srate);
data.srate = srateNew; % need this for granger functions

% make a new variable with data organized properly
for i = 1:length(signalx)
    data.signals{i}(1,:) = signalx{i};
    data.signals{i}(2,:) = signaly{i};
end

% estimate model order
for i = 1:length(signalx)
    data.signals      = [];
    data.signals(1,:) = signalx{i};
    data.signals(2,:) = signaly{i};
    
    [pf{i},ssmo{i}] = EstimateModelOrder_2(data);
    disp(['Model order estimated for session ',num2str(i)])
end

% run granger on separate sessions
for i = 1:length(signalx)
    data.signals      = [];
    data.signals(1,:) = signalx{i};
    data.signals(2,:) = signaly{i};
    
    % state space function
    [fx2y{i},fy2x{i},freqs{i}] = StateSpaceGranger(data,ssmo{i},pf{i}); 
    
    disp(['GC estimates obtained from session ',num2str(i)])   
end 

    prompt = 'Please briefly describe this dataset ';
    data_description = input(prompt,'s');

    prompt   = 'Please enter a unique name for this dataset ';
    unique_name = input(prompt,'s');

    prompt   = 'Enter the directory to save the data ';
    dir_name = input(prompt,'s');

    save_var = unique_name;

    cd(dir_name);
    save(save_var);    
    
end
    
