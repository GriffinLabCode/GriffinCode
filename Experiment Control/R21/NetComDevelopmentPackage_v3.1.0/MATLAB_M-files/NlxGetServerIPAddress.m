%NLXGETSERVERIPADDRESS   Gets the ip of the PC that this client is
%						 connected to.
%
%   SERVERIPADDRESS = NLXGETSERVERIPADDRESS() 
%
%   Example:  serverIPAddress = NlxGetServerIPAddress();
%
%

function serverIPAddress = NlxGetServerIPAddress()  

	serverIPAddress = 0;
	if libisloaded('MatlabNetComClient')

		serverIPAddress = calllib('MatlabNetComClient', 'GetServerIPAddress');
	else
		disp 'Not Connected - call NlxConnectToServer before calling this function.'
	end
	
end