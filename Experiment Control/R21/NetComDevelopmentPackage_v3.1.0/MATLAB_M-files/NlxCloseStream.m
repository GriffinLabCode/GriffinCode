%NLXCLOSESTREAM   Closes a data stream to a specified DAS object
%
%   Function takes a string containing the name of the object whos
%	data stream you wish to close,.
%
%	NLXCLOSETREAM(OBJECTNAME,)
%
%	Once a data stream is closed, the DAS will no longer stream data
%	for the specified object.  All calls to the GETNEW<type>DATA 
%	functions will fail. Objects of type 'AcqSource' cannot stream
%   data, so closing a stream for those objects will fail.
%
%   Example:  NlxCloseStream('SE1');
%	Closes a data stream for the single electrode named SE1.
%
%	Returns: 1 means the stream was successfully opened.
%			 0 means the stream was not opened.
%
%

function succeeded = NlxCloseStream(objectName)  

	succeeded = libisloaded('MatlabNetComClient');
	
	if succeeded == 1
		succeeded = calllib('MatlabNetComClient', 'CloseStream', char(objectName));
	else
		disp 'Not Connected - call NlxConnectToServer before calling this function.'
    end;
	
end