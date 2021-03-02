%% setup
% -- INPUTS -- %
% LFP1name: name of first CSC channel
% LFP2name: name of second CSC channel
% amountOfData: in time (sec), how much data you want to consider. Try .25
%                   for .25 sec (250ms)
%
% -- OUTPUTS -- %
% srate: sampling rate
% timing: amount of time actually streamed
%
%
function [srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,amountOfData)

% downloaded location of github code - automate for github
github_download_directory = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21';
addpath(github_download_directory);

% connect to netcom - automate this for github
pathName   = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21\NetComDevelopmentPackage_v3.1.0\MATLAB_M-files';
serverName = '192.168.3.100';
connect2netcom(pathName,serverName)

% open a stream to interface with Nlx objects - this is required
[succeeded, cheetahObjects, cheetahTypes] = NlxGetDASObjectsAndTypes; % gets cheetah objects and types

% sometimes you'll get an error here, still trying to figure out why. It
% has something to due with the duration of sampling.

% check various features of streaming - this includes srate checks.
% Sometimes, when this is initially run, you'll get errors. THis is
% probably related to the amount of data being streamed.
try
    openStreamCheckStream(LFP1name,LFP2name);
catch
    pause(2) % adding this pause helps get data. Sometimes you'll get an error bc youre streaming too quickly without enough data
    openStreamCheckStream(LFP1name,LFP2name);
end

% clear the working stream via netcom - funDur is a variable to track time
funDur.clearStream = clearStream(LFP1name,LFP2name);

% get data - note that in the theta range of 4-12hz, .25 seconds gets you
% 1-3cycles. Thats not a whole lot of theta cycles to detect coherence and
% may induce high coherence due to low number of cycles. Therefore,
% consider using .5-1 per event, then using a threshold of 1 event being
% high coherence. We need to test the distribution of coherence events.
% Therefore, acquire data and calculate coherence using this script, then
% open SCRIPT_determining_threshold to plot the results. Note that if the
% sampling event exceeds .5, doubling to 1 or adding a multiple of 4 to
% .75seconds, its okay because coherence has been high for a while. Its
% just a confound. Sometimes, this jump in sampling occurs.
pause(amountOfData); % pause for the amount of time you want to get data from
[succeeded, dataArray, timeStampArray, channelNumberArray, samplingFreqArray, ...
    numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

% get sampling rate - note that 'openStreamCheckStream' checks for
% inconsistencies in sampling rate between your two signals
srate = double(mode(samplingFreqArray(1,:)));

% get timing
timing(1,:) = length(dataArray(1,:))/srate;
timing(2,:) = length(dataArray(2,:))/srate;

% display
disp('Setup successful');

end
