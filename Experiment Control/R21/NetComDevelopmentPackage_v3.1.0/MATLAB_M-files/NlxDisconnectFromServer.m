%NLXDISCONNECTFROMSERVER   Disconnects from the current NetCom server
%						if currently connected.
%   Disconnects from the current NetCom server. Any streams not
%   closed using NlxCloseStream before disconnection will be
%   automatically reopened upon reconnection without
%
%   NLXDISCONNECTFROMSERVER() disconnects from the server
%
%   Example:  NlxDisconnectFromServer;
%
%	Returns: 1 means a successful disconnection.
%			 0 means the disconnection failed
%

function succeeded = NlxDisconnectFromServer()  
	
	succeeded = libisloaded('MatlabNetComClient');
	
	if succeeded == 1
		succeeded = calllib('MatlabNetComClient', 'DisconnectFromServer');
	else
		disp 'Not Connected - call NlxConnectToServer before calling this function.'
		return;
    end;
	
	if succeeded == 1
		unloadlibrary('MatlabNetComClient');
	end;
	
	if libisloaded('MatlabNetComClient')
		succeeded = 0;
	end
end