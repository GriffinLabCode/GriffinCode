%NLXGETSERVERPCNAME   Gets the name of the PC that this client is
%					  connected to.
%
%   SERVERNAME = NLXNLXGETSERVERPCNAME() 
%
%   Example:  serverName = NlxGetServerPCName();
%
%

function serverName = NlxGetServerPCName()  

	serverName = 0;
	
	if libisloaded('MatlabNetComClient')

		serverName = calllib('MatlabNetComClient', 'GetServerPCName');
	else
		disp 'Not Connected - call NlxConnectToServer before calling this function.'		
	end
	
end