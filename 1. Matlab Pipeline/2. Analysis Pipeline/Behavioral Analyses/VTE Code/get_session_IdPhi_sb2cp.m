%% get_session_IdPhi
% this function uses a function gifted to me (JS) from David Redish to
% estimate IdPhi. I modified the function to work with our lab, but he
% should be acknowledged for his contribution.
%
% this function takes one days worth of data and computes IdPhi across
% trials. There are many outputs

function [IdPhi,x_data,y_data,ts_data,ExtractedX,ExtractedY,TimeStamps,timeSpent,x_data_raw,y_data_raw,ts_data_raw,remEmpty] = get_session_IdPhi(datafolder,int_name,vt_name,missing_data,middleStemPosition,stemOrientation,preSmooth,mazeLoc,runDirection)

% load vt data
%missing_data = 'interp';
%vt_name      = 'VT1.mat';
[ExtractedX,ExtractedY,TimeStamps] = getVTdata(datafolder,missing_data,vt_name);

% load int
cd(datafolder);
load(int_name);

% numtrials
numTrials = size(Int,1);

% mazeLoc predefined to be stem entry to t exit
if exist('mazeLoc') == 0
    mazeLoc = [1 6];
end

% get data from sb entry to cp exit - I want to know what they were doing
% at CP exit
for i = 1:numTrials
    x_data_raw{i}  = ExtractedX(TimeStamps >= (Int(i,1)-(5*1e6)) & TimeStamps <= Int(i,6));
    y_data_raw{i}  = ExtractedY(TimeStamps >= (Int(i,1)-(5*1e6)) & TimeStamps <= Int(i,6));
    ts_data_raw{i} = TimeStamps(TimeStamps >= (Int(i,1)-(5*1e6)) & TimeStamps <= Int(i,6));
end

% middle position of stem
if contains(stemOrientation,'x') | contains(stemOrientation,'X')
    if contains(runDirection,[{'r'} {'R'}])
        %PosMidStem = 500;
        for i = 1:numTrials
            idx_mid = []; idx_mid = find(x_data_raw{i} >= middleStemPosition);
            x_data{i}  = x_data_raw{i}(idx_mid);
            y_data{i}  = y_data_raw{i}(idx_mid);
            ts_data{i} = ts_data_raw{i}(idx_mid);
        end
    elseif contains(runDirection,[{'l'} {'L'}])
        for i = 1:numTrials
            idx_mid = []; idx_mid = find(x_data_raw{i} <= middleStemPosition);
            x_data{i}  = x_data_raw{i}(idx_mid);
            y_data{i}  = y_data_raw{i}(idx_mid);
            ts_data{i} = ts_data_raw{i}(idx_mid);
        end
    end
elseif contains(stemOrientation,'y') | contains(stemOrientation,'Y')
    %PosMidStem = 500;
    for i = 1:numTrials
        idx_mid = []; idx_mid = find(y_data_raw{i} >= middleStemPosition);
        x_data{i}  = x_data_raw{i}(idx_mid);
        y_data{i}  = y_data_raw{i}(idx_mid);
        ts_data{i} = ts_data_raw{i}(idx_mid);
    end    
end

% remove empty arrays (this can happen if youre missing data)
remEmpty = find(~cellfun('isempty',x_data)==0);
x_data(remEmpty)  =[];
y_data(remEmpty)  = [];
ts_data(remEmpty) = [];
x_data_raw(remEmpty) = [];
y_data_raw(remEmpty)  = [];
ts_data_raw(remEmpty) = [];
if isempty(remEmpty) == 0
    disp(['Trials ',num2str(remEmpty),' were removed'])
    numTrials = length(x_data);
end

% get timespent
for i = 1:numTrials
    timeSpent(i) = (ts_data{i}(end)-ts_data{i}(1))./1e6;
end 

% pre smoothing
if preSmooth == 1  
    x_data_og = x_data; %x_data = [];
    y_data_og = y_data; %y_data = [];
    for i = 1:numTrials
        %x_data{i}  = smoothdata(x_data_og{i},'gauss',10);
        %y_data{i}  = smoothdata(y_data_og{i},'gauss',10);  
    end    
end

% get IdPhi
window_sec    = 1;   % redish inputs
postSmoothing = 0.5; % redish inputs
vt_srate      = ceil(1/mean(diff(TimeStamps/1e6))); % rounded to a integer for ease of computation and stuff
display       = 0;

for i = 1:numTrials
    [IdPhi(i),dphi{i}] = IdPhi_RedishFun(x_data_og{i},y_data_og{i},window_sec,postSmoothing,vt_srate,display);
end

end