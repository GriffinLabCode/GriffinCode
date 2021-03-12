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
    
function [ModIdx] = modindex_movingWindow(phaseLFP,ampLFP,times,shuffle,params)

% define srate
srate = params.Fs;

% first for stem lfp
winStep   = params.movingwin(2); % 250ms
winSizeTime = params.movingwin(1); % in sec
winLength = floor((length(phaseLFP)/(srate*winSizeTime))/(winStep));
   
for i = 1:winLength
    % get how many samples to move
    numSamples2Move = srate*winStep;
    if i == 1      
        % define a starter variable that will be saved for each loop and
        % modified each time
        starter(i) = 1;
        ender(i)   = floor(srate*winSizeTime);

        % get data        
        data_temp1 = []; data_temp2 = []; times_temp = [];
        data_temp1 = phaseLFP(starter(i):ender(i));
        data_temp2 = ampLFP(starter(i):ender(i));
        times_temp = times(starter(i):ender(i));
        
		% -- enter your code here and save per each loop -- %
        
        % prep for PAC
        signal_data                    = [];
        signal_data.phase_EEG          = data_temp1;
        signal_data.amplitude_EEG      = data_temp2;            
        signal_data.phase_bandpass     = [4 12];  % theta phase 
        signal_data.amplitude_bandpass = [30 80]; % gamma amp
        signal_data.srate              = params.Fs;
        signal_data.timestamps         = times_temp;
        signal_data.phase_extraction   = 1; % set to 1 to use phase interpolation for theta                   

        % make datafile
        datafile = [];
        datafile = makedatafile(signal_data);
        
        % compute MI
        M = [];
        M = modindex(datafile,shuffle,'n');   
        
        % cache
        ModIdx(i) = M.MI;

    else
        starter(i) = floor(starter(i-1)+(numSamples2Move));
        ender(i)   = starter(i)+floor(srate*winSizeTime);

        % in the case where you've run out of data, break out of the loop
        if ender(i) > length(phaseLFP)
            starter(i) = [];
            ender(i)   = [];
            break
        end
        
        % get data        
        data_temp1 = []; data_temp2 = []; times_temp = [];
        data_temp1 = phaseLFP(starter(i):ender(i));
        data_temp2 = ampLFP(starter(i):ender(i));
        times_temp = times(starter(i):ender(i));
        
		% -- enter your code here and save per each loop -- %
        
        % prep for PAC
        signal_data                    = [];
        signal_data.phase_EEG          = data_temp1;
        signal_data.amplitude_EEG      = data_temp2;            
        signal_data.phase_bandpass     = [4 12];  % theta phase 
        signal_data.amplitude_bandpass = [30 80]; % gamma amp
        signal_data.srate              = params.Fs;
        signal_data.timestamps         = times_temp;
        signal_data.phase_extraction   = 1; % set to 1 to use phase interpolation for theta                   

        % make datafile
        datafile = [];
        datafile = makedatafile(signal_data);
        
        % compute MI
        M = [];
        M = modindex(datafile,shuffle,'n');   
        
        % cache
        ModIdx(i) = M.MI;
        
    end

end



