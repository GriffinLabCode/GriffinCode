%% get theta coherence in moving window
% get data
%data1 = cleaned_lfp_hpc_stem2gz{triali};
%data2 = cleaned_lfp_pfc_stem2gz{triali};
    
function [coh_theta] = coherencyc_theta_movWinCustom(data1,data2,params)

% first for stem lfp
winStep   = params.movingwin(2); % 250ms
winSizeTime = params.movingwin(1); % in sec
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
        
        % coherence
        C = coherencyc(data_temp1,data_temp2,params);
        
        % average across frequencies
        coh_theta(i) = mean(C);
        
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
           
        % coherence
        C = coherencyc(data_temp1,data_temp2,params);

        % average across frequencies
        coh_theta(i) = mean(C);
        
    end

end


