%NLXGETCLIENTVERSIONSTRING   Gets the NetCom Client version being used.
%
%   VERSIONSTRING = NLXGETCLIENTVERSIONSTRING() 
%
%   Example:  versionString = NlxGetClientVersionString();
%
%

function versionString = NlxGetClientVersionString()  

	versionString = 0;
	
	if libisloaded('MatlabNetComClient')

		versionString = calllib('MatlabNetComClient', 'GetClientVersionString');
	else
		disp 'Not Connected - call NlxConnectToServer before calling this function.'		
	end
	
end