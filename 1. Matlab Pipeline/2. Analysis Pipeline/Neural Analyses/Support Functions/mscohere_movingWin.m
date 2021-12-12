%% Coherence in moving window
% this code computes coherence over a moving window. This code uses
% mscohere, and detrends the data by removing 3rd degree polynomials using
% the moving window as the segment to detrend over.
%
% -- INPUTS -- %
% data1: LFP data to sample over. Vector format
% data2: LFP data to sample over
% movingwin: moving window parameters. For example:
%               -> movingwin = [1.25 .25]; 
%               -> 1.25 sec window, moving with .25sec steps
% srate: sampling rate (e.g. 2000)
% f: frequencies to compute coherence over. For example:
%               -> f = [1:.5:20]; computes coherence bw 1 hz to 20hz over a
%               range of 0.5 increments
% 
% --- OUTPUTS --- %
% coh: Coherence outputs per frequency
% dataDet1: data used in moving window format
% dataDet2: detrended data in moving window format
%
% written by John Stout
    
function [coh,f,dataDet1,dataDet2] = mscohere_movingWin(data1,data2,movingwin,srate,f)
clear starter ender coh

% first for stem lfp
%movingwin = [1.25 .25];
%srate = 2000;
%f = [1:.5:20];
winStep   = movingwin(2); % 250ms
winSizeTime = movingwin(1); % in sec
winLength = round((length(data1)/(srate*winSizeTime))/(winStep),1);
   
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
        
        % coherence
        coh{i} = mscohere(dataDet1,dataDet2,[],[],f,srate);        
        
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
        
        % coherence
        coh{i} = mscohere(dataDet1{i},dataDet2{i},[],[],f,srate);            
    end

end