%NLXAREWECONNECTED   Gets the current connection state of this client
%
%   CONNECTED = NLXAREWECONNECTED() 
%
%   Example:  connected = NlxAreWeConnected();
%
%	Returns:	1 client is currently connected
%				0 client is not connected
%

function connected = NlxAreWeConnected()  

	if libisloaded('MatlabNetComClient')

		connected = calllib('MatlabNetComClient', 'AreWeConnected');
	else
		connected = 0;
	end
	
end