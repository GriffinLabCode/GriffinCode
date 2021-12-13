%% define baseline and std for artifactDetect
% this code provides averages and std used for 'artifactDetect'
%
% -- INPUTS -- %
% data1: LFP data to sample over. Vector format
% data2: LFP data to sample over
% movingwin: moving window parameters. For example:
%               -> movingwin = [1.25 .25]; 
%               -> 1.25 sec window, moving with .25sec steps
% srate: sampling rate (e.g. 2000)
% 
% --- OUTPUTS --- %
% baselineMean: average lfp after detrending
% baselineSTD: std lfp after detrending
%
% written by John Stout
    
function [baselineMean,baselineSTD] = get_artifactBaseline(data1,data2,movingwin,srate)
clear starter ender coh

% first for stem lfp
%movingwin = [1.25 .25];
%srate = 2000;
%f = [1:.5:20];
winStep   = movingwin(2); % 250ms
winSizeTime = movingwin(1); % in sec
winLength = round((length(data1)/(srate*winSizeTime))/(winStep),1);
dataDet1 = []; dataDet2 = []; 
for i = 1:winLength
    % get 2 sec moving window by .25
    numSamples2Move = srate*winStep;
    if i == 1      
        % define a starter variable that will be saved for each loop and
        % modified each time
        starter(i) = 1;
        ender(i)   = srate*winSizeTime;

        % get data        
        data_temp1 = []; data_temp2 = [];
        data_temp1 = data1(starter(i):ender(i));
        data_temp2 = data2(starter(i):ender(i));
        
		% -- enter your code here and save per each loop -- %
        %dataDet1 = []; dataDet2 = [];
        dataDet1{i} = detrend(data_temp1,3);
        dataDet2{i} = detrend(data_temp2,3);
        
        % average
        %lfpMean1(i) = nanmean(dataDet1);
        %lfpMean2(i) = nanmean(dataDet2);
        
        % standard deviation
        %lfpStd1(i) = std(dataDet1);
        %lfpStd2(i) = std(dataDet2);
        
    else
        starter(i) = starter(i-1)+(numSamples2Move);
        ender(i)   = starter(i)+(srate*winSizeTime);

        % in the case where you've run out of data, break out of the loop
        if ender(i) > length(data1)
            starter(i) = [];
            ender(i)   = [];
            break
        end
        
        % get data
        data_temp1 = []; data_temp2 = [];
        data_temp1 = data1(starter(i):ender(i));
        data_temp2 = data2(starter(i):ender(i));        
           
		% -- enter your code here and save per each loop -- %
        %dataDet1 = []; dataDet2 = [];
        dataDet1{i} = detrend(data_temp1,3);
        dataDet2{i} = detrend(data_temp2,3);
        
        % average
        %lfpMean1(i) = nanmean(dataDet1);
        %lfpMean2(i) = nanmean(dataDet2);
        
        % standard deviation
        %lfpStd1(i) = std(dataDet1);
        %lfpStd2(i) = std(dataDet2);
        
    end

end

% concatenate moving window data, get mean and std
dataMat1 = horzcat(dataDet1{:});
dataMat2 = horzcat(dataDet2{:});
baselineMean(1) = nanmean(dataMat1);
baselineMean(2) = nanmean(dataMat2);
baselineSTD(1)  = nanstd(dataMat1);
baselineSTD(2)  = nanstd(dataMat2);