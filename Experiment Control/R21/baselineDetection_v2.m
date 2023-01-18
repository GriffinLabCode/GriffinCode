%% baseline detection
% this code is designed for a baseline recording, where the data will be
% applied to coherence_detection to identify outlier signals. We will only
% allow coherence to be triggered if the signal in the 0.5 second window is
% within 1 standard deviation range
%
% -- INPUTS -- %
% LFP1name
% LFP2name
% srate: sampling rate
% numMin: duration in minutes for baseline detection
%
%
% John Stout

function [baselineMean,baselineSTD] = baselineDetection(LFP1name,LFP2name,srate,numMin)

% clear stream   
clearStream(LFP1name,LFP2name);

% after 10 minutes, pull data
%numMin = 10;
for i = 1:10
    if i == 1
        disp('Beginning pause')
    end
    pauseTime = 1*60;
    pause(pauseTime)
    disp([num2str([numMin-i]), ' minutes remaining'])
end

% pull data
attempt = 0;
while attempt == 0
    try

        % clear stream   
        clearStream(LFP1name,LFP2name);

        % pause 0.5 sec
        pause(0.5);

        % pull data
        [~, dataArray, timeStampArray, ~, ~, ...
        numValidSamplesArray, numRecordsReturned, numRecordsDropped , funDur.getData ] = NlxGetNewCSCData_2signals(LFP1name, LFP2name);  

        attempt = 1;
    catch
    end
end

<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
% notch filter
filtLFP = [];
filtLFP(1,:) = notchfilt(dataArray(1,:),srate);
filtLFP(2,:) = notchfilt(dataArray(2,:),srate);

% detrend
data_det = [];
data_det(1,:) = detrend(filtLFP(1,:)); 
data_det(2,:) = detrend(filtLFP(2,:)); 

% arrive at baselines for both signals
baselineMean = []; baselineSTD = [];
baselineMean(:,1) = mean(data_det(1,:));
baselineSTD(:,1)  = std(data_det(1,:));
baselineMean(:,2) = mean(data_det(2,:));
baselineSTD(:,2)  = std(data_det(2,:));
=======
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

% detrend data - did not clean to improve processing speed
%data_det = [];
%data_det(1,:) = locdetrend(dataArray(1,:),srate); 
%data_det(2,:) = locdetrend(dataArray(2,:),srate); 

% arrive at baselines for both signals
baselineMean = []; baselineSTD = [];
baselineMean(:,1) = mean(dataArray(1,:));
baselineSTD(:,1)  = std(dataArray(1,:));
baselineMean(:,2) = mean(dataArray(2,:));
baselineSTD(:,2)  = std(dataArray(2,:));
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

end


