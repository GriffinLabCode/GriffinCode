%% Netcom connection

% addpath to the netcom functions
addpath('C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21\NetComDevelopmentPackage_v3.1.0\MATLAB_M-files')

% define the computers IP address
serverName = '192.168.3.100'; % open cmd, type "ipconfig" look for IPv4

% connected via netcom to cheetah
disp('Connecting with NetCom. This may take a few minutes...')
if NlxAreWeConnected() ~= 1
    succeeded = NlxConnectToServer(serverName);
    if succeeded ~= 1
        error('FAILED to connect');
        return
    else
        display('Connected to NetCom Server - Ready to run session.');
    end
end

% start acquisition
prompt  = 'If you are ready to begin acquisition, type "Begin" ';
acquire = input(prompt,'s');

if acquire == 'Begin'
    % end acquisition if its already occuring as a safety precaution
    [succeeded, cheetahReply] = NlxSendCommand('-StopAcquisition');    
    [succeeded, cheetahReply] = NlxSendCommand('-StartAcquisition');
else
    disp('Please manually start data acquisition')
end

% open a stream to interface with events
[succeeded, cheetahObjects, cheetahTypes] = NlxGetDASObjectsAndTypes; % gets cheetah objects and types

% open a stream to interface with objects - note that this will fail
% without somewhat continuous updating. Note that you need to open stream
% with the CSCs you want to extract.
succeeded = NlxOpenStream(cheetahObjects(1));
if succeeded == 1
    disp('Successfully opened a stream with Events')
end
succeeded = NlxOpenStream(cheetahObjects(2));
if succeeded == 1
    disp('Successfully opened a stream with Events')
end

% -- get live CSC data -- %
% note, if these are run together, then the timestamps are identical.

% open stream for CSC data - why does numValidSamplesArray fluctuate?
[succeeded1, dataArray1, timeStampArray1, channelNumberArray1, samplingFreqArray1, ...
    numValidSamplesArray1, numRecordsReturned1, numRecordsDropped1 ] = NlxGetNewCSCData(char(cheetahObjects(1)));  

% get csc2
[succeeded2, dataArray2, timeStampArray2, channelNumberArray2, samplingFreqArray2, ...
    numValidSamplesArray2, numRecordsReturned2, numRecordsDropped2 ] = NlxGetNewCSCData(char(cheetahObjects(2)));  







