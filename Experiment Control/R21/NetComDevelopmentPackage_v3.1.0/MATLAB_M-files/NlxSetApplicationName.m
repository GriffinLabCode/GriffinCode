%NLXSETAPPLICATIONNAME   Sets the name that identifies this program to the
%	   					 NetCom server
%   Takes a string containing the name you wish to use to identify
%	this application to the NetCom server.
%
%   NLXSETAPPLICATIONNAME(APPLICATIONNAME) sets the application name
%
%   Example:  NlxSetApplicationName('Matlab Script');
%	Sets the identification for this application to 'Matlab Script'
%
%	Returns: 1 means a successful connection was made.
%			 0 means the connection failed
%
%

function succeeded = NlxSetApplicationName(applicationName)  

	succeeded = libisloaded('MatlabNetComClient');
	
	if succeeded == 1
		succeeded = calllib('MatlabNetComClient', 'SetApplicationName', applicationName);
	else
		disp 'Not Connected - call NlxConnectToServer before calling this function.'
    end;
	
end