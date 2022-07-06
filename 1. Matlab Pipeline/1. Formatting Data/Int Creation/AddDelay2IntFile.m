%% add delay data to Int file
% 1) view vt data 
% 2) create int file and check all trajectories
% 3) Run SCRIPT_addDelay2Int
%       -> go to your rats sessions folder
clear; clc;

% define datafolder
datafolder = pwd;
load('Int')

% get path for delay data
place2store = getCurrentPath;
cd(place2store);
load('data_delayDurations');

% concatenate delay duration with Int file
if size(delay_durations,1) < size(Int,1)
    % find size difference
    sizeDiff=size(Int,1)-size(delay_durations,1);
    % add nans
    delay_durations(end+1:end+sizeDiff)=NaN;
    % concatenate
    Int(:,size(Int,2)+1)=delay_durations;
elseif size(delay_durations,1) == size(Int,1)
    Int(:,size(Int,2)+1)=delay_durations;
elseif size(delay_durations,1) > size(Int,1)
    error('You have more delay durations than the Int file detected as trials')
end

% enter trials to remove
prompt = input('Enter trials that you manually excluded ','s');
trials2rem = str2num(prompt);
% column 9 tells you what to exclude
Int(trials2rem,9) = 1;
% column 10 is going to be delays
trials2fill = find(isnan(Int(:,10)));
trials2fill(1)=[];
for i = 1:length(trials2fill)
    prompt = [];
    prompt = input(['Enter delay duration for trajectory #',num2str(trials2fill(i)),' '],'s');
    delayFill(i) = str2num(prompt);
end
Int(trials2fill,10)=delayFill;

% save data
cd(datafolder);
save('Int_final','Int')

