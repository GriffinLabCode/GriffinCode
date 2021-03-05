%NLXGETSERVERAPPLICATIONNAME   Gets the name of the application that this client is
%							   connected to.
%
%   SERVERAPPLICATIONNAME = NLXGETSERVERAPPLICATIONNAME() 
%
%   Example:  serverApplicationName = NlxGetServerApplicationName();
%
%

function serverApplicationName = NlxGetServerApplicationName()  

	serverApplicationName = 0;
	if libisloaded('MatlabNetComClient')

		serverApplicationName = calllib('MatlabNetComClient', 'GetServerApplicationName');
	else
		disp 'Not Connected - call NlxConnectToServer before calling this function.'
	end
	
end