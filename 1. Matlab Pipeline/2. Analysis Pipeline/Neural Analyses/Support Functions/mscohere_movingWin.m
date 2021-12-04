%% get theta coherence in moving window
% this code performs a moving window method nearly identical to chronux
% methods. It was tested using coherencyc, and compared against
% cohgramc
%
% -- INPUTS -- %
% data1: lfp data
% data2: lfp data
% params: parameters for your stuff
%
% -- OUTPUTS -- %
% you define them
%
% written by John Stout
%
% get data
%data1 = cleaned_lfp_hpc_stem2gz{triali};
%data2 = cleaned_lfp_pfc_stem2gz{triali};
    
function [coh] = mscohere_movingWin(data1,data2)
clear starter ender coh

% first for stem lfp
movingwin = [1.25 .25];
srate = 2000;
f = [1:.5:20];
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
        dataDet1 = []; dataDet2 = [];
        dataDet1 = detrend(data_temp1,3);
        dataDet2 = detrend(data_temp2,3);
        
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
        dataDet1 = []; dataDet2 = [];
        dataDet1 = detrend(data_temp1,3);
        dataDet2 = detrend(data_temp2,3);
        
        % coherence
        coh{i} = mscohere(dataDet1,dataDet2,[],[],f,srate);            
    end

end