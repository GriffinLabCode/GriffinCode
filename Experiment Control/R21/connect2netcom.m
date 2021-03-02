%% Netcom connection
% INPUTS:
% pathName: the name of the directory path that houses the netcom functions
%              pathName = 'C:\Users\jstout\Documents\GitHub\NeuroCode\MATLAB Code\R21\NetComDevelopmentPackage_v3.1.0\MATLAB_M-files'
% serverName: The IP address of the server you are working with. To get
%              this, open cmd, type "ipconfig" and look for IPv4. If you
%              are connected to the internet, do NOT use that IP address.
%              Ex. serverName = '192.168.3.100';
%
% written by John Stout

function [] = connect2netcom(pathName,serverName)

% addpath to the netcom functions
addpath(pathName)

% connected via netcom to cheetah
disp('Connecting with NetCom. This may take a few minutes...')
if NlxAreWeConnected() ~= 1
    succeeded = NlxConnectToServer(serverName);
    if succeeded ~= 1
        error('FAILED to connect');
        return
    else
        disp('Connected to NetCom Server - Ready to run session.');
    end
else
    disp('Connected to NetCom Server.');    
end

% test acquisition control
succeeded1 = NlxSendCommand('-StopAcquisition');    
succeeded2 = NlxSendCommand('-StartAcquisition'); 

if succeeded1 == 1 && succeeded2 == 1
    disp('Netcom succesfully controlling cheetah.')
else
    disp('Matlab was unsuccessful in controlling cheetah acquisition. Troubleshoot this error.')
    return
end


end





